const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');

// ══════════════════════════════════════════════════════════════════
// ECONOMIC FUNCTIONS — Server-authoritative mutations
// All economic fields (donations, XP, streak, level) MUST go through
// these functions. Direct client writes are blocked by Firestore rules.
// ══════════════════════════════════════════════════════════════════

const MAX_XP_PER_LESSON = 100;
const MAX_DAILY_XP = 500;

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
        return { success: true, duplicate: true, totalDonated: userDoc.data()?.totalDonated || 0 };
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
          totalDonated: (userData.totalDonated || 0) + amount,
          _ts_totalDonated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        transaction.update(userRef, {
          totalDonated: (userData.totalDonated || 0) + amount,
          _ts_totalDonated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      transaction.create(logRef, {
        userId,
        type: 'donation',
        method,
        amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, totalDonated: (userData.totalDonated || 0) + amount };
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

  const { lessonId } = data;

  if (!lessonId || typeof lessonId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'lessonId requerido');
  }

  // Server-authoritative rewards: ignore client-proposed values
  const rewards = LESSON_REWARDS[lessonId] || LESSON_REWARDS.default;
  const xp = Math.min(rewards.xp, MAX_XP_PER_LESSON);

  if (xp === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'xp debe ser > 0');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const logRef = admin.firestore().doc(`transaction_logs/${userId}_${lessonId}`);
  const dailyXpRef = getDailyXpDocRef(userId);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc, dailyXpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
        transaction.get(dailyXpRef),
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
        };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};

      const dailyData = dailyXpDoc.data() || {};
      const xpEarnedToday = dailyData.total || 0;
      const { cappedXp } = computeCappedXp(xpEarnedToday, xp);

      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;
      const newTotalXp = currentTotalXp + cappedXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;
      const leveledUp = newLevel > currentLevel;

      const currentStreak = userData.currentStreak || 0;
      const longestStreak = userData.longestStreak || 0;
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
      };
    });

    functions.logger.info('completeLesson', {
      userId, lessonId, duplicate: result.duplicate,
      xpAdded: result.xp.added,
      level: result.level.current, streak: result.streak.current,
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('completeLesson error', error);
    throw new functions.https.HttpsError('internal', 'Error al completar leccion');
  }
});


