/**
 * Tests for the Vercel API (api/index.js) — the LIVE payment webhook and
 * admin/manual donation endpoints. Mirrors the Cloud Functions contract tests
 * but drives the express route handlers registered by api/index.js.
 */

jest.mock('firebase-admin', () => require('../../functions/__mocks__/firebase-admin'));
jest.mock('mercadopago', () => require('../../functions/__mocks__/mercadopago'));

const crypto = require('crypto');

const admin = require('firebase-admin');
const app = require('../index');

const AUTH_UID = 'user-payment-test';
const WEBHOOK_SECRET = 'test-webhook-secret';

process.env.MERCADOPAGO_ACCESS_TOKEN = 'test-token';
process.env.MERCADOPAGO_WEBHOOK_SECRET = WEBHOOK_SECRET;
process.env.PURCHASE_SECRET = 'test-purchase-secret-key';

beforeEach(() => {
  admin._resetFirestore();
});

function setUserDoc(uid, data) {
  admin._setDoc(`users/${uid}`, data);
}

function makeRes() {
  return {
    _status: 200,
    _body: null,
    _headers: {},
    status(code) { this._status = code; return this; },
    json(body) { this._body = body; },
    send(body) { this._body = body; },
  };
}

function signedWebhookReq(body, { signature } = {}) {
  const rawBody = JSON.stringify(body);
  const ts = '1752660000';
  const expected = crypto
    .createHmac('sha256', WEBHOOK_SECRET)
    .update(`ts${ts}req${rawBody}`)
    .digest('hex');
  return {
    method: 'POST',
    body,
    rawBody: Buffer.from(rawBody),
    headers: {
      'x-signature': signature === undefined ? `ts=${ts};v1=${expected}` : signature,
    },
  };
}

function approvedPayment() {
  return {
    status: 'approved',
    external_reference: 'hash123|3|donation_basic',
    metadata: { userId: AUTH_UID, amount: 3, productId: 'donation_basic' },
    transaction_amount: 3,
    currency_id: 'PEN',
    payment_method_id: 'pix',
  };
}

describe('api health', () => {
  test('returns ok status', async () => {
    const handler = app._handlers.get['/api/health'][0];
    expect(handler).toBeDefined();
    const r = makeRes();
    await handler({}, r);
    expect(r._status).toBe(200);
    expect(r._body).toEqual(expect.objectContaining({ status: 'ok' }));
  });
});

describe('api handlePaymentWebhook', () => {
  const webhookHandler = () => app._handlers.post['/api/handlePaymentWebhook'][0];

  afterEach(() => {
    if (global.fetch && global.fetch.mockRestore) global.fetch.mockRestore();
  });

  test('rejects webhook without signature', async () => {
    const r = makeRes();
    const req = { method: 'POST', body: { type: 'payment', data: { id: 'pay_1' } }, headers: {} };
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects malformed (non-hex) signature with 401, not 500', async () => {
    const r = makeRes();
    const req = signedWebhookReq(
      { type: 'payment', data: { id: 'pay_2' } },
      { signature: 'ts=1752660000;v1=zzzz-not-hex' },
    );
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects webhook with mismatched signature', async () => {
    const r = makeRes();
    const req = signedWebhookReq(
      { type: 'payment', data: { id: 'pay_3' } },
      { signature: 'ts=1;v1=deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef' },
    );
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('returns 502 when MercadoPago fetch fails so MP retries', async () => {
    global.fetch = jest.fn().mockResolvedValue({ ok: false, status: 503 });
    const r = makeRes();
    const req = signedWebhookReq({ type: 'payment', data: { id: 'pay_4' } });
    await webhookHandler()(req, r);
    expect(global.fetch).toHaveBeenCalled();
    expect(r._status).toBe(502);
  });

  test('credits an approved signed payment idempotently', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => approvedPayment(),
    });
    setUserDoc(AUTH_UID, { total_donated: 0, learning_gems: 100 });
    const r1 = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_5' } }), r1);
    expect(r1._status).toBe(200);

    const log = admin._getDoc('payment_logs/pay_5');
    expect(log).toBeTruthy();
    expect(log.userId).toBe(AUTH_UID);
    expect(log.amount).toBe(3);
    expect(log.paymentAmount).toBe(3);

    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.total_donated).toBe(3);
    expect(user.is_supporter).toBe(true);

    // Idempotency: replaying the same paymentId must not double-credit.
    const r2 = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_5' } }), r2);
    expect(r2._status).toBe(200);
    const user2 = admin._getDoc(`users/${AUTH_UID}`);
    expect(user2.total_donated).toBe(3);
  });

  test('flips matching pending payments to completed', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => approvedPayment(),
    });
    admin._setDoc('pending_payments/owner_pay_6', {
      userId: AUTH_UID, operationId: 'pay_6', status: 'pending',
    });
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_6' } }), r);
    expect(r._status).toBe(200);
    const flipped = admin._getDoc('pending_payments/owner_pay_6');
    expect(flipped.status).toBe('completed');
  });
});

