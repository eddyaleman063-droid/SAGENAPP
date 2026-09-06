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

describe('earnGems', () => {
  test('credits server-authoritative gems for mission', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    const result = await gems.earnGems({ reason: 'mission' }, makeContext());
    expect(result.success).toBe(true);
    expect(result.gemsAdded).toBe(12);
    expect(result.balance).toBe(22);
  });

  test('accumulates the lifetime learning_total_gems counter', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    await gems.earnGems({ reason: 'mission' }, makeContext());
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_total_gems).toBe(12);
    expect(user.learning_gems).toBe(22);
  });

  test('credits achievement gems from the server XP table (ignores forged meta.xp)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    // streak_7 = 50 XP server → clamp(floor(50/4),2,30)=12. El meta.xp del
    // cliente (355) se IGNORA por completo.
    const result = await gems.earnGems(
      { reason: 'achievement', achievementId: 'streak_7', meta: { xp: 355 } },
      makeContext()
    );
    expect(result.gemsAdded).toBe(12);
  });

  test('NUEVO-fix (anti-forge): rechaza un achievementId no whitelisted', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const result = await gems.earnGems(
      { reason: 'achievement', achievementId: '../injected-0', meta: { xp: 4000 } },
      makeContext()
    );
    expect(result.success).toBe(false);
    expect(result.invalidAchievement).toBe(true);
    expect(result.gemsAdded).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_gems).toBe(0);
  });

  test('NUEVO-fix (anti-forge): rechaza achievement sin id (ya no paga flat 20)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const result = await gems.earnGems({ reason: 'achievement', meta: { xp: 80 } }, makeContext());
    expect(result.success).toBe(false);
    expect(result.invalidAchievement).toBe(true);
    expect(result.gemsAdded).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_gems).toBe(0);
  });

  test('pays achievement gems once via the claim flag (NUEVO-fix)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const first = await gems.earnGems(
      { reason: 'achievement', achievementId: 'streak_7' },
      makeContext()
    );
    expect(first.gemsAdded).toBe(12);
    const claim = admin._getDoc(`users/${AUTH_UID}/achievements/streak_7`);
    expect(claim.gemsClaimed).toBe(true);

    // Segunda reclamación (con otra meta/idempotencia): ya pagada, 0 gemas.
    const second = await gems.earnGems(
      { reason: 'achievement', achievementId: 'streak_7' },
      makeContext()
    );
    expect(second.success).toBe(false);
    expect(second.alreadyClaimed).toBe(true);
    expect(second.gemsAdded).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_gems).toBe(12);
  });

  test('keeps the claim open when the daily cap cuts the gems (NUEVO-fix)', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today()}`, { total: 196 });
    const result = await gems.earnGems(
      { reason: 'achievement', achievementId: 'all_stages' },
      makeContext()
    );
    // all_stages = 200 XP → clamp(floor(200/4),2,30)=30. Cap diario 200 → 4.
    expect(result.gemsAdded).toBe(4);
    expect(result.dailyCapped).toBe(true);
    expect(
      admin._getDoc(`users/${AUTH_UID}/achievements/all_stages`) || {}
    ).not.toHaveProperty('gemsClaimed');
  });

  test('uses streak milestone table from server streak', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 30 });
    const result = await gems.earnGems({ reason: 'streak_milestone', meta: { streakDays: 30 } }, makeContext());
    expect(result.gemsAdded).toBe(60);
  });

  test('ignores forged streakDays in streak_milestone', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 3 });
    const result = await gems.earnGems({ reason: 'streak_milestone', meta: { streakDays: 365 } }, makeContext());
    expect(result.gemsAdded).toBe(0);
  });

  test('credits daily bonus escalating with the server day streak', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 1 });
    const base = await gems.earnGems({ reason: 'daily_bonus', meta: { dayStreak: 1 } }, makeContext());
    expect(base.gemsAdded).toBe(5);

    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 7 });
    const mid = await gems.earnGems({ reason: 'daily_bonus', meta: { dayStreak: 7 } }, makeContext());
    expect(mid.gemsAdded).toBe(12);

    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 30 });
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

  test('rejects unverified user (requiere email_verified)', async () => {
    await expect(gems.earnGems({ reason: 'mission' }, makeUnverifiedContext())).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('rejects non-existent user', async () => {
    await expect(gems.earnGems({ reason: 'mission' }, makeContext('ghost'))).rejects.toThrow();
  });
});

describe('earnGems idempotency & seals (NUEVO-fix)', () => {
  test('retry with the same idempotencyKey does not duplicate the credit', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 10 });
    const first = await gems.earnGems(
      { reason: 'mission', idempotencyKey: 'earn-k-1' },
      makeContext()
    );
    expect(first.success).toBe(true);
    expect(first.gemsAdded).toBe(12);

    // Replay del MISMO idempotencyKey (retry por timeout): no vuelve a pagar.
    const replay = await gems.earnGems(
      { reason: 'mission', idempotencyKey: 'earn-k-1' },
      makeContext()
    );
    expect(replay.duplicate).toBe(true);
    expect(replay.gemsAdded).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_gems).toBe(22);

    // El log de transacción quedó sellado con el idempotencyKey.
    const log = admin._getDoc(`transaction_logs/earn-k-1`);
    expect(log).toBeTruthy();
    expect(log.gemsAdded).toBe(12);
  });

  test('unkeys with a different idempotencyKey still credit (independent earns)', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await gems.earnGems({ reason: 'review', idempotencyKey: 'earn-r-1' }, makeContext());
    const second = await gems.earnGems({ reason: 'review', idempotencyKey: 'earn-r-2' }, makeContext());
    expect(second.gemsAdded).toBe(6);
  });

  test('legacy earn without idempotencyKey still works (no dedup, old clients)', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const result = await gems.earnGems({ reason: 'mission' }, makeContext());
    expect(result.success).toBe(true);
    expect(result.gemsAdded).toBe(12);
    expect(admin._getDoc(`transaction_logs/earn-k-1`) || {}).not.toHaveProperty('createdAt');
  });

  test('daily bonus pays once per UTC day (server seal)', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 7 });
    const first = await gems.earnGems({ reason: 'daily_bonus', meta: { dayStreak: 7 } }, makeContext());
    expect(first.gemsAdded).toBe(12);

    // Segundo persist del mismo día UTC: sellado -> no paga de nuevo.
    const second = await gems.earnGems(
      { reason: 'daily_bonus', meta: { dayStreak: 7 }, idempotencyKey: 'earn-db-2' },
      makeContext()
    );
    expect(second.alreadyClaimed).toBe(true);
    expect(second.gemsAdded).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_gems).toBe(12);
    expect(user._last_daily_bonus_day).toBe(today());
  });

  test('streak milestone pays once per reached milestone (anti-farm)', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 30 });
    const first = await gems.earnGems(
      { reason: 'streak_milestone', meta: { streakDays: 30 }, idempotencyKey: 'earn-sm-1' },
      makeContext()
    );
    expect(first.gemsAdded).toBe(60);

    // Replay del Mismo hito en "otro día": sellado -> 0 gemas (antes pagaba
    // de nuevo hasta el cap diario).
    const replay = await gems.earnGems(
      { reason: 'streak_milestone', meta: { streakDays: 30 }, idempotencyKey: 'earn-sm-2' },
      makeContext()
    );
    expect(replay.alreadyClaimed).toBe(true);
    expect(replay.gemsAdded).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_gems).toBe(60);
    expect(user._paid_streak_milestones).toContain(30);
  });

  test('idempotency log is only sealed when gems were actually added', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    // Cap diario ya agotado -> gemsAdded 0 -> sin sello de log ni de bonos.
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today()}`, { total: 200 });
    const result = await gems.earnGems(
      { reason: 'achievement', achievementId: 'streak_7', idempotencyKey: 'earn-capped-1' },
      makeContext()
    );
    expect(result.gemsAdded).toBe(0);
    expect(admin._getDoc(`transaction_logs/earn-capped-1`) || {}).not.toHaveProperty('createdAt');
  });

  test('NUEVO-fix: keeps the daily bonus seal open when the daily cap cuts the gems', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 7 });
    // Cap de daily_bonus = 30: casi agotado, quedan 3 de los 12 del bono.
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today()}`, { total: 27 });
    const result = await gems.earnGems(
      { reason: 'daily_bonus', meta: { dayStreak: 7 } },
      makeContext()
    );
    expect(result.gemsAdded).toBe(3);
    expect(result.dailyCapped).toBe(true);
    // Pago parcial: NO se sella el día -> el resto se paga en otro día.
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user).not.toHaveProperty('_last_daily_bonus_day');
    expect(user.learning_gems).toBe(3);
  });

  test('NUEVO-fix: keeps the streak milestone seal open when the daily cap cuts the gems', async () => {
    admin._resetFirestore();
    setUserDoc(AUTH_UID, { learning_gems: 0, currentStreak: 30 });
    // Cap de streak_milestone = 200: casi agotado, quedan 8 de los 60 del hito.
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today()}`, { total: 192 });
    const result = await gems.earnGems(
      { reason: 'streak_milestone', meta: { streakDays: 30 } },
      makeContext()
    );
    expect(result.gemsAdded).toBe(8);
    expect(result.dailyCapped).toBe(true);
    // Pago parcial: el hito NO queda sellado -> el resto se paga otro día.
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user._paid_streak_milestones || []).not.toContain(30);
    expect(user.learning_gems).toBe(8);
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

  test('returns lifetimeEarned from the lifetime accumulator', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 42, learning_total_gems: 500 });
    const result = await gems.getGemsBalance({}, makeContext());
    expect(result.lifetimeEarned).toBe(500);
    expect(result.balance).toBe(42);
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
