const express = require('express');
const admin = require('firebase-admin');
const crypto = require('crypto');
const { MercadoPagoConfig, Preference } = require('mercadopago');

// ── Firebase Admin ──────────────────────────────────────────────
if (admin.apps.length === 0) {
  const saKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (saKey) {
    admin.initializeApp({ credential: admin.credential.cert(JSON.parse(saKey)) });
  } else {
    admin.initializeApp();
  }
}

const MERCADOPAGO_ACCESS_TOKEN = process.env.MERCADOPAGO_ACCESS_TOKEN;
if (!MERCADOPAGO_ACCESS_TOKEN) {
  console.warn('MERCADOPAGO_ACCESS_TOKEN not configured. Set in Vercel env vars.');
}

const mpClient = new MercadoPagoConfig({
  accessToken: MERCADOPAGO_ACCESS_TOKEN || '',
  options: { timeout: 15000 },
});

const APP_URL = 'sagen://';
const WEBHOOK_BASE = process.env.VERCEL_URL
  ? `https://${process.env.VERCEL_URL}`
  : 'https://sagen-app.vercel.app';

const STREAK_SHIELD_MAX = 2;

const hardcodedCatalog = require('../functions/catalog');
const catalogService = hardcodedCatalog.createCatalog(admin, { warn: (m, ctx) => console.warn(m, ctx && ctx.error) });

const loadCatalog = () => catalogService.loadCatalog();

function getProductDetails(productId) {
  return catalogService.getProductDetails(productId);
}

function getStreakShieldSlots(currentShields) {
  return Math.max(0, STREAK_SHIELD_MAX - currentShields);
}

/**
 * Applies product bonus grants to the user doc update payload.
 * The SAGEN PASS grants: premium flag, question-bank unlock, and gems.
 */
function applyProductBonuses(updateData, userData, bonuses) {
  for (const bonus of bonuses) {
    if (bonus.type === 'streakProtector') {
      const currentShields = userData.shop_streak_shields || 0;
      const available = getStreakShieldSlots(currentShields);
      const toAdd = Math.min(bonus.quantity, available);
      if (toAdd > 0) updateData.shop_streak_shields = currentShields + toAdd;
    } else if (bonus.type === 'xpBoost') {
      updateData.shop_purchased_xp_boosts = (userData.shop_purchased_xp_boosts || 0) + bonus.quantity;
    } else if (bonus.type === 'xpMultiplier') {
      updateData.shop_purchased_xp_multipliers = (userData.shop_purchased_xp_multipliers || 0) + bonus.quantity;
    } else if (bonus.type === 'luckBoost') {
      updateData.shop_purchased_luck_boosts = (userData.shop_purchased_luck_boosts || 0) + bonus.quantity;
    } else if (bonus.type === 'sagenPass') {
      updateData.sagen_pass_active = true;
      updateData.sagen_pass_purchased_at = admin.firestore.FieldValue.serverTimestamp();
      updateData.premium_question_bank = true;
      updateData.learning_gems = Math.min(100000, (userData.learning_gems || 0) + (bonus.gems || 500));
    }
  }
  return updateData;
}

function shortHash(s) {
  const secret = process.env.PURCHASE_SECRET;
  if (!secret) {
    console.error('PURCHASE_SECRET not configured for shortHash');
    return crypto.createHash('sha256').update(s).digest('hex').slice(0, 12);
  }
  return crypto.createHmac('sha256', secret).update(s).digest('hex').slice(0, 16);
}

// ── Auth middleware ─────────────────────────────────────────────
async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization || '';
  const idToken = authHeader.replace('Bearer ', '');
  if (!idToken) {
    return res.status(401).json({ error: 'unauthenticated', message: 'Debes iniciar sesión' });
  }
  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ error: 'unauthenticated', message: 'Token inválido' });
  }
}

async function requireAdmin(req, res, next) {
  await requireAuth(req, res, async () => {
    const adminDoc = await admin.firestore().doc(`admins/${req.user.uid}`).get();
    if (!adminDoc.exists) {
      return res.status(403).json({ error: 'permission-denied', message: 'No tienes permisos de administrador' });
    }
    next();
  });
}