describe('api registerPendingPayment', () => {
  // Route: requireAuth, rateLimit, handler → the handler is index 2.
  const registerHandler = () => app._handlers.post['/api/registerPendingPayment'][2];

  function authedReq(body) {
    return { method: 'POST', body, user: { uid: AUTH_UID } };
  }

  test('registers a pending payment and is idempotent on retry', async () => {
    const r1 = makeRes();
    await registerHandler()(authedReq({
      paymentMethod: 'whatsapp', operationId: 'op-123', amount: 50, productId: 'donation_basic',
    }), r1);
    expect(r1._status).toBe(200);
    expect(r1._body.result).toEqual(expect.objectContaining({ success: true, duplicate: false }));

    const r2 = makeRes();
    await registerHandler()(authedReq({
      paymentMethod: 'whatsapp', operationId: 'op-123', amount: 50,
    }), r2);
    expect(r2._status).toBe(200);
    expect(r2._body.result).toEqual(expect.objectContaining({ success: true, duplicate: true }));
  });

  test('rejects an unsupported payment method', async () => {
    const r = makeRes();
    await registerHandler()(authedReq({ paymentMethod: 'bitcoin', operationId: 'op-1', amount: 50 }), r);
    expect(r._status).toBe(400);
  });

  test('rejects non-numeric or out-of-range amount', async () => {
    const r1 = makeRes();
    await registerHandler()(authedReq({ paymentMethod: 'yape', operationId: 'op-2', amount: '50' }), r1);
    expect(r1._status).toBe(400);

    const r2 = makeRes();
    await registerHandler()(authedReq({ paymentMethod: 'yape', operationId: 'op-3', amount: 100001 }), r2);
    expect(r2._status).toBe(400);
  });

  test('rejects malicious operationId (path injection)', async () => {
    const r = makeRes();
    await registerHandler()(authedReq({ paymentMethod: 'plin', operationId: '../admin/x', amount: 50 }), r);
    expect(r._status).toBe(400);
  });
});

describe('api checkPendingPaymentStatus', () => {
  // Route: requireAuth, rateLimit, handler → the handler is index 2.
  const checkHandler = () => app._handlers.all['/api/checkPendingPaymentStatus'][2];
  const registerHandler = () => app._handlers.post['/api/registerPendingPayment'][2];

  function authedReq(body) {
    return { method: 'POST', body, user: { uid: AUTH_UID } };
  }

  test('returns not_found when nothing matches', async () => {
    const r = makeRes();
    await checkHandler()(authedReq({ pendingPaymentId: 'nope' }), r);
    expect(r._status).toBe(200);
    expect(r._body.result.status).toBe('not_found');
  });

  test('returns only the caller-own pending payment', async () => {
    const rr = makeRes();
    await registerHandler()(authedReq({ paymentMethod: 'yape', operationId: 'op-owner', amount: 25 }), rr);
    const pendingId = rr._body.result.pendingPaymentId;

    // Another user's pending with the same operationId must not leak.
    admin._setDoc('pending_payments/other_user', {
      userId: 'someone-else', operationId: 'op-owner', status: 'pending',
    });
    // Owner pending flipped by the webhook/admin.
    const pendingDoc = admin._getDoc(`pending_payments/${pendingId}`);
    admin._setDoc(`pending_payments/${pendingId}`, {
      ...pendingDoc, status: 'completed', completedAt: { toMillis: () => 123 },
    });

    const r = makeRes();
    await checkHandler()(authedReq({ pendingPaymentId: pendingId }), r);
    expect(r._status).toBe(200);
    expect(r._body.result.status).toBe('completed');

    const rOther = makeRes();
    await checkHandler()(authedReq({ pendingPaymentId: 'other_user' }), rOther);
    expect(rOther._body.result.status).toBe('not_found');
  });
});

