/**
 * Tests for index.js — Payment, webhook, and utility functions.
 * Covers: health, createPaymentPreference, adminCreditDonation,
 * registerPendingPayment, checkPendingPaymentStatus, validatePurchase.
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));
jest.mock('mercadopago', () => require('../__mocks__/mercadopago'));

const admin = require('firebase-admin');
const mpMock = require('../__mocks__/mercadopago');
const functions = require('firebase-functions');
const index = require('../index');

const AUTH_UID = 'user-payment-test';
const PURCHASE_SECRET = 'test-purchase-secret-key';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid } });
const NO_AUTH = {};

functions.config = jest.fn(() => ({
  app: { purchase_secret: PURCHASE_SECRET },
}));

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
    headers: authHeader ? { authorization: authHeader, origin: 'https://sagen-bdd3f.web.app' } : { origin: 'https://sagen-bdd3f.web.app' },
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
    setUserDoc(AUTH_UID, { totalDonated: 0 });
    const { req, res } = makeReqRes(
      { amount: 3, productId: 'donate_basic' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(200);
    expect(res._body.result.preferenceId).toBe('mock_preference_id_123');
    expect(res._body.result.initPoint).toBeDefined();
    expect(res._body.result.externalRef).toBeDefined();
  });

  test('rejects request without origin header', async () => {
    const { req, res } = makeReqRes({ amount: 3, productId: 'donate_basic' });
    delete req.headers.origin;
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(403);
  });

  test('rejects disallowed origin', async () => {
    const { req, res } = makeReqRes({ amount: 3, productId: 'donate_basic' });
    req.headers.origin = 'https://evil.example.com';
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(403);
  });

  test('rejects unauthenticated user', async () => {
    const { req, res } = makeReqRes({ amount: 3, productId: 'donate_basic' });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(401);
  });

  test('rejects missing amount', async () => {
    const { req, res } = makeReqRes(
      { productId: 'donate_basic' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('rejects missing productId', async () => {
    const { req, res } = makeReqRes(
      { amount: 3 },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('rejects amount that does not match catalog', async () => {
    const { req, res } = makeReqRes(
      { amount: 999, productId: 'donate_basic' },
      'Bearer fake-token-for-test'
    );
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(400);
  });

  test('rejects unknown productId', async () => {
    const { req, res } = makeReqRes(
      { amount: 50, productId: 'unknown_product' },
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

describe('adminCreditDonation', () => {
  test('credits donation as admin', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    setUserDoc('target-user', { totalDonated: 100 });
    const result = await index.adminCreditDonation(
      {
        userId: 'target-user',
        amount: 50,
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
    setUserDoc(AUTH_UID, { totalDonated: 0 });
    await expect(
      index.adminCreditDonation(
        {
          userId: 'target-user',
          amount: 50,
          idempotencyKey: 'admin-credit-2',
        },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      index.adminCreditDonation(
        { userId: 'target-user', amount: 50, idempotencyKey: 'k' },
        NO_AUTH
      )
    ).rejects.toThrow();
  });

  test('rejects amount <= 0', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditDonation(
        { userId: 'target-user', amount: 0, idempotencyKey: 'k' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditDonation(
        { userId: 'target-user', amount: 50 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects non-existent target user', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditDonation(
        { userId: 'ghost-user', amount: 50, idempotencyKey: 'k' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    setUserDoc('target-user', { totalDonated: 100 });
    await index.adminCreditDonation(
      {
        userId: 'target-user',
        amount: 50,
        idempotencyKey: 'admin-credit-idem',
      },
      makeContext()
    );
    const result = await index.adminCreditDonation(
      {
        userId: 'target-user',
        amount: 50,
        idempotencyKey: 'admin-credit-idem',
      },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
  });

  test('grants SAGEN PASS: premium flag, question bank, and gems', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    setUserDoc('pass-user', { totalDonated: 0, learning_gems: 100 });
    const result = await index.adminCreditDonation(
      {
        userId: 'pass-user',
        amount: 9.90,
        paymentMethod: 'whatsapp',
        productId: 'sagen_pass',
        idempotencyKey: 'admin-pass-1',
      },
      makeContext()
    );
    expect(result.success).toBe(true);
    const user = admin._getDoc('users/pass-user');
    expect(user.sagen_pass_active).toBe(true);
    expect(user.premium_question_bank).toBe(true);
    expect(user.learning_gems).toBe(600);
  });
});

describe('registerPendingPayment', () => {
  test('registers a pending payment', async () => {
    const result = await index.registerPendingPayment(
      {
        paymentMethod: 'whatsapp',
        operationId: 'op-1',
        amount: 10,
        productId: 'donate_basic',
      },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.pendingPaymentId).toBe(`${AUTH_UID}_op-1`);
  });

  test('rejects invalid payment method', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'bitcoin', operationId: 'op-2' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing operationId', async () => {
    await expect(
      index.registerPendingPayment({ paymentMethod: 'whatsapp' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'whatsapp', operationId: 'op-3' },
        NO_AUTH
      )
    ).rejects.toThrow();
  });
});

describe('checkPendingPaymentStatus', () => {
  test('returns status of own pending payment', async () => {
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);
    admin._setDoc(`pending_payments/${AUTH_UID}_op-1`, {
      userId: AUTH_UID,
      status: 'pending',
      createdAt: { toDate: () => new Date() },
      expiresAt: { toDate: () => expiresAt },
    });
    setUserDoc(AUTH_UID, { totalDonated: 42 });
    const result = await index.checkPendingPaymentStatus(
      { pendingPaymentId: `${AUTH_UID}_op-1` },
      makeContext()
    );
    expect(result.status).toBe('pending');
    expect(result.serverBalance).toBe(42);
    expect(result.isExpired).toBe(false);
  });

  test('returns not_found for missing payment', async () => {
    const result = await index.checkPendingPaymentStatus(
      { pendingPaymentId: 'nope' },
      makeContext()
    );
    expect(result.status).toBe('not_found');
  });

  test('rejects access to another users payment', async () => {
    admin._setDoc(`pending_payments/other_uid_op-1`, {
      userId: 'other_uid',
      status: 'pending',
    });
    await expect(
      index.checkPendingPaymentStatus(
        { pendingPaymentId: 'other_uid_op-1' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      index.checkPendingPaymentStatus({ pendingPaymentId: 'x' }, NO_AUTH)
    ).rejects.toThrow();
  });
});

describe('validatePurchase', () => {
  test('issues signed token when balance is sufficient', async () => {
    setUserDoc(AUTH_UID, { totalDonated: 200 });
    const result = await index.validatePurchase(
      { cost: 50, itemId: 'bundle_xp' },
      makeContext()
    );
    expect(result.valid).toBe(true);
    expect(result.totalDonated).toBe(200);
    expect(result.token).toBeDefined();
  });

  test('rejects insufficient donation balance', async () => {
    setUserDoc(AUTH_UID, { totalDonated: 10 });
    await expect(
      index.validatePurchase(
        { cost: 50, itemId: 'bundle_xp' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects missing cost or itemId', async () => {
    setUserDoc(AUTH_UID, { totalDonated: 200 });
    await expect(
      index.validatePurchase({ cost: 50 }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      index.validatePurchase({ cost: 10, itemId: 'x' }, NO_AUTH)
    ).rejects.toThrow();
  });
});
