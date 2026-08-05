/**
 * Tests for economic.js — Server-authoritative economic functions.
 * Covers: addGems, spendGems, addXp, incrementStreak, completeLesson, validateAndExecuteSpend
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const admin = require('firebase-admin');
const crypto = require('crypto');
const economic = require('../economic');
const functions = require('firebase-functions');

const AUTH_UID = 'test-user-123';
const PURCHASE_SECRET = 'test-purchase-secret-key';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid } });
const NO_AUTH = {};

// Configure purchase_secret in mock config
functions.config = jest.fn(() => ({
  app: { purchase_secret: PURCHASE_SECRET },
}));

/**
 * Generate a valid purchase token for spendGems tests.
 */
function makePurchaseToken({ userId = AUTH_UID, cost, itemId, ttlMs = 60000 } = {}) {
  const payload = JSON.stringify({
    userId,
    cost,
    itemId,
    exp: Date.now() + ttlMs,
  });
  const sig = crypto.createHmac('sha256', PURCHASE_SECRET).update(payload).digest('hex');
  const encoded = JSON.stringify({ payload, sig });
  return Buffer.from(encoded).toString('base64');
}

beforeEach(() => {
  admin._resetFirestore();
});

function setUserDoc(uid, data) {
  admin._setDoc(`users/${uid}`, data);
}

describe('addGems', () => {
  test('adds gems to user balance', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100, learning_total_gems: 100 });
    const result = await economic.addGems(
      { amount: 25, reason: 'lesson', lessonId: 'l1', idempotencyKey: 'addGems-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.newBalance).toBe(125);
    expect(result.actualAdded).toBe(25);
    expect(result.capped).toBe(false);
    expect(result.duplicate).toBe(false);
  });

  test('caps gems at MAX_GEM_CAP (999999)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 999990, learning_total_gems: 999990 });
    const result = await economic.addGems(
      { amount: 50, reason: 'lesson', lessonId: 'l1', idempotencyKey: 'addGems-cap' },
      makeContext()
    );
    expect(result.newBalance).toBe(999999);
    expect(result.actualAdded).toBe(9);
    expect(result.capped).toBe(false);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.addGems({ amount: 10, idempotencyKey: 'addGems-noauth' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('rejects amount > MAX_GEMS_PER_TRANSACTION (500)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.addGems({ amount: 600, idempotencyKey: 'addGems-over' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects amount < 1', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.addGems({ amount: 0, idempotencyKey: 'addGems-under' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects non-existent user', async () => {
    await expect(
      economic.addGems({ amount: 10, idempotencyKey: 'addGems-nouser' }, makeContext('nonexistent'))
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.addGems({ amount: 10 }, makeContext())
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100, learning_total_gems: 100 });
    await economic.addGems(
      { amount: 25, reason: 'lesson', lessonId: 'l1', idempotencyKey: 'addGems-dup' },
      makeContext()
    );
    const result = await economic.addGems(
      { amount: 25, reason: 'lesson', lessonId: 'l1', idempotencyKey: 'addGems-dup' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.newBalance).toBe(125);
  });

  test('enforces per-source daily gem cap', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100, learning_total_gems: 100 });
    // First call — should succeed (lesson cap is 50)
    const r1 = await economic.addGems(
      { amount: 40, reason: 'lesson', lessonId: 'l1', idempotencyKey: 'addGems-cap1' },
      makeContext()
    );
    expect(r1.success).toBe(true);
    expect(r1.actualAdded).toBe(40);
    expect(r1.capped).toBe(false);

    // Second call — should be capped (40 + 20 > 50 daily cap)
    const r2 = await economic.addGems(
      { amount: 20, reason: 'lesson', lessonId: 'l2', idempotencyKey: 'addGems-cap2' },
      makeContext()
    );
    expect(r2.success).toBe(true);
    expect(r2.actualAdded).toBe(10);
    expect(r2.capped).toBe(false);
  });
});

