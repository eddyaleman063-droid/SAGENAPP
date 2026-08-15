/**
 * Tests for economic.js — Server-authoritative economic functions.
 * Covers: processDonation, addXp, incrementStreak, completeLesson,
 * and the daily XP cap helpers (checkDailyXpCap, computeCappedXp).
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const admin = require('firebase-admin');
const economic = require('../economic');

const AUTH_UID = 'test-user-123';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid } });
const NO_AUTH = {};

beforeEach(() => {
  admin._resetFirestore();
});

function setUserDoc(uid, data) {
  admin._setDoc(`users/${uid}`, data);
}

describe('computeCappedXp', () => {
  test('caps XP at MAX_DAILY_XP (500)', () => {
    const result = economic.computeCappedXp(480, 50);
    expect(result.cappedXp).toBe(20);
    expect(result.remaining).toBe(20);
  });

  test('returns full amount when under cap', () => {
    const result = economic.computeCappedXp(0, 50);
    expect(result.cappedXp).toBe(50);
    expect(result.remaining).toBe(500);
  });

  test('returns zero when cap reached', () => {
    const result = economic.computeCappedXp(500, 50);
    expect(result.cappedXp).toBe(0);
    expect(result.remaining).toBe(0);
  });
});

describe('checkDailyXpCap', () => {
  test('allows when under cap', async () => {
    const result = await economic.checkDailyXpCap(AUTH_UID, 30);
    expect(result.allowed).toBe(true);
    expect(result.cappedXp).toBe(30);
  });

  test('blocks when cap exhausted', async () => {
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${new Date().toISOString().split('T')[0]}`, { total: 500 });
    const result = await economic.checkDailyXpCap(AUTH_UID, 30);
    expect(result.allowed).toBe(false);
    expect(result.cappedXp).toBe(0);
  });
});

describe('processDonation', () => {
  test('credits donation to user balance', async () => {
    setUserDoc(AUTH_UID, { total_donated: 100 });
    const result = await economic.processDonation(
      { amount: 25, method: 'mercadopago', idempotencyKey: 'donation-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.total_donated).toBe(125);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('rejects amount <= 0', async () => {
    setUserDoc(AUTH_UID, {});
    await expect(
      economic.processDonation({ amount: 0, method: 'wallet', idempotencyKey: 'k' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, {});
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects insufficient wallet balance', async () => {
    setUserDoc(AUTH_UID, { walletBalance: 5 });
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, makeContext())
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { total_donated: 100 });
    await economic.processDonation(
      { amount: 25, method: 'mercadopago', idempotencyKey: 'donation-dup' },
      makeContext()
    );
    const result = await economic.processDonation(
      { amount: 25, method: 'mercadopago', idempotencyKey: 'donation-dup' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.total_donated).toBe(125);
  });

  test('rejects non-existent user', async () => {
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, makeContext('ghost'))
    ).rejects.toThrow();
  });
});

describe('addXp', () => {
  test('adds XP using server-authoritative reason reward', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(15);
    expect(result.level).toBe(1);
    expect(result.leveledUp).toBe(false);
    expect(result.duplicate).toBe(false);
  });

  test('detects level up', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 90, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-level' },
      makeContext()
    );
    expect(result.totalXp).toBe(105);
    expect(result.level).toBe(2);
    expect(result.leveledUp).toBe(true);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.addXp({ reason: 'lesson_reward', idempotencyKey: 'addXp-noauth' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0 });
    await expect(
      economic.addXp({ reason: 'lesson_reward' }, makeContext())
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 50, learning_level: 1 });
    await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-dup' },
      makeContext()
    );
    const result = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-dup' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.totalXp).toBe(65);
  });

  test('uses default reward for unknown reason', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'unknown_reason', idempotencyKey: 'addXp-unk' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(5);
  });

  test('throws resource-exhausted when daily XP cap reached', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 490, learning_level: 1 });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today}`, { total: 500 });
    await expect(
      economic.addXp({ reason: 'lesson_reward', idempotencyKey: 'addXp-cap' }, makeContext())
    ).rejects.toThrow(/Limite diario/);
  });

  test('rejects non-existent user', async () => {
    await expect(
      economic.addXp({ reason: 'lesson_reward', idempotencyKey: 'addXp-nouser' }, makeContext('ghost'))
    ).rejects.toThrow();
  });
});

describe('incrementStreak', () => {
  test('increments streak for consecutive day', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      currentStreak: 5,
      longestStreak: 10,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.success).toBe(true);
    expect(result.currentStreak).toBe(6);
    expect(result.alreadyCheckedIn).toBe(false);
  });

  test('returns alreadyCheckedIn if same day', async () => {
    const now = new Date();
    setUserDoc(AUTH_UID, {
      currentStreak: 5,
      longestStreak: 10,
      streak_last_activity: { toDate: () => now },
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.alreadyCheckedIn).toBe(true);
    expect(result.currentStreak).toBe(5);
  });

  test('resets streak if gap > 1 day', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.currentStreak).toBe(1);
    expect(result.streakBroken).toBe(true);
    expect(result.previousStreak).toBe(10);
  });

  test('keeps streak alive and debits a shield when freeze is honored', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 2,
    });
    const result = await economic.incrementStreak(
      { freezeUsed: true },
      makeContext()
    );
    expect(result.currentStreak).toBe(11);
    expect(result.freezeConsumed).toBe(true);
    expect(result.streakBroken).toBeUndefined();
    expect(result.shieldsRemaining).toBe(1);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(1);
  });

  test('honors shop streak shields when streak_shields is zero', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 0,
      shop_streak_shields: 1,
    });
    const result = await economic.incrementStreak(
      { freezeUsed: true },
      makeContext()
    );
    expect(result.freezeConsumed).toBe(true);
    expect(result.shieldsRemaining).toBe(0);
    expect(admin._getDoc(`users/${AUTH_UID}`).shop_streak_shields).toBe(0);
  });

  test('denies freeze and breaks streak when no shields owned', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    const result = await economic.incrementStreak(
      { freezeUsed: true },
      makeContext()
    );
    expect(result.currentStreak).toBe(1);
    expect(result.streakBroken).toBe(true);
    expect(result.freezeDenied).toBe(true);
    expect(result.previousStreak).toBe(10);
  });

  test('starts streak at 1 if no previous activity', async () => {
    setUserDoc(AUTH_UID, {
      currentStreak: 0,
      longestStreak: 0,
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.currentStreak).toBe(1);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.incrementStreak({}, NO_AUTH)
    ).rejects.toThrow();
  });
});

describe('completeLesson', () => {
  test('completes lesson with server-authoritative rewards', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.xp.added).toBe(15);
    expect(result.xp.totalXp).toBe(115);
    expect(result.streak.current).toBe(4);
    expect(result.lessonsCompleted).toBe(6);
  });

  test('ignores client-specified rewards, uses server rewards', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', gemsEarned: 9999, xpEarned: 9999 },
      makeContext()
    );
    expect(result.xp.added).toBe(15);
    expect(result.xp.totalXp).toBe(15);
  });

  test('applies bonus XP for _l6 lessons', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'ac_s1_ses1_l6' },
      makeContext()
    );
    expect(result.xp.added).toBe(20);
  });

  test('applies the streak multiplier to lesson XP (streak 10 = 1.1x)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 10,
      longestStreak: 10,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    // 15 * 1.1 = 16.5 -> round 17
    expect(result.xp.added).toBe(17);
    expect(result.xp.totalXp).toBe(17);
  });

  test('caps the streak multiplier at 2.0', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 100,
      longestStreak: 100,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    // 15 * 2.0 = 30
    expect(result.xp.added).toBe(30);
  });

  test('streak multiplier is not applied below streak 10', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 9,
      longestStreak: 9,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.xp.added).toBe(15);
  });

  test('rejects missing lessonId', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.completeLesson({}, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.completeLesson({ lessonId: 'l1' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('is idempotent for same lessonId', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    await economic.completeLesson({ lessonId: 'lesson-dup' }, makeContext());
    const result = await economic.completeLesson({ lessonId: 'lesson-dup' }, makeContext());
    expect(result.duplicate).toBe(true);
    expect(result.xp.added).toBe(0);
  });

  test('caps daily XP at 500', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today}`, { total: 495 });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.xp.added).toBe(5);
    expect(result.xp.totalXp).toBe(5);
  });

  test('awards Sagen Pass SP from a server-verified lesson', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.sagenPass).toBeTruthy();
    expect(result.sagenPass.spAdded).toBe(10);
    expect(result.sagenPass.sp).toBe(10);
    expect(result.sagenPass.level).toBe(1);
  });

  test('awards perfect_lesson SP bonus when the lesson is perfect', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: 15, totalQuestions: 15 },
      makeContext()
    );
    // 10 (lesson) + 15 (perfect_lesson)
    expect(result.sagenPass.spAdded).toBe(25);
    expect(result.sagenPass.sp).toBe(25);
  });

  test('ignores perfect claim without a consistent answer set (anti-farm)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      learning_gems: 0,
      sagen_pass_level: 1,
    });
    // perfect=true but totalQuestions missing / inconsistent: bonus must NOT apply
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: 15, totalQuestions: 10 },
      makeContext()
    );
    expect(result.gems.perfect).toBe(false);
    expect(result.sagenPass.spAdded).toBe(10); // lesson SP only
    expect(result.sagenPass.sp).toBe(10);
  });

  test('completeLesson SP respects the daily cap', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today}`, { total: 95 });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.sagenPass.spAdded).toBe(5);
    expect(result.sagenPass.dailyCapped).toBe(true);
  });

  test('completeLesson does not award SP on duplicates', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    await economic.completeLesson({ lessonId: 'lesson-sp-dup' }, makeContext());
    const result = await economic.completeLesson({ lessonId: 'lesson-sp-dup' }, makeContext());
    expect(result.duplicate).toBe(true);
    expect(result.sagenPass).toBeNull();
  });

  test('completeLesson pass holders earn unlimited SP', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
      sagen_pass_active: true,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today}`, { total: 100 });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.sagenPass.spAdded).toBe(10);
    expect(result.sagenPass.dailyCapped).toBe(false);
    expect(result.sagenPass.premium).toBe(true);
  });

  test('addXp rejects path-injecting idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    await expect(
      economic.addXp(
        { reason: 'lesson_reward', idempotencyKey: 'a/b/c' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('completeLesson rejects malicious lessonId with path chars', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    await expect(
      economic.completeLesson({ lessonId: 'lesson/../admin' }, makeContext())
    ).rejects.toThrow();
  });

  test('completeLesson treats non-integer correctCount as non-perfect', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      learning_gems: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: '15x', totalQuestions: '15y' },
      makeContext()
    );
    expect(result.gems.perfect).toBe(false);
    // Only the first-lesson-of-day bonus applies — string answers earn nothing.
    expect(result.gems.added).toBe(10);
  });

  test('processDonation rejects path-injecting idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    await expect(
      economic.processDonation(
        { amount: 25, method: 'mercadopago', idempotencyKey: 'donation/../x' },
        makeContext()
      )
    ).rejects.toThrow();
  });
});
