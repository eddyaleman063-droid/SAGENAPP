const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

const PROBABILITIES = {
  'bronze->silver': 0.45,
  'silver->gold': 0.20,
  'gold->legendary': 0.03,
};

const RATE_LIMIT_WINDOW = 60 * 1000;
const RATE_LIMIT_MAX = 10;

async function checkRateLimit(uid) {
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW;
  const bucketRef = admin.firestore().doc(`rate_limits/${uid}`);

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(bucketRef);
      const data = doc.data() || {};
      const timestamps = (data.gacha_timestamps || []).filter(t => t > windowStart);
      if (timestamps.length >= RATE_LIMIT_MAX) {
        throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes. Intenta de nuevo.');
      }
      timestamps.push(now);
      transaction.set(bucketRef, { gacha_timestamps: timestamps }, { merge: true });
    });
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    functions.logger.error('Rate limit check failed, rejecting', { uid, error: e.message });
    throw new functions.https.HttpsError('resource-exhausted', 'Servicio temporalmente no disponible. Intenta de nuevo.');
  }
}

/**
 * Server-side chest evolution gacha roll.
 * Accepts: { currentTier: 'bronze'|'silver'|'gold' }
 * Returns: { newTier, evolved }
 *
 * The user's actual tier is tracked server-side (users/{uid}.gacha_tier) and
 * the client-provided tier must match it, so a client cannot jump tiers by
 * lying about currentTier. The roll is idempotent per tier per day: an
 * unlucky user can retry the next day instead of being locked forever.
 */
exports.rollChestEvolution = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  await checkRateLimit(context.auth.uid);

  const { currentTier } = data;
  if (!['bronze', 'silver', 'gold', 'legendary'].includes(currentTier)) {
    throw new functions.https.HttpsError('invalid-argument', 'Tier inválido');
  }

  if (currentTier === 'legendary') {
    return { newTier: 'legendary', evolved: false };
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const date = new Date().toISOString().split('T')[0];
  const logRef = admin.firestore().doc(`transaction_logs/${userId}_evolution_${currentTier}_${date}`);

  const nextTier = { bronze: 'silver', silver: 'gold', gold: 'legendary' }[currentTier];
  const probability = PROBABILITIES[`${currentTier}->${nextTier}`] || 0;

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const serverTier = userData.gacha_tier || 'bronze';
      if (serverTier !== currentTier) {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'El tier no coincide con el del servidor',
        );
      }

      const logDoc = await transaction.get(logRef);
      if (logDoc.exists) {
        const prev = logDoc.data();
        return {
          newTier: prev.toTier || currentTier,
          evolved: prev.evolved || false,
          duplicate: true,
        };
      }

      const roll = crypto.randomInt(1, 101) / 100;
      const evolved = roll <= probability;
      const newTier = evolved ? nextTier : currentTier;

      transaction.set(logRef, {
        userId,
        fromTier: currentTier,
        toTier: newTier,
        roll,
        probability,
        evolved,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      if (evolved) {
        transaction.update(userRef, { gacha_tier: newTier });
      }

      return { newTier, evolved, duplicate: false };
    });

    if (result.evolved && !result.duplicate) {
      await admin.firestore().collection('gacha_logs').add({
        userId,
        fromTier: currentTier,
        toTier: result.newTier,
        probability,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('rollChestEvolution error', error);
    throw new functions.https.HttpsError('internal', 'Error al intentar la evolución');
  }
});
