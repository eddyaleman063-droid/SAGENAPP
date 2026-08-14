const admin = require('firebase-admin');

// ══════════════════════════════════════════════════════════════════
// SAGEN PASS SP — shared, server-authoritative logic
// SP is only awarded from within server-verified actions
// (completeLesson / claimDailyChest / claimAdReward). There is NO
// free-form "earn SP" callable: a modified client cannot farm SP.
// ══════════════════════════════════════════════════════════════════

// Server-authoritative Sagen Pass SP per reason.
// The client can NOT specify the amount or a custom reason.
const SP_REWARDS = {
  lesson: 10,
  daily_chest: 5,
  ad_reward: 3,
  perfect_lesson: 15,
};

// Max Sagen Pass SP earnable per day (anti-farm).
const MAX_DAILY_SP = 100;

function getDailySpDocRef(userId) {
  const today = new Date().toISOString().split('T')[0];
  return admin.firestore().doc(`daily_sp_sources/${userId}_${today}`);
}

/**
 * Applies Sagen Pass SP inside an existing transaction.
 * The amount is decided here from `spToAdd` (which the caller derives
 * from SP_REWARDS), never from the client.
 * Returns the SP result object, or null when the daily cap is exhausted.
 */
function applySagenPassSp({ transaction, userRef, userData, dailySpRef, dailySpData, reason, spToAdd }) {
  // SAGEN PASS holders earn unlimited SP (no daily cap).
  const isPassHolder = userData.sagen_pass_active === true;
  const spEarnedToday = dailySpData.total || 0;
  const remainingDailySp = isPassHolder
    ? spToAdd
    : Math.max(0, MAX_DAILY_SP - spEarnedToday);
  const cappedSp = Math.min(spToAdd, remainingDailySp);

  if (cappedSp <= 0) {
    return null;
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
}

module.exports = {
  SP_REWARDS,
  MAX_DAILY_SP,
  getDailySpDocRef,
  applySagenPassSp,
};
