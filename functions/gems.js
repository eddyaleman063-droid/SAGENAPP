const functions = require('firebase-functions');
const admin = require('firebase-admin');

// ══════════════════════════════════════════════════════════════════
// GEM ECONOMY — Server-authoritative
// Gems are now a server-side economy: the authoritative balance lives
// on users/{uid}/learning_gems (blocked from direct client writes by
// Firestore rules). The client SharedPreferences value is only a cache.
// Daily per-source caps (anti-farm) mirror Remote Config defaults.
// ══════════════════════════════════════════════════════════════════

// Server-authoritative gem rewards per reason.
// The client can NOT specify the amount — the server decides it.
const GEM_REWARDS = {
  lesson_correct: 5,        // per correct answer
  perfect_bonus: 20,        // flat bonus for a perfect lesson
  first_lesson_of_day: 10,  // flat, once per day
  daily_chest: 5,
  chest_drop_per_xp: 3,     // gems = floor(xp / 3)
  chest_drop_min: 2,
  chest_drop_max: 75,
  achievement_per_xp: 4,    // gems = floor(xp / 4)
  achievement_min: 2,
  achievement_max: 30,
  mission: 12,
  review: 6,
  mini_game: 5,
  challenge: 10,
  ad_reward: 2,
  gacha: 10,
  sagen_pass_bonus: 300,    // bonus gems granted with a SAGEN PASS purchase
  streak_milestones: { 7: 15, 14: 30, 30: 60, 60: 100, 100: 150, 180: 250, 365: 500 },
};
const DEFAULT_GEM_REWARD = 5;

// Daily gem caps per source (anti-farm). Mirrors Remote Config
// daily_gem_cap_* defaults in lib/services/remote_config_service.dart.
const GEM_DAILY_CAPS = {
  lesson: 50,
  daily_chest: 20,
  chest_drop: 200,
  ad_reward: 30,
  achievement: 200,
  mission: 50,
  streak_milestone: 200,
  review: 50,
  mini_game: 30,
  challenge: 30,
  gacha: 200,
  sagen_pass: 300,
};
const DEFAULT_DAILY_GEM_CAP = 50;

// Absolute balance cap (anti-inflation).
const MAX_GEM_BALANCE = 100000;

// Reasons that can ONLY be earned via earnGems() (the rest are credited
// atomically inside completeLesson / rollChestDrop / claimDailyChest /
// claimAdReward so there is a single authoritative path per source).
const EARN_GEMS_REASONS = ['achievement', 'mission', 'review', 'streak_milestone', 'mini_game', 'challenge', 'gacha'];

exports.GEM_REWARDS = GEM_REWARDS;
exports.GEM_DAILY_CAPS = GEM_DAILY_CAPS;
exports.DEFAULT_DAILY_GEM_CAP = DEFAULT_DAILY_GEM_CAP;
exports.MAX_GEM_BALANCE = MAX_GEM_BALANCE;

function getDailyGemsDocRef(userId) {
  const today = new Date().toISOString().split('T')[0];
  return admin.firestore().doc(`daily_gem_sources/${userId}_${today}`);
}

exports.getDailyGemsDocRef = getDailyGemsDocRef;

function getDailyGemCap(reason) {
  return GEM_DAILY_CAPS[reason] || DEFAULT_DAILY_GEM_CAP;
}

exports.getDailyGemCap = getDailyGemCap;

function computeCappedGems(currentDailyTotal, requestedGems, reason) {
  const remaining = Math.max(0, getDailyGemCap(reason) - currentDailyTotal);
  const cappedGems = Math.min(requestedGems, remaining);
  return { cappedGems, remaining };
}

exports.computeCappedGems = computeCappedGems;

/**
 * Credits gems atomically inside an existing transaction.
 * Callers MUST already have read userDoc, dailyGemsDoc inside the txn.
 * Returns the authoritative result for the caller to return to the client.
 */