describe('api adminCreditDonation', () => {
  const adminHandlers = () => app._handlers.post['/api/adminCreditDonation'];

  // Express runs requireAuth/requireAdmin first, which set req.user; invoking
  // the route handler directly with req.user mirrors that state deterministically.
  async function callAdminRoute(body) {
    const [, handler] = adminHandlers();
    const req = { method: 'POST', body, user: { uid: 'admin-uid' } };
    const res = makeRes();
    await handler(req, res);
    return res;
  }

  test('rejects requests without an admin token (401)', async () => {
    const [authMw] = adminHandlers();
    const req = { method: 'POST', body: { userId: AUTH_UID, amount: 5, idempotencyKey: 'k1' }, headers: {} };
    const res = makeRes();
    await authMw(req, res, () => {});
    expect(res._status).toBe(401);
  });

  test('rejects an authenticated non-admin user (403)', async () => {
    const [authMw] = adminHandlers();
    admin._setVerifyIdTokenResult({ uid: 'regular-user' });
    const req = { method: 'POST', body: { userId: AUTH_UID, amount: 5, idempotencyKey: 'k1' }, headers: { authorization: 'Bearer token' } };
    const res = makeRes();
    await authMw(req, res, () => {});
    expect(res._status).toBe(403);
  });

  test('requires userId, numeric amount and idempotencyKey', async () => {
    const r = await callAdminRoute({ amount: 5 });
    expect(r._status).toBe(400);
  });

  test('rejects non-numeric amount', async () => {
    const r = await callAdminRoute({ userId: AUTH_UID, amount: 'abc', idempotencyKey: 'k1' });
    expect(r._status).toBe(400);
  });

  test('rejects amount over 100000', async () => {
    const r = await callAdminRoute({ userId: AUTH_UID, amount: 100001, idempotencyKey: 'k1' });
    expect(r._status).toBe(400);
  });

  test('rejects invalid userId', async () => {
    const r = await callAdminRoute({ userId: '../etc/passwd', amount: 5, idempotencyKey: 'k1' });
    expect(r._status).toBe(400);
  });

  test('coerces a string amount to a number (no string concatenation)', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    const r = await callAdminRoute({ userId: AUTH_UID, amount: '105', idempotencyKey: 'k-str' });
    expect(r._status).toBe(200);
    expect(r._body.result).toEqual(expect.objectContaining({ success: true, duplicate: false }));
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.total_donated).toBe(105);
  });

  test('credits a valid donation and stays idempotent on replay', async () => {
    setUserDoc(AUTH_UID, { total_donated: 10 });
    const r = await callAdminRoute({ userId: AUTH_UID, amount: 5, idempotencyKey: 'k-1' });
    expect(r._status).toBe(200);
    expect(admin._getDoc(`users/${AUTH_UID}`).total_donated).toBe(15);

    const r2 = await callAdminRoute({ userId: AUTH_UID, amount: 5, idempotencyKey: 'k-1' });
    expect(r2._status).toBe(200);
    expect(r2._body.result).toEqual(expect.objectContaining({ duplicate: true }));
    expect(admin._getDoc(`users/${AUTH_UID}`).total_donated).toBe(15);
  });

  test('returns 404 when the user does not exist', async () => {
    const r = await callAdminRoute({ userId: 'nobody-here', amount: 5, idempotencyKey: 'k-2' });
    expect(r._status).toBe(404);
  });
});
