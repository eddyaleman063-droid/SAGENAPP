/**
 * Canonical SAGEN product catalog — SINGLE SOURCE OF TRUTH.
 *
 * The client (lib/models/product.dart) defines the canonical product IDs,
 * amounts and bonuses. Both backends (Cloud Functions and the Vercel API)
 * MUST use THIS module so createPaymentPreference and the webhook bonus
 * grants resolve identically regardless of which backend processes a payment.
 *
 * Keep this in sync with lib/models/product.dart.
 */
const SAGEN_PASS_GEMS = 500;

const hardcodedCatalog = {
  'donation_basic':    { amount: 3,   title: 'Donación Básica - SAGEN',     price: 3.00,  bonuses: [] },
  'donation_standard': { amount: 5,   title: 'Donación Estándar - SAGEN',   price: 5.00,  bonuses: [] },
  'donation_premium':  { amount: 10,  title: 'Donación Premium - SAGEN',    price: 10.00, bonuses: [] },
  'bundle_protector':  { amount: 12,  title: 'Pack Protegido - SAGEN',      price: 12.00, bonuses: [{ type: 'streakProtector', quantity: 1 }] },
  'bundle_xp':         { amount: 20,  title: 'Pack Impulso - SAGEN',        price: 20.00, bonuses: [{ type: 'xpBoost', quantity: 1 }] },
  'bundle_luck':       { amount: 24,  title: 'Pack Suerte - SAGEN',         price: 24.00, bonuses: [{ type: 'luckBoost', quantity: 1 }] },
  'sagen_pass':        { amount: 9.90, title: 'SAGEN PASS',                  price: 9.90,  bonuses: [{ type: 'sagenPass', quantity: 1, gems: SAGEN_PASS_GEMS }] },
};

const CATALOG_CACHE_TTL = 5 * 60 * 1000;

function createCatalog(admin, logger) {
  let _catalogCache = null;
  let _catalogCacheTime = 0;

  async function loadCatalog() {
    const now = Date.now();
    if (_catalogCache && (now - _catalogCacheTime) < CATALOG_CACHE_TTL) {
      return _catalogCache;
    }
    try {
      const snap = await admin.firestore().doc('config/productCatalog').get();
      if (snap.exists) {
        const data = snap.data();
        _catalogCache = data.products || hardcodedCatalog;
        _catalogCacheTime = now;
        return _catalogCache;
      }
    } catch (e) {
      const warn = (logger && logger.warn) ? logger.warn : console.warn;
      warn('Failed to load catalog from Firestore, using hardcoded', { error: e.message });
    }
    _catalogCache = hardcodedCatalog;
    _catalogCacheTime = now;
    return _catalogCache;
  }

  async function getProductDetails(productId) {
    const catalog = await loadCatalog();
    const item = catalog[productId];
    if (item) return item;
    return null;
  }

  return { loadCatalog, getProductDetails };
}

module.exports = hardcodedCatalog;
module.exports.SAGEN_PASS_GEMS = SAGEN_PASS_GEMS;
module.exports.createCatalog = createCatalog;
