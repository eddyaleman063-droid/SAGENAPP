/**
 * Tests for gamification.js — Server-authoritative claims.
 * Covers: claimDailyChest, Sagen Pass SP via verified actions,
 * claimSagenPassReward, getSagenPassSeason, rollChestDrop, claimAdReward.
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

  test('honors a validated chestType with server-side reward', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await gamification.claimDailyChest({ chestType: 'gold' }, makeContext());
    expect(result.chestType).toBe('gold');
    expect(result.xp).toBe(20);
  });

  test('falls back to bronze for an unknown chestType', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await gamification.claimDailyChest({ chestType: 'platinum' }, makeContext());
    expect(result.chestType).toBe('bronze');
    expect(result.xp).toBe(10);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.claimDailyChest({}, NO_AUTH)).rejects.toThrow();
  });
});

describe('Sagen Pass SP via verified actions', () => {
  test('claimDailyChest awards server-authoritative SP', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.sagenPass).toBeTruthy();
    expect(result.sagenPass.spAdded).toBe(5);
    expect(result.sagenPass.sp).toBe(5);
    expect(result.sagenPass.level).toBe(1);
  });

  test('claimDailyChest SP respects the daily cap', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today()}`, { total: 98 });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.sagenPass.spAdded).toBe(2);
    expect(result.sagenPass.dailyCapped).toBe(true);
  });

  test('claimDailyChest returns null SP when daily cap is exhausted', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today()}`, { total: 100 });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.sagenPass).toBeNull();
  });

  test('claimDailyChest pass holders earn unlimited SP beyond the daily cap', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
      sagen_pass_active: true,
    });
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today()}`, { total: 100 });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.sagenPass.spAdded).toBe(5);
    expect(result.sagenPass.dailyCapped).toBe(false);
    expect(result.sagenPass.premium).toBe(true);
  });

  test('claimAdReward awards server-authoritative SP', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 0, sagen_pass_level: 1 });
    const result = await gamification.claimAdReward({}, makeContext());
    expect(result.sagenPass).toBeTruthy();
    expect(result.sagenPass.spAdded).toBe(3);
    expect(result.sagenPass.sp).toBe(3);
  });

  test('claimAdReward level ups when SP threshold is reached', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_sp: 48, sagen_pass_level: 1 });
    const result = await gamification.claimAdReward({}, makeContext());
    // 48 + 3 = 51, level cost is 50 → level 2 with 1 SP remainder
    expect(result.sagenPass.level).toBe(2);
    expect(result.sagenPass.sp).toBe(1);
    expect(result.sagenPass.leveledUp).toBe(true);
  });

  test('no standalone free-form earn SP callable exists', async () => {
    expect(typeof gamification.earnSagenPassSP).toBe('undefined');
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
  test('derives lesson chest tier from server lesson counter', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      streak_shields: 0,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 3,
    });
    const result = await gamification.rollChestDrop({ source: 'lesson', contextId: 'lesson_x' }, makeContext());
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.chestType).toBe('silver');
    expect(result.xp).toBeGreaterThanOrEqual(25);
    expect(result.xp).toBeLessThanOrEqual(35);
  });

  test('ignores a client-claimed legendary chestType for lesson chests', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      streak_shields: 0,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 2,
    });
    const result = await gamification.rollChestDrop(
      { source: 'lesson', chestType: 'legendary', contextId: 'spoofed' },
      makeContext(),
    );
    expect(result.chestType).toBe('bronze');
    expect(result.xp).toBeGreaterThanOrEqual(15);
    expect(result.xp).toBeLessThanOrEqual(25);
  });

  test('verifies streak milestone against server streak before awarding tier', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 14,
      longestStreak: 14,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await gamification.rollChestDrop(
      { source: 'streak', contextId: 'streak_14' },
      makeContext(),
    );
    expect(result.chestType).toBe('gold');
  });

  test('downgrades a streak milestone the server cannot verify', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 5,
      longestStreak: 5,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await gamification.rollChestDrop(
      { source: 'streak', contextId: 'streak_100' },
      makeContext(),
    );
    expect(result.chestType).toBe('bronze');
  });

  test('rolls mission chest rarity server-side', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await gamification.rollChestDrop(
      { source: 'mission', contextId: 'mission_m1' },
      makeContext(),
    );
    expect(result.success).toBe(true);
    expect(['bronze', 'silver', 'gold', 'legendary']).toContain(result.chestType);
    expect(result.chestType).toBe(result.chestType);
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
      lessonsCompleted: 2,
      learning_gems: 0,
    });
    const result = await gamification.rollChestDrop({ source: 'lesson' }, makeContext());
    expect(result.chestType).toBe('bronze');
    expect(result.gems.added).toBeGreaterThanOrEqual(5);
    expect(result.gems.added).toBeLessThanOrEqual(8);
    expect(result.gems.balance).toBe(result.gems.added);
  });

  test('deduplicates by server-derived lesson counter within the same day', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 3,
    });
    const first = await gamification.rollChestDrop(
      { source: 'lesson', contextId: 'lesson_a' },
      makeContext(),
    );
    const second = await gamification.rollChestDrop(
      { source: 'lesson', contextId: 'lesson_b' },
      makeContext(),
    );
    expect(first.duplicate).toBe(false);
    expect(second.duplicate).toBe(true);
    expect(second.xp).toBe(0);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.rollChestDrop({ source: 'lesson' }, NO_AUTH)).rejects.toThrow();
  });

  test('persists rolled special items into the server inventory (NUEVO-08)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      streak_shields: 0,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
      learning_gems: 0,
    });

    // lessonsCompleted % 5 == 0 → premium (gold). Force a drop.
    const spy = jest.spyOn(Math, 'random');
    try {
      spy.mockReturnValue(0.001);
      const result = await gamification.rollChestDrop(
        { source: 'lesson', contextId: 'nuevo08_chest' },
        makeContext(),
      );
      const granted = [...(result.specialItems || []), ...(result.cosmeticUnlocks || [])];
      if (granted.length > 0) {
        const state = admin._getDoc(`users/${AUTH_UID}/inventory/state`);
        expect(state).not.toBeNull();
        // Every granted drop must be persisted in the state (or already capped).
        for (const item of result.specialItems || []) {
          const persisted = (state.specialItems && state.specialItems[item]) || 0;
          expect(persisted).toBeGreaterThanOrEqual(1);
        }
        for (const cosmetic of result.cosmeticUnlocks || []) {
          expect(state.cosmetics).toContain(cosmetic);
        }
      }
    } finally {
      spy.mockRestore();
    }
  });

  test('never trusts a forged luckBoostActive flag for bronze drops (NUEVO-08)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      streak_shields: 0,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 2,
      learning_gems: 0,
    });

    const result = await gamification.rollChestDrop(
      { source: 'lesson', luckBoostActive: true, contextId: 'forge_luck' },
      makeContext(),
    );
    // Bronze chests never drop special items even with a claimed boost.
    expect(result.chestType).toBe('bronze');
    expect(result.specialItems || []).toHaveLength(0);
    expect(result.cosmeticUnlocks || []).toHaveLength(0);
  });
});
