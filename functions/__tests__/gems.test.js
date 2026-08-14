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

  test('credits daily bonus escalating with the day streak', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const base = await gems.earnGems({ reason: 'daily_bonus', meta: { dayStreak: 1 } }, makeContext());
    expect(base.gemsAdded).toBe(5);

    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const mid = await gems.earnGems({ reason: 'daily_bonus', meta: { dayStreak: 7 } }, makeContext());
    expect(mid.gemsAdded).toBe(12);

    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const high = await gems.earnGems({ reason: 'daily_bonus', meta: { dayStreak: 30 } }, makeContext());
    expect(high.gemsAdded).toBe(30);
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

  test('ignores forged client amount, uses server catalog cost', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    const result = await gems.spendGems(
      { itemId: 'titanium_shield', amount: 1, idempotencyKey: 'spend-forge' },
      makeContext()
    );
    expect(result.spent).toBe(80);
    expect(result.balance).toBe(20);
  });

  test('rejects unknown shop item even with valid amount', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    await expect(
      gems.spendGems({ itemId: 'made_up_item', amount: 30, idempotencyKey: 'spend-unknown' }, makeContext())
    ).rejects.toThrow(/Artículo desconocido/);
  });

  test('allows re-buying a consumable with a fresh key (NUEVO-01)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100 });
    const first = await gems.spendGems(
      { itemId: 'focus_elixir', idempotencyKey: 'cons-1' },
      makeContext()
    );
    expect(first.success).toBe(true);
    expect(first.duplicate).toBe(false);
    expect(first.balance).toBe(70);

    const second = await gems.spendGems(
      { itemId: 'focus_elixir', idempotencyKey: 'cons-2' },
      makeContext()
    );
    expect(second.success).toBe(true);
    expect(second.duplicate).toBe(false);
    expect(second.balance).toBe(40);
  });

  test('refuses a second purchase of a one-time item even with a fresh key (NUEVO-01)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 500 });
    const first = await gems.spendGems(
      { itemId: 'theme_blue', idempotencyKey: 'ot-1' },
      makeContext()
    );
    expect(first.success).toBe(true);
    expect(first.owned).toBe(true);
    expect(first.balance).toBe(350);

    // A different key must NOT bypass the ownership check.
    const second = await gems.spendGems(
      { itemId: 'theme_blue', idempotencyKey: 'ot-2' },
      makeContext()
    );
    expect(second.success).toBe(false);
    expect(second.owned).toBe(true);
    expect(second.balance).toBe(350);
  });

  test('writes shop ownership to users/{uid}/inventory/shop_items (NUEVO-11)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 500 });
    await gems.spendGems(
      { itemId: 'theme_blue', idempotencyKey: 'inv-1' },
      makeContext()
    );
    const inv = admin._getDoc(`users/${AUTH_UID}/inventory/shop_items`);
    expect(inv).not.toBeNull();
    expect(inv.items).toContain('theme_blue');
  });

  test('persists consumable purchases into the server inventory (NUEVO-08)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 500 });
    await gems.spendGems(
      { itemId: 'focus_elixir', idempotencyKey: 'inv-cons-1' },
      makeContext()
    );
    const state = admin._getDoc(`users/${AUTH_UID}/inventory/state`);
    expect(state).not.toBeNull();
    expect(state.specialItems.focusElixir).toBe(1);
  });

  test('persists cosmetic purchases into the server inventory (NUEVO-08)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 500 });
    await gems.spendGems(
      { itemId: 'avatar_frame_neon', idempotencyKey: 'inv-cos-1' },
      makeContext()
    );
    const state = admin._getDoc(`users/${AUTH_UID}/inventory/state`);
    expect(state).not.toBeNull();
    expect(state.cosmetics).toContain('avatarFrameNeon');
  });

  test('clamps repeated consumable purchases to the item max limit (NUEVO-08)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 100000 });
    for (let i = 0; i < 10; i++) {
      await gems.spendGems(
        { itemId: 'titanium_shield', idempotencyKey: `inv-clamp-${i}` },
        makeContext()
      );
    }
    const state = admin._getDoc(`users/${AUTH_UID}/inventory/state`);
    expect(state.specialItems.titaniumShield).toBe(3);
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
