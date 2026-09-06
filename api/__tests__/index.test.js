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

function signedWebhookReq(body, { signature, ts, requestId, dataId } = {}) {
  // NUEVO-fix A1 (ronda 7): firma con el algoritmo OFICIAL de MercadoPago
  // (mirror de Cloud Functions): manifest `id:<data.id>;request-id:<x-request-id>;ts:<ts>;`
  // en el header x-signature con data.id como query param.
  const tsValue = ts || String(Math.floor(Date.now() / 1000));
  const reqId = requestId || 'test-request-id-123';
  const id = dataId || String(body.data?.id || '');
  const manifest = `id:${id};request-id:${reqId};ts:${tsValue};`;
  const expected = crypto
    .createHmac('sha256', WEBHOOK_SECRET)
    .update(manifest)
    .digest('hex');
  return {
    method: 'POST',
    body,
    query: { 'data.id': id },
    headers: {
      'x-signature': signature === undefined ? `ts=${tsValue},v1=${expected}` : signature,
      'x-request-id': reqId,
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
      { signature: 'zzzz-not-hex-plain-text' },
    );
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects webhook with mismatched signature (fresh ts, wrong v1)', async () => {
    const r = makeRes();
    const req = signedWebhookReq(
      { type: 'payment', data: { id: 'pay_3' } },
      { signature: 'ts=1,v1=deadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef' },
    );
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects signature computed for a different data.id', async () => {
    const ts = String(Math.floor(Date.now() / 1000));
    const reqId = 'test-request-id-123';
    const wrongManifest = `id:forgeable-id;request-id:${reqId};ts:${ts};`;
    const wrongSig = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(wrongManifest)
      .digest('hex');
    const r = makeRes();
    const req = signedWebhookReq(
      { type: 'payment', data: { id: 'pay_3b' } },
      { signature: `ts=${ts},v1=${wrongSig}` },
    );
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects webhook without x-request-id', async () => {
    const ts = String(Math.floor(Date.now() / 1000));
    const dataId = 'pay_3c';
    const manifest = `id:${dataId};ts:${ts};`;
    const expected = crypto
      .createHmac('sha256', WEBHOOK_SECRET)
      .update(manifest)
      .digest('hex');
    const r = makeRes();
    const req = {
      method: 'POST',
      body: { type: 'payment', data: { id: dataId } },
      query: { 'data.id': dataId },
      headers: { 'x-signature': `ts=${ts},v1=${expected}` },
    };
    await webhookHandler()(req, r);
    expect(r._status).toBe(401);
  });

  test('rejects stale timestamp (replay)', async () => {
    const r = makeRes();
    const req = signedWebhookReq(
      { type: 'payment', data: { id: 'pay_3d' } },
      { ts: '1704908010' },
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
    // NUEVO-fix A2 (ronda 7): el log persiste los deltas EFECTIVOS concedidos
    // para que un reembolso revierta exactamente eso.
    expect(log.granted).toEqual(expect.objectContaining({ total_donated: 3, is_supporter: true }));

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
    // NUEVO-fix (ronda 9): el webhook ahora falla con 5xx si el usuario del pago
    // aprobado no existe (nunca más 200 silencioso), así que el owner DEBE existir.
    setUserDoc(AUTH_UID, { total_donated: 0 });
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_6' } }), r);
    expect(r._status).toBe(200);
    const flipped = admin._getDoc('pending_payments/owner_pay_6');
    expect(flipped.status).toBe('completed');
  });

  test('NUEVO-fix ronda 7: does NOT flip a pending payment owned by another user', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => approvedPayment(),
    });
    // Un pending de OTRO usuario con el mismo operationId no debe marcarse
    // completed cuando el webhook acredita el pago del OWNER.
    admin._setDoc('pending_payments/other_pay_6b', {
      userId: 'someone-else', operationId: 'pay_6b', status: 'pending',
    });
    // NUEVO-fix (ronda 9): idem — el owner del pago debe existir para que el
    // webhook acredite con 200 y solo voltee el pending del MISMO usuario.
    setUserDoc(AUTH_UID, { total_donated: 0 });
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_6b' } }), r);
    expect(r._status).toBe(200);
    expect(admin._getDoc('pending_payments/other_pay_6b').status).toBe('pending');
  });

  test('NUEVO-fix ronda 9: approved payment with a missing user is NOT swallowed with 200', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({
        status: 'approved',
        transaction_amount: 3,
        external_reference: 'hash123|3|donation_basic',
        metadata: { userId: 'ghost-user', amount: 3, productId: 'donation_basic' },
      }),
    });
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_ghost_user' } }), r);
    expect(r._status).toBeGreaterThanOrEqual(500);
    expect(admin._getDoc('users/ghost-user')).toBeNull();
    expect(admin._getDoc('payment_logs/pay_ghost_user')).toBeNull();
  });

  function refundedPayment(status) {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({ status, transaction_amount: 10 }),
    });
  }

  test('NUEVO-fix A2 (ronda 7): refund reverts the granted benefits', async () => {
    setUserDoc('refund-uid', {
      total_donated: 10, is_supporter: true, shop_streak_shields: 1,
    });
    admin._setDoc('payment_logs/pay_refund_1', {
      userId: 'refund-uid',
      amount: 10,
      status: 'approved',
      bonuses: [{ type: 'streakProtector', quantity: 1 }],
      granted: { total_donated: 10, shop_streak_shields: 1, is_supporter: true },
    });
    refundedPayment('refunded');
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_refund_1' } }), r);
    expect(r._status).toBe(200);
    const user = admin._getDoc('users/refund-uid');
    expect(user.total_donated).toBe(0);
    expect(user.is_supporter).toBe(false);
    expect(user.shop_streak_shields).toBe(0);
    expect(admin._getDoc('payment_logs/pay_refund_1').status).toBe('refunded');
  });

  test('NUEVO-fix A2 (ronda 7): refund reversal is idempotent on replay', async () => {
    setUserDoc('refund-uid2', { total_donated: 5, is_supporter: true });
    admin._setDoc('payment_logs/pay_refund_2', {
      userId: 'refund-uid2',
      amount: 5,
      status: 'approved',
      bonuses: [],
      granted: { total_donated: 5, is_supporter: true },
    });
    refundedPayment('refunded');
    const r1 = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_refund_2' } }), r1);
    const r2 = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_refund_2' } }), r2);
    expect(r1._status).toBe(200);
    expect(r2._status).toBe(200);
    expect(admin._getDoc('users/refund-uid2').total_donated).toBe(0);
  });

  test('NUEVO-fix A2 (ronda 7): chargeback with SAGEN PASS reverts gems and flags', async () => {
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
        total_donated: 9.9, learning_gems: 500, is_supporter: true, sagen_pass_granted: true,
      },
    });
    refundedPayment('charged_back');
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_chargeback_1' } }), r);
    expect(r._status).toBe(200);
    const user = admin._getDoc('users/pass-uid');
    expect(user.total_donated).toBe(0);
    expect(user.is_supporter).toBe(false);
    expect(user.learning_gems).toBe(0);
    expect(user.sagen_pass_active).toBe(false);
    expect(user.premium_question_bank).toBe(false);
  });

  test('NUEVO-fix A2 (ronda 7): refund keeps supporter when other donations remain', async () => {
    setUserDoc('multi-uid', { total_donated: 30, is_supporter: true });
    admin._setDoc('payment_logs/pay_refund_3', {
      userId: 'multi-uid',
      amount: 10,
      status: 'approved',
      bonuses: [],
      granted: { total_donated: 10, is_supporter: true },
    });
    refundedPayment('refunded');
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_refund_3' } }), r);
    expect(r._status).toBe(200);
    const user = admin._getDoc('users/multi-uid');
    expect(user.total_donated).toBe(20);
    expect(user.is_supporter).toBe(true);
  });

  test('NUEVO-fix A2 (ronda 7): refund of a never-credited payment is a no-op OK', async () => {
    refundedPayment('refunded');
    const r = makeRes();
    await webhookHandler()(signedWebhookReq({ type: 'payment', data: { id: 'pay_ghost' } }), r);
    expect(r._status).toBe(200);
    expect(admin._getDoc('payment_logs/pay_ghost')).toBeNull();
  });
});