// ── Rate limiting (Firestore-based, distributed) ───────────────
const RATE_LIMIT_WINDOW = 60 * 1000;
const RATE_LIMIT_MAX = 10;

async function rateLimit(req, res, next) {
  const key = req.user?.uid || req.ip;
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW;

  try {
    const rateLimitRef = admin.firestore().doc(`rate_limits/${key}`);
    await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(rateLimitRef);
      const data = doc.data() || {};
      const timestamps = (data.timestamps || []).filter(t => t > windowStart);

      if (timestamps.length >= RATE_LIMIT_MAX) {
        throw new Error('RATE_LIMIT_EXCEEDED');
      }

      timestamps.push(now);
      transaction.set(rateLimitRef, {
        timestamps,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    });
    next();
  } catch (e) {
    if (e.message === 'RATE_LIMIT_EXCEEDED') {
      return res.status(429).json({ error: 'resource-exhausted', message: 'Demasiadas solicitudes. Intenta de nuevo.' });
    }
    // Fail-closed on Firestore errors (aligned with the Cloud Functions
    // layers): under degradation the endpoint rejects instead of allowing
    // unlimited abuse.
    console.error('Rate limit check failed (fail-closed)', e.message);
    return res.status(503).json({ error: 'unavailable', message: 'Servicio temporalmente no disponible. Intenta de nuevo.' });
  }
}

// ── Express app ────────────────────────────────────────────────
const app = express();
app.use(express.json({
  verify: (req, res, buf) => { req.rawBody = buf; },
}));

// ────────────────────────────────────────────────────────────────
// POST /api/createPaymentPreference
// ────────────────────────────────────────────────────────────────
app.post('/api/createPaymentPreference', requireAuth, rateLimit, async (req, res) => {
  try {
    const { amount, productId } = req.body;
    if (!amount || !productId) {
      return res.status(400).json({ error: 'invalid-argument', message: 'Se requieren amount y productId' });
    }

    const pkg = await getProductDetails(productId);
    if (!pkg) {
      return res.status(400).json({ error: 'invalid-argument', message: `Producto no encontrado: ${productId}` });
    }
    if (pkg.amount !== amount) {
      return res.status(400).json({ error: 'invalid-argument', message: `Monto no coincide: esperado ${pkg.amount}` });
    }

    const userId = req.user.uid;
    const obfuscatedRef = `${shortHash(userId)}|${amount}|${productId}`;

    const preference = new Preference(mpClient);
    const result = await preference.create({
      body: {
        items: [{
          id: productId,
          title: pkg.title,
          description: `Donación de $${amount} para SAGEN`,
          quantity: 1,
          unit_price: pkg.price,
          currency_id: 'PEN',
        }],
        external_reference: obfuscatedRef,
        metadata: { userId, amount, productId },
        back_urls: {
          success: `${APP_URL}payment/success`,
          failure: `${APP_URL}payment/failure`,
          pending: `${APP_URL}payment/pending`,
        },
        auto_return: 'approved',
        notification_url: `${WEBHOOK_BASE}/api/handlePaymentWebhook`,
        payment_methods: { installments: 1, default_installments: 1 },
      },
    });

    console.log('Preference created', { preferenceId: result.id, obfuscatedRef, amount, productId: productId || 'none' });
    res.json({ result: { preferenceId: result.id, initPoint: result.init_point || result.sandbox_init_point, externalRef: obfuscatedRef } });
  } catch (error) {
    console.error('createPaymentPreference error', error);
    res.status(500).json({ error: 'internal', message: 'Error al crear la preferencia de pago' });
  }
});

