const functions = require('firebase-functions');
const admin = require('firebase-admin');

// ══════════════════════════════════════════════════════════════════
// INVENTORY — Server-authoritative items & cosmetics (NUEVO-08)
// Special items, consumables and cosmetics are generated and persisted
// SERVER-SIDE. The client never rolls them locally and never writes the
// inventory directly (Firestore rules block it). This closes the vector
// where a modified client could fabricate infinite shields/boosts/elixirs.
// ══════════════════════════════════════════════════════════════════

// Max quantity per item (mirror of lib/models/special_item.dart maxLimit).
const ITEM_MAX_LIMIT = {
  focusElixir: 5,
  phoenixFeather: 3,
  sageMonocle: 4,
  titaniumShield: 3,
  luckBoost: 4,
  timeWarp: 3,
  avatarFrameNeon: 1,
  avatarFrameDragon: 1,
  avatarFrameCrystal: 1,
  avatarFrameSkull: 1,
  avatarFrameGalaxy: 1,
  titleCyberSage: 1,
  titleNightGuardian: 1,
  titleDigitalPhoenix: 1,
  titleShadowHacker: 1,
  titleStormBreaker: 1,
  themeDarkFire: 1,
  themeCyberNeon: 1,
  effectDigitalRain: 1,
  effectFireTrail: 1,
};

exports.ITEM_MAX_LIMIT = ITEM_MAX_LIMIT;

// Shop (gem catalog) item IDs → SpecialItemType names. Used so gem-shop
// purchases are persisted server-side in the inventory (NUEVO-08).
const SHOP_ITEM_TO_SPECIAL = {
  focus_elixir: 'focusElixir',
  luck_boost: 'luckBoost',
  sage_monocle: 'sageMonocle',
  time_warp: 'timeWarp',
  titanium_shield: 'titaniumShield',
  phoenix_feather: 'phoenixFeather',
  avatar_frame_neon: 'avatarFrameNeon',
  avatar_frame_galaxy: 'avatarFrameGalaxy',
  avatar_frame_dragon: 'avatarFrameDragon',
  avatar_frame_crystal: 'avatarFrameCrystal',
  avatar_frame_skull: 'avatarFrameSkull',
  title_storm_breaker: 'titleStormBreaker',
  title_cyber_sage: 'titleCyberSage',
  title_shadow_hacker: 'titleShadowHacker',
  title_night_guardian: 'titleNightGuardian',
  title_digital_phoenix: 'titleDigitalPhoenix',
  effect_digital_rain: 'effectDigitalRain',
  effect_fire_trail: 'effectFireTrail',
  theme_dark_fire: 'themeDarkFire',
  theme_cyber_neon: 'themeCyberNeon',
};

exports.SHOP_ITEM_TO_SPECIAL = SHOP_ITEM_TO_SPECIAL;

// Consumables (usable / decremented). Everything else is a cosmetic.
const CONSUMABLES = new Set([
  'focusElixir',
  'phoenixFeather',
  'sageMonocle',
  'titaniumShield',
  'luckBoost',
  'timeWarp',
]);

const isCosmetic = (name) => ITEM_MAX_LIMIT[name] !== undefined && !CONSUMABLES.has(name);

// Drop chance per chest type (mirror of ChestSpecialDropService).
const DROP_CHANCE = { bronze: 0.0, silver: 0.08, gold: 0.25, legendary: 0.60 };
const LUCK_BOOST_BONUS = 0.15;
const MAX_DROP_CHANCE = 0.95;
const MAX_ITEMS_PER_CHEST = 2;

