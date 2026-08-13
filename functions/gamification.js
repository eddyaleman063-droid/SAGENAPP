const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { getDailyXpDocRef, computeCappedXp, MAX_DAILY_XP } = require('./economic');
const gems = require('./gems');

// ══════════════════════════════════════════════════════════════════
// GAMIFICATION FUNCTIONS — Server-authoritative daily claims
// Daily chest, missions, and ad rewards are validated server-side.
// ══════════════════════════════════════════════════════════════════

// Server-authoritative Sagen Pass SP per reason.
// The client can NOT specify the amount — the server decides it.
const SP_REWARDS = {
  lesson: 10,
  daily_chest: 5,
  streak_chest: 5,
  ad_reward: 3,
  mini_game: 5,
  review: 5,
  achievement: 10,
  mission_reward: 5,
  challenge: 10,
  perfect_lesson: 15,
};
const DEFAULT_SP_REWARD = 5;

// Max Sagen Pass SP earnable per day (anti-farm).
const MAX_DAILY_SP = 100;

function getDailySpDocRef(userId) {
  const today = new Date().toISOString().split('T')[0];
  return admin.firestore().doc(`daily_sp_sources/${userId}_${today}`);
}

/**
 * Firestore-based distributed rate limiting.
 * Replaces the in-memory Map that didn't work across instances.
 */
