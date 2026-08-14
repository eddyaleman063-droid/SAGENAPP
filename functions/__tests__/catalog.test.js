/**
 * Contract tests for the product catalog.
 * The client (lib/models/product.dart) is the SOURCE OF TRUTH for product
 * IDs, amounts and bonuses. Both backends (Cloud Functions and Vercel API)
 * consume the shared module functions/catalog.js, so createPaymentPreference
 * and the webhook bonuses resolve identically regardless of backend.
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));
jest.mock('mercadopago', () => require('../__mocks__/mercadopago'));

const admin = require('firebase-admin');
const functions = require('firebase-functions');
const index = require('../index');
const sharedCatalog = require('../catalog');

const AUTH_UID = 'user-catalog-test';
const makeReqRes = (body) => {
  const req = {
    method: 'POST',
    body,
    headers: { authorization: 'Bearer fake-token-for-test', origin: 'https://sagen-bdd3f.web.app' },
  };
  const res = {
    _status: 200,
    _body: null,
    set() { return this; },
    status(code) { this._status = code; return this; },
    json(body) { this._body = body; },
    send(body) { this._body = body; },
  };
  return { req, res };
};

functions.config = jest.fn(() => ({
  app: { purchase_secret: 'test-purchase-secret-key' },
  mercadopago: { access_token: 'TEST-TOKEN' },
}));

beforeEach(() => {
  admin._resetFirestore();
});

// Canonical client product set — mirrors lib/models/product.dart
const canonicalProducts = {
  donation_basic: { amount: 3, price: 3.00, bonuses: [] },
  donation_standard: { amount: 5, price: 5.00, bonuses: [] },
  donation_premium: { amount: 10, price: 10.00, bonuses: [] },
  bundle_protector: { amount: 12, price: 12.00, bonuses: [{ type: 'streakProtector', quantity: 1 }] },
  bundle_xp: { amount: 20, price: 20.00, bonuses: [{ type: 'xpBoost', quantity: 1 }] },
  bundle_luck: { amount: 24, price: 24.00, bonuses: [{ type: 'luckBoost', quantity: 1 }] },
};

describe('shared catalog module', () => {
  test('exposes every canonical client product with matching amount, price and bonuses', async () => {
    const service = sharedCatalog.createCatalog(admin, { warn: jest.fn() });
    const catalog = await service.loadCatalog();
    for (const [productId, product] of Object.entries(canonicalProducts)) {
      const item = catalog[productId];
      expect(item).toBeDefined();
      expect(item.amount).toBe(product.amount);
      expect(item.price).toBe(product.price);
      expect(item.bonuses).toEqual(product.bonuses);
    }
  });

  test('getProductDetails resolves every canonical product', async () => {
    const service = sharedCatalog.createCatalog(admin, { warn: jest.fn() });
    for (const productId of Object.keys(canonicalProducts)) {
      await expect(service.getProductDetails(productId)).resolves.toBeDefined();
    }
  });

  test('sagen_pass carries the SAGEN_PASS_GEMS bonus', () => {
    expect(sharedCatalog.SAGEN_PASS_GEMS).toBe(500);
    const pass = sharedCatalog['sagen_pass'];
    expect(pass.amount).toBe(9.90);
    expect(pass.bonuses).toEqual([{ type: 'sagenPass', quantity: 1, gems: 500 }]);
  });

  test('both backends import the shared catalog module', () => {
    const indexSrc = require('fs').readFileSync(require('path').join(__dirname, '..', 'index.js'), 'utf8');
    const apiSrc = require('fs').readFileSync(require('path').join(__dirname, '..', '..', 'api', 'index.js'), 'utf8');
    expect(indexSrc).toContain("require('./catalog')");
    expect(apiSrc).toContain("require('../functions/catalog')");
  });
});

describe('catalog contract (Cloud Functions)', () => {
  test('accepts every canonical client product with matching amount', async () => {
    for (const [productId, product] of Object.entries(canonicalProducts)) {
      admin._setVerifyIdTokenResult({ uid: AUTH_UID });
      const { req, res } = makeReqRes({ amount: product.amount, productId });
      await index.createPaymentPreference(req, res);
      expect(res._status).toBe(200);
      expect(res._body.result.preferenceId).toBeDefined();
    }
  });
});