// ────────────────────────────────────────────────────────────────
// POST /api/handlePaymentWebhook
// ────────────────────────────────────────────────────────────────
app.post('/api/handlePaymentWebhook', async (req, res) => {
  try {
    const { type, data } = req.body;
    console.log('Webhook received', { type, data });

    if (type !== 'payment' || !data?.id) {
      return res.status(200).send('OK');
    }

    // ── VERIFY WEBHOOK SIGNATURE (MANDATORY) ───────────────────
    const WEBHOOK_SECRET = process.env.MERCADOPAGO_WEBHOOK_SECRET;
    if (!WEBHOOK_SECRET) {
      console.error('MERCADOPAGO_WEBHOOK_SECRET not configured — rejecting webhook for security');
      return res.status(500).send('Server misconfigured');
    }
    {
      const signature = req.headers['x-signature'] || '';
      const parts = {};
      for (const part of signature.split(';')) {
        const [k, v] = part.split('=');
        if (k && v) parts[k.trim()] = v.trim();
      }
      const ts = parts['ts'];
      const v1 = parts['v1'];
      if (!ts || !v1) {
        console.warn('Webhook missing signature', { paymentId: data.id });
        return res.status(401).send('Unauthorized');
      }
      const rawBody = req.rawBody
        ? req.rawBody.toString('utf8')
        : JSON.stringify(req.body);
      const expected = crypto.createHmac('sha256', WEBHOOK_SECRET)
        .update(`ts${ts}req${rawBody}`)
        .digest('hex');
      if (!crypto.timingSafeEqual(Buffer.from(v1, 'hex'), Buffer.from(expected, 'hex'))) {
        console.warn('Webhook signature mismatch', { paymentId: data.id });
        return res.status(401).send('Unauthorized');
      }
    }

    const paymentId = data.id.toString();
    const response = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { Authorization: `Bearer ${MERCADOPAGO_ACCESS_TOKEN}` },
    });

    if (!response.ok) {
      console.error('Failed to fetch payment', { paymentId, status: response.status });
      // Return non-2xx so MercadoPago retries: an approved payment must never
      // be silently dropped because of a transient API failure.
      return res.status(502).send('Failed to fetch payment from MercadoPago');
    }

    const payment = await response.json();
    const externalRef = payment.external_reference || '';
    const extParts = externalRef.split('|');
    const userId = payment.metadata?.userId || extParts[0] || '';
    const amount = parseInt(payment.metadata?.amount || extParts[1], 10);
    const productId = payment.metadata?.productId || extParts[2] || null;

    if (payment.status !== 'approved') {
      if (payment.status === 'pending' || payment.status === 'in_process') {
        const pendingRef = admin.firestore().collection('pending_payments').doc(paymentId);
        const pendingDoc = await pendingRef.get();
        if (!pendingDoc.exists) {
          await pendingRef.set({
            userId, paymentMethod: 'mercadopago', operationId: paymentId,
            amount: payment.transaction_amount || 0, productId, status: payment.status, externalRef,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 48 * 60 * 60 * 1000)),
          });
        }
      }
      return res.status(200).send('OK');
    }

    if (!userId || isNaN(amount) || amount <= 0) {
      // NUEVO-fix: never silently swallow an approved payment without the
      // metadata needed to credit the user. Log details and return a
      // non-2xx so MercadoPago retries / flags the webhook for review.
      console.error('Approved payment missing userId/amount — NOT credited', {
        paymentId, externalRef, amount, hasMetadata: !!payment.metadata,
        hasExternalRef: !!externalRef,
      });
      return res.status(400).send('Missing payment metadata');
    }

    const userRef = admin.firestore().doc(`users/${userId}`);
    const logRef = admin.firestore().doc(`payment_logs/${paymentId}`);
    const catalog = await loadCatalog();
    const pkg = catalog[productId];
    const bonuses = pkg ? pkg.bonuses : [];

    await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc] = await Promise.all([transaction.get(userRef), transaction.get(logRef)]);
      if (logDoc.exists) return;

      if (!userDoc.exists) {
        console.error('User not found', { userId });
        return;
      }

      const userData = userDoc.data() || {};
      const updateData = {
        total_donated: (userData.total_donated || 0) + amount,
        is_supporter: true,
        lastPaymentAt: admin.firestore.FieldValue.serverTimestamp(),
        lastPaymentMethod: 'mercadopago',
        lastPaymentAmount: amount,
        _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
      };

      applyProductBonuses(updateData, userData, bonuses);

      transaction.update(userRef, updateData);
      transaction.create(logRef, {
        userId, amount, productId, bonuses, amount: payment.transaction_amount || 0,
        currency: payment.currency_id || 'PEN', paymentId, paymentMethod: payment.payment_method_id || 'unknown',
        status: payment.status, externalRef, createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // Flip any matching pending payment to completed so the app can poll it.
    try {
      const pendSnap = await admin.firestore()
        .collection('pending_payments')
        .where('operationId', '==', paymentId)
        .get();
      await Promise.all(pendSnap.docs.map((doc) =>
        admin.firestore().doc(`pending_payments/${doc.id}`).update({
          status: 'completed',
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        })));
    } catch (e) {
      console.warn('Failed to flip pending payment status', e.message);
    }

    console.log('Payment processed', { userId, amount, productId: productId || 'none' });
    return res.status(200).send('OK');
  } catch (error) {
    // Return non-2xx so MercadoPago retries the webhook instead of silently
    // swallowing an approved payment. 4xx paths above already returned, so any
    // exception reaching here is transient/internal.
    console.error('Webhook handler error', error);
    return res.status(500).send('Internal error');
  }
});

