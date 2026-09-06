const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
const gems = require('./gems');
const sagenpass = require('./sagenpass');
const { requireVerifiedUser } = require('./auth_guard');

// ══════════════════════════════════════════════════════════════════
// ECONOMIC FUNCTIONS — Server-authoritative mutations
// All economic fields (donations, XP, streak, level) MUST go through
// these functions. Direct client writes are blocked by Firestore rules.
// ══════════════════════════════════════════════════════════════════

const MAX_XP_PER_LESSON = 100;
const MAX_DAILY_XP = 500;
const MAX_DONATION_AMOUNT = 100000;

// Server-authoritative XP rewards per reason.
// Client cannot specify amount — server uses these predefined values.
const REASON_REWARDS = {
  lesson_reward: { xp: 15 },
  chest_reward: { xp: 10 },
  streak_chest: { xp: 10 },
  ad_reward: { xp: 5 },
  mini_game: { xp: 10 },
  review: { xp: 15 },
  achievement: { xp: 10 },
  mission_reward: { xp: 10 },
  daily_chest: { xp: 10 },
};
const DEFAULT_REASON_REWARD = { xp: 5 };

// NUEVO-fix: XP por logro según su id (espejo de los templates del cliente en
// lib/services/achievement_service.dart). El cliente reporta SOLO el
// achievementId; el servidor decide el XP. Antes todos los logros acreditaban
// flat 10 y el cliente optimistamente sumaba el XP real (10-200), provocando un
// rollback visible de XP/nivel al llegar la respuesta del servidor.
const ACHIEVEMENT_REWARDS = {
  first_lesson: 10,
  five_lessons: 25,
  ten_lessons: 40,
  twenty_five_lessons: 60,
  fifty_lessons: 100,
  stage_complete: 30,
  all_stages: 200,
  streak_3: 20,
  streak_7: 50,
  streak_30: 100,
  perfect_lesson: 30,
  sage_talk: 40,
};

// Server-authoritative XP rewards per lesson.
// If a lessonId is not listed here, the default reward applies.
const LESSON_REWARDS = {
  default: { xp: 15 },
  _bonus: { xp: 20 },
};
function getLessonXp(lessonId) {
  if (!lessonId) return LESSON_REWARDS.default.xp;
  // Match by lessonId prefix (e.g., "ac_s1_ses1_l6" for bonus lessons ending in _l6)
  if (lessonId.endsWith('_l6')) return LESSON_REWARDS._bonus.xp;
  return LESSON_REWARDS.default.xp;
}

// Server-authoritative streak multiplier (mirrors the client's
// streakMultiplier in streak_provider.dart:77-81). Applied to lesson XP so
// the XP shown locally equals what the server actually credits.
function getStreakMultiplier(currentStreak) {
  if (currentStreak < 10) return 1.0;
  const mult = 1.0 + Math.floor(currentStreak / 10) * 0.1;
  return Math.min(Math.max(mult, 1.0), 2.0);
}

function getDailyXpDocRef(userId) {
  const today = new Date().toISOString().split('T')[0];
  return admin.firestore().doc(`daily_xp_sources/${userId}_${today}`);
}

// ---------------------------------------------------------------------------
// Streak backfill (NUEVO-fix): recuperación de días offline acotada y
// verificada. IncrementStreak no recibía el día de actividad del cliente:
// un usuario que chequeó offline días de corrido colapsaba a 1 al volver
// online (el server veía un gap y rompía), pese a haber hecho check-in cada
// día. El cliente ahora envía `activityDay` (día UTC de su ÚLTIMO check-in
// local previo) y `activityStreak` (su racha consecutiva ANTES de este
// check-in). El server solo confía en la combinación cuando la ecuación de
// continuidad se cumple EXACTAMENTE, el día es plausible (no futuro, no
// anterior al día del server) y el gap no supera la ventana de confianza.
// La ventana acota el vector de farmeo (un cliente deshonesto gana a lo sumo
// MAX_STREAK_BACKFILL_DAYS por día; la prueba real de "hice cada día" solo
// vive localmente y no es criptográficamente verificable). Fuera de la
// ventana o ante contradicciones se cae al flujo histórico freeze/romper.
const MAX_STREAK_BACKFILL_DAYS = 3;

// Día calendario UTC (entero) de `YYYY-MM-DD`, o null si es inválido.
function utcDayNumber(str) {
  if (typeof str !== 'string') return null;
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(str);
  if (!m) return null;
  return Math.floor(Date.UTC(+m[1], +m[2] - 1, +m[3]) / 86400000);
}

