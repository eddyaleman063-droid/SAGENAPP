const functions = require('firebase-functions');
const admin = require('firebase-admin');
const inventory = require('./inventory');

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
  streak_milestones: { 7: 15, 14: 30, 30: 60, 60: 100, 100: 150, 180: 250, 365: 500 },
  daily_bonus: { 3: 8, 7: 12, 14: 18, 30: 30 },  // day streak -> bonus; base 5
};
const DEFAULT_GEM_REWARD = 5;

// Server-authoritative gem shop catalog.
// The server decides the cost of each item — the client amount is ignored
// (anti-farm). Unknown items are rejected.
const SHOP_GEM_CATALOG = {
  focus_elixir: 30,
  xp_boost: 40,
  luck_boost: 40,
  sage_monocle: 50,
  time_warp: 60,
  titanium_shield: 80,
  phoenix_feather: 100,
  avatar_frame_neon: 120,
  avatar_frame_galaxy: 180,
  avatar_frame_dragon: 200,
  avatar_frame_crystal: 250,
  avatar_frame_skull: 350,
  title_storm_breaker: 120,
  title_cyber_sage: 150,
  title_shadow_hacker: 200,
  title_night_guardian: 220,
  title_digital_phoenix: 300,
  effect_digital_rain: 250,
  effect_fire_trail: 350,
  theme_blue: 150,
  theme_purple: 150,
  theme_dark_fire: 250,
  theme_cyber_neon: 350,
};

// Items that are purchased ONE time per user (cosmetics/themes). Consumables
// (elixirs, boosts, shields, feathers) can be bought repeatedly, each time
// charging the server catalog cost with a fresh idempotencyKey.
const SHOP_ONE_TIME_ITEMS = new Set([
  'avatar_frame_neon',
  'avatar_frame_galaxy',
  'avatar_frame_dragon',
  'avatar_frame_crystal',
  'avatar_frame_skull',
  'title_storm_breaker',
  'title_cyber_sage',
  'title_shadow_hacker',
  'title_night_guardian',
  'title_digital_phoenix',
  'effect_digital_rain',
  'effect_fire_trail',
  'theme_blue',
  'theme_purple',
  'theme_dark_fire',
  'theme_cyber_neon',
]);

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
  daily_bonus: 30,
};
const DEFAULT_DAILY_GEM_CAP = 50;

// Absolute balance cap (anti-inflation).
const MAX_GEM_BALANCE = 100000;

// Reasons that can ONLY be earned via earnGems() (the rest are credited
// atomically inside completeLesson / rollChestDrop / claimDailyChest /
// claimAdReward so there is a single authoritative path per source).
const EARN_GEMS_REASONS = ['achievement', 'mission', 'review', 'streak_milestone', 'mini_game', 'challenge', 'gacha', 'daily_bonus'];

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
    case 'daily_bonus': {
      // Base 5, escalating with the day streak: 8 at 3d, 12 at 7d, 18 at 14d,
      // 30 at 30d+ (mirrors the client's awardDailyBonus table).
      const days = m.dayStreak || 0;
      const table = GEM_REWARDS.daily_bonus;
      const keys = Object.keys(table).map(Number).sort((a, b) => a - b);
      let reward = 5;
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
  if (!itemId || typeof itemId !== 'string' || !idempotencyKey || typeof idempotencyKey !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'itemId e idempotencyKey requeridos');
  }
  if (!/^[A-Za-z0-9_-]{1,128}$/.test(idempotencyKey)) {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey invalido');
  }

  // Server-authoritative cost: the client amount is ignored when the item is
  // in the catalog. Unknown items are rejected (no forged-amount purchases).
  const catalogCost = SHOP_GEM_CATALOG[itemId];
  if (typeof catalogCost !== 'number') {
    throw new functions.https.HttpsError('invalid-argument', 'Artículo desconocido en la tienda');
  }
  const amount = catalogCost;

  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);
  const isOneTime = SHOP_ONE_TIME_ITEMS.has(itemId);
  const inventoryRef = admin.firestore().doc(`users/${userId}/inventory/shop_items`);
  const inventoryStateRef = inventory.getInventoryRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc, inventoryDoc, inventoryStateDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
        transaction.get(inventoryRef),
        transaction.get(inventoryStateRef),
      ]);

      // One-time items cannot be bought twice, regardless of the
      // idempotencyKey used. This prevents re-buying cosmetics for free
      // with a different key (see NUEVO-01).
      const ownedItems = (inventoryDoc.data()?.items || []);
      if (isOneTime && ownedItems.includes(itemId)) {
        return {
          success: false,
          owned: true,
          duplicate: false,
          balance: userDoc.data()?.learning_gems || 0,
        };
      }

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

      if (isOneTime) {
        // Persist shop ownership server-side so "already owned" survives
        // reinstalls / multi-device and _validatePurchase works (NUEVO-11).
        transaction.set(inventoryRef, {
          items: [...ownedItems, itemId],
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      // NUEVO-08: gem purchases are also credited into the authoritative
      // inventory state (users/{uid}/inventory/state) so consumables survive
      // reinstalls and the client only reads what the server granted.
      const purchasedState = inventory.applyShopPurchaseToState(inventoryStateDoc.data() || {}, itemId);
      if (purchasedState) {
        transaction.set(inventoryStateRef, {
          ...purchasedState,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      transaction.create(logRef, {
        userId,
        type: 'gemSpend',
        itemId,
        amount,
        balanceAfter: balance - amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, owned: isOneTime, balance: balance - amount, spent: amount, itemId };
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
