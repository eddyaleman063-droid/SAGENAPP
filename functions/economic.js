const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
const gems = require('./gems');
const sagenpass = require('./sagenpass');

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
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesion');
  }

  const { amount, method, idempotencyKey } = data;
  if (typeof amount !== 'number' || amount <= 0) {
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
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesion');
  }

  const { amount, method, idempotencyKey } = data;
  if (typeof amount !== 'number' || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'El monto debe ser mayor a 0');
  }
  if (amount > MAX_DONATION_AMOUNT) {
    throw new functions.https.HttpsError('invalid-argument', `El monto excede el límite de ${MAX_DONATION_AMOUNT}`);
  }
  if (!method || typeof method !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'method requerido');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const key = idempotencyKey || `donation_${userId}_${Date.now()}`;
  const logRef = admin.firestore().doc(`transaction_logs/${key}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
      ]);

      if (logDoc.exists) {
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
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesion');
  }

  const { reason, lessonId, idempotencyKey } = data;

  if (!idempotencyKey || typeof idempotencyKey !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'idempotencyKey requerido');
  }

  // Server-authoritative: ignore client amount, use predefined reward per reason
  const reasonKey = reason || 'unknown';
  const reward = REASON_REWARDS[reasonKey] || DEFAULT_REASON_REWARD;
  const xp = reward.xp;

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${idempotencyKey}`);
  const today = new Date().toISOString().split('T')[0];
  const dailyXpRef = admin.firestore().doc(`daily_xp_sources/${userId}_${today}`);
  const leaderboardRef = admin.firestore().doc(`leaderboards/${userId}`);

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
        [reason || 'unknown']: admin.firestore.FieldValue.increment(cappedXp),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      transaction.set(leaderboardRef, {
        firstName: userData.firstName || '',
        lastName: userData.lastName || '',
        photoUrl: userData.photoUrl || '',
        learning_total_xp: newTotalXp,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

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
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesion');
  }

  const { freezeUsed } = data;

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

        const yesterday = new Date(now);
        yesterday.setDate(yesterday.getDate() - 1);
        const yesterdayStr = yesterday.toISOString().split('T')[0];

        if (lastStr !== yesterdayStr) {
          // Server-side freeze decision (NUEVO-09): a freeze is only honored
          // if the user actually owns streak shields. The server verifies and
          // debits them; the client's freezeUsed is never trusted on its own.
          if (freezeUsed === true) {
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
            // Client asked for a freeze but owns no shields: the freeze is
            // denied and the streak breaks (server-authoritative).
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
              freezeDenied: true,
            };
          }
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

      return { success: true, currentStreak: newStreak, longestStreak: newLongest, alreadyCheckedIn: false };
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

exports.completeLesson = functions.runWith({ maxInstances: 10 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesion');
  }

  const { lessonId, correctCount, perfect, totalQuestions } = data;

  if (!lessonId || typeof lessonId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'lessonId requerido');
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
      let streakToSet = currentStreak;
      let longestToSet = longestStreak;

      const now = new Date();
      const today = now.toISOString().split('T')[0];

      if (!lastActivity) {
        streakToSet = 1;
        longestToSet = Math.max(longestStreak, 1);
      } else {
        const lastDate = lastActivity.toDate ? lastActivity.toDate() : new Date(lastActivity);
        const lastStr = lastDate.toISOString().split('T')[0];

        if (lastStr !== today) {
          const yesterday = new Date(now);
          yesterday.setDate(yesterday.getDate() - 1);
          const yesterdayStr = yesterday.toISOString().split('T')[0];

          if (lastStr === yesterdayStr) {
            streakToSet = currentStreak + 1;
            longestToSet = Math.max(longestStreak, streakToSet);
          } else {
            streakToSet = 1;
            longestToSet = Math.max(longestStreak, currentStreak);
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
      const rawCorrect = parseInt(correctCount, 10);
      const rawTotal = parseInt(totalQuestions, 10);
      const reportedTotal = Number.isFinite(rawTotal) && rawTotal > 0
        ? Math.min(rawTotal, 20)
        : 0;
      const reportedCorrect = Number.isFinite(rawCorrect)
        ? Math.min(Math.max(rawCorrect, 0), reportedTotal || 20)
        : 0;
      // "perfect" requires a claim that is actually consistent: the raw
      // correct count must equal the reported total (clamping would mask
      // impossible claims like 15/10).
      const consistentPerfect = perfect === true &&
        reportedTotal > 0 &&
        Number.isFinite(rawCorrect) &&
        rawCorrect === reportedTotal &&
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
        transaction.set(dailyGemsRef, { first_lesson_of_day: true }, { merge: true });
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

      transaction.update(userRef, {
        learning_total_xp: newTotalXp,
        learning_level: newLevel,
        currentStreak: streakToSet,
        longestStreak: longestToSet,
        streak_last_activity: admin.firestore.FieldValue.serverTimestamp(),
        lessonsCompleted,
        _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
        _ts_learning_level: admin.firestore.FieldValue.serverTimestamp(),
        _ts_currentStreak: admin.firestore.FieldValue.serverTimestamp(),
        _ts_longestStreak: admin.firestore.FieldValue.serverTimestamp(),
      });

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

      transaction.create(logRef, {
        userId,
        type: 'completeLesson',
        lessonId,
        xpAdded: cappedXp,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

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