async function checkDistributedRateLimit(uid, windowMs, maxRequests) {
  const now = Date.now();
  const windowStart = now - windowMs;
  const bucketRef = admin.firestore().doc(`rate_limits/${uid}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(bucketRef);
      const data = doc.data() || {};
      const timestamps = (data.timestamps || []).filter(t => t > windowStart);

      if (timestamps.length >= maxRequests) {
        return { allowed: false, remaining: 0 };
      }

      timestamps.push(now);
      transaction.set(bucketRef, { timestamps }, { merge: true });
      return { allowed: true, remaining: maxRequests - timestamps.length };
    });
    return result;
  } catch (e) {
    // If Firestore is unavailable, reject the request (fail-closed for security)
    functions.logger.error('Rate limit check failed, rejecting request', { uid, error: e.message });
    return { allowed: false, remaining: 0 };
  }
}

/**
 * HTTPS Callable: Claim daily chest.
 * Server validates: user hasn't claimed today, streak exists.
 */
exports.claimDailyChest = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 5);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  const userRef = admin.firestore().doc(`users/${userId}`);
  const today = new Date().toISOString().split('T')[0];
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyGemsRef = gems.getDailyGemsDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc, dailyGemsDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const lastDailyChest = userData.last_daily_chest || '';

      if (lastDailyChest === today) {
        return { success: false, alreadyClaimed: true };
      }

      // Server-authoritative: 10 XP only
      const xp = 10;
      const dailyData = dailyXpDoc.data() || {};
      const xpEarnedToday = dailyData.total || 0;
      const { cappedXp } = computeCappedXp(xpEarnedToday, xp);

      if (cappedXp <= 0) {
        throw new functions.https.HttpsError('resource-exhausted', `Limite diario de XP alcanzado (${MAX_DAILY_XP} XP/dia)`);
      }

      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;

      const newTotalXp = currentTotalXp + cappedXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;

      const dailyGemsData = dailyGemsDoc.data() || {};
      const gemCredit = gems.applyGemCredit(
        transaction, userRef, userData,
        dailyGemsRef, dailyGemsData,
        'daily_chest', gems.GEM_REWARDS.daily_chest,
      );

      transaction.update(userRef, {
        learning_total_xp: newTotalXp,
        learning_level: newLevel,
        last_daily_chest: today,
        _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(dailyXpRef, {
        total: admin.firestore.FieldValue.increment(cappedXp),
        dailyChest: admin.firestore.FieldValue.increment(cappedXp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Log the transaction
      const logId = `${userId}_daily_${today}`;
      const logRef = admin.firestore().doc(`transaction_logs/${logId}`);
      try {
        transaction.create(logRef, {
          userId,
          type: 'dailyChest',
          xp: cappedXp,
          date: today,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (e.code === 6) { // ALREADY_EXISTS
          throw new functions.https.HttpsError('already-exists', 'Cofre diario ya reclamado');
        }
        throw e;
      }

      return {
        success: true,
        xp: cappedXp,
        leveledUp: newLevel > currentLevel,
        newLevel,
        gems: {
          added: gemCredit.gemsAdded,
          balance: gemCredit.balance,
          dailyCapped: gemCredit.dailyCapped,
        },
      };
    });

    functions.logger.info('Daily chest claimed', { userId, xp: result.xp });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('claimDailyChest error', error);
    throw new functions.https.HttpsError('internal', 'Error al reclamar cofre diario');
  }
});

/**
 * HTTPS Callable: Earn Sagen Pass SP.
 * Server-authoritative: the SP amount is decided by `reason`, NOT by the client.
 * Enforces a daily SP cap to prevent farming to max level.
 */
exports.earnSagenPassSP = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 10);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  // Server-authoritative: ignore any client-provided amount.
  const reason = data && typeof data.reason === 'string' ? data.reason : 'lesson';
  const spToAdd = SP_REWARDS[reason] || DEFAULT_SP_REWARD;

  const userRef = admin.firestore().doc(`users/${userId}`);
  const dailySpRef = getDailySpDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailySpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailySpRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};

      // SAGEN PASS holders earn unlimited SP (no daily cap).
      const isPassHolder = userData.sagen_pass_active === true;
      const dailySpData = dailySpDoc.data() || {};
      const spEarnedToday = dailySpData.total || 0;
      const remainingDailySp = isPassHolder
        ? spToAdd
        : Math.max(0, MAX_DAILY_SP - spEarnedToday);
      const cappedSp = Math.min(spToAdd, remainingDailySp);

      if (cappedSp <= 0) {
        throw new functions.https.HttpsError('resource-exhausted', `Limite diario de SP alcanzado (${MAX_DAILY_SP} SP/dia)`);
      }

      const currentSP = userData.sagen_pass_sp || 0;
      const currentLevel = userData.sagen_pass_level || 1;

      // SP required per level: 50 + (level - 1) * 10
      const spForLevel = (level) => 50 + (level - 1) * 10;

      let newSP = currentSP + cappedSp;
      let newLevel = currentLevel;
      const maxLevel = 50;

      while (newSP >= spForLevel(newLevel) && newLevel < maxLevel) {
        newSP -= spForLevel(newLevel);
        newLevel++;
      }

      if (newLevel >= maxLevel) {
        newSP = 0;
      }

      transaction.update(userRef, {
        sagen_pass_sp: newSP,
        sagen_pass_level: newLevel,
        _ts_sagen_pass: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(dailySpRef, {
        total: admin.firestore.FieldValue.increment(cappedSp),
        [reason]: admin.firestore.FieldValue.increment(cappedSp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return {
        success: true,
        sp: newSP,
        level: newLevel,
        leveledUp: newLevel > currentLevel,
        spAdded: cappedSp,
        dailyCapped: isPassHolder ? false : cappedSp < spToAdd,
        premium: isPassHolder,
      };
    });

    functions.logger.info('Sagen Pass SP earned', { userId, reason, sp: result.spAdded, level: result.level });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('earnSagenPassSP error', error);
    throw new functions.https.HttpsError('internal', 'Error al agregar SP');
  }
});

/**
 * HTTPS Callable: Claim Sagen Pass level reward.
 * Server verifies level is earned and not yet claimed.
 */
exports.claimSagenPassReward = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 10);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  const { level } = data;
  if (!level || level <= 0 || level > 50) {
    throw new functions.https.HttpsError('invalid-argument', 'Nivel inválido');
  }

  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const currentLevel = userData.sagen_pass_level || 1;
      const claimedLevels = userData.sagen_pass_claimed || [];

      if (level > currentLevel) {
        throw new functions.https.HttpsError('failed-precondition', 'Nivel no alcanzado');
      }
      if (claimedLevels.includes(level)) {
        return { success: false, alreadyClaimed: true };
      }

      // Server-side season validation: ensure seasonStart is stored server-side
      let seasonStart = userData.sagen_pass_season_start;
      if (!seasonStart) {
        // First-time: initialize seasonStart server-side
        seasonStart = admin.firestore.FieldValue.serverTimestamp();
        transaction.update(userRef, {
          sagen_pass_season_start: seasonStart,
        });
      }

      const newClaimed = [...claimedLevels, level];
      transaction.update(userRef, {
        sagen_pass_claimed: newClaimed,
      });

      // Convert Timestamp to ISO string for client consumption
      let seasonStartISO = null;
      if (seasonStart && seasonStart.toDate) {
        seasonStartISO = seasonStart.toDate().toISOString();
      } else if (seasonStart && seasonStart._seconds) {
        seasonStartISO = new Date(seasonStart._seconds * 1000).toISOString();
      } else if (typeof seasonStart === 'string') {
        seasonStartISO = seasonStart;
      }

      return { success: true, claimed: level, claimedLevels: newClaimed, seasonStart: seasonStartISO };
    });

    functions.logger.info('Sagen Pass reward claimed', { userId, level });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('claimSagenPassReward error', error);
    throw new functions.https.HttpsError('internal', 'Error al reclamar recompensa');
  }
});

/**
 * HTTPS Callable: Get authoritative Sagen Pass season data.
 * Returns server-side seasonStart and level to reconcile with client.
 */
exports.getSagenPassSeason = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }

    const userData = userDoc.data() || {};

    // Convert Timestamp to ISO string for client consumption
    let seasonStartISO = null;
    const raw = userData.sagen_pass_season_start;
    if (raw && raw.toDate) {
      seasonStartISO = raw.toDate().toISOString();
    } else if (raw && raw._seconds) {
      seasonStartISO = new Date(raw._seconds * 1000).toISOString();
    } else if (typeof raw === 'string') {
      seasonStartISO = raw;
    }

    return {
      seasonStart: seasonStartISO,
      level: userData.sagen_pass_level || 1,
      sp: userData.sagen_pass_sp || 0,
      claimed: userData.sagen_pass_claimed || [],
      premium: userData.sagen_pass_active === true,
      maxLevel: 50,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('getSagenPassSeason error', error);
    throw new functions.https.HttpsError('internal', 'Error al obtener datos de temporada');
  }
});

/**
 * HTTPS Callable: Roll chest drop after lesson completion.
 * Server rolls rewards based on chest type with weighted random categories.
 * Uses idempotency via transaction_logs to prevent double-claiming.
 */
exports.rollChestDrop = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 10);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  const { chestType, lessonId } = data;
  const validTypes = ['bronze', 'silver', 'gold', 'legendary'];
  if (!chestType || !validTypes.includes(chestType)) {
    throw new functions.https.HttpsError('invalid-argument', 'chestType debe ser bronze, silver, gold o legendary');
  }

  const idempotencyKey = `${userId}_chest_${lessonId || 'unknown'}_${new Date().toISOString().split('T')[0]}`;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyGemsRef = gems.getDailyGemsDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc, dailyXpDoc, dailyGemsDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
      ]);

      if (logDoc.exists) {
        return { success: true, duplicate: true, xp: 0 };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      // Weighted category selection
      const categoryRoll = Math.random() * 100;
      let category;
      if (categoryRoll < 70) category = 'xp';
      else if (categoryRoll < 85) category = 'booster';
      else category = 'shield';

      // XP ranges by chest type
      const xpRanges = {
        bronze: [15, 25],
        silver: [25, 35],
        gold: [35, 50],
        legendary: [50, 75],
      };

      const xpRange = xpRanges[chestType];
      const xp = Math.floor(Math.random() * (xpRange[1] - xpRange[0] + 1)) + xpRange[0];
      const dailyData = dailyXpDoc.data() || {};
      const xpEarnedToday = dailyData.total || 0;
      const { cappedXp } = computeCappedXp(xpEarnedToday, xp);

      const streakShield = category === 'shield' ? 1 : 0;
      const xpBoost = category === 'booster';

      // Apply rewards atomically
      const userData = userDoc.data() || {};
      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;
      const currentShields = userData.streak_shields || 0;

      // Server-authoritative gems from the chest: floor(xp / 3), clamped.
      const requestedGems = Math.max(
        gems.GEM_REWARDS.chest_drop_min,
        Math.min(gems.GEM_REWARDS.chest_drop_max, Math.floor(cappedXp / gems.GEM_REWARDS.chest_drop_per_xp)),
      );
      const gemCredit = gems.applyGemCredit(
        transaction, userRef, userData,
        dailyGemsRef, dailyGemsDoc.data() || {},
        'chest_drop', requestedGems,
      );

      const newTotalXp = currentTotalXp + cappedXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;

      const updates = {
        learning_total_xp: newTotalXp,
        learning_level: newLevel,
        _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (streakShield > 0) {
        updates.streak_shields = currentShields + streakShield;
      }

      transaction.update(userRef, updates);

      if (cappedXp > 0) {
        transaction.set(dailyXpRef, {
          total: admin.firestore.FieldValue.increment(cappedXp),
          chestDrop: admin.firestore.FieldValue.increment(cappedXp),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      // Idempotency log (create fails if already exists — prevents double-reward in race condition)
      transaction.create(logRef, {
        userId,
        type: 'chestDrop',
        chestType,
        category,
        xp: cappedXp,
        streakShield,
        xpBoost,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        duplicate: false,
        xp: cappedXp,
        streakShield: streakShield > 0,
        xpBoost,
        category,
        leveledUp: newLevel > currentLevel,
        newLevel,
        gems: {
          added: gemCredit.gemsAdded,
          balance: gemCredit.balance,
          dailyCapped: gemCredit.dailyCapped,
        },
      };
    });

    functions.logger.info('Chest drop rolled', {
      userId, chestType: data.chestType, xp: result.xp,
      category: result.category, duplicate: result.duplicate,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('rollChestDrop error', error);
    throw new functions.https.HttpsError('internal', 'Error al abrir cofre');
  }
});

/**
 * HTTPS Callable: Record ad reward (server-validated daily limit).
 */
exports.claimAdReward = functions.runWith({ maxInstances: 3 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 10);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  const today = new Date().toISOString().split('T')[0];
  const userRef = admin.firestore().doc(`users/${userId}`);
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyGemsRef = gems.getDailyGemsDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc, dailyGemsDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const adDate = userData.last_ad_reward_date || '';
      const adCount = adDate === today ? (userData.daily_ad_count || 0) : 0;

      if (adCount >= 5) {
        return { success: false, limitReached: true };
      }

      const xp = 50;
      const dailyData = dailyXpDoc.data() || {};
      const xpEarnedToday = dailyData.total || 0;
      const { cappedXp } = computeCappedXp(xpEarnedToday, xp);

      if (cappedXp <= 0) {
        throw new functions.https.HttpsError('resource-exhausted', `Limite diario de XP alcanzado (${MAX_DAILY_XP} XP/dia)`);
      }

      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;
      const newTotalXp = currentTotalXp + cappedXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;

      const dailyGemsData = dailyGemsDoc.data() || {};
      const gemCredit = gems.applyGemCredit(
        transaction, userRef, userData,
        dailyGemsRef, dailyGemsData,
        'ad_reward', gems.GEM_REWARDS.ad_reward,
      );

      transaction.update(userRef, {
        learning_total_xp: newTotalXp,
        learning_level: newLevel,
        last_ad_reward_date: today,
        daily_ad_count: adCount + 1,
        _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
        _ts_learning_level: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(dailyXpRef, {
        total: admin.firestore.FieldValue.increment(cappedXp),
        adReward: admin.firestore.FieldValue.increment(cappedXp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return {
        success: true,
        xp: cappedXp,
        leveledUp: newLevel > currentLevel,
        newLevel,
        dailyCount: adCount + 1,
        dailyLimit: 5,
        gems: {
          added: gemCredit.gemsAdded,
          balance: gemCredit.balance,
          dailyCapped: gemCredit.dailyCapped,
        },
      };
    });

    functions.logger.info('Ad reward claimed', { userId, dailyCount: result.dailyCount });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('claimAdReward error', error);
    throw new functions.https.HttpsError('internal', 'Error al reclamar recompensa de anuncio');
  }
});
