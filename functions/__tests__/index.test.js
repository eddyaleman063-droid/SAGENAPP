/**
 * Tests for index.js — Payment, webhook, and utility functions.
 * Covers: health, createPaymentPreference, adminCreditDonation,
 * registerPendingPayment, checkPendingPaymentStatus.
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
const makeContext = (uid = AUTH_UID) => ({ auth: { uid, token: { email_verified: true } } });
const NO_AUTH = {};
const makeUnverifiedContext = (uid = AUTH_UID) => ({ auth: { uid, token: { email_verified: false } } });

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
    setUserDoc(AUTH_UID, { total_donated: 0 });
    const { req, res } = makeReqRes(
      { amount: 3, productId: 'donation_basic' },
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
    const { req, res } = makeReqRes({ amount: 3, productId: 'donation_basic' });
    delete req.headers.origin;
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(403);
  });

  test('rejects disallowed origin', async () => {
    const { req, res } = makeReqRes({ amount: 3, productId: 'donation_basic' });
    req.headers.origin = 'https://evil.example.com';
    admin._setVerifyIdTokenResult({ uid: AUTH_UID });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(403);
  });

  test('rejects unauthenticated user', async () => {
    const { req, res } = makeReqRes({ amount: 3, productId: 'donation_basic' });
    await index.createPaymentPreference(req, res);
    expect(res._status).toBe(401);
  });

  test('rejects unverified user (requiere email_verified)', async () => {
    await expect(index.registerPendingPayment({}, makeUnverifiedContext())).rejects.toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('rejects missing amount', async () => {
    const { req, res } = makeReqRes(
      { productId: 'donation_basic' },
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
      { amount: 999, productId: 'donation_basic' },
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
    setUserDoc('target-user', { total_donated: 100 });
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
    setUserDoc(AUTH_UID, { total_donated: 0 });
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

  test('rejects amount over the cap', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditDonation(
        { userId: 'target-user', amount: 100001, idempotencyKey: 'k' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects userId with path-injection characters', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditDonation(
        { userId: 'target/../user', amount: 50, idempotencyKey: 'k' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects invalid idempotencyKey', async () => {
    setAdminDoc(AUTH_UID, { role: 'admin' });
    await expect(
      index.adminCreditDonation(
        { userId: 'target-user', amount: 50, idempotencyKey: 'a/b' },
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
    setUserDoc('target-user', { total_donated: 100 });
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
    setUserDoc('pass-user', { total_donated: 0, learning_gems: 100 });
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
        productId: 'donation_basic',
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

  test('rejects non-numeric amount', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'whatsapp', operationId: 'op-3', amount: '10' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects amount <= 0', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'whatsapp', operationId: 'op-4', amount: 0 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects amount over the cap', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'whatsapp', operationId: 'op-5', amount: 100001 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects operationId with path-injection characters', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'whatsapp', operationId: 'op/../../evil', amount: 10 },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      index.registerPendingPayment(
        { paymentMethod: 'whatsapp', operationId: 'op-6' },
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
    setUserDoc(AUTH_UID, { total_donated: 42 });
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
  test('removed: real purchase flow uses spendGems, not validatePurchase (NUEVO-14)', () => {
    expect(typeof index.validatePurchase).toBe('undefined');
  });
});

describe('handlePaymentWebhook', () => {
  const crypto = require('crypto');
  const WEBHOOK_SECRET = 'test-webhook-secret';
  const origConfig = functions.config;

  function signedReq(body, { signature } = {}) {
    // NUEVO-fix (A1): firma con el algoritmo OFICIAL de Mercado Pago:
    // manifest `id:<data.id>;request-id:<x-request-id>;ts:<ts>;`, header
    // x-signature separado por comas, data.id como query param.
    const ts = String(Math.floor(Date.now() / 1000));
    const reqId = 'test-request-id-123';
    const dataId = String(body.data?.id || '');
    const manifest = `id:${dataId};request-id:${reqId};ts:${ts};`;
    const expected = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(manifest)
      .digest('hex');
    return {
      method: 'POST',
      body,
      query: { 'data.id': dataId },
      headers: {
        origin: 'https://sagen-bdd3f.web.app',
        'x-signature': signature === undefined ? `ts=${ts},v1=${expected}` : signature,
        'x-request-id': reqId,
      },
    };
  }

  const res = () => ({
    _status: 200,
    _body: null,
    status(code) { this._status = code; return this; },
    send(body) { this._body = body; },
  });

  beforeEach(() => {
    functions.config = jest.fn(() => ({
      mercadopago: { webhook_secret: WEBHOOK_SECRET, access_token: 'test-token' },
    }));
  });

  afterEach(() => {
    functions.config = origConfig;
    if (global.fetch && global.fetch.mockRestore) global.fetch.mockRestore();
  });

  test('rejects webhook without signature', async () => {
    const r = res();
    const req = { method: 'POST', body: { type: 'payment', data: { id: 'pay_1' } }, headers: {} };
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects webhook with mismatched signature', async () => {
    const r = res();
    const req = signedReq({ type: 'payment', data: { id: 'pay_1' } }, { signature: 'ts=1,v1=deadbeef' });
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(401);
  });

  test('NUEVO-fix A1: rejects signature computed for a different data.id', async () => {
    const ts = String(Math.floor(Date.now() / 1000));
    const reqId = 'test-request-id-123';
    const wrongManifest = `id:forgeable-id;request-id:${reqId};ts:${ts};`;
    const wrongSig = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(wrongManifest)
      .digest('hex');
    const r = res();
    const req = signedReq(
      { type: 'payment', data: { id: 'pay_3' } },
      { signature: `ts=${ts},v1=${wrongSig}` }
    );
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(401);
  });

  test('NUEVO-fix A1: accepts an authentically signed webhook (reaches MP fetch)', async () => {
    global.fetch = jest.fn().mockResolvedValue({ ok: false, status: 500 });
    const r = res();
    const req = signedReq({ type: 'payment', data: { id: 'pay_4' } });
    await index.handlePaymentWebhook(req, r);
    expect(global.fetch).toHaveBeenCalled();
    expect(r._status).toBe(502);
  });

  test('NUEVO-fix A1: rejects webhook without x-request-id', async () => {
    const ts = String(Math.floor(Date.now() / 1000));
    const dataId = 'pay_5';
    const manifest = `id:${dataId};ts:${ts};`;
    const expected = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(manifest)
      .digest('hex');
    const r = res();
    const req = {
      method: 'POST',
      body: { type: 'payment', data: { id: dataId } },
      query: { 'data.id': dataId },
      headers: {
        origin: 'https://sagen-bdd3f.web.app',
        'x-signature': `ts=${ts},v1=${expected}`,
      },
    };
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(401);
  });

  test('NUEVO-fix A1: rejects stale timestamp (replay)', async () => {
    const staleTs = '1704908010';
    const reqId = 'test-request-id-123';
    const dataId = 'pay_6';
    const manifest = `id:${dataId};request-id:${reqId};ts:${staleTs};`;
    const expected = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(manifest)
      .digest('hex');
    const r = res();
    const req = {
      method: 'POST',
      body: { type: 'payment', data: { id: dataId } },
      query: { 'data.id': dataId },
      headers: {
        origin: 'https://sagen-bdd3f.web.app',
        'x-signature': `ts=${staleTs},v1=${expected}`,
        'x-request-id': reqId,
      },
    };
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(401);
  });

  test('returns 502 when MercadoPago fetch fails so MP retries', async () => {
    global.fetch = jest.fn().mockResolvedValue({ ok: false, status: 500 });
    const r = res();
    const req = signedReq({ type: 'payment', data: { id: 'pay_2' } });
    await index.handlePaymentWebhook(req, r);
    expect(global.fetch).toHaveBeenCalled();
    expect(r._status).toBe(502);
  });

  function refundedPayment(status) {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({ status, transaction_amount: 10 }),
    });
  }

  test('NUEVO-fix A2: refund reverts the granted benefits', async () => {
    setUserDoc('refund-uid', {
      total_donated: 10,
      is_supporter: true,
      shop_streak_shields: 1,
    });
    admin._setDoc('payment_logs/pay_refund_1', {
      userId: 'refund-uid',
      amount: 10,
      status: 'approved',
      bonuses: [{ type: 'streakProtector', quantity: 1 }],
      granted: { total_donated: 10, shop_streak_shields: 1, is_supporter: true },
    });
    refundedPayment('refunded');
    const r = res();
    const req = signedReq({ type: 'payment', data: { id: 'pay_refund_1' } });
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(200);
    const user = admin._getDoc('users/refund-uid');
    expect(user.total_donated).toBe(0);
    expect(user.is_supporter).toBe(false);
    expect(user.shop_streak_shields).toBe(0);
    expect(admin._getDoc('payment_logs/pay_refund_1').status).toBe('refunded');
  });

  test('NUEVO-fix A2: refund reversal is idempotent on replay', async () => {
    setUserDoc('refund-uid2', { total_donated: 5, is_supporter: true });
    admin._setDoc('payment_logs/pay_refund_2', {
      userId: 'refund-uid2',
      amount: 5,
      status: 'approved',
      bonuses: [],
      granted: { total_donated: 5, is_supporter: true },
    });
    refundedPayment('refunded');
    const r1 = res();
    await index.handlePaymentWebhook(
      signedReq({ type: 'payment', data: { id: 'pay_refund_2' } }),
      r1,
    );
    const r2 = res();
    await index.handlePaymentWebhook(
      signedReq({ type: 'payment', data: { id: 'pay_refund_2' } }),
      r2,
    );
    expect(r1._status).toBe(200);
    expect(r2._status).toBe(200);
    // Segundo proceso es no-op: total_donated no vuelve a bajar.
    expect(admin._getDoc('users/refund-uid2').total_donated).toBe(0);
  });

  test('NUEVO-fix A2: chargeback with SAGEN PASS reverts gems and flags', async () => {
    setUserDoc('pass-uid', {
      total_donated: 9.9,
      is_supporter: true,
      learning_gems: 500,
      sagen_pass_active: true,
      premium_question_bank: true,
    });
    admin._setDoc('payment_logs/pay_chargeback_1', {
      userId: 'pass-uid',
      amount: 9.9,
      status: 'approved',
      bonuses: [{ type: 'sagenPass', quantity: 1, gems: 500 }],
      granted: {
        total_donated: 9.9,
        learning_gems: 500,
        is_supporter: true,
        sagen_pass_granted: true,
      },
    });
    refundedPayment('charged_back');
    const r = res();
    const req = signedReq({ type: 'payment', data: { id: 'pay_chargeback_1' } });
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(200);
    const user = admin._getDoc('users/pass-uid');
    expect(user.total_donated).toBe(0);
    expect(user.is_supporter).toBe(false);
    expect(user.learning_gems).toBe(0);
    expect(user.sagen_pass_active).toBe(false);
    expect(user.premium_question_bank).toBe(false);
  });

  test('NUEVO-fix A2: refund keeps supporter when other donations remain', async () => {
    setUserDoc('multi-uid', { total_donated: 30, is_supporter: true });
    admin._setDoc('payment_logs/pay_refund_3', {
      userId: 'multi-uid',
      amount: 10,
      status: 'approved',
      bonuses: [],
      granted: { total_donated: 10, is_supporter: true },
    });
    refundedPayment('refunded');
    const r = res();
    await index.handlePaymentWebhook(
      signedReq({ type: 'payment', data: { id: 'pay_refund_3' } }),
      r,
    );
    expect(r._status).toBe(200);
    const user = admin._getDoc('users/multi-uid');
    expect(user.total_donated).toBe(20);
    expect(user.is_supporter).toBe(true);
  });

  test('NUEVO-fix A2: refund of a never-credited payment is a no-op OK', async () => {
    refundedPayment('refunded');
    const r = res();
    const req = signedReq({ type: 'payment', data: { id: 'pay_ghost' } });
    await index.handlePaymentWebhook(req, r);
    expect(r._status).toBe(200);
    expect(admin._getDoc('payment_logs/pay_ghost')).toBeNull();
  });
});
