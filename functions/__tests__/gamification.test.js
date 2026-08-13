/**
 * Tests for gamification.js — Server-authoritative claims.
 * Covers: claimDailyChest, earnSagenPassSP, claimSagenPassReward,
 * getSagenPassSeason, rollChestDrop, claimAdReward.
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const admin = require('firebase-admin');
const gamification = require('../gamification');

const AUTH_UID = 'test-gamification-123';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid } });
const NO_AUTH = {};

beforeEach(() => {
  admin._resetFirestore();
});

function setUserDoc(uid, data) {
  admin._setDoc(`users/${uid}`, data);
}

function today() {
  return new Date().toISOString().split('T')[0];
}

describe('claimDailyChest', () => {
  test('claims chest with server XP when not claimed today', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 100, learning_level: 1 });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.success).toBe(true);
    expect(result.xp).toBe(10);
    expect(result.newLevel).toBe(2);
  });

  test('returns alreadyClaimed if claimed today', async () => {
    setUserDoc(AUTH_UID, {
      learning_total_xp: 100,
      learning_level: 1,
      last_daily_chest: today(),
    });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.alreadyClaimed).toBe(true);
  });

  test('credits server-authoritative gems when claiming the chest', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 100, learning_level: 1, learning_gems: 10 });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.gems.added).toBe(5);
    expect(result.gems.balance).toBe(15);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.claimDailyChest({}, NO_AUTH)).rejects.toThrow();
  });
});

describe('earnSagenPassSP', () => {
  test('awards server-authoritative SP for lesson reason', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    const result = await gamification.earnSagenPassSP({ reason: 'lesson' }, makeContext());
    expect(result.success).toBe(true);
    expect(result.spAdded).toBe(10);
    expect(result.sp).toBe(10);
    expect(result.level).toBe(1);
    expect(result.leveledUp).toBe(false);
  });

  test('ignores client-provided amount entirely', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    const result = await gamification.earnSagenPassSP({ amount: 50, reason: 'lesson' }, makeContext());
    expect(result.spAdded).toBe(10);
    expect(result.sp).toBe(10);
  });

  test('uses default reward for unknown reason', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    const result = await gamification.earnSagenPassSP({ reason: 'unknown_reason' }, makeContext());
    expect(result.spAdded).toBe(5);
  });

  test('level ups when SP threshold is reached', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 45, sagen_pass_level: 1 });
    const result = await gamification.earnSagenPassSP({ reason: 'lesson' }, makeContext());
    expect(result.spAdded).toBe(10);
    expect(result.level).toBe(2);
    expect(result.leveledUp).toBe(true);
    // 45 + 10 = 55, level cost is 50 → 5 SP remainder
    expect(result.sp).toBe(5);
  });

  test('enforces daily SP cap', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today()}`, { total: 95 });
    const result = await gamification.earnSagenPassSP({ reason: 'lesson' }, makeContext());
    expect(result.spAdded).toBe(5);
    expect(result.dailyCapped).toBe(true);
    expect(result.sp).toBe(5);
  });

  test('rejects when daily SP cap is exhausted', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today()}`, { total: 100 });
    await expect(
      gamification.earnSagenPassSP({ reason: 'lesson' }, makeContext())
    ).rejects.toThrow(/Limite diario de SP/);
  });

  test('pass holders earn unlimited SP beyond the daily cap', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
      sagen_pass_active: true,
    });
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today()}`, { total: 100 });
    const result = await gamification.earnSagenPassSP({ reason: 'lesson' }, makeContext());
    expect(result.spAdded).toBe(10);
    expect(result.sp).toBe(10);
    expect(result.dailyCapped).toBe(false);
    expect(result.premium).toBe(true);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.earnSagenPassSP({ reason: 'lesson' }, NO_AUTH)).rejects.toThrow();
  });
});

describe('claimSagenPassReward', () => {
  test('claims unclaimed level reward', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 3, sagen_pass_claimed: [1] });
    const result = await gamification.claimSagenPassReward({ level: 2 }, makeContext());
    expect(result.success).toBe(true);
    expect(result.claimed).toBe(2);
    expect(result.claimedLevels).toEqual([1, 2]);
  });

  test('returns alreadyClaimed for claimed level', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 3, sagen_pass_claimed: [1, 2] });
    const result = await gamification.claimSagenPassReward({ level: 2 }, makeContext());
    expect(result.alreadyClaimed).toBe(true);
  });

  test('rejects level above current level', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 1, sagen_pass_claimed: [] });
    await expect(
      gamification.claimSagenPassReward({ level: 5 }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.claimSagenPassReward({ level: 1 }, NO_AUTH)).rejects.toThrow();
  });
});

describe('getSagenPassSeason', () => {
  test('returns server-side season data', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 4,
      sagen_pass_sp: 9,
      sagen_pass_claimed: [1, 2],
    });
    const result = await gamification.getSagenPassSeason({}, makeContext());
    expect(result.level).toBe(4);
    expect(result.sp).toBe(9);
    expect(result.claimed).toEqual([1, 2]);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.getSagenPassSeason({}, NO_AUTH)).rejects.toThrow();
  });
});

describe('claimAdReward', () => {
  test('claims ad reward up to daily limit of 5', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await gamification.claimAdReward({}, makeContext());
    expect(result.success).toBe(true);
    expect(result.xp).toBe(50);
    expect(result.dailyCount).toBe(1);
  });

  test('returns limitReached after 5 ads', async () => {
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      last_ad_reward_date: today(),
      daily_ad_count: 5,
    });
    const result = await gamification.claimAdReward({}, makeContext());
    expect(result.limitReached).toBe(true);
  });

  test('credits gems when claiming an ad reward', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1, learning_gems: 0 });
    const result = await gamification.claimAdReward({}, makeContext());
    expect(result.gems.added).toBe(2);
    expect(result.gems.balance).toBe(2);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.claimAdReward({}, NO_AUTH)).rejects.toThrow();
  });
});

describe('rollChestDrop', () => {
  test('rolls XP reward for valid chest type', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      streak_shields: 0,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await gamification.rollChestDrop({ chestType: 'bronze' }, makeContext());
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.xp).toBeGreaterThanOrEqual(15);
    expect(result.xp).toBeLessThanOrEqual(25);
  });

  test('rejects invalid chest type', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    await expect(
      gamification.rollChestDrop({ chestType: 'diamond' }, makeContext())
    ).rejects.toThrow();
  });

  test('credits gems from chest drop based on server formula', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      streak_shields: 0,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      learning_gems: 0,
    });
    const result = await gamification.rollChestDrop({ chestType: 'bronze' }, makeContext());
    expect(result.gems.added).toBeGreaterThanOrEqual(5);
    expect(result.gems.added).toBeLessThanOrEqual(8);
    expect(result.gems.balance).toBe(result.gems.added);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.rollChestDrop({ chestType: 'bronze' }, NO_AUTH)).rejects.toThrow();
  });
});
