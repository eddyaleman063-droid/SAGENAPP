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
const makeContext = (uid = AUTH_UID) => ({ auth: { uid, token: { email_verified: true } } });
const NO_AUTH = {};
const makeUnverifiedContext = (uid = AUTH_UID) => ({ auth: { uid, token: { email_verified: false } } });

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
    expect(result.lastClaimedDate).toBe(today());
  });

  test('returns alreadyClaimed if claimed today', async () => {
    setUserDoc(AUTH_UID, {
      learning_total_xp: 100,
      learning_level: 1,
      last_daily_chest: today(),
    });
    const result = await gamification.claimDailyChest({}, makeContext());
    expect(result.alreadyClaimed).toBe(true);
    expect(result.lastClaimedDate).toBe(today());
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

  test('rejects unverified user (requiere email_verified)', async () => {
    await expect(gamification.claimDailyChest({}, makeUnverifiedContext())).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
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
    setUserDoc(AUTH_UID, { sagen_pass_level: 3, sagen_pass_claimed: [1], sagen_pass_active: true });
    const result = await gamification.claimSagenPassReward({ level: 2 }, makeContext());
    expect(result.success).toBe(true);
    expect(result.claimed).toBe(2);
    expect(result.claimedLevels).toEqual([1, 2]);
  });

  test('grants 200 XP server-side for a default-level reward (level 1)', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 3,
      sagen_pass_claimed: [],
      learning_total_xp: 0,
      learning_level: 1,
      sagen_pass_active: true,
    });
    const result = await gamification.claimSagenPassReward({ level: 1 }, makeContext());
    expect(result.success).toBe(true);
    expect(result.reward.key).toBe('reward200Exp');
    expect(result.reward.type).toBe('xp');
    expect(result.reward.granted).toBe(200);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_total_xp).toBe(200);
    expect(user.learning_level).toBe(3);
    const daily = admin._getDoc(`daily_xp_sources/${AUTH_UID}_${today()}`);
    expect(daily.total).toBe(200);
    expect(daily.sagenPass).toBe(200);
  });

  test('grants 100 XP for multiple-of-5 levels (level 5)', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 6,
      sagen_pass_claimed: [],
      learning_total_xp: 0,
      learning_level: 1,
      sagen_pass_active: true,
    });
    const result = await gamification.claimSagenPassReward({ level: 5 }, makeContext());
    expect(result.reward.key).toBe('reward100Xp');
    expect(result.reward.granted).toBe(100);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_total_xp).toBe(100);
  });

  test('caps the pass XP reward against the daily XP limit (MAX_DAILY_XP=500)', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 3,
      sagen_pass_claimed: [],
      learning_total_xp: 0,
      learning_level: 1,
      sagen_pass_active: true,
    });
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today()}`, { total: 400 });
    // Quedan 100 del límite diario para un reward de 200.
    const result = await gamification.claimSagenPassReward({ level: 1 }, makeContext());
    expect(result.reward.granted).toBe(100);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_total_xp).toBe(100);
    const daily = admin._getDoc(`daily_xp_sources/${AUTH_UID}_${today()}`);
    expect(daily.total).toBe(500);
  });

  test('grants a Titanium Shield (streak_shields) for multiple-of-3 levels', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 5,
      sagen_pass_claimed: [],
      streak_shields: 2,
      sagen_pass_active: true,
    });
    const result = await gamification.claimSagenPassReward({ level: 3 }, makeContext());
    expect(result.reward.key).toBe('rewardTitaniumShield');
    expect(result.reward.type).toBe('item');
    expect(result.reward.totalShields).toBe(3);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.streak_shields).toBe(3);
  });

  test('NUEVO-fix (decisión de producto): rechaza el claim sin pass activo', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 3,
      sagen_pass_claimed: [],
      // Sin sagen_pass_active: free track — el no-comprador puede ganar SP y
      // ver su nivel, pero NO reclamar recompensas.
    });
    await expect(
      gamification.claimSagenPassReward({ level: 1 }, makeContext())
    ).rejects.toThrow(expect.objectContaining({ code: 'failed-precondition' }));
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.sagen_pass_claimed).toEqual([]);
  });

  test('NUEVO-fix (decisión de producto): cap de escudos en el claim (FREE_SHIELD_MAX=3)', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 5,
      sagen_pass_claimed: [],
      streak_shields: 3,
      sagen_pass_active: true,
    });
    const result = await gamification.claimSagenPassReward({ level: 3 }, makeContext());
    // El claim se marca (no bloquea el progreso) pero no acumula escudos extra.
    expect(result.reward.type).toBe('item');
    expect(result.reward.granted).toBe(0);
    expect(result.reward.cappedAtMax).toBe(true);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.streak_shields).toBe(3);
    expect(user.sagen_pass_claimed).toEqual([3]);
  });

  test('NUEVO-fix (type confusion): rechaza nivel no entero o fuera de rango', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 3,
      sagen_pass_claimed: [],
      sagen_pass_active: true,
    });
    for (const badLevel of ['7abc', 7.5, 0, -1, 51, null]) {
      await expect(
        gamification.claimSagenPassReward({ level: badLevel }, makeContext())
      ).rejects.toThrow(expect.objectContaining({ code: 'invalid-argument' }));
    }
  });

  test('grants a Golden Chest into the bank for multiple-of-10 levels', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 25, sagen_pass_claimed: [], sagen_pass_active: true });
    const result = await gamification.claimSagenPassReward({ level: 20 }, makeContext());
    expect(result.reward.key).toBe('rewardGoldenChest');
    expect(result.reward.type).toBe('chest');
    expect(result.reward.chest).toBe('golden');
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.sagen_pass_chests).toEqual(['golden']);
  });

  test('grants an Epic Chest for level 25', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 30, sagen_pass_claimed: [], sagen_pass_active: true });
    const result = await gamification.claimSagenPassReward({ level: 25 }, makeContext());
    expect(result.reward.key).toBe('rewardEpicChest');
    expect(result.reward.chest).toBe('epic');
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.sagen_pass_chests).toEqual(['epic']);
  });

  test('does not double-grant an already claimed level', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 3,
      sagen_pass_claimed: [1],
      learning_total_xp: 0,
      learning_level: 1,
      sagen_pass_active: true,
    });
    const result = await gamification.claimSagenPassReward({ level: 1 }, makeContext());
    expect(result.alreadyClaimed).toBe(true);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_total_xp).toBe(0);
    expect(user.sagen_pass_claimed).toEqual([1]);
  });

  test('returns alreadyClaimed for claimed level', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 3, sagen_pass_claimed: [1, 2], sagen_pass_active: true });
    const result = await gamification.claimSagenPassReward({ level: 2 }, makeContext());
    expect(result.alreadyClaimed).toBe(true);
  });

  test('rejects level above current level', async () => {
    setUserDoc(AUTH_UID, { sagen_pass_level: 1, sagen_pass_claimed: [], sagen_pass_active: true });
    await expect(
      gamification.claimSagenPassReward({ level: 5 }, makeContext())
    ).rejects.toThrow();
  });

  test('rotates the season when claiming after the window expired', async () => {
    const expiredStart = {
      _seconds: Math.floor((Date.now() - 91 * 24 * 60 * 60 * 1000) / 1000),
    };
    // Temporada vieja: nivel 30, claims 1..3 y un cofre dorado en el banco.
    setUserDoc(AUTH_UID, {
      sagen_pass_season_start: expiredStart,
      sagen_pass_level: 30,
      sagen_pass_sp: 12,
      sagen_pass_claimed: [1, 2, 3],
      sagen_pass_chests: ['golden'],
      sagen_pass_active: true,
    });
    const result = await gamification.claimSagenPassReward({ level: 1 }, makeContext());
    expect(result.success).toBe(true);
    expect(result.claimed).toBe(1);
    // La temporada nueva parte limpia: reclamar 1 ya no cuenta como duplicado
    // y las claims anteriores NO se arrastran.
    expect(result.claimedLevels).toEqual([1]);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.sagen_pass_claimed).toEqual([1]);
    expect(user.sagen_pass_level).toBe(1);
    expect(user.sagen_pass_sp).toBe(0);
    // El banco de cofres de la temporada anterior se vacía en la rotación.
    expect(user.sagen_pass_chests).toEqual([]);
    // El start de la nueva temporada se persiste (serverTimestamp sentinel vs
    // null porque el doc anterior sí lo tenía).
    expect(user.sagen_pass_season_start).toBeDefined();
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

  test('rotates to a fresh season when the stored window expired', async () => {
    const expiredStart = {
      _seconds: Math.floor((Date.now() - 91 * 24 * 60 * 60 * 1000) / 1000),
    };
    setUserDoc(AUTH_UID, {
      sagen_pass_season_start: expiredStart,
      sagen_pass_level: 30,
      sagen_pass_sp: 12,
      sagen_pass_claimed: [1, 2, 5],
    });
    const result = await gamification.getSagenPassSeason({}, makeContext());
    expect(result.rotated).toBe(true);
    expect(result.level).toBe(1);
    expect(result.sp).toBe(0);
    expect(result.claimed).toEqual([]);
    // La nueva temporada arranca en "ahora": aún no vence.
    expect(Date.now() - Date.parse(result.seasonStart)).toBeLessThan(60000);
  });

  test('does not reset engaged users with progress but no stored start', async () => {
    setUserDoc(AUTH_UID, {
      sagen_pass_level: 7,
      sagen_pass_sp: 42,
      sagen_pass_claimed: [1, 3],
    });
    const result = await gamification.getSagenPassSeason({}, makeContext());
    expect(result.rotated).toBe(false);
    expect(result.level).toBe(7);
    expect(result.sp).toBe(42);
    expect(result.claimed).toEqual([1, 3]);
    // Sin start almacenado la temporada ahora sí arranca (clock starts at now).
    expect(Date.now() - Date.parse(result.seasonStart)).toBeLessThan(60000);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.getSagenPassSeason({}, NO_AUTH)).rejects.toThrow();
  });
});

// NUEVO-fix (chest desync): estado autoritativo del cofre para reconciliar el
// ledger local en el arranque. lastClaimedDate debe viajar en TODAS las
// respuestas para que el cliente pueda persistirla y no dejar el cofre en el
// bucle "reclamado → reaparece".
describe('getDailyChestStatus', () => {
  test('returns claimed (unavailable) with lastClaimedDate when claimed today', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 100, last_daily_chest: today() });
    const result = await gamification.getDailyChestStatus({}, makeContext());
    expect(result.available).toBe(false);
    expect(result.lastClaimedDate).toBe(today());
  });

  test('returns available with null lastClaimedDate when never claimed', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0 });
    const result = await gamification.getDailyChestStatus({}, makeContext());
    expect(result.available).toBe(true);
    expect(result.lastClaimedDate).toBeNull();
  });

  test('returns available when last claim was yesterday', async () => {
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    setUserDoc(AUTH_UID, { last_daily_chest: yesterday });
    const result = await gamification.getDailyChestStatus({}, makeContext());
    expect(result.available).toBe(true);
    expect(result.lastClaimedDate).toBe(yesterday);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gamification.getDailyChestStatus({}, NO_AUTH)).rejects.toThrow();
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

  test('booster chest credits a usable XP boost counter (NUEVO-boost)', async () => {
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
    // Categoría booster = número aleatorio en [70, 85). Forzamos el roll y el XP.
    let call = 0;
    const realRandom = Math.random;
    Math.random = () => (call++ === 0 ? 0.75 : 0.5);
    try {
      const result = await gamification.rollChestDrop(
        { source: 'lesson', contextId: 'lesson_boost' },
        makeContext()
      );
      expect(result.success).toBe(true);
      expect(result.xpBoost).toBe(true);
      const user = admin._getDoc(`users/${AUTH_UID}`);
      expect(user.shop_purchased_xp_boosts).toBe(1);
    } finally {
      Math.random = realRandom;
    }
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
      lessonsCompleted: 5,
    });
    // Milestone válido (5) pero el cliente pide legendary: el servidor otorga
    // el tier deducido del contador (gold), nunca el del cliente.
    const result = await gamification.rollChestDrop(
      { source: 'lesson', chestType: 'legendary', contextId: 'spoofed' },
      makeContext(),
    );
    expect(result.chestType).toBe('gold');
    expect(result.xp).toBeGreaterThanOrEqual(35);
    expect(result.xp).toBeLessThanOrEqual(50);
  });

  test('rejects a lesson chest outside real milestones (anti-farm)', async () => {
    setUserDoc(AUTH_UID, {
      lessonsCompleted: 2,
      currentStreak: 1,
      longestStreak: 1,
      learning_total_xp: 0,
      learning_level: 1,
    });
    await expect(
      gamification.rollChestDrop({ source: 'lesson', contextId: 'farm_2' }, makeContext())
    ).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('rejects a streak chest at an unverified milestone (anti-farm)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 5,
      longestStreak: 5,
      streak_last_activity: { toDate: () => yesterday },
    });
    await expect(
      gamification.rollChestDrop(
        { source: 'streak', contextId: 'streak_100' },
        makeContext(),
      )
    ).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
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

  test('NUEVO-fix (anti-farm): daily cap 30 for mission chest rolls', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
    });
    const todayStr = new Date().toISOString().split('T')[0];
    // Cap diario agotado → rechazo inequívoco (antes un cliente modificado
    // podía inventar infinitos contextIds para tocar infinitas keys).
    admin._setDoc(`daily_mission_rolls/${AUTH_UID}_${todayStr}`, { count: 30 });
    await expect(
      gamification.rollChestDrop({ source: 'mission', contextId: 'cap_m1' }, makeContext())
    ).rejects.toThrow(expect.objectContaining({ code: 'failed-precondition' }));
    // 29 rolls: el último pasa y deja el contador sellado en 30.
    admin._setDoc(`daily_mission_rolls/${AUTH_UID}_${todayStr}`, { count: 29 });
    const roll = await gamification.rollChestDrop(
      { source: 'mission', contextId: 'cap_m2' },
      makeContext(),
    );
    expect(roll.success).toBe(true);
    expect(admin._getDoc(`daily_mission_rolls/${AUTH_UID}_${todayStr}`).count).toBe(30);
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
      lessonsCompleted: 3,
      learning_gems: 0,
    });
    const result = await gamification.rollChestDrop({ source: 'lesson' }, makeContext());
    expect(result.chestType).toBe('silver');
    // gems = clamp(2, 75, floor(xp / 3)); xp 25-35 → 8..11
    expect(result.gems.added).toBeGreaterThanOrEqual(8);
    expect(result.gems.added).toBeLessThanOrEqual(11);
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
      lessonsCompleted: 1,
      learning_gems: 0,
    });

    // source='mission' con random alto → rareza bronze (73%, alineado con los
    // defaults de Remote Config 1/6/20). Bronze nunca dropea ítems aunque el
    // cliente forjee luckBoostActive.
    const spy = jest.spyOn(Math, 'random');
    try {
      spy.mockReturnValue(0.9);
      const result = await gamification.rollChestDrop(
        { source: 'mission', luckBoostActive: true, contextId: 'forge_luck' },
        makeContext(),
      );
      expect(result.chestType).toBe('bronze');
      expect(result.specialItems || []).toHaveLength(0);
      expect(result.cosmeticUnlocks || []).toHaveLength(0);
    } finally {
      spy.mockRestore();
    }
  });

  test('rolls a banked Sagen Pass chest once and consumes it', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const seasonStarted = {
      _seconds: Math.floor((Date.now() - 1 * 24 * 60 * 60 * 1000) / 1000),
    };
    setUserDoc(AUTH_UID, {
      sagen_pass_season_start: seasonStarted,
      sagen_pass_claimed: [20],
      sagen_pass_chests: ['golden'],
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      learning_gems: 0,
    });
    const first = await gamification.rollChestDrop(
      { source: 'sagen', contextId: 'pass_20' },
      makeContext(),
    );
    expect(first.success).toBe(true);
    expect(first.chestType).toBe('gold');
    expect(first.xp).toBeGreaterThanOrEqual(35);
    expect(first.xp).toBeLessThanOrEqual(50);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.sagen_pass_chests).toEqual([]);
    // Second roll: bank consumed → no entitlement.
    await expect(
      gamification.rollChestDrop({ source: 'sagen', contextId: 'pass_20' }, makeContext())
    ).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('rejects a Sagen Pass chest roll with no banked chest', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
    });
    await expect(
      gamification.rollChestDrop({ source: 'sagen', contextId: 'pass_20' }, makeContext())
    ).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('rejects rolling a banked chest from an EXPIRED season', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const expiredStart = {
      _seconds: Math.floor((Date.now() - 91 * 24 * 60 * 60 * 1000) / 1000),
    };
    setUserDoc(AUTH_UID, {
      sagen_pass_season_start: expiredStart,
      sagen_pass_chests: ['golden'],
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
    });
    // El cofre está en el banco pero pertenece a una temporada vencida: el
    // rollo se rechaza (la rotación vacía el banco de forma efectiva) para no
    // abrir recompensas de la temporada anterior.
    await expect(
      gamification.rollChestDrop({ source: 'sagen', contextId: 'pass_20' }, makeContext())
    ).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('rejects a Sagen Pass roll for a non-chest level', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      sagen_pass_chests: ['golden'],
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
    });
    // pass_5 es un nivel de 100 XP (no chest) → el banco golden no aplica.
    await expect(
      gamification.rollChestDrop({ source: 'sagen', contextId: 'pass_5' }, makeContext())
    ).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });
});
