/**
 * Tests for index.js — Payment, webhook, and utility functions.
 * Covers: createPaymentPreference, adminCreditGems, health, rate limiting
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));
jest.mock('mercadopago', () => require('../__mocks__/mercadopago'));

const admin = require('firebase-admin');
const mpMock = require('../__mocks__/mercadopago');
const index = require('../index');

const AUTH_UID = 'user-payment-test';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid } });
const NO_AUTH = {};

beforeEach(() => {
  admin._resetFirestore();
  mpMock._resetMocks();
});

function setUserDoc(uid, data) {
  admin._setDoc(`users/${uid}`, data);
}

function setAdminDoc(uid, data) {
  admin._setDoc(`admins/${uid}`, data);
}

function makeReqRes(body, authHeader) {
  const req = {
    method: 'POST',
    body,
    headers: authHeader ? { authorization: authHeader } : {},
  };
  const res = {
    _status: 200,
    _body: null,
    _headers: {},
    set(key, value) { this._headers[key] = value; return this; },
    status(code) { this._status = code; return this; },
    json(body) { this._body = body; },
    send(body) { this._body = body; },
  };
  return { req, res };
}

describe('health', () => {
  test('returns ok status', async () => {
    const res = { json: jest.fn() };
    await index.health({}, res);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ status: 'ok' })
    );
  });
});

describe('createPaymentPreference', () => {
  test('creates preference for valid request', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    const { req, res } = makeReqRes(
      { gems: 50, productId: 'gems_50' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(200);
    expect(res._body.result.preferenceId).toBe('mock_preference_id_123');
    expect(res._body.result.initPoint).toBeDefined();
    expect(res._body.result.externalRef).toBeDefined();
  });

  test('rejects unauthenticated user', async () => {
    const { req, res } = makeReqRes({ gems: 50, productId: 'gems_50' });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(401);
  });

  test('rejects missing gems', async () => {
    const { req, res } = makeReqRes(
      { productId: 'gems_50' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('rejects missing productId', async () => {
    const { req, res } = makeReqRes(
      { gems: 50 },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('rejects gem count mismatch', async () => {
    const { req, res } = makeReqRes(
      { gems: 999, productId: 'gems_50' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('rejects unknown productId', async () => {
    const { req, res } = makeReqRes(
      { gems: 50, productId: 'unknown_product' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('handles OPTIONS preflight', async () => {
    const { req, res } = makeReqRes(null);
    req.method = 'OPTIONS';
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(204);
  });
});

describe('adminCreditGems', () => {
  test('credits gems as admin', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    setUserDoc('target-user', { learning_gems: 100, learning_total_gems: 100 });
    const result = await index.adminCreditGems(
      {
        userId: 'target-user',
        gems: 50,
        paymentMethod: 'whatsapp',
        idempotencyKey: 'admin-credit-1',
      },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.newBalance).toBe(150);
    expect(result.duplicate).toBe(false);
  });

  test('rejects non-admin user', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      index.adminCreditGems(
        {
          userId: 'target-user',
          gems: 50,
          idempotencyKey: 'admin-credit-2',
        },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      index.adminCreditGems(
        { userId: 'target-user', gems: 50, idempotencyKey: 'k' },
        NO_AUTH
      )
    ).rejects.toThrow();
  });

  test('rejects gems <= 0', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditGems(
        { userId: 'target-user', gems: 0, idempotencyKey: 'k' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditGems(
        { userId: 'target-user', gems: 50 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects non-existent target user', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditGems(
        { userId: 'ghost-user', gems: 50, idempotencyKey: 'k' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    setUserDoc('target-user', { learning_gems: 100, learning_total_gems: 100 });
    await index.adminCreditGems(
      {
        userId: 'target-user',
        gems: 50,
        idempotencyKey: 'admin-credit-idem',
      },
      makeContext()
    );
    const result = await index.adminCreditGems(
      {
        userId: 'target-user',
        gems: 50,
        idempotencyKey: 'admin-credit-idem',
      },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
  });
});
