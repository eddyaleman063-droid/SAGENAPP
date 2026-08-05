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

const hardcodedCatalog = {
  'donation_5':    { amount: 5,   title: 'Donación $5 - SAGEN',            price: 5.00,  bonuses: [] },
  'donation_10':   { amount: 10,  title: 'Donación $10 - SAGEN',           price: 10.00, bonuses: [] },
  'donation_20':   { amount: 20,  title: 'Donación $20 - SAGEN',           price: 20.00, bonuses: [] },
  'donation_35':   { amount: 35,  title: 'Donación $35 - SAGEN',           price: 35.00, bonuses: [] },
  'donation_60':   { amount: 60,  title: 'Donación $60 - SAGEN',           price: 60.00, bonuses: [] },
  'bundle_protector':   { amount: 12,  title: 'Pack Protegido - SAGEN',      price: 12.00, bonuses: [{ type: 'streakProtector', quantity: 1 }] },
  'bundle_xp':          { amount: 20,  title: 'Pack Impulso - SAGEN',        price: 20.00, bonuses: [{ type: 'xpBoost', quantity: 1 }] },
  'bundle_multiplier':  { amount: 28,  title: 'Pack Fortuna - SAGEN',        price: 28.00, bonuses: [{ type: 'xpMultiplier', quantity: 1 }] },
  'bundle_luck':        { amount: 24,  title: 'Pack Suerte - SAGEN',         price: 24.00, bonuses: [{ type: 'luckBoost', quantity: 1 }] },
};

let _catalogCache = null;
let _catalogCacheTime = 0;
const CATALOG_CACHE_TTL = 5 * 60 * 1000;

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
    console.warn('Failed to load catalog from Firestore, using hardcoded', e.message);
  }
  _catalogCache = hardcodedCatalog;
  _catalogCacheTime = now;
  return _catalogCache;
}

async function getProductDetails(productId) {
  const catalog = await loadCatalog();
  const item = catalog[productId];
  if (item) return item;
  throw new Error(`Producto desconocido: ${productId}`);
}

function getStreakShieldSlots(currentShields) {
  return Math.max(0, STREAK_SHIELD_MAX - currentShields);
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
    // On Firestore errors, fail open (allow request) to avoid blocking users
    console.warn('Rate limit check failed (fail-open)', e.message);
    next();
  }
}

// ── Express app ────────────────────────────────────────────────
const app = express();
app.use(express.json());

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
      const rawBody = JSON.stringify(req.body);
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
      return res.status(200).send('OK');
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
      console.error('Invalid userId or amount', { userId, amount });
      return res.status(200).send('OK');
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
        }
      }

      transaction.update(userRef, updateData);
      transaction.create(logRef, {
        userId, amount, productId, bonuses, amount: payment.transaction_amount || 0,
        currency: payment.currency_id || 'PEN', paymentId, paymentMethod: payment.payment_method_id || 'unknown',
        status: payment.status, externalRef, createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    console.log('Payment processed', { userId, amount, productId: productId || 'none' });
    return res.status(200).send('OK');
  } catch (error) {
    console.error('Webhook handler error', error);
    return res.status(200).send('OK');
  }
});

// ────────────────────────────────────────────────────────────────
// POST /api/adminCreditDonation
// ────────────────────────────────────────────────────────────────
app.post('/api/adminCreditDonation', requireAdmin, async (req, res) => {
  try {
    const { userId, amount, paymentMethod, productId, idempotencyKey } = req.body;
    if (!userId || !amount || amount <= 0 || !idempotencyKey) {
      return res.status(400).json({ error: 'invalid-argument', message: 'userId, amount e idempotencyKey requeridos' });
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
        }
      }

      transaction.update(userRef, updateData);
      transaction.create(logRef, {
        userId, amount, productId: productId || null, bonuses, method: 'manual_' + method,
        creditedBy: 'admin', postBalance: currentBalance + amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, duplicate: false, newBalance: currentBalance + amount, bonuses };
    });

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
// POST /api/validatePurchase
// ────────────────────────────────────────────────────────────────
app.post('/api/validatePurchase', requireAuth, rateLimit, async (req, res) => {
  try {
    const { cost, itemId } = req.body;
    if (!cost || cost <= 0 || !itemId) {
      return res.status(400).json({ error: 'invalid-argument', message: 'cost y itemId requeridos' });
    }

    const userId = req.user.uid;
    const userRef = admin.firestore().doc(`users/${userId}`);
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'not-found', message: 'Usuario no encontrado' });
    }

    const balance = userDoc.data()?.learning_gems || 0;
    if (balance < cost) {
      return res.status(400).json({ error: 'failed-precondition', message: 'Gemas insuficientes' });
    }

    const hmacSecret = process.env.PURCHASE_SECRET;
    if (!hmacSecret) {
      console.error('PURCHASE_SECRET not configured');
      return res.status(500).json({ error: 'internal', message: 'Server configuration error' });
    }

    const payload = JSON.stringify({ userId, itemId, cost, ts: Date.now(), exp: Date.now() + 60000 });
    const hmac = crypto.createHmac('sha256', hmacSecret).update(payload).digest('hex');
    const token = Buffer.from(JSON.stringify({ payload, sig: hmac })).toString('base64');

    console.log('Purchase validation token issued', { userId, itemId, cost });
    res.json({ result: { valid: true, balance, token } });
  } catch (error) {
    console.error('validatePurchase error', error);
    res.status(500).json({ error: 'internal', message: 'Error al validar la compra' });
  }
});

// ────────────────────────────────────────────────────────────────
// POST /api/registerPendingPayment
// ────────────────────────────────────────────────────────────────
app.post('/api/registerPendingPayment', requireAuth, rateLimit, async (req, res) => {
  try {
    const { paymentMethod, operationId, amount, productId } = req.body;
    if (!paymentMethod || !operationId) {
      return res.status(400).json({ error: 'invalid-argument', message: 'paymentMethod y operationId requeridos' });
    }

    const validMethods = ['whatsapp', 'yape', 'plin'];
    if (!validMethods.includes(paymentMethod)) {
      return res.status(400).json({ error: 'invalid-argument', message: 'Método de pago no válido' });
    }

    const userId = req.user.uid;
    const pendingRef = admin.firestore().collection('pending_payments').doc();
    await pendingRef.set({
      userId, paymentMethod, operationId, amount: amount || 0, productId: productId || null,
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
// GET /api/health
// ────────────────────────────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', project: 'sagen-vercel', mercadopagoConfigured: !!MERCADOPAGO_ACCESS_TOKEN });
});

// ── Export for Vercel ───────────────────────────────────────────
module.exports = app;