// Weighted pools per chest type (mirror of ChestSpecialDropService pools).
const ITEM_POOLS = {
  bronze: [],
  silver: [
    ['focusElixir', 45],
    ['luckBoost', 25],
    ['sageMonocle', 18],
    ['titleStormBreaker', 7],
    ['avatarFrameGalaxy', 5],
  ],
  gold: [
    ['focusElixir', 20],
    ['luckBoost', 16],
    ['sageMonocle', 16],
    ['timeWarp', 12],
    ['titaniumShield', 8],
    ['phoenixFeather', 5],
    ['avatarFrameNeon', 4],
    ['avatarFrameGalaxy', 4],
    ['avatarFrameDragon', 3],
    ['titleCyberSage', 3],
    ['titleStormBreaker', 3],
    ['titleShadowHacker', 2],
    ['effectDigitalRain', 2],
    ['themeDarkFire', 2],
    ['titleNightGuardian', 1],
    ['titleDigitalPhoenix', 1],
  ],
  legendary: [
    ['focusElixir', 8],
    ['luckBoost', 7],
    ['sageMonocle', 8],
    ['timeWarp', 7],
    ['titaniumShield', 7],
    ['phoenixFeather', 6],
    ['avatarFrameCrystal', 5],
    ['avatarFrameDragon', 4],
    ['avatarFrameGalaxy', 4],
    ['avatarFrameNeon', 3],
    ['avatarFrameSkull', 2],
    ['titleNightGuardian', 3],
    ['titleShadowHacker', 3],
    ['titleCyberSage', 2],
    ['titleStormBreaker', 2],
    ['titleDigitalPhoenix', 2],
    ['effectDigitalRain', 3],
    ['effectFireTrail', 2],
    ['themeDarkFire', 2],
    ['themeCyberNeon', 1],
  ],
};

/**
 * Rolls the special items/cosmetics for a chest SERVER-SIDE.
 * Never trusts the client chestType (already derived server-side by the
 * caller) and never accepts a forged luck boost: the +15% is only applied
 * from the server-verified luck boost hint, and even then the GRANT itself
 * is capped and persisted here.
 */
function rollSpecialDrops(chestType, luckBoostActive) {
  const baseChance = DROP_CHANCE[chestType] || 0.0;
  let dropChance = baseChance;
  if (luckBoostActive === true) {
    dropChance = Math.min(MAX_DROP_CHANCE, baseChance + LUCK_BOOST_BONUS);
  }
  if (Math.random() > dropChance) {
    return { specialItems: [], cosmeticUnlocks: [] };
  }

  const pool = ITEM_POOLS[chestType] || [];
  if (pool.length === 0) {
    return { specialItems: [], cosmeticUnlocks: [] };
  }

  const itemCount = chestType === 'legendary' && Math.random() < 0.4 ? 2 : 1;
  const used = new Set();
  const specialItems = [];
  const cosmeticUnlocks = [];

  for (let i = 0; i < itemCount && specialItems.length + cosmeticUnlocks.length < MAX_ITEMS_PER_CHEST; i++) {
    const item = weightedPick(pool, used);
    if (!item) continue;
    used.add(item);
    if (isCosmetic(item)) {
      cosmeticUnlocks.push(item);
    } else {
      specialItems.push(item);
    }
  }

  return { specialItems, cosmeticUnlocks };
}

exports.rollSpecialDrops = rollSpecialDrops;

function weightedPick(pool, exclude) {
  const available = pool.filter(([name]) => !exclude.has(name));
  if (available.length === 0) return null;
  const totalWeight = available.reduce((sum, [, weight]) => sum + weight, 0);
  if (totalWeight <= 0) return null;
  let roll = Math.random() * totalWeight;
  for (const [name, weight] of available) {
    roll -= weight;
    if (roll < 0) return name;
  }
  return available[available.length - 1][0];
}

function getInventoryRef(userId) {
  return admin.firestore().doc(`users/${userId}/inventory/state`);
}

exports.getInventoryRef = getInventoryRef;

/**
 * Applies granted drops to the inventory state (inside a transaction).
 * Quantities are clamped to ITEM_MAX_LIMIT; cosmetics are only added once.
 */