// `serverLastStr` puede ser null (usuario sin historial en el server).
// Devuelve { newStreak, backfilledDays } o null (no confiable / no aplica).
function computeStreakBackfill({
  serverStreak, serverLastStr, todayStr, activityDay, activityStreak,
}) {
  if (typeof activityDay !== 'string' || typeof activityStreak !== 'number') {
    return null;
  }
  if (!Number.isInteger(activityStreak) || activityStreak < 0) return null;

  const todayNum = utcDayNumber(todayStr);
  const dayNum = utcDayNumber(activityDay);
  if (dayNum === null || dayNum > todayNum) return null; // reloj adelantado/imposible

  const startNum = serverLastStr ? utcDayNumber(serverLastStr) : null;

  if (startNum === null) {
    // Primera vez en el server: se acepta solo un baseline reciente y acotado.
    const age = todayNum - dayNum;
    if (age > 1) return null;
    if (activityStreak > MAX_STREAK_BACKFILL_DAYS) return null;
    const newStreak = activityStreak + (dayNum === todayNum ? 1 : 0);
    return { newStreak, backfilledDays: activityStreak };
  }

  if (dayNum < startNum) return null; // regresivo: contradice el historial server

  const daysElapsed = dayNum - startNum;
  if (daysElapsed < 1) return null; // sin días nuevos: flujo normal (freeze/ítem/romper)
  if (daysElapsed > MAX_STREAK_BACKFILL_DAYS) return null;

  const expected = serverStreak + daysElapsed;
  if (activityStreak !== expected) return null; // ecuación de continuidad rota

  // El check-in que ocurre HOY avanza 1; si el último día local ya era hoy
  // (el usuario chequeó antes hoy sin sync), la racha ya lo incluye.
  const newStreak = activityStreak + (dayNum === todayNum ? 0 : 1);
  return { newStreak, backfilledDays: daysElapsed };
}

function computeCappedXp(currentDailyTotal, requestedXp) {
  const remaining = Math.max(0, MAX_DAILY_XP - currentDailyTotal);
  const cappedXp = Math.min(requestedXp, remaining);
  return { cappedXp, remaining };
}

async function checkDailyXpCap(userId, additionalXp) {
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyXpDoc = await dailyXpRef.get();
  const dailyData = dailyXpDoc.data() || {};
  const currentTotal = dailyData.total || 0;
  const { cappedXp, remaining } = computeCappedXp(currentTotal, additionalXp);
  return { allowed: cappedXp > 0, currentTotal, remaining, cappedXp };
}

exports.MAX_DAILY_XP = MAX_DAILY_XP;
exports.checkDailyXpCap = checkDailyXpCap;
exports.getDailyXpDocRef = getDailyXpDocRef;
exports.computeCappedXp = computeCappedXp;

function safeInt(value, min, max, fieldName) {
  const n = parseInt(value, 10);
  if (isNaN(n) || n < min || n > max) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `${fieldName} debe estar entre ${min} y ${max}`
    );
  }
  return n;
}

exports.processDonation = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const { amount, method, idempotencyKey } = data;
  if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'El monto debe ser mayor a 0');
  }
  if (amount > MAX_DONATION_AMOUNT) {
    throw new functions.https.HttpsError('invalid-argument', `El monto excede el límite de ${MAX_DONATION_AMOUNT}`);
  }
  if (!method || typeof method !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'method requerido');
  }
  if (!idempotencyKey || typeof idempotencyKey !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey requerido');
  }
  if (!/^[A-Za-z0-9_-]{1,128}$/.test(idempotencyKey)) {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey invalido');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
      ]);

      if (logDoc.exists) {
        // NUEVO-fix: la clave de idempotencia pertenece al usuario que la
        // creó. Si otro uid la reenvía es una colisión/replay, no un duplicado
        // legítimo: error explícito en vez de tragarse la donación en silencio.
        const logData = logDoc.data() || {};
        if (logData.userId && logData.userId !== userId) {
          throw new functions.https.HttpsError('already-exists', 'Clave de donación en uso');
        }
        return { success: true, duplicate: true, total_donated: userDoc.data()?.total_donated || 0 };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};

      if (method === 'wallet') {
        const walletBalance = userData.walletBalance || 0;
        if (walletBalance < amount) {
          throw new functions.https.HttpsError('failed-precondition', 'Saldo insuficiente');
        }
        transaction.update(userRef, {
          walletBalance: walletBalance - amount,
          total_donated: (userData.total_donated || 0) + amount,
          is_supporter: true,
          _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(userRef, {
          total_donated: (userData.total_donated || 0) + amount,
          is_supporter: true,
          _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      transaction.create(logRef, {
        userId,
        type: 'donation',
        method,
        amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, total_donated: (userData.total_donated || 0) + amount };
    });

    functions.logger.info('processDonation', {
      userId, amount, method, duplicate: result.duplicate,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('processDonation error', error);
    throw new functions.https.HttpsError('internal', 'Error al procesar donación');
  }
});

/**
 * HTTPS Callable: Record a user-reported donation (manual methods like
 * WhatsApp/Yape/Plin). The amount is user-provided by design (verified later
 * by an admin), but bounds are enforced and the write is idempotent.
 */
exports.recordDonation = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const { amount, method, idempotencyKey } = data;
  if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'El monto debe ser mayor a 0');
  }
  if (amount > MAX_DONATION_AMOUNT) {
    throw new functions.https.HttpsError('invalid-argument', `El monto excede el límite de ${MAX_DONATION_AMOUNT}`);
  }
  if (!method || typeof method !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'method requerido');
  }
  if (idempotencyKey && !/^[A-Za-z0-9_-]{1,128}$/.test(idempotencyKey)) {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey invalido');
  }