function applyGemCredit(transaction, userRef, userData, dailyGemsRef, dailyGemsData, reason, requestedGems) {
  const gemsEarnedToday = (dailyGemsData && dailyGemsData.total) || 0;
  const { cappedGems } = computeCappedGems(gemsEarnedToday, requestedGems, reason);

  if (cappedGems > 0) {
    const currentBalance = userData.learning_gems || 0;
    const newBalance = Math.min(MAX_GEM_BALANCE, currentBalance + cappedGems);
    const actualAdded = newBalance - currentBalance;

    transaction.update(userRef, {
      learning_gems: newBalance,
      _ts_learning_gems: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(dailyGemsRef, {
      total: admin.firestore.FieldValue.increment(actualAdded),
      [reason]: admin.firestore.FieldValue.increment(actualAdded),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return {
      gemsAdded: actualAdded,
      dailyCapped: actualAdded < requestedGems,
      balance: newBalance,
      dailyTotal: gemsEarnedToday + actualAdded,
    };
  }

  return {
    gemsAdded: 0,
    dailyCapped: requestedGems > 0,
    balance: userData.learning_gems || 0,
    dailyTotal: gemsEarnedToday,
  };
}

exports.applyGemCredit = applyGemCredit;

function gemAmountForReason(reason, meta) {
  const m = meta || {};
  switch (reason) {
    case 'achievement':
      return Math.max(
        GEM_REWARDS.achievement_min,
        Math.min(GEM_REWARDS.achievement_max, Math.floor((m.xp || 0) / GEM_REWARDS.achievement_per_xp)),
      );
    case 'streak_milestone': {
      const table = GEM_REWARDS.streak_milestones;
      const days = m.streakDays || 0;
      const keys = Object.keys(table).map(Number).sort((a, b) => a - b);
      let reward = 0;
      for (const k of keys) {
        if (days >= k) reward = table[k];
      }
      return reward;
    }
    case 'mission':
      return GEM_REWARDS.mission;
    case 'review':
      return GEM_REWARDS.review;
    case 'mini_game':
      return GEM_REWARDS.mini_game;
    case 'challenge':
      return GEM_REWARDS.challenge;
    case 'gacha':
      return GEM_REWARDS.gacha;
    default:
      return DEFAULT_GEM_REWARD;
  }
}

exports.gemAmountForReason = gemAmountForReason;

/**
 * HTTPS Callable: Earn gems from a server-authoritative reason.
 * The server decides the amount. Daily per-reason caps apply.
 * 'lesson', 'daily_chest', 'chest_drop' and 'ad_reward' are NOT allowed
 * here — they are credited inside their own functions to keep a single
 * authoritative path per source.
 */
exports.earnGems = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkGemsRateLimit(userId);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  const reason = data && typeof data.reason === 'string' ? data.reason : 'unknown';
  if (!EARN_GEMS_REASONS.includes(reason)) {
    throw new functions.https.HttpsError('invalid-argument', 'Reason no permitido para earnGems');
  }

  const requestedGems = gemAmountForReason(reason, data && data.meta);
  if (requestedGems <= 0) {
    return { success: false, gemsAdded: 0, reason };
  }

  const userRef = admin.firestore().doc(`users/${userId}`);
  const dailyGemsRef = getDailyGemsDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyGemsDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyGemsRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const dailyGemsData = dailyGemsDoc.data() || {};
      const credit = applyGemCredit(
        transaction, userRef, userData,
        dailyGemsRef, dailyGemsData,
        reason, requestedGems,
      );

      return { success: true, reason, ...credit };
    });

    functions.logger.info('Gems earned', { userId, reason, gems: result.gemsAdded, balance: result.balance });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('earnGems error', error);
    throw new functions.https.HttpsError('internal', 'Error al agregar gemas');
  }
});

/**
 * HTTPS Callable: Spend gems on a shop item.
 * Server-authoritative spend: validates balance, decrements it, and
 * records an idempotent log (no double-spend possible).
 */
exports.spendGems = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkGemsRateLimit(userId);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  const { itemId, idempotencyKey } = data;
  const amount = parseInt(data && data.amount, 10);
  if (!itemId || typeof itemId !== 'string' || !idempotencyKey || typeof idempotencyKey !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'itemId e idempotencyKey requeridos');
  }
  if (isNaN(amount) || amount <= 0 || amount > 100000) {
    throw new functions.https.HttpsError('invalid-argument', 'El monto debe estar entre 1 y 100000');
  }

  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
      ]);

      if (logDoc.exists) {
        return { success: true, duplicate: true, balance: userDoc.data()?.learning_gems || 0 };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const balance = userData.learning_gems || 0;
      if (balance < amount) {
        throw new functions.https.HttpsError('failed-precondition', 'Saldo insuficiente de gemas');
      }

      transaction.update(userRef, {
        learning_gems: balance - amount,
        _ts_learning_gems: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.create(logRef, {
        userId,
        type: 'gemSpend',
        itemId,
        amount,
        balanceAfter: balance - amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, balance: balance - amount, spent: amount, itemId };
    });

    functions.logger.info('Gems spent', { userId, itemId, amount, duplicate: result.duplicate });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('spendGems error', error);
    throw new functions.https.HttpsError('internal', 'Error al gastar gemas');
  }
});

/**
 * HTTPS Callable: Get the authoritative gem balance and daily caps.
 */
exports.getGemsBalance = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const dailyGemsRef = getDailyGemsDocRef(userId);

  try {
    const [userDoc, dailyGemsDoc] = await Promise.all([
      userRef.get(),
      dailyGemsRef.get(),
    ]);

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }

    const userData = userDoc.data() || {};
    const dailyGemsData = dailyGemsDoc.data() || {};

    return {
      balance: userData.learning_gems || 0,
      dailyTotal: dailyGemsData.total || 0,
      dailyCaps: GEM_DAILY_CAPS,
      maxBalance: MAX_GEM_BALANCE,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('getGemsBalance error', error);
    throw new functions.https.HttpsError('internal', 'Error al obtener saldo de gemas');
  }
});

async function checkGemsRateLimit(uid) {
  const now = Date.now();
  const windowStart = now - 60 * 1000;
  const bucketRef = admin.firestore().doc(`rate_limits/${uid}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(bucketRef);
      const data = doc.data() || {};
      const timestamps = (data.timestamps || []).filter(t => t > windowStart);

      if (timestamps.length >= 20) {
        return { allowed: false };
      }

      timestamps.push(now);
      transaction.set(bucketRef, { timestamps }, { merge: true });
      return { allowed: true };
    });
    return result;
  } catch (e) {
    functions.logger.error('Gems rate limit check failed, rejecting request', { uid, error: e.message });
    return { allowed: false };
  }
}
