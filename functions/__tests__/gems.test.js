/**
 * Tests for gems.js — Server-authoritative gem economy.
 * Covers: earnGems (server-decided amounts + daily caps), spendGems
 * (validated + idempotent), getGemsBalance, and shared helpers.
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const admin = require('firebase-admin');
const gems = require('../gems');

const AUTH_UID = 'test-gems-123';
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

describe('earnGems', () => {
  test('credits server-authoritative gems for mission', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    const result = await gems.earnGems({ reason: 'mission' }, makeContext());
    expect(result.success).toBe(true);
    expect(result.gemsAdded).toBe(12);
    expect(result.balance).toBe(22);
  });

  test('credits achievement gems based on server formula', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const result = await gems.earnGems({ reason: 'achievement', meta: { xp: 100 } }, makeContext());
    expect(result.gemsAdded).toBe(25);
  });

  test('uses streak milestone table', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const result = await gems.earnGems({ reason: 'streak_milestone', meta: { streakDays: 30 } }, makeContext());
    expect(result.gemsAdded).toBe(60);
  });

  test('rejects client-provided amount and uses server value', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const result = await gems.earnGems({ reason: 'review', amount: 9999 }, makeContext());
    expect(result.gemsAdded).toBe(6);
  });

  test('enforces daily cap per reason', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today()}`, { total: 48 });
    const result = await gems.earnGems({ reason: 'mission' }, makeContext());
    expect(result.gemsAdded).toBe(2);
    expect(result.dailyCapped).toBe(true);
  });

  test('does not exceed max gem balance', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 99995 });
    const result = await gems.earnGems({ reason: 'mission' }, makeContext());
    expect(result.balance).toBe(100000);
  });

  test('rejects disallowed reasons (lesson/chest are handled elsewhere)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      gems.earnGems({ reason: 'lesson' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(gems.earnGems({ reason: 'mission' }, NO_AUTH)).rejects.toThrow();
  });

  test('rejects non-existent user', async () => {
    await expect(gems.earnGems({ reason: 'mission' }, makeContext('ghost'))).rejects.toThrow();
  });
});

describe('spendGems', () => {
  test('spends gems when balance is sufficient', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    const result = await gems.spendGems(
      { itemId: 'focus_elixir', amount: 30, idempotencyKey: 'spend-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.spent).toBe(30);
    expect(result.balance).toBe(70);
  });

  test('rejects insufficient balance', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    await expect(
      gems.spendGems({ itemId: 'focus_elixir', amount: 30, idempotencyKey: 'spend-2' }, makeContext())
    ).rejects.toThrow(/Saldo insuficiente/);
  });

  test('is idempotent for same idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    await gems.spendGems({ itemId: 'focus_elixir', amount: 30, idempotencyKey: 'spend-dup' }, makeContext());
    const result = await gems.spendGems(
      { itemId: 'focus_elixir', amount: 30, idempotencyKey: 'spend-dup' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.balance).toBe(70);
  });

  test('rejects missing itemId or idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    await expect(gems.spendGems({ amount: 10 }, makeContext())).rejects.toThrow();
    await expect(gems.spendGems({ itemId: 'x', amount: 10 }, makeContext())).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      gems.spendGems({ itemId: 'x', amount: 10, idempotencyKey: 'k' }, NO_AUTH)
    ).rejects.toThrow();
  });
});

describe('getGemsBalance', () => {
  test('returns balance and daily caps', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 42 });
    const result = await gems.getGemsBalance({}, makeContext());
    expect(result.balance).toBe(42);
    expect(result.dailyCaps.lesson).toBe(50);
    expect(result.maxBalance).toBe(100000);
  });

  test('rejects unauthenticated user', async () => {
    await expect(gems.getGemsBalance({}, NO_AUTH)).rejects.toThrow();
  });
});

describe('helpers', () => {
  test('computeCappedGems caps by daily cap for the reason', () => {
    const result = gems.computeCappedGems(45, 12, 'mission');
    expect(result.cappedGems).toBe(5);
    expect(result.remaining).toBe(5);
  });

  test('getDailyGemCap falls back to default cap', () => {
    expect(gems.getDailyGemCap('mission')).toBe(50);
    expect(gems.getDailyGemCap('unknown')).toBe(50);
  });
});