const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  // NUEVO-fix idempotencia: sin clave del cliente se deriva una determinista
  // del día UTC + monto + método, así un retry de red de la MISMA donación no
  // la acredita dos veces (el viejo fallback Date.now() generaba una clave
  // distinta en cada intento y duplicaba total_donated/is_supporter).
  const todayStr = new Date().toISOString().split('T')[0];
  const key = idempotencyKey || `donation_${userId}_${todayStr}_${amount}_${String(method).slice(0, 32)}`;
  const logRef = admin.firestore().doc(`transaction_logs/${key}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
      ]);

      if (logDoc.exists) {
        // NUEVO-fix: la clave de idempotencia es del alcance del usuario que
        // la creó. Si otro uid la reenvía, es una colisión (o intento de
        // replay), no un duplicado legítimo: no tragarse la donación en
        // silencio.
        const logData = logDoc.data() || {};
        if (logData.userId && logData.userId !== userId) {
          throw new functions.https.HttpsError('already-exists', 'Clave de donación en uso');
        }
        return { success: true, duplicate: true, total_donated: userDoc.data()?.total_donated || 0 };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const newTotal = (userData.total_donated || 0) + amount;

      transaction.update(userRef, {
        total_donated: newTotal,
        is_supporter: true,
        _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.create(logRef, {
        userId,
        type: 'donation',
        method,
        amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, total_donated: newTotal };
    });

    functions.logger.info('recordDonation', {
      userId, amount, method, duplicate: result.duplicate,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('recordDonation error', error);
    throw new functions.https.HttpsError('internal', 'Error al registrar donación');
  }
});

exports.addXp = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const { reason, lessonId, idempotencyKey } = data;

  if (!idempotencyKey || typeof idempotencyKey !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey requerido');
  }

  // Guard against Firestore path/field-path injection: idempotencyKey is used
  // as a document id and reason as a field name. Only [A-Za-z0-9_-] is allowed.
  if (!/^[A-Za-z0-9_-]{1,128}$/.test(idempotencyKey)) {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey invalido');
  }

  // Whitelist the reason: unknown reasons fall back to the default reward but
  // are never used as a field name (prevents malicious field-path injection).
  const reasonKey = Object.prototype.hasOwnProperty.call(REASON_REWARDS, reason)
    ? reason
    : 'unknown';
  const reward = REASON_REWARDS[reasonKey] || DEFAULT_REASON_REWARD;
  let xp = reward.xp;
  // NUEVO-fix: los logros acreditan el XP real de cada uno (10-200), no un
  // flat 10. El cliente reporta solo el achievementId; el servidor decide el
  // XP. Se valida el id (regex) y se ignora si no está en el map (fallback al
  // flat 10) para no aceptar ids arbitrarios/inyectados.
  const achievementId = data.achievementId;
  const isAchievementClaim =
    reasonKey === 'achievement' &&
    typeof achievementId === 'string' &&
    /^[A-Za-z0-9_-]{1,64}$/.test(achievementId) &&
    Object.prototype.hasOwnProperty.call(ACHIEVEMENT_REWARDS, achievementId);
  if (isAchievementClaim) {
    xp = ACHIEVEMENT_REWARDS[achievementId];
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);
  const today = new Date().toISOString().split('T')[0];
  const dailyXpRef = admin.firestore().doc(`daily_xp_sources/${userId}_${today}`);
  const leaderboardRef = admin.firestore().doc(`leaderboards/${userId}`);
  // Claim-once de logros: users/{uid}/achievements/{achievementId}. Un solo doc
  // con flags separados para XP y gemas, así addXp y earnGems pagan UNA vez cada
  // uno sin bloquearse entre sí (ver NUEVO-fix en el txn).
  const achievementClaimRef = isAchievementClaim
    ? admin.firestore().doc(`users/${userId}/achievements/${achievementId}`)
    : null;

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc, dailyXpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
        transaction.get(dailyXpRef),
      ]);

      if (logDoc.exists) {
        return { success: true, duplicate: true, totalXp: userDoc.data()?.learning_total_xp || 0, level: userDoc.data()?.learning_level || 1, leveledUp: false };
      }

      // NUEVO-fix anti-farm: un logro PAGA una sola vez. Antes, un cliente
      // modificado podía llamar addXp con reason='achievement' + achievementId
      // (hasta 200 XP) infinitamente, topado solo por el cap diario (500 XP).
      // Mismo patrón "no double-grant" que los niveles del Pass y los one-time
      // items de la tienda. La segunda reclamación devuelve alreadyClaimed
      // (shape idéntico al duplicate) para que el cliente no aplique totales.
      if (isAchievementClaim) {
        const achievementClaimDoc = await transaction.get(achievementClaimRef);
        if (
          achievementClaimDoc.exists &&
          achievementClaimDoc.data()?.xpClaimed === true
        ) {
          return { success: true, duplicate: true, alreadyClaimed: true, totalXp: userDoc.data()?.learning_total_xp || 0, level: userDoc.data()?.learning_level || 1, leveledUp: false };
        }
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const dailyData = dailyXpDoc.data() || {};
      const xpEarnedToday = dailyData.total || 0;
      const remainingDailyXp = Math.max(0, MAX_DAILY_XP - xpEarnedToday);
      const cappedXp = Math.min(xp, remainingDailyXp);

      if (cappedXp <= 0) {
        throw new functions.https.HttpsError('resource-exhausted', `Limite diario de XP alcanzado (${MAX_DAILY_XP} XP/dia)`);
      }

      const userData = userDoc.data() || {};
      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;

      const newTotalXp = currentTotalXp + cappedXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;
      const leveledUp = newLevel > currentLevel;

      transaction.update(userRef, {
        learning_total_xp: newTotalXp,
        learning_level: newLevel,
        _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
        _ts_learning_level: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(dailyXpRef, {
        total: admin.firestore.FieldValue.increment(cappedXp),
        // NUEVO-fix: se usa reasonKey (whitelisteado) como field name, nunca el
        // reason crudo del cliente. Antes un reason='a.b' creaba campos
        // anidados o 'total'/'__name__' corrompía el doc diario.
        [reasonKey]: admin.firestore.FieldValue.increment(cappedXp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      transaction.set(leaderboardRef, {
        firstName: userData.firstName || '',
        lastName: userData.lastName || '',
        photoUrl: userData.photoUrl || '',
        learning_total_xp: newTotalXp,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // Claim-once del logro (merge: no pisa las gemas ya marcadas por
      // earnGems en el mismo doc). NUEVO-fix: sellar SOLO si el cap diario no
      // recortó el pago. Si el XP esperado supera el remanente diario, la
      // reclamación queda ABIERTA y el saldo restante se paga otro día (mismo
      // patrón full-payment que sellos de gemas).
      if (isAchievementClaim && cappedXp === xp) {
        transaction.set(achievementClaimRef, {
          userId,
          achievementId,
          xpClaimed: true,
          xpClaimedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
      }

      transaction.create(logRef, {
        userId,
        type: 'addXp',
        reason: reason || 'unknown',
        lessonId: lessonId || null,
        amount: cappedXp,
        requestedAmount: xp,
        dailyCapped: cappedXp < xp,
        previousTotalXp: currentTotalXp,
        newTotalXp,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, totalXp: newTotalXp, level: newLevel, leveledUp, dailyCapped: cappedXp < xp };
    });

    functions.logger.info('addXp', {
      userId, xp, reason, lessonId, duplicate: result.duplicate,
      level: result.level, leveledUp: result.leveledUp,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('addXp error', error);
    throw new functions.https.HttpsError('internal', 'Error al agregar XP');
  }
});

exports.incrementStreak = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const { freezeUsed, checkIn = true, itemUsed, activityDay, activityStreak } = data;

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const currentStreak = userData.currentStreak || 0;
      const longestStreak = userData.longestStreak || 0;
      const lastActivity = userData.streak_last_activity;

      // NUEVO-fix (H1): sync-only mode. reload/login only reconciles the local
      // ledgers with the authoritative server state WITHOUT mutating anything:
      // no streak advance for merely opening the app, no silent shield burn and
      // no break. Only an explicit check-in (checkIn: true, the default) may
      // write. The client keeps the read-only path (checkIn: false) for
      // app-start reconciliation.
      if (checkIn === false) {
        const streakShieldsNow = userData.streak_shields || 0;
        const shopShieldsNow = userData.shop_streak_shields || 0;
        return {
          success: true,
          synced: true,
          currentStreak,
          longestStreak,
          alreadyCheckedIn: false,
          shieldsRemaining: streakShieldsNow + shopShieldsNow,
        };
      }

      const now = new Date();
      const todayStr = now.toISOString().split('T')[0];

      if (lastActivity) {
        const lastDate = lastActivity.toDate ? lastActivity.toDate() : new Date(lastActivity);
        const lastStr = lastDate.toISOString().split('T')[0];
        if (lastStr === todayStr) {
          return {
            success: true, currentStreak, longestStreak, alreadyCheckedIn: true,
          };
        }

        // NUEVO-fix (streak backfill): si el cliente prueba (ecuación de
        // continuidad exacta + día plausible + ventana acotada) que hizo
        // check-in offline en los días intermedios, se recuperan en vez de
        // colapsar la racha a 1 al volver online.
        const backfill = computeStreakBackfill({
          serverStreak: currentStreak,
          serverLastStr: lastStr,
          todayStr,
          activityDay,
          activityStreak,
        });
        if (backfill) {
          const newLongest = Math.max(longestStreak, backfill.newStreak);
          transaction.update(userRef, {
            currentStreak: backfill.newStreak,
            longestStreak: newLongest,
            streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
            _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
            _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
          });
          return {
            success: true, currentStreak: backfill.newStreak, longestStreak: newLongest,
            alreadyCheckedIn: false, backfilledDays: backfill.backfilledDays,
            shieldsRemaining: (userData.streak_shields || 0) + (userData.shop_streak_shields || 0),
          };
        }

        const yesterday = new Date(now);
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];

        if (lastStr !== yesterdayStr) {
          // NUEVO-fix: the freeze decision is SERVER-side and driven by the
          // shields the user actually owns (streak_shields + shop_streak_shields),
          // not by the client's `freezeUsed` flag. The client keeps its own
          // local freeze counter that can diverge from the server (e.g. shields
          // earned via chest/shop that the client has not yet mirrored, or
          // "phantom" local freezes the server never granted). By deciding
          // purely on real shields we guarantee that a shield the user owns
          // ALWAYS protects the streak, and a shield they do NOT own never does.
          const streakShields = userData.streak_shields || 0;
          const shopShields = userData.shop_streak_shields || 0;
          const availableShields = streakShields + shopShields;

          if (availableShields > 0) {
            const keptStreak = currentStreak + 1;
            const newLongest = Math.max(longestStreak, keptStreak);
            const shieldUpdates = streakShields > 0
              ? { streak_shields: streakShields - 1 }
              : { shop_streak_shields: shopShields - 1 };
            transaction.update(userRef, {
              currentStreak: keptStreak,
              longestStreak: newLongest,
              streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
              _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
              _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
              ...shieldUpdates,
            });
            return {
              success: true, currentStreak: keptStreak, longestStreak: newLongest,
              freezeConsumed: true, previousStreak: currentStreak,
              shieldsRemaining: availableShields - 1,
            };
          }
          // No shields owned: premium items (H5) may protect the streak, decided
          // SERVER-authoritatively. The client declares the intended item but
          // the server validates ownership against the inventory doc and
          // decrements it in the same transaction. Titanium Shield keeps the
          // streak alive (like a shield, without burning one); Phoenix Feather
          // revives it (keeps the previous value, it is a grace — not an
          // advance). When the declared item is not owned, we fall through to
          // the break and signal itemDenied so the client never consumes it.
          if (itemUsed === 'titaniumShield' || itemUsed === 'phoenixFeather') {
            const stateRef = admin.firestore().doc(`users/${userId}/inventory/state`);
            const invDoc = await transaction.get(stateRef);
            const invData = invDoc.data() || {};
            const specialItems = invData.specialItems || {};
            if ((specialItems[itemUsed] || 0) >= 1) {
              const nextSpecialItems = {
                ...specialItems,
                [itemUsed]: specialItems[itemUsed] - 1,
              };
              transaction.set(stateRef, {
                specialItems: nextSpecialItems,
                cosmetics: invData.cosmetics || [],
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
              }, { merge: true });

              const newLongest = Math.max(longestStreak, currentStreak + 1);
              const keptStreak = itemUsed === 'titaniumShield'
                ? currentStreak + 1
                : currentStreak;
              transaction.update(userRef, {
                currentStreak: keptStreak,
                longestStreak: newLongest,
                streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
                _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
                _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
              });
              return {
                success: true, currentStreak: keptStreak, longestStreak: newLongest,
                itemConsumed: true, itemUsed, revived: itemUsed === 'phoenixFeather',
                previousStreak: currentStreak, shieldsRemaining: 0,
              };
            }
          }
          // No shields owned and no usable item: the streak breaks
          // (server-authoritative). `freezeDenied` is kept for backward-compat
          // signaling when the client asked for a freeze but none could be
          // honored; `itemDenied` tells an item-requesting client not to
          // consume the premium item locally.
          const newStreak = 1;
          const newLongest = Math.max(longestStreak, currentStreak);
          transaction.update(userRef, {
            currentStreak: newStreak,
            longestStreak: newLongest,
            streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
            _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
            _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
          });
          return {
            success: true, currentStreak: newStreak, longestStreak: newLongest,
            streakBroken: true, previousStreak: currentStreak,
            shieldsRemaining: 0,
            freezeDenied: freezeUsed === true,
            itemDenied: itemUsed != null,
          };
        }
      } else {
        // NUEVO-fix (streak backfill): primer contacto con el server donde el
        // usuario ya tiene un baseline local reciente y acotado.
        const backfill = computeStreakBackfill({
          serverStreak: currentStreak,
          serverLastStr: null,
          todayStr,
          activityDay,
          activityStreak,
        });
        if (backfill) {
          const newLongest = Math.max(longestStreak, backfill.newStreak);
          transaction.update(userRef, {
            currentStreak: backfill.newStreak,
            longestStreak: newLongest,
            streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
            _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
            _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
          });
          return {
            success: true, currentStreak: backfill.newStreak, longestStreak: newLongest,
            alreadyCheckedIn: false, backfilledDays: backfill.backfilledDays,
            shieldsRemaining: (userData.streak_shields || 0) + (userData.shop_streak_shields || 0),
          };
        }
      }

      const newStreak = currentStreak + 1;
      const newLongest = Math.max(longestStreak, newStreak);

      transaction.update(userRef, {
        currentStreak: newStreak,
        longestStreak: newLongest,
        streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
        _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
        _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
      });

      // NUEVO-fix: include the authoritative shield count so the client can
      // reconcile its local freeze counter with the real server balance on
      // every valid check-in (not just on freeze/break events). This prevents
      // the client from showing "phantom" freezes the server never granted, or
      // failing to reflect shields earned server-side.
      const streakShieldsNow = userData.streak_shields || 0;
      const shopShieldsNow = userData.shop_streak_shields || 0;

      return {
        success: true, currentStreak: newStreak, longestStreak: newLongest,
        alreadyCheckedIn: false,
        shieldsRemaining: streakShieldsNow + shopShieldsNow,
      };
    });

    functions.logger.info('incrementStreak', {
      userId, currentStreak: result.currentStreak,
      alreadyCheckedIn: result.alreadyCheckedIn, streakBroken: result.streakBroken,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('incrementStreak error', error);
    throw new functions.https.HttpsError('internal', 'Error al actualizar racha');
  }
});

// FREE STREAK SHIELD: claims a free streak shield server-side with a daily
// anti-farm cap. The result is written to users/{uid}/streak_shields (server-only
// via Firestore rules + the client profile whitelist), so incrementStreak's
// server-side freeze check actually honors shields granted by the "Gratis"
// button. Without this, the client bumped a local SP counter that the server
// never saw, so the freeze was denied and the streak broke despite the user
// "owning" a shield.
const FREE_SHIELD_DAILY = 1;
const FREE_SHIELD_MAX = 3;

exports.claimFreeStreakShield = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const today = new Date().toISOString().split('T')[0];

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }
      const userData = userDoc.data() || {};
      const claimedToday = userData.last_free_shield_claim === today;
      const currentShields = userData.streak_shields || 0;

      if (claimedToday) {
        return { claimed: false, alreadyClaimedToday: true, shields: currentShields };
      }
      if (currentShields >= FREE_SHIELD_MAX) {
        return { claimed: false, atCap: true, shields: currentShields };
      }

      const newShields = currentShields + 1;
      transaction.update(userRef, {
        streak_shields: newShields,
        last_free_shield_claim: today,
        _ts_streak_shields: admin.firestore.FieldValue.serverTimestamp(),
      });
      return { claimed: true, shields: newShields };
    });

    functions.logger.info('claimFreeStreakShield', {
      userId, claimed: result.claimed, shields: result.shields,
    });
    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('claimFreeStreakShield error', error);
    throw new functions.https.HttpsError('internal', 'Error al reclamar escudo gratis');
  }
});

exports.completeLesson = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);

  const { lessonId, correctCount, perfect, totalQuestions } = data;

  if (!lessonId || typeof lessonId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'lessonId requerido');
  }

  // lessonId is interpolated into a Firestore doc id — only safe characters.
  if (!/^[A-Za-z0-9_-]{1,100}$/.test(lessonId)) {
    throw new functions.https.HttpsError('invalid-argument', 'lessonId invalido');
  }

  // Server-authoritative rewards: ignore client-proposed values
  const xp = Math.min(getLessonXp(lessonId), MAX_XP_PER_LESSON);

  if (xp === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'xp debe ser > 0');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${userId}_${lessonId}`);
  const dailyXpRef = getDailyXpDocRef(userId);
  const dailyGemsRef = gems.getDailyGemsDocRef(userId);
  const dailySpRef = sagenpass.getDailySpDocRef(userId);
  const leaderboardRef = admin.firestore().doc(`leaderboards/${userId}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc, dailyXpDoc, dailyGemsDoc, dailySpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
        transaction.get(dailyXpRef),
        transaction.get(dailyGemsRef),
        transaction.get(dailySpRef),
      ]);

      if (logDoc.exists) {
        return {
          success: true, duplicate: true,
          xp: { added: 0, totalXp: userDoc.data()?.learning_total_xp || 0 },
          level: { current: userDoc.data()?.learning_level || 1, leveledUp: false },
          streak: {
            current: userDoc.data()?.currentStreak || 0,
            longest: userDoc.data()?.longestStreak || 0,
            broken: false,
            previousStreak: userDoc.data()?.currentStreak || 0,
          },
          lessonsCompleted: userDoc.data()?.lessonsCompleted || 0,
          gems: { added: 0, balance: userDoc.data()?.learning_gems || 0 },
          sagenPass: null,
        };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};

      const currentStreak = userData.currentStreak || 0;
      const longestStreak = userData.longestStreak || 0;

      // Server-authoritative XP: base lesson reward scaled by the streak
      // multiplier (mirrors the client's xpForLesson). Boost multipliers are
      // NOT applied here — boosts have no server-side effect (see NUEVO-10).
      const effectiveXp = Math.min(
        Math.round(xp * getStreakMultiplier(currentStreak)),
        MAX_XP_PER_LESSON,
      );

      const dailyData = dailyXpDoc.data() || {};
      const xpEarnedToday = dailyData.total || 0;
      const { cappedXp } = computeCappedXp(xpEarnedToday, effectiveXp);

      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;
      const newTotalXp = currentTotalXp + cappedXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;
      const leveledUp = newLevel > currentLevel;
      const lastActivity = userData.streak_last_activity;

      // NUEVO-12 (race fix): a completed lesson is only ONE of the two daily
      // activity events. The dedicated incrementStreak callable is the single
      // owner of the freeze-vs-break decision for a missed day because it
      // honors streak shields. So completeLesson must NOT break the streak on
      // its own; if it did and incremented/exposed lastActivity first, the
      // concurrent incrementStreak would see "already checked in today" and
      // the user would lose their streak AND their shields.
      //
      // => For today (already active) or a consecutive day (yesterday) we
      //    keep/increment as before. For a gap of 2+ days we do nothing to the
      //    streak here and leave lastActivity stale, so incrementStreak (which
      //    always runs in the same frame via checkIn) decides freeze-or-break
      //    atomically. Both callables now commute regardless of commit order.
      let streakToSet = currentStreak;
      let longestToSet = longestStreak;
      let updateStreakFields = true;

      const now = new Date();
      const today = now.toISOString().split('T')[0];

      if (!lastActivity) {
        streakToSet = 1;
        longestToSet = Math.max(longestStreak, 1);
      } else {
        const lastDate = lastActivity.toDate ? lastActivity.toDate() : new Date(lastActivity);
        const lastStr = lastDate.toISOString().split('T')[0];

        if (lastStr === today) {
          // Already active today — keep the current streak.
          streakToSet = currentStreak;
        } else {
          const yesterday = new Date(now);
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayStr = yesterday.toISOString().split('T')[0];

          if (lastStr === yesterdayStr) {
            streakToSet = currentStreak + 1;
            longestToSet = Math.max(longestStreak, streakToSet);
          } else {
            // Gap of 2+ days: hand the decision to incrementStreak. Do not
            // break the streak and do not mark activity here, otherwise the
            // shield freeze in incrementStreak becomes a coin flip.
            updateStreakFields = false;
          }
        }
      }

      const lessonsCompleted = (userData.lessonsCompleted || 0) + 1;

      // Server-authoritative gems for the lesson: correct answers, perfect
      // bonus and first-lesson-of-day bonus, all capped by the daily gem cap.
      // correctCount/perfect are NOT trusted blindly: the client must report a
      // consistent answer set (totalQuestions > 0, correctCount <= totalQuestions)
      // for the perfect bonus and SP to apply. Inconsistent or missing claims
      // are treated as a non-perfect lesson (anti-farm).
      const gemsDailyData = dailyGemsDoc.data() || {};
      // Strict integer types only: strings like '15x' or fractional values are
      // rejected (anti-farm). The client sends plain ints.
      const rawCorrect = Number.isInteger(correctCount)
        ? correctCount
        : NaN;
      const rawTotal = Number.isInteger(totalQuestions) && totalQuestions > 0
        ? totalQuestions
        : NaN;
      const reportedTotal = Number.isFinite(rawTotal) && rawTotal > 0
        ? Math.min(rawTotal, 20)
        : 0;
      const reportedCorrect = Number.isFinite(rawCorrect)
        ? Math.min(Math.max(rawCorrect, 0), reportedTotal || 20)
        : 0;
      // "perfect" requires a claim that is actually consistent: the RAW correct
      // count must equal the RAW total (clamping would mask impossible claims
      // like 15/10). NUEVO-fix: el clamp anti-farm (a 20 preguntas) afecta
      // SOLO al cálculo de gemas; antes una lección legítima de >20 preguntas
      // (p.ej. 30/30) daba `30 !== 20` y perdía el bonus perfect + SP.
      const consistentPerfect = perfect === true &&
        Number.isFinite(rawTotal) &&
        Number.isFinite(rawCorrect) &&
        rawCorrect === rawTotal &&
        rawCorrect > 0;
      const correct = reportedCorrect;
      const baseGems = correct * gems.GEM_REWARDS.lesson_correct;
      const perfectGems = consistentPerfect ? gems.GEM_REWARDS.perfect_bonus : 0;
      let firstOfDayGems = 0;
      if (!gemsDailyData.first_lesson_of_day) {
        firstOfDayGems = gems.GEM_REWARDS.first_lesson_of_day;
      }
      const requestedGems = baseGems + perfectGems + firstOfDayGems;
      const gemCredit = gems.applyGemCredit(
        transaction, userRef, userData,
        dailyGemsRef, gemsDailyData,
        'lesson', requestedGems,
      );
      if (firstOfDayGems > 0) {
        // NUEVO-fix: sellar el bonus "primera lección del día" SOLO si el cap
        // diario de gemas NO recortó el pago completo (mismo patrón full-payment
        // que los sellos de logros/gemas). Antes se sellaba incondicionalmente:
        // con el cap agotado y requested=50 acreditando 5, el bonus de 10 gemas
        // se perdía para siempre.
        if (!gemCredit.dailyCapped && gemCredit.gemsAdded >= firstOfDayGems) {
          transaction.set(dailyGemsRef, { first_lesson_of_day: true }, { merge: true });
        }
      }

      // SAGEN PASS SP — awarded from a server-verified action only.
      const lessonSp = sagenpass.SP_REWARDS.lesson;
      const perfectSp = consistentPerfect ? sagenpass.SP_REWARDS.perfect_lesson : 0;
      const spCredit = sagenpass.applySagenPassSp({
        transaction,
        userRef,
        userData,
        dailySpRef,
        dailySpData: dailySpDoc.data() || {},
        reason: 'lesson',
        spToAdd: lessonSp + perfectSp,
      });

      const updateFields = {
        learning_total_xp: newTotalXp,
        learning_level: newLevel,
        lessonsCompleted,
        _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
        _ts_learning_level: admin.firestore.FieldValue.serverTimestamp(),
      };
      if (updateStreakFields) {
        updateFields.currentStreak = streakToSet;
        updateFields.longestStreak = longestToSet;
        updateFields.streak_last_activity = admin.firestore.FieldValue.serverTimestamp();
        updateFields._ts_currentStreak = admin.firestore.FieldValue.serverTimestamp();
        updateFields._ts_longestStreak = admin.firestore.FieldValue.serverTimestamp();
      }
      transaction.update(userRef, updateFields);

      transaction.set(dailyXpRef, {
        total: admin.firestore.FieldValue.increment(cappedXp),
        completeLesson: admin.firestore.FieldValue.increment(cappedXp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      transaction.set(leaderboardRef, {
        firstName: userData.firstName || '',
        lastName: userData.lastName || '',
        photoUrl: userData.photoUrl || '',
        learning_total_xp: newTotalXp,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      // NUEVO-fix: sellar la lección como completada SOLO si el XP esperado se
      // acreditó COMPLETO (mismo patrón full-payment que logros/gemas). Antes se
      // sellaba aunque el cap diario (500) recortara el XP a 0, con clave
      // `userId_lessonId` sin día: el replay al día siguiente era `duplicate` y
      // el XP de ESA lección se perdía permanentemente. Ahora, si el cap recorta,
      // la lección queda abierta y el resto se paga otro día.
      if (cappedXp === effectiveXp) {
        transaction.create(logRef, {
          userId,
          type: 'completeLesson',
          lessonId,
          xpAdded: cappedXp,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {
        success: true,
        duplicate: false,
        xp: { added: cappedXp, totalXp: newTotalXp },
        level: { current: newLevel, leveledUp },
        streak: {
          current: streakToSet,
          longest: longestToSet,
          broken: streakToSet === 1 && currentStreak > 1,
          previousStreak: currentStreak,
        },
        lessonsCompleted,
        gems: {
          added: gemCredit.gemsAdded,
          balance: gemCredit.balance,
          dailyCapped: gemCredit.dailyCapped,
          perfect: perfectGems > 0,
          firstOfDay: firstOfDayGems > 0,
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

    functions.logger.info('completeLesson', {
      userId, lessonId, duplicate: result.duplicate,
      xpAdded: result.xp.added,
      level: result.level.current, streak: result.streak.current,
      gems: result.gems && result.gems.added,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('completeLesson error', error);
    throw new functions.https.HttpsError('internal', 'Error al completar leccion');
  }
});


