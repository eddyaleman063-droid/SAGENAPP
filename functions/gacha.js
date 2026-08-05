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
 */
exports.rollChestEvolution = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  await checkRateLimit(context.auth.uid);

  const { currentTier } = data;
  if (!['bronze', 'silver', 'gold'].includes(currentTier)) {
    throw new functions.https.HttpsError('invalid-argument', 'Tier inválido');
  }

  if (currentTier === 'legendary') {
    return { newTier: 'legendary', evolved: false };
  }

  const userId = context.auth.uid;
  const logRef = admin.firestore().doc(`transaction_logs/${userId}_evolution_${currentTier}`);

  const nextTier = { bronze: 'silver', silver: 'gold', gold: 'legendary' }[currentTier];
  const probability = PROBABILITIES[`${currentTier}->${nextTier}`] || 0;

  const roll = crypto.randomInt(1, 101) / 100;
  const evolved = roll <= probability;

  const newTier = evolved ? nextTier : currentTier;

  // Atomic idempotency: create() fails with ALREADY_EXISTS if doc exists (race-condition safe)
  try {
    await logRef.create({
      userId,
      fromTier: currentTier,
      toTier: newTier,
      roll,
      probability,
      evolved,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (e) {
    if (e.code === 6) { // ALREADY_EXISTS
      const prev = (await logRef.get()).data();
      return { newTier: prev.toTier || currentTier, evolved: prev.evolved || false, duplicate: true };
    }
    throw e;
  }

  if (evolved) {
    await admin.firestore().collection('gacha_logs').add({
      userId,
      fromTier: currentTier,
      toTier: newTier,
      roll,
      probability,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  return { newTier, evolved };
});