// ────────────────────────────────────────────────────────────────
// POST /api/adminCreditDonation
// ────────────────────────────────────────────────────────────────
app.post('/api/adminCreditDonation', requireAdmin, async (req, res) => {
  try {
    const { userId, paymentMethod, productId, idempotencyKey } = req.body;
    // NUEVO-fix: coerce amount to a real number BEFORE any arithmetic so a
    // string payload cannot produce "105" from amount="10"+"5" concatenation.
    const rawAmount = req.body.amount;
    const amount = typeof rawAmount === 'number'
      ? rawAmount
      : parseFloat(String(rawAmount ?? '').replace(',', '.'));
    if (!userId || !Number.isFinite(amount) || amount <= 0 || !idempotencyKey) {
      return res.status(400).json({ error: 'invalid-argument', message: 'userId, amount (número) e idempotencyKey requeridos' });
    }
    if (amount > 100000) {
      return res.status(400).json({ error: 'invalid-argument', message: 'El monto excede el límite de 100000' });
    }
    if (!/^[A-Za-z0-9_-]{1,128}$/.test(userId)) {
      return res.status(400).json({ error: 'invalid-argument', message: 'userId invalido' });
    }
    if (!/^[A-Za-z0-9_-]{1,128}$/.test(idempotencyKey)) {
      return res.status(400).json({ error: 'invalid-argument', message: 'idempotencyKey invalido' });
    }

    const logRef = admin.firestore().doc(`payment_logs/${idempotencyKey}`);
    const userRef = admin.firestore().doc(`users/${userId}`);
    const method = paymentMethod || 'whatsapp';

    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [logDoc, userDoc] = await Promise.all([transaction.get(logRef), transaction.get(userRef)]);
      if (logDoc.exists) {
        const existingData = logDoc.data() || {};
        return { success: true, duplicate: true, newBalance: existingData.postBalance || 0, bonuses: existingData.bonuses || [] };
      }
      if (!userDoc.exists) {
        throw new Error('Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const currentBalance = userData.total_donated || 0;
      const updateData = {
        total_donated: currentBalance + amount,
        is_supporter: true,
        lastManualCreditAt: admin.firestore.FieldValue.serverTimestamp(),
        lastManualCreditMethod: method,
        lastManualCreditAmount: amount,
        _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
      };

      const catalog = await loadCatalog();
      const pkg = catalog[productId];
      const bonuses = pkg ? pkg.bonuses : [];
      applyProductBonuses(updateData, userData, bonuses);

      transaction.update(userRef, updateData);
      transaction.create(logRef, {
        userId, amount, productId: productId || null, bonuses, method: 'manual_' + method,
        creditedBy: 'admin', postBalance: currentBalance + amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, newBalance: currentBalance + amount, bonuses };
    });

    // Flip any matching pending payment to completed so the app can poll it.
    try {
      const pendSnap = await admin.firestore()
        .collection('pending_payments')
        .where('operationId', '==', idempotencyKey)
        .get();
      await Promise.all(pendSnap.docs.map((doc) =>
        admin.firestore().doc(`pending_payments/${doc.id}`).update({
          status: 'completed',
          completedAt: admin.firestore.FieldValue.serverTimestamp(),
        })));
    } catch (e) {
      console.warn('Failed to flip pending payment status (admin)', e.message);
    }

    console.log('Manual donation credited', { userId, amount, method });
    res.json({ result });
  } catch (error) {
    console.error('adminCreditDonation error', error);
    if (error.message === 'Usuario no encontrado') {
      return res.status(404).json({ error: 'not-found', message: error.message });
    }
    res.status(500).json({ error: 'internal', message: 'Error al acreditar gemas' });
  }
});

// ────────────────────────────────────────────────────────────────
// POST /api/registerPendingPayment
// ────────────────────────────────────────────────────────────────
app.post('/api/registerPendingPayment', requireAuth, rateLimit, async (req, res) => {
  try {
    const { paymentMethod, operationId, amount, productId } = req.body;
    if (!paymentMethod || typeof paymentMethod !== 'string' || !operationId) {
      return res.status(400).json({ error: 'invalid-argument', message: 'paymentMethod y operationId requeridos' });
    }

    const validMethods = ['whatsapp', 'yape', 'plin'];
    if (!validMethods.includes(paymentMethod)) {
      return res.status(400).json({ error: 'invalid-argument', message: 'Método de pago no válido' });
    }

    if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0 || amount > 100000) {
      return res.status(400).json({ error: 'invalid-argument', message: 'El monto debe ser un número mayor a 0' });
    }
    if (typeof operationId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(operationId)) {
      return res.status(400).json({ error: 'invalid-argument', message: 'operationId invalido' });
    }

    const userId = req.user.uid;
    const pendingRef = admin.firestore().collection('pending_payments').doc();
    await pendingRef.set({
      userId, paymentMethod, operationId, amount, productId: productId || null,
      status: 'pending', createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 24 * 60 * 60 * 1000)),
    });

    console.log('Pending payment registered', { userId, paymentMethod, operationId, pendingId: pendingRef.id });
    res.json({ result: { success: true, pendingPaymentId: pendingRef.id } });
  } catch (error) {
    console.error('registerPendingPayment error', error);
    res.status(500).json({ error: 'internal', message: 'Error al registrar el pago' });
  }
});

