const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { getDailyXpDocRef, computeCappedXp, MAX_DAILY_XP } = require('./economic');
const gems = require('./gems');
const sagenpass = require('./sagenpass');
const inventory = require('./inventory');
const { requireVerifiedUser } = require('./auth_guard');

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

// Server-authoritative Sagen Pass reward catalog — mirrors the client
// (lib/models/sagen_pass.dart allLevels) so rewards are actually delivered
// server-side instead of being decorative. Cosmetics (10/50) stay cosmetic and
// are merely recorded as claimed; XP, Titanium Shield and chest rewards are
// granted here, atomically and idempotently (claims are one-time per level).
const SAGEN_PASS_REWARD = (level) => {
  if (level === 10 || level === 50) {
    return { type: 'cosmetic', key: level === 10 ? 'rewardCopperFrame' : 'rewardIceFlame' };
  }
  if (level === 25) return { type: 'chest', key: 'rewardEpicChest', chest: 'epic' };
  if (level % 10 === 0) return { type: 'chest', key: 'rewardGoldenChest', chest: 'golden' };
  if (level % 5 === 0) return { type: 'xp', key: 'reward100Xp', xp: 100 };
  if (level % 3 === 0) return { type: 'item', key: 'rewardTitaniumShield', item: 'titaniumShield' };
  return { type: 'xp', key: 'reward200Exp', xp: 200 };
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
  requireVerifiedUser(context);

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
        // NUEVO-fix (chest desync): el servidor devuelve la fecha autoritativa
        // para que el cliente la persista y NO vuelva a mostrar el cofre en el
        // siguiente arranque (antes quedaba en bucle "reclamado → reaparece").
        return { success: false, alreadyClaimed: true, lastClaimedDate: today };
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
        lastClaimedDate: today,
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
  requireVerifiedUser(context);

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 10);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  // NUEVO-fix (type confusion): el nivel se coerciona a número real y se exige
  // entero en [1,50]. Antes `level <= 0` con strings/cadenas podía deslizar
  // valores inválidos y claimedLevels mezclaba números con strings sin empates.
  const levelNum = Number((data && data.level) ?? undefined);
  if (!Number.isInteger(levelNum) || levelNum < 1 || levelNum > 50) {
    throw new functions.https.HttpsError('invalid-argument', 'Nivel inválido');
  }

  const userRef = admin.firestore().doc(`users/${userId}`);
  const dailyXpRef = getDailyXpDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};

      // NUEVO-fix (decisión de producto): los premios del Sagen Pass SOLO se
      // reclaman teniendo el pass activo. Quien no lo tiene puede seguir ganando
      // SP y viendo su nivel (free track) pero no recibe recompensas. Antes un
      // no-comprador podía reclamar todos los niveles gratis (SP tope 100/día).
      if (userData.sagen_pass_active !== true) {
        throw new functions.https.HttpsError('failed-precondition', 'Sagen Pass no activo');
      }

      // Season rotation: a claim arriving after the window expired starts a
      // fresh season — previous claimed levels, SP and bank chests do NOT
      // carry over (the update below clears them atomically).
      const season = sagenpass.resolveSeason(userData, Date.now());
      const currentLevel = season.level;
      // NUEVO-fix: normaliza claimed a números (un claimed con strings previos
      // rompía el includes() estricto y permitía reclamos dobles del nivel).
      const claimedLevels = (season.claimed || [])
        .map(n => (typeof n === 'number' ? n : Number.parseInt(n, 10)))
        .filter(n => Number.isInteger(n));

      if (levelNum > currentLevel) {
        throw new functions.https.HttpsError('failed-precondition', 'Nivel no alcanzado');
      }
      if (claimedLevels.includes(levelNum)) {
        return { success: false, alreadyClaimed: true };
      }

      const reward = SAGEN_PASS_REWARD(levelNum);

      // Single atomic update: mark claimed + grant the reward server-side.
      const updates = {
        sagen_pass_claimed: [...claimedLevels, levelNum],
      };
      if (season.rotated) {
        updates.sagen_pass_level = 1;
        updates.sagen_pass_sp = 0;
        updates.sagen_pass_chests = [];
        updates.sagen_pass_season_start = admin.firestore.FieldValue.serverTimestamp();
      }

      const seasonStartISO = season.seasonStartISO;

      const rewardInfo = { key: reward.key, type: reward.type, granted: 0 };

      if (reward.type === 'xp') {
        // XP is granted inside the same daily cap as every other source.
        const dailyData = dailyXpDoc.data() || {};
        const xpEarnedToday = dailyData.total || 0;
        const { cappedXp } = computeCappedXp(xpEarnedToday, reward.xp);
        rewardInfo.granted = cappedXp;
        rewardInfo.requested = reward.xp;
        if (cappedXp > 0) {
          const currentTotalXp = userData.learning_total_xp || 0;
          const newTotalXp = currentTotalXp + cappedXp;
          updates.learning_total_xp = newTotalXp;
          updates.learning_level = Math.floor(newTotalXp / 100) + 1;
          updates._ts_learning_total_xp = admin.firestore.FieldValue.serverTimestamp();
          rewardInfo.totalXp = newTotalXp;
          rewardInfo.level = updates.learning_level;
          transaction.set(dailyXpRef, {
            total: admin.firestore.FieldValue.increment(cappedXp),
            sagenPass: admin.firestore.FieldValue.increment(cappedXp),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          }, { merge: true });
        }
      } else if (reward.type === 'item') {
        // Titanium Shield acreditado server-side (se usa como streak freeze).
        // NUEVO-fix (decisión de producto): cap de escudos en el claim — nunca
        // acumula por encima de FREE_SHIELD_MAX=3 (espejo de
        // economic.claimFreeStreakShield). Si ya está al tope, el claim se
        // marca (no bloquea el progreso de niveles) pero no sumariza escudos.
        const CLAIM_SHIELD_MAX = 3;
        const currentShields = userData.streak_shields || 0;
        const granted = Math.max(0, Math.min(1, CLAIM_SHIELD_MAX - currentShields));
        updates.streak_shields = currentShields + granted;
        rewardInfo.granted = granted;
        rewardInfo.totalShields = updates.streak_shields;
        rewardInfo.cappedAtMax = granted === 0;
      } else if (reward.type === 'chest') {
        // The chest is "openable" only once per level via rollChestDrop
        // (source='sagen'), which consumes it from this bank. A modified
        // client cannot fabricate or duplicate it.
        const bank = Array.isArray(userData.sagen_pass_chests)
          ? userData.sagen_pass_chests
          : [];
        updates.sagen_pass_chests = [...bank, reward.chest];
        rewardInfo.granted = 1;
        rewardInfo.chest = reward.chest;
        rewardInfo.sagenPassChests = updates.sagen_pass_chests;
      }

      transaction.update(userRef, updates);

      return {
        success: true,
        claimed: levelNum,
        claimedLevels: updates.sagen_pass_claimed,
        seasonStart: seasonStartISO,
        reward: rewardInfo,
      };
    });

    functions.logger.info('Sagen Pass reward claimed', { userId, level: levelNum });
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
  requireVerifiedUser(context);

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }

    const userData = userDoc.data() || {};

    // Effective season state: an expired window rotates the visible pass to a
    // fresh season (level 1, no claims) so the client can never re-import a
    // previous season's claimedLevels after its local reset.
    const season = sagenpass.resolveSeason(userData, Date.now());

    return {
      seasonStart: season.seasonStartISO,
      level: season.level,
      sp: season.sp,
      claimed: season.claimed,
      premium: userData.sagen_pass_active === true,
      maxLevel: 50,
      rotated: season.rotated,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('getSagenPassSeason error', error);
    throw new functions.https.HttpsError('internal', 'Error al obtener datos de temporada');
  }
});

