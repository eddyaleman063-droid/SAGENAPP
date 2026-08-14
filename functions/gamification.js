const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { getDailyXpDocRef, computeCappedXp, MAX_DAILY_XP } = require('./economic');
const gems = require('./gems');
const sagenpass = require('./sagenpass');
const inventory = require('./inventory');

// ══════════════════════════════════════════════════════════════════
// GAMIFICATION FUNCTIONS — Server-authoritative daily claims
// Daily chest, missions, and ad rewards are validated server-side.
// ══════════════════════════════════════════════════════════════════

// Server-authoritative daily chest rewards per tier.
// Unknown/absent chestType falls back to bronze.
const DAILY_CHEST_REWARDS = {
  bronze: { xp: 10 },
  silver: { xp: 15 },
  gold: { xp: 20 },
  legendary: { xp: 25 },
};

/**
 * Firestore-based distributed rate limiting.
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

  // Server-authoritative: the reward is decided by the validated chestType,
  // never by the client. Unknown types fall back to bronze.
  const rawChestType = data && data.chestType || 'bronze';
  const chestType = DAILY_CHEST_REWARDS[rawChestType] ? rawChestType : 'bronze';
  const dailyReward = DAILY_CHEST_REWARDS[chestType];
  const xp = dailyReward.xp;

  const userRef = admin.firestore().doc(`users/${userId}`);
  const today = new Date().toISOString().split('T')[0];
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyGemsRef = gems.getDailyGemsDocRef(userId);
  const dailySpRef = sagenpass.getDailySpDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc, dailyGemsDoc, dailySpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
        transaction.get(dailySpRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const lastDailyChest = userData.last_daily_chest || '';

      if (lastDailyChest === today) {
        return { success: false, alreadyClaimed: true };
      }

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

      const spCredit = sagenpass.applySagenPassSp({
        transaction,
        userRef,
        userData,
        dailySpRef,
        dailySpData: dailySpDoc.data() || {},
        reason: 'daily_chest',
        spToAdd: sagenpass.SP_REWARDS.daily_chest,
      });

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
        chestType,
        xp: cappedXp,
        leveledUp: newLevel > currentLevel,
        newLevel,
        gems: {
          added: gemCredit.gemsAdded,
          balance: gemCredit.balance,
          dailyCapped: gemCredit.dailyCapped,
        },
        sagenPass: spCredit
          ? {
              spAdded: spCredit.spAdded,
              sp: spCredit.sp,
              level: spCredit.level,
              leveledUp: spCredit.leveledUp,
              dailyCapped: spCredit.dailyCapped,
              premium: spCredit.premium,
            }
          : null,
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

  // NUEVO-02: the rarity is decided SERVER-SIDE from verifiable user state,
  // never from the client. The client chestType is ignored entirely.
  const { source, lessonId, contextId, luckBoostActive } = data;
  const validSources = ['lesson', 'streak', 'mission'];
  const src = validSources.includes(source) ? source : 'lesson';

  const userRef = admin.firestore().doc(`users/${userId}`);
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyGemsRef = gems.getDailyGemsDocRef(userId);
  const inventoryRef = inventory.getInventoryRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc, dailyGemsDoc, inventoryDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
        transaction.get(inventoryRef),
      ]);

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const today = new Date().toISOString().split('T')[0];

      // Server-authoritative chest type derivation.
      let chestType;
      let idempotencyKey;
      if (src === 'streak') {
        // Streak milestones must be verified against the server streak.
        const m = /^streak_(\d+)$/.exec(contextId || '');
        const milestone = m ? parseInt(m[1], 10) : 0;
        const milestoneMap = { 7: 'silver', 14: 'gold', 30: 'gold', 100: 'legendary' };
        const serverStreak = userData.currentStreak || 0;
        chestType = milestoneMap[milestone] && serverStreak >= milestone
          ? milestoneMap[milestone]
          : 'bronze';
        idempotencyKey = `${userId}_chest_streak_${milestone}_${today}`;
      } else if (src === 'mission') {
        // Missions are client-tracked: roll the rarity server-side so a
        // modified client cannot force a legendary chest.
        const roll = Math.random() * 100;
        if (roll < 2) chestType = 'legendary';
        else if (roll < 8) chestType = 'gold';
        else if (roll < 25) chestType = 'silver';
        else chestType = 'bronze';
        const missionId = (contextId || 'mission').replace(/[^a-zA-Z0-9_-]/g, '_');
        idempotencyKey = `${userId}_chest_mission_${missionId}_${today}`;
      } else {
        // Lesson chest: derive the tier from the server-authoritative lesson
        // counter (the same mapping the client uses), keyed by that counter so
        // a modified client cannot farm chests between real lessons.
        const lessons = userData.lessonsCompleted || 0;
        if (lessons > 0 && lessons % 15 === 0) chestType = 'legendary';
        else if (lessons > 0 && lessons % 5 === 0) chestType = 'gold';
        else if (lessons > 0 && lessons % 3 === 0) chestType = 'silver';
        else chestType = 'bronze';
        idempotencyKey = `${userId}_chest_lesson_${lessons}_${today}`;
      }

      const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);
      const logDoc = await transaction.get(logRef);

      if (logDoc.exists) {
        return { success: true, duplicate: true, xp: 0, chestType };
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

      // NUEVO-08: special items & cosmetics are rolled SERVER-SIDE and
      // persisted to users/{uid}/inventory/state. The client never rolls
      // them locally, so a modified client cannot fabricate items.
      //
      // A forged luckBoostActive flag is harmless by itself (bronze still
      // never drops), but the +15% bonus is only honored when the server
      // verifies the user actually owns a luck boost (purchased or dropped).
      const inventoryData = inventoryDoc.data() || {};
      const inventoryState = inventoryData.specialItems || {};
      const ownsLuckBoost =
        (inventoryState.luckBoost || 0) > 0 ||
        (userData.shop_purchased_luck_boosts || 0) > 0;
      const effectiveLuckBoost = luckBoostActive === true && ownsLuckBoost;
      const drops = inventory.rollSpecialDrops(chestType, effectiveLuckBoost);
      const nextState = inventory.applyDropsToState(inventoryData, drops.specialItems, drops.cosmeticUnlocks);
      transaction.set(inventoryRef, {
        ...nextState,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Idempotency log (create fails if already exists — prevents double-reward in race condition)
      transaction.create(logRef, {
        userId,
        type: 'chestDrop',
        source: src,
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
        chestType,
        xp: cappedXp,
        streakShield: streakShield > 0,
        xpBoost,
        category,
        leveledUp: newLevel > currentLevel,
        newLevel,
        specialItems: drops.specialItems,
        cosmeticUnlocks: drops.cosmeticUnlocks,
        gems: {
          added: gemCredit.gemsAdded,
          balance: gemCredit.balance,
          dailyCapped: gemCredit.dailyCapped,
        },
      };
    });

    functions.logger.info('Chest drop rolled', {
      userId, source: src, chestType: result.chestType, xp: result.xp,
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
  const dailySpRef = sagenpass.getDailySpDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc, dailyGemsDoc, dailySpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
        transaction.get(dailySpRef),
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

      const spCredit = sagenpass.applySagenPassSp({
        transaction,
        userRef,
        userData,
        dailySpRef,
        dailySpData: dailySpDoc.data() || {},
        reason: 'ad_reward',
        spToAdd: sagenpass.SP_REWARDS.ad_reward,
      });

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
        sagenPass: spCredit
          ? {
              spAdded: spCredit.spAdded,
              sp: spCredit.sp,
              level: spCredit.level,
              leveledUp: spCredit.leveledUp,
              dailyCapped: spCredit.dailyCapped,
              premium: spCredit.premium,
            }
          : null,
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