describe('spendGems', () => {
  test('deducts gems from balance', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    const token = makePurchaseToken({ cost: 30, itemId: 'chest_bronze' });
    const result = await economic.spendGems(
      { cost: 30, itemId: 'chest_bronze', idempotencyKey: 'key-1', token },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.newBalance).toBe(70);
    expect(result.duplicate).toBe(false);
  });

  test('rejects insufficient balance', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    const token = makePurchaseToken({ cost: 50, itemId: 'chest_gold' });
    await expect(
      economic.spendGems(
        { cost: 50, itemId: 'chest_gold', idempotencyKey: 'key-2', token },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing itemId', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    const token = makePurchaseToken({ cost: 10, itemId: '' });
    await expect(
      economic.spendGems({ cost: 10, idempotencyKey: 'key-3', token }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    const token = makePurchaseToken({ cost: 10, itemId: 'item-1' });
    await expect(
      economic.spendGems({ cost: 10, itemId: 'item-1', token }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects cost > MAX_GEM_CAP', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 999999 });
    const token = makePurchaseToken({ cost: 1000000, itemId: 'item-1' });
    await expect(
      economic.spendGems(
        { cost: 1000000, itemId: 'item-1', idempotencyKey: 'key-4', token },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    const token = makePurchaseToken({ cost: 10, itemId: 'item-1' });
    await expect(
      economic.spendGems({ cost: 10, itemId: 'item-1', idempotencyKey: 'key-5', token }, NO_AUTH)
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
  test('completes lesson with gems and XP', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_gems: 50,
      learning_total_gems: 50,
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', gemsEarned: 15, xpEarned: 25 },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.gems.added).toBe(15);
    expect(result.gems.newBalance).toBe(65);
    expect(result.xp.added).toBe(25);
    expect(result.streak.current).toBe(4);
    expect(result.lessonsCompleted).toBe(6);
  });

  test('rejects if both gems and XP are 0', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.completeLesson(
        { lessonId: 'lesson-1', gemsEarned: 0, xpEarned: 0 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing lessonId', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.completeLesson({ gemsEarned: 10, xpEarned: 10 }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.completeLesson(
        { lessonId: 'l1', gemsEarned: 10, xpEarned: 10 },
        NO_AUTH
      )
    ).rejects.toThrow();
  });

  test('is idempotent for same lessonId', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_gems: 50,
      learning_total_gems: 50,
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    await economic.completeLesson(
      { lessonId: 'lesson-dup', gemsEarned: 15, xpEarned: 25 },
      makeContext()
    );
    const result = await economic.completeLesson(
      { lessonId: 'lesson-dup', gemsEarned: 15, xpEarned: 25 },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.gems.added).toBe(0);
    expect(result.xp.added).toBe(0);
  });
});

describe('validateAndExecuteSpend', () => {
  test('validates and deducts gems for purchase', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 200 });
    const result = await economic.validateAndExecuteSpend(
      { itemId: 'chest_gold', cost: 50, idempotencyKey: 'spend-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.newBalance).toBe(150);
    expect(result.itemId).toBe('chest_gold');
  });

  test('rejects if already processed (idempotent)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 200 });
    await economic.validateAndExecuteSpend(
      { itemId: 'chest_gold', cost: 50, idempotencyKey: 'spend-2' },
      makeContext()
    );
    const result = await economic.validateAndExecuteSpend(
      { itemId: 'chest_gold', cost: 50, idempotencyKey: 'spend-2' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
  });

  test('rejects insufficient balance', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    await expect(
      economic.validateAndExecuteSpend(
        { itemId: 'chest_gold', cost: 50, idempotencyKey: 'spend-3' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    await expect(
      economic.validateAndExecuteSpend(
        { itemId: 'item-1', cost: 10 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.validateAndExecuteSpend(
        { itemId: 'item-1', cost: 10, idempotencyKey: 'k' },
        NO_AUTH
      )
    ).rejects.toThrow();
  });
});