function applyDropsToState(state, specialItems, cosmeticUnlocks) {
  const next = {
    specialItems: { ...(state.specialItems || {}) },
    cosmetics: [...(state.cosmetics || [])],
  };
  for (const name of specialItems) {
    if (ITEM_MAX_LIMIT[name] === undefined) continue;
    if (isCosmetic(name)) continue;
    const current = next.specialItems[name] || 0;
    next.specialItems[name] = Math.min(ITEM_MAX_LIMIT[name], current + 1);
  }
  for (const name of cosmeticUnlocks) {
    if (!isCosmetic(name)) continue;
    if (!next.cosmetics.includes(name)) {
      next.cosmetics.push(name);
    }
  }
  return next;
}

exports.applyDropsToState = applyDropsToState;

/**
 * Applies a gem-shop purchase to the inventory state (server-side).
 * Consumables increment (clamped); cosmetics are added once.
 * Returns null when the shop item has no special item mapping.
 */
function applyShopPurchaseToState(state, shopItemId) {
  const specialName = SHOP_ITEM_TO_SPECIAL[shopItemId];
  if (!specialName || ITEM_MAX_LIMIT[specialName] === undefined) return null;

  const next = {
    specialItems: { ...(state.specialItems || {}) },
    cosmetics: [...(state.cosmetics || [])],
  };
  if (isCosmetic(specialName)) {
    if (!next.cosmetics.includes(specialName)) {
      next.cosmetics.push(specialName);
    }
  } else {
    const current = next.specialItems[specialName] || 0;
    next.specialItems[specialName] = Math.min(ITEM_MAX_LIMIT[specialName], current + 1);
  }
  return next;
}

exports.applyShopPurchaseToState = applyShopPurchaseToState;

/**
 * HTTPS Callable: Returns the authoritative inventory for the current user.
 * Includes chest special items/cosmetics plus server-purchased boosts and
 * streak shields (webhook fields the client previously never read).
 */
exports.getInventory = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const stateRef = getInventoryRef(userId);
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const [stateDoc, userDoc] = await Promise.all([stateRef.get(), userRef.get()]);
    const state = stateDoc.data() || {};
    const userData = userDoc.data() || {};

    return {
      success: true,
      specialItems: state.specialItems || {},
      cosmetics: state.cosmetics || [],
      streakShields: userData.streak_shields || 0,
      shopStreakShields: userData.shop_streak_shields || 0,
      purchasedXpBoosts: userData.shop_purchased_xp_boosts || 0,
      purchasedLuckBoosts: userData.shop_purchased_luck_boosts || 0,
    };
  } catch (error) {
    functions.logger.error('getInventory error', error);
    throw new functions.https.HttpsError('internal', 'Error al obtener el inventario');
  }
});

/**
 * HTTPS Callable: Consumes a consumable item server-authoritatively.
 * Validates ownership server-side (quantity >= requested) and decrements.
 */
exports.useInventoryItem = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const userId = context.auth.uid;
  const itemName = data && typeof data.itemName === 'string' ? data.itemName : '';
  const quantity = data && Number.isInteger(data.quantity) && data.quantity > 0 ? data.quantity : 1;

  if (!CONSUMABLES.has(itemName)) {
    throw new functions.https.HttpsError('invalid-argument', 'Item no consumible o desconocido');
  }

  const stateRef = getInventoryRef(userId);
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [stateDoc, userDoc] = await Promise.all([
        transaction.get(stateRef),
        transaction.get(userRef),
      ]);
      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const state = stateDoc.data() || {};
      const current = (state.specialItems && state.specialItems[itemName]) || 0;
      if (current < quantity) {
        throw new functions.https.HttpsError('failed-precondition', 'No tienes suficientes items');
      }

      const nextSpecialItems = {
        ...(state.specialItems || {}),
        [itemName]: current - quantity,
      };

      transaction.set(stateRef, {
        specialItems: nextSpecialItems,
        cosmetics: state.cosmetics || [],
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });

      return {
        success: true,
        itemName,
        consumed: quantity,
        specialItems: nextSpecialItems,
      };
    });

    return result;
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('useInventoryItem error', error);
    throw new functions.https.HttpsError('internal', 'Error al usar el item');
  }
});