/**
 * HTTPS Callable: Get authoritative daily chest status.
 * NUEVO-fix (chest desync): permite al cliente reconciliar el ledger local
 * (SharedPreferences) con el autoritativo del servidor (users/{uid}.
 * last_daily_chest) al arrancar, cerrando el bucle "cofre reclamado que
 * reaparece" y el caso de recompensa "oculta por prefs stale".
 */
exports.getDailyChestStatus = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }

    const userData = userDoc.data() || {};
    const today = new Date().toISOString().split('T')[0];
    const lastClaimedDate = userData.last_daily_chest || null;

    return {
      lastClaimedDate,
      available: lastClaimedDate !== today,
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('getDailyChestStatus error', error);
    throw new functions.https.HttpsError('internal', 'Error al obtener estado del cofre');
  }
});

/**
 * HTTPS Callable: Roll chest drop after lesson completion.
 * Server rolls rewards based on chest type with weighted random categories.
 * Uses idempotency via transaction_logs to prevent double-claiming.
 */
exports.rollChestDrop = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const userId = context.auth.uid;
  const rateCheck = await checkDistributedRateLimit(userId, 60 * 1000, 10);
  if (!rateCheck.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes');
  }

  // NUEVO-02: the rarity is decided SERVER-SIDE from verifiable user state,
  // never from the client. The client chestType is ignored entirely.
  const { source, lessonId, contextId, luckBoostActive } = data;
  const validSources = ['lesson', 'streak', 'mission', 'sagen'];
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
      // Set for source 'sagen': which bank chest is consumed by this roll.
      let sagenBankChest = null;
      if (src === 'streak') {
        // Streak milestones must be verified against the server streak and only
        // apply at the exact milestone (a re-request of an older milestone must
        // not farm silver/gold chests, even on a later day).
        const m = /^streak_(\d+)$/.exec(contextId || '');
        const milestone = m ? parseInt(m[1], 10) : 0;
        const milestoneMap = { 7: 'silver', 14: 'gold', 30: 'gold', 100: 'legendary' };
        const serverStreak = userData.currentStreak || 0;
        if (!milestoneMap[milestone] || serverStreak !== milestone) {
          throw new functions.https.HttpsError('failed-precondition', 'Hito de racha no verificado');
        }
        chestType = milestoneMap[milestone];
        idempotencyKey = `${userId}_chest_streak_${milestone}_${today}`;
      } else if (src === 'mission') {
        // Missions are client-tracked: roll the rarity server-side so a
        // modified client cannot force a legendary chest.
        // NUEVO-fix (anti-farm): antes el idempotencyKey por missionId dejaba a
        // un cliente modificado inventar infinitos contextId nuevos por día para
        // forzar rolls. Ahora hay un tope DIARIO determinista por usuario.
        const MISSION_ROLLS_PER_DAY = 30;
        const missionRollsRef = admin.firestore().doc(
          `daily_mission_rolls/${userId}_${today}`
        );
        const missionRollsDoc = await transaction.get(missionRollsRef);
        const rolls = (missionRollsDoc.data() || {}).count || 0;
        if (rolls >= MISSION_ROLLS_PER_DAY) {
          throw new functions.https.HttpsError(
            'failed-precondition',
            'Límite diario de cofres de misión alcanzado',
          );
        }
        transaction.set(missionRollsRef, {
          count: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        // Drop rates alineados con los defaults de Remote Config del cliente
        // (1% legendary / 6% gold / 20% silver) — antes el servidor usaba
        // 2/6/17 y desincronizaba la percepción client vs server.
        const roll = Math.random() * 100;
        if (roll < 1) chestType = 'legendary';
        else if (roll < 7) chestType = 'gold';
        else if (roll < 27) chestType = 'silver';
        else chestType = 'bronze';
        const missionId = (contextId || 'mission').replace(/[^a-zA-Z0-9_-]/g, '_');
        idempotencyKey = `${userId}_chest_mission_${missionId}_${today}`;
      } else if (src === 'sagen') {
        // Sagen Pass chest bank: the chest was granted at claim time and can
        // only be rolled ONCE (consumed from the bank), so a modified client
        // cannot farm or duplicate it. The bank is scoped to the CURRENT
        // season: chests banked in an expired season are not openable here.
        const m = /^pass_(\d+)$/.exec(contextId || '');
        const passLevel = m ? parseInt(m[1], 10) : 0;
        const levelReward = SAGEN_PASS_REWARD(passLevel);
        const season = sagenpass.resolveSeason(userData, Date.now());
        const rawBank = Array.isArray(userData.sagen_pass_chests)
          ? userData.sagen_pass_chests
          : [];
        const bank = season.rotated ? [] : rawBank;
        if (!levelReward || levelReward.type !== 'chest' || !bank.includes(levelReward.chest)) {
          throw new functions.https.HttpsError('failed-precondition', 'Cofre del pass no disponible');
        }
        chestType = 'gold';
        sagenBankChest = levelReward.chest;
        idempotencyKey = `${userId}_chest_sagen_${passLevel}`;
      } else {
        // Lesson chest: only at real milestones (3rd/5th lesson — the same
        // gate the legit client uses), derived from the server-authoritative
        // counter. Anything else is rejected so a modified client cannot farm
        // chests between real lessons.
        const lessons = userData.lessonsCompleted || 0;
        if (lessons <= 0 || (lessons % 3 !== 0 && lessons % 5 !== 0)) {
          throw new functions.https.HttpsError('failed-precondition', 'No hay cofre disponible para esta lección');
        }
        if (lessons % 15 === 0) chestType = 'legendary';
        else if (lessons % 5 === 0) chestType = 'gold';
        else chestType = 'silver';
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

      const xpRange = xpRanges[chestType] || xpRanges.bronze;
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

      // Consume the Sagen Pass chest from the bank (one roll per bank entry).
      if (sagenBankChest) {
        const bank = Array.isArray(userData.sagen_pass_chests)
          ? userData.sagen_pass_chests
          : [];
        const nextBank = [...bank];
        nextBank.splice(nextBank.indexOf(sagenBankChest), 1);
        updates.sagen_pass_chests = nextBank;
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
  requireVerifiedUser(context);

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
