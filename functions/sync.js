const functions = require('firebase-functions');
const admin = require('firebase-admin');

const MAX_DAILY_XP = 500;

/**
 * Accepts batched offline lesson completions and writes atomically.
 * Accepts: { completions: [{ lessonId, stageId, xpEarned, completedAt }] }
 * Returns: { synced: number, duplicates: number, results: [...] }
 */
exports.syncLessonCompletions = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const { completions } = data;
  if (!Array.isArray(completions) || completions.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Se requiere un arreglo de completions');
  }

  if (completions.length > 20) {
    throw new functions.https.HttpsError('invalid-argument', 'Máximo 20 completions por lote');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);
  const MAX_XP_PER_LESSON = 100;
  const SERVER_XP_PER_LESSON = 15;
  const todayStr = new Date().toISOString().split('T')[0];
  const dailyXpRef = admin.firestore().doc(`daily_xp_sources/${userId}_${todayStr}`);

  // Deduplicate by lessonId (keep first occurrence)
  const seen = new Set();
  const uniqueCompletions = [];
  for (const c of completions) {
    if (!seen.has(c.lessonId)) {
      seen.add(c.lessonId);
      uniqueCompletions.push(c);
    }
  }

  const results = [];
  let totalXp = 0;

  for (const c of uniqueCompletions) {
    if (!c.lessonId || typeof c.lessonId !== 'string') {
      results.push({ lessonId: c.lessonId, success: false, error: 'lessonId inválido' });
      continue;
    }
    // Server-authoritative: ignore client-submitted xpEarned
    const xp = Math.min(SERVER_XP_PER_LESSON, MAX_XP_PER_LESSON);
    totalXp += xp;
  }

  if (totalXp === 0) {
    return { synced: 0, duplicates: completions.length, results };
  }

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, dailyXpDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(dailyXpRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const currentTotalXp = userData.learning_total_xp || 0;
      const currentLevel = userData.learning_level || 1;

      // Daily XP cap enforcement
      const dailyXpSourceData = dailyXpDoc.data() || {};
      const dailyLessonXp = dailyXpSourceData.lesson || 0;
      const remainingXpCap = Math.max(0, MAX_DAILY_XP - dailyLessonXp);
      const cappedTotalXp = Math.min(totalXp, remainingXpCap);

      const newTotalXp = currentTotalXp + cappedTotalXp;
      const newLevel = Math.floor(newTotalXp / 100) + 1;
      const leveledUp = newLevel > currentLevel;

      const logRefs = uniqueCompletions.map(c =>
        admin.firestore().doc(`transaction_logs/${userId}_${c.lessonId}`)
      );
      const logDocs = await Promise.all(logRefs.map(r => transaction.get(r)));

      let syncedCount = 0;
      let duplicateCount = 0;
      let cappedXpAccum = 0;

      for (let i = 0; i < uniqueCompletions.length; i++) {
        if (logDocs[i].exists) {
          results.push({ lessonId: uniqueCompletions[i].lessonId, success: true, duplicate: true });
          duplicateCount++;
          continue;
        }

        const c = uniqueCompletions[i];
        // Server-authoritative: ignore client-submitted xpEarned
        const xp = Math.min(SERVER_XP_PER_LESSON, MAX_XP_PER_LESSON);

        // Cap individual lesson XP against remaining daily XP cap
        const remainingXpForLesson = Math.max(0, cappedTotalXp - cappedXpAccum);
        const actualLessonXp = Math.min(xp, remainingXpForLesson);
        cappedXpAccum += actualLessonXp;

        transaction.create(logRefs[i], {
          userId,
          type: 'completeLesson',
          lessonId: c.lessonId,
          stageId: c.stageId || null,
          xpAdded: actualLessonXp,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        results.push({ lessonId: c.lessonId, success: true, duplicate: false });
        syncedCount++;
      }

      if (syncedCount > 0) {
        // Update daily XP source tracking
        const newXpSourceData = { ...dailyXpSourceData };
        newXpSourceData.lesson = dailyLessonXp + cappedTotalXp;
        transaction.set(dailyXpRef, newXpSourceData, { merge: true });

        transaction.update(userRef, {
          learning_total_xp: newTotalXp,
          learning_level: newLevel,
          lessonsCompleted: (userData.lessonsCompleted || 0) + syncedCount,
          _ts_learning_total_xp: admin.firestore.FieldValue.serverTimestamp(),
          _ts_learning_level: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    return {
      synced: results.filter(r => r.success && !r.duplicate).length,
      duplicates: results.filter(r => r.duplicate).length,
      results,
    };
  } catch (e) {
    functions.logger.error('syncLessonCompletions error', e);
    throw new functions.https.HttpsError('internal', 'Error de sincronización');
  }
});
