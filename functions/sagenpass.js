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

// ══════════════════════════════════════════════════════════════════
// SEASONS — server-authoritative season window for the Sagen Pass.
// A season begins at `sagen_pass_season_start` (serverTimestamp) and lasts
// SEASON_DURATION_DAYS. When an economic transaction detects that the window
// expired (now >= start + duration), the season rotates: fresh level 1, SP 0,
// EMPTY claimed list and EMPTY chest bank. This prevents `claimedLevels` (and
// un-rolled bank chests) from leaking across seasons — the client would
// otherwise inherit a previous season's claims right after its local reset.
// ══════════════════════════════════════════════════════════════════
const SEASON_DURATION_DAYS = 90;
const SEASON_DURATION_MS = SEASON_DURATION_DAYS * 24 * 60 * 60 * 1000;

function parseSeasonStartMs(raw) {
  if (raw == null) return null;
  if (raw.toDate) return raw.toDate().getTime();
  if (raw._seconds != null) return raw._seconds * 1000;
  if (typeof raw === 'number') return raw;
  if (typeof raw === 'string') {
    const t = Date.parse(raw);
    return Number.isNaN(t) ? null : t;
  }
  return null;
}

/**
 * Resolves the effective Sagen Pass season state for [userData].
 * Returns:
 *   - rotated: true when the stored season expired (or never started) and the
 *     effective state is a fresh season beginning at now
 *   - seasonStartMs / seasonStartISO: the effective season start
 *   - level / sp / claimed: the effective values for that season
 */
function resolveSeason(userData, nowMs) {
  const storedStart = parseSeasonStartMs(userData && userData.sagen_pass_season_start);
  const expired =
    storedStart != null &&
    nowMs - storedStart >= SEASON_DURATION_MS;

  if (expired) {
    // The window expired: the effective state is a fresh season at `now`.
    return {
      rotated: true,
      seasonStartMs: nowMs,
      seasonStartISO: new Date(nowMs).toISOString(),
      level: 1,
      sp: 0,
      claimed: [],
    };
  }

  const engaged = !!(userData && (
    (userData.sagen_pass_level || 0) > 1 ||
    (userData.sagen_pass_sp || 0) > 0 ||
    (Array.isArray(userData.sagen_pass_claimed) && userData.sagen_pass_claimed.length > 0)
  ));

  // No stored start: users who never started a season (no claims yet) begin a
  // fresh one at `now`. Users with existing progress but no start (data written
  // before season tracking) keep their earned level/SP/claims; the season clock
  // simply starts now without a destructive reset.
  const seasonStartMs = storedStart != null ? storedStart : nowMs;

  if (storedStart == null && !engaged) {
    return {
      rotated: true,
      seasonStartMs: seasonStartMs,
      seasonStartISO: new Date(seasonStartMs).toISOString(),
      level: 1,
      sp: 0,
      claimed: [],
    };
  }

  return {
    rotated: false,
    seasonStartMs: seasonStartMs,
    seasonStartISO: new Date(seasonStartMs).toISOString(),
    level: (userData && userData.sagen_pass_level) || 1,
    sp: (userData && userData.sagen_pass_sp) || 0,
    claimed: Array.isArray(userData && userData.sagen_pass_claimed)
      ? userData.sagen_pass_claimed
      : [],
  };
}

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

  // Season rotation: if the current season window expired, the SP accumulates
  // into a FRESH season (level 1, no previous claims, empty bank).
  const season = resolveSeason(userData, Date.now());

  // SP required per level: 50 + (level - 1) * 10
  const spForLevel = (level) => 50 + (level - 1) * 10;

  let newSP = season.sp + cappedSp;
  let newLevel = season.level;
  const maxLevel = 50;

  while (newSP >= spForLevel(newLevel) && newLevel < maxLevel) {
    newSP -= spForLevel(newLevel);
    newLevel++;
  }

  if (newLevel >= maxLevel) {
    newSP = 0;
  }

  const updates = {
    sagen_pass_sp: newSP,
    sagen_pass_level: newLevel,
    _ts_sagen_pass: admin.firestore.FieldValue.serverTimestamp(),
  };
  if (season.rotated) {
    updates.sagen_pass_claimed = [];
    updates.sagen_pass_chests = [];
    updates.sagen_pass_season_start = admin.firestore.FieldValue.serverTimestamp();
  }

  transaction.update(userRef, updates);

  transaction.set(dailySpRef, {
    total: admin.firestore.FieldValue.increment(cappedSp),
    [reason]: admin.firestore.FieldValue.increment(cappedSp),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  return {
    success: true,
    sp: newSP,
    level: newLevel,
    leveledUp: newLevel > season.level,
    spAdded: cappedSp,
    dailyCapped: isPassHolder ? false : cappedSp < spToAdd,
    premium: isPassHolder,
    seasonStarted: season.rotated,
  };
}

module.exports = {
  SP_REWARDS,
  MAX_DAILY_SP,
  SEASON_DURATION_DAYS,
  getDailySpDocRef,
  applySagenPassSp,
  resolveSeason,
};