describe('api createPaymentPreference', () => {
  // Route: requireAuth, rateLimit, handler → the handler is index 2.
  const mpHandler = () => app._handlers.post['/api/createPaymentPreference'][2];
  const mpMock = require('mercadopago');

  beforeEach(() => {
    mpMock._resetMocks();
  });

  function authedReq(body, { emailVerified = true, origin } = {}) {
    return {
      method: 'POST',
      body,
      user: { uid: AUTH_UID, email_verified: emailVerified },
      headers: { origin: origin ?? 'https://sagen-bdd3f.web.app' },
    };
  }

  test('creates a preference for a verified user', async () => {
    const r = makeRes();
    await mpHandler()(authedReq({ amount: 3, productId: 'donation_basic' }), r);
    expect(r._status).toBe(200);
    expect(r._body.result).toEqual(expect.objectContaining({ preferenceId: 'mock_preference_id_123' }));
    expect(mpMock._mockPreferenceCreate).toHaveBeenCalled();
  });

  test('NUEVO-fix ronda 7: rejects 403 when the user email is not verified', async () => {
    const r = makeRes();
    await mpHandler()(authedReq(
      { amount: 3, productId: 'donation_basic' },
      { emailVerified: false },
    ), r);
    expect(r._status).toBe(403);
    expect(mpMock._mockPreferenceCreate).not.toHaveBeenCalled();
  });

  test('NUEVO-fix ronda 8: allows a request WITHOUT Origin header (native apps)', async () => {
    const r = makeRes();
    const req = authedReq({ amount: 3, productId: 'donation_basic' });
    delete req.headers.origin;
    await mpHandler()(req, r);
    expect(r._status).toBe(200);
    expect(mpMock._mockPreferenceCreate).toHaveBeenCalled();
  });

  test('NUEVO-fix ronda 7: rejects 403 a browser Origin not in the allow-list', async () => {
    const r = makeRes();
    await mpHandler()(authedReq(
      { amount: 3, productId: 'donation_basic' },
      { origin: 'https://evil.example.com' },
    ), r);
    expect(r._status).toBe(403);
    expect(mpMock._mockPreferenceCreate).not.toHaveBeenCalled();
  });
});

describe('api registerPendingPayment', () => {
  // Route: requireAuth, rateLimit, handler → the handler is index 2.
  const registerHandler = () => app._handlers.post['/api/registerPendingPayment'][2];

  function authedReq(body) {
    return { method: 'POST', body, user: { uid: AUTH_UID, email_verified: true } };
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

  test('NUEVO-fix ronda 8: rejects 403 when the email is not verified', async () => {
    const r = makeRes();
    await registerHandler()({
      method: 'POST',
      body: { paymentMethod: 'yape', operationId: 'op-email-1', amount: 25 },
      user: { uid: AUTH_UID, email_verified: false },
    }, r);
    expect(r._status).toBe(403);
    expect(r._body.error).toBe('email-not-verified');
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
    return { method: 'POST', body, user: { uid: AUTH_UID, email_verified: true } };
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
    // NUEVO-fix A2 (ronda 7): el log del crédito manual también persiste deltas.
    expect(admin._getDoc('payment_logs/k-1').granted).toEqual(
      expect.objectContaining({ total_donated: 5, is_supporter: true }),
    );

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