// ────────────────────────────────────────────────────────────────
// GET/POST /api/checkPendingPaymentStatus
// ────────────────────────────────────────────────────────────────
app.all('/api/checkPendingPaymentStatus', requireAuth, rateLimit, async (req, res) => {
  try {
    const { operationId, pendingPaymentId } = { ...req.query, ...req.body };
    if (!operationId && !pendingPaymentId) {
      return res.status(400).json({ error: 'invalid-argument', message: 'operationId o pendingPaymentId requerido' });
    }

    const userId = req.user.uid;
    let pendingRef = admin.firestore().collection('pending_payments');
    if (pendingPaymentId) {
      pendingRef = pendingRef.where('__name__', '==', String(pendingPaymentId));
    } else {
      pendingRef = pendingRef.where('operationId', '==', String(operationId));
    }

    const snap = await pendingRef.get();
    const latest = snap.docs
      .map((doc) => ({ id: doc.id, ...doc.data() }))
      .filter((doc) => doc.userId === userId)
      .sort((a, b) => {
        const atA = a.createdAt && a.createdAt.toMillis ? a.createdAt.toMillis() : 0;
        const atB = b.createdAt && b.createdAt.toMillis ? b.createdAt.toMillis() : 0;
        return atB - atA;
      })[0] || null;

    if (!latest) {
      return res.json({ result: { status: 'not_found' } });
    }

    res.json({
      result: {
        status: latest.status,
        operationId: latest.operationId,
        productId: latest.productId || null,
        completedAt: latest.completedAt && latest.completedAt.toMillis
          ? latest.completedAt.toMillis()
          : null,
      },
    });
  } catch (error) {
    console.error('checkPendingPaymentStatus error', error);
    res.status(500).json({ error: 'internal', message: 'Error al consultar el estado del pago' });
  }
});

// ────────────────────────────────────────────────────────────────
// GET /api/health
// ────────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', project: 'sagen-vercel', mercadopagoConfigured: !!MERCADOPAGO_ACCESS_TOKEN });
});

// ── Export for Vercel ───────────────────────────────────────────
// Attach the catalog helpers for contract testing (Vercel uses `app`).
app.loadCatalog = loadCatalog;
app.getProductDetails = getProductDetails;
module.exports = app;
