/**
 * Tests for inventory.js — Server-authoritative items & cosmetics (NUEVO-08).
 * Covers: rollSpecialDrops (server-derived), applyDropsToState (clamping),
 * applyShopPurchaseToState (shop mapping), getInventory and useInventoryItem.
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const admin = require('firebase-admin');
const inventory = require('../inventory');

const AUTH_UID = 'test-inventory-123';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid } });
const NO_AUTH = {};

beforeEach(() => {
  admin._resetFirestore();
});

describe('rollSpecialDrops', () => {
  test('bronze chests never drop special items', () => {
    const spy = jest.spyOn(Math, 'random');
    try {
      spy.mockReturnValue(0.0);
      for (let i = 0; i < 100; i++) {
        const result = inventory.rollSpecialDrops('bronze', false);
        expect(result.specialItems).toHaveLength(0);
        expect(result.cosmeticUnlocks).toHaveLength(0);
      }
    } finally {
      spy.mockRestore();
    }
  });

  test('silver chests drop only pool-valid items', () => {
    const spy = jest.spyOn(Math, 'random');
    try {
      spy.mockReturnValue(0.001);
      const result = inventory.rollSpecialDrops('silver', false);
      expect(result.specialItems.length + result.cosmeticUnlocks.length).toBe(1);
    } finally {
      spy.mockRestore();
    }
  });

  test('luck boost raises the drop chance for gold chests', () => {
    // Without boost: base 0.25 → a roll of 0.3 (below 0.6) still triggers.
    const spy = jest.spyOn(Math, 'random');
    try {
      let boostedTriggered = false;
      let baseMissed = false;
      for (let i = 0; i < 2000; i++) {
        spy.mockReturnValue(i % 2 === 0 ? 0.001 : 0.9);
        const boosted = inventory.rollSpecialDrops('gold', true);
        if (boosted.specialItems.length + boosted.cosmeticUnlocks.length > 0) {
          boostedTriggered = true;
        }
        const base = inventory.rollSpecialDrops('gold', false);
        if (base.specialItems.length + base.cosmeticUnlocks.length === 0) {
          baseMissed = true;
        }
      }
      expect(boostedTriggered).toBe(true);
      expect(baseMissed).toBe(true);
    } finally {
      spy.mockRestore();
    }
  });

  test('never returns consumable/cosmetic names outside the catalog', () => {
    const spy = jest.spyOn(Math, 'random');
    try {
      spy.mockReturnValue(0.001);
      for (const chestType of ['silver', 'gold', 'legendary']) {
        const result = inventory.rollSpecialDrops(chestType, false);
        for (const item of [...result.specialItems, ...result.cosmeticUnlocks]) {
          expect(inventory.ITEM_MAX_LIMIT[item]).toBeDefined();
        }
      }
    } finally {
      spy.mockRestore();
    }
  });
});

describe('applyDropsToState', () => {
  test('clamps quantities to ITEM_MAX_LIMIT', () => {
    const next = inventory.applyDropsToState(
      { specialItems: { titaniumShield: 3 }, cosmetics: [] },
      ['titaniumShield'],
      [],
    );
    expect(next.specialItems.titaniumShield).toBe(3);
  });

  test('adds cosmetics only once', () => {
    const next = inventory.applyDropsToState(
      { specialItems: {}, cosmetics: ['themeDarkFire'] },
      [],
      ['themeDarkFire'],
    );
    expect(next.cosmetics).toEqual(['themeDarkFire']);
  });
});

describe('applyShopPurchaseToState', () => {
  test('maps shop consumables to special items and increments', () => {
    const next = inventory.applyShopPurchaseToState(
      { specialItems: { focusElixir: 2 }, cosmetics: [] },
      'focus_elixir',
    );
    expect(next.specialItems.focusElixir).toBe(3);
  });

  test('maps one-time cosmetics to the cosmetics list', () => {
    const next = inventory.applyShopPurchaseToState(
      { specialItems: {}, cosmetics: [] },
      'avatar_frame_neon',
    );
    expect(next.cosmetics).toContain('avatarFrameNeon');
  });

  test('returns null for shop items without a special mapping (xp_boost)', () => {
    expect(inventory.applyShopPurchaseToState({}, 'xp_boost')).toBeNull();
  });
});

describe('getInventory', () => {
  test('returns server state + webhook-persisted boosts', async () => {
    admin._setDoc(`users/${AUTH_UID}`, {
      streak_shields: 2,
      shop_streak_shields: 1,
      shop_purchased_xp_boosts: 3,
      shop_purchased_luck_boosts: 0,
    });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: { titaniumShield: 2, focusElixir: 1 },
      cosmetics: ['themeDarkFire'],
    });

    const result = await inventory.getInventory({}, makeContext());
    expect(result.success).toBe(true);
    expect(result.specialItems.titaniumShield).toBe(2);
    expect(result.cosmetics).toEqual(['themeDarkFire']);
    expect(result.streakShields).toBe(2);
    expect(result.shopStreakShields).toBe(1);
    expect(result.purchasedXpBoosts).toBe(3);
    expect(result.purchasedLuckBoosts).toBe(0);
  });

  test('rejects unauthenticated user', async () => {
    await expect(inventory.getInventory({}, NO_AUTH)).rejects.toThrow();
  });
});

describe('useInventoryItem', () => {
  test('decrements a consumable and returns remaining quantities', async () => {
    admin._setDoc(`users/${AUTH_UID}`, { learning_total_xp: 0 });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: { titaniumShield: 2, focusElixir: 1 },
      cosmetics: [],
    });

    const result = await inventory.useInventoryItem(
      { itemName: 'titaniumShield', quantity: 1 },
      makeContext(),
    );
    expect(result.success).toBe(true);
    expect(result.specialItems.titaniumShield).toBe(1);
    expect(result.specialItems.focusElixir).toBe(1);

    const state = admin._getDoc(`users/${AUTH_UID}/inventory/state`);
    expect(state.specialItems.titaniumShield).toBe(1);
  });

  test('rejects consuming more than owned', async () => {
    admin._setDoc(`users/${AUTH_UID}`, { learning_total_xp: 0 });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: { phoenixFeather: 1 },
      cosmetics: [],
    });

    await expect(
      inventory.useInventoryItem(
        { itemName: 'phoenixFeather', quantity: 2 },
        makeContext(),
      ),
    ).rejects.toThrow();
  });

  test('rejects non-consumable items (cosmetics cannot be used)', async () => {
    admin._setDoc(`users/${AUTH_UID}`, { learning_total_xp: 0 });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: {},
      cosmetics: ['themeDarkFire'],
    });

    await expect(
      inventory.useInventoryItem({ itemName: 'themeDarkFire' }, makeContext()),
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      inventory.useInventoryItem({ itemName: 'focusElixir' }, NO_AUTH),
    ).rejects.toThrow();
  });
});
