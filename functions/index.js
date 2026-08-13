const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
const { MercadoPagoConfig, Preference } = require('mercadopago');

admin.initializeApp();

const MERCADOPAGO_ACCESS_TOKEN = functions.config().mercadopago?.access_token;
if (!MERCADOPAGO_ACCESS_TOKEN) {
  console.warn('MERCADOPAGO_ACCESS_TOKEN not configured. Set via: firebase functions:config:set mercadopago.access_token="APP_USR-xxx"');
}

const mpClient = new MercadoPagoConfig({
  accessToken: MERCADOPAGO_ACCESS_TOKEN || '',
  options: { timeout: 15000 },
});

const APP_URL = 'sagen://';
const WEBHOOK_BASE = `https://us-central1-${process.env.GCLOUD_PROJECT || 'sagen-bdd3f'}.cloudfunctions.net`;

const STREAK_SHIELD_MAX = 2;

// Gems bonus granted when the SAGEN PASS is purchased (one-time).
const SAGEN_PASS_GEMS = 500;

const hardcodedCatalog = {
  'donate_basic':    { amount: 3,   title: 'Supporter - SAGEN',       price: 3.00,  bonuses: [] },
  'donate_popular':  { amount: 5,   title: 'Super Supporter - SAGEN', price: 5.00,  bonuses: [] },
  'donate_premium':  { amount: 10,  title: 'Champion - SAGEN',        price: 10.00, bonuses: [] },
  'bundle_protector':{ amount: 12,  title: 'Pack Protegido - SAGEN',  price: 12.00, bonuses: [{ type: 'streakProtector', quantity: 1 }] },
  'bundle_xp':       { amount: 20,  title: 'Pack Impulso - SAGEN',    price: 20.00, bonuses: [{ type: 'xpBoost', quantity: 1 }] },
  'bundle_luck':     { amount: 24,  title: 'Pack Suerte - SAGEN',     price: 24.00, bonuses: [{ type: 'luckBoost', quantity: 1 }] },
  'sagen_pass':      { amount: 9.90, title: 'SAGEN PASS',             price: 9.90,  bonuses: [{ type: 'sagenPass', quantity: 1, gems: SAGEN_PASS_GEMS }] },
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
    functions.logger.warn('Failed to load catalog from Firestore, using hardcoded', { error: e.message });
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

async function getProductBonuses(amount) {
  const catalog = await loadCatalog();
  const match = Object.values(catalog).find(p => p.amount === amount && p.bonuses.length === 0);
  if (match) return match;
  return { bonuses: [] };
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
      if (toAdd > 0) {
        updateData.shop_streak_shields = currentShields + toAdd;
      }
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
      updateData.learning_gems = Math.min(100000, (userData.learning_gems || 0) + (bonus.gems || SAGEN_PASS_GEMS));
    }
  }
  return updateData;
}

// ── Rate limiting (Firestore-based, distributed) ─────────────────
const RATE_LIMIT_WINDOW = 60 * 1000;
const RATE_LIMIT_MAX = 10;

async function checkRateLimit(uid, maxRequests = RATE_LIMIT_MAX, windowMs = RATE_LIMIT_WINDOW) {
  const now = Date.now();
  const windowStart = now - windowMs;
  const bucketRef = admin.firestore().doc(`rate_limits/${uid}`);

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(bucketRef);
      const data = doc.data() || {};
      const timestamps = (data.timestamps || []).filter(t => t > windowStart);

      if (timestamps.length >= maxRequests) {
        throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes. Intenta de nuevo.');
      }

      timestamps.push(now);
      transaction.set(bucketRef, { timestamps }, { merge: true });
    });
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    // Fail-closed if Firestore is unavailable (security first)
    functions.logger.error('Rate limit check failed, rejecting request', { uid, error: e.message });
    throw new functions.https.HttpsError('resource-exhausted', 'Servicio temporalmente no disponible. Intenta de nuevo.');
  }
}

/**
 * HTTP endpoint: Creates a Mercado Pago checkout preference
 */
exports.createPaymentPreference = functions.runWith({ maxInstances: 10 }).https.onRequest(async (req, res) => {
  const allowedOrigins = [
    'https://sagen-bdd3f.web.app',
    'https://sagen-bdd3f.firebaseapp.com',
  ];
  const origin = req.headers.origin || '';

  // Reject requests with missing or non-allowed origin (except OPTIONS preflight)
  if (req.method !== 'OPTIONS') {
    if (!origin) {
      return res.status(403).json({ error: 'Falta el encabezado de origen' });
    }
    if (!allowedOrigins.includes(origin)) {
      return res.status(403).json({ error: 'Origen no permitido' });
    }
  }

  const allowed = allowedOrigins.includes(origin) ? origin : allowedOrigins[0];
  res.set('Access-Control-Allow-Origin', allowed);
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Debes iniciar sesión' });
    }

    const idToken = authHeader.split('Bearer ')[1];
    const decoded = await admin.auth().verifyIdToken(idToken);
    const userId = decoded.uid;

    try {
      await checkRateLimit(userId);
    } catch (e) {
      if (e instanceof functions.https.HttpsError) {
        return res.status(429).json({ error: 'Demasiadas solicitudes. Intenta de nuevo.' });
      }
      throw e;
    }

    const { amount, productId } = req.body;
    if (!amount || !productId) {
      return res.status(400).json({ error: 'Se requieren amount y productId' });
    }

    const pkg = await getProductDetails(productId);
    if (!pkg || pkg.amount !== amount) {
      return res.status(400).json({ error: `Amount no coincide: esperado ${pkg?.amount ?? 'desconocido'}, recibido ${amount}` });
    }

    const shortHash = (s) => {
      const secret = functions.config().app?.purchase_secret;
      if (!secret) {
        functions.logger.error('purchase_secret not configured');
        throw new functions.https.HttpsError('internal', 'Error de configuración del servidor');
      }
      return crypto.createHmac('sha256', secret).update(s).digest('hex').slice(0, 16);
    };
    const obfuscatedRef = `${shortHash(userId)}|${amount}|${productId}`;

    const preferenceData = {
      body: {
        items: [
          {
            id: productId,
            title: pkg.title,
            description: `$${amount} donation`,
            quantity: 1,
            unit_price: pkg.price,
            currency_id: 'PEN',
          },
        ],
        external_reference: obfuscatedRef,
        metadata: { userId, amount: String(amount), productId },
        back_urls: {
          success: `${APP_URL}payment/success?amount=${amount}`,
          failure: `${APP_URL}payment/failure`,
          pending: `${APP_URL}payment/pending`,
        },
        auto_return: 'approved',
        notification_url: `${WEBHOOK_BASE}/handlePaymentWebhook`,
        payment_methods: { installments: 1, default_installments: 1 },
      },
    };

    const preference = new Preference(mpClient);
    const result = await preference.create(preferenceData);

    functions.logger.info('Preference created', {
      preferenceId: result.id,
      obfuscatedRef,
      amount,
      productId,
    });

    return res.status(200).json({
      result: {
        preferenceId: result.id,
        initPoint: result.init_point || result.sandbox_init_point,
        externalRef: obfuscatedRef,
      },
    });
  } catch (error) {
    functions.logger.error('Failed to create preference', error);
    return res.status(500).json({ error: 'Error al crear la preferencia de pago' });
  }
});

/**
 * HTTP endpoint: Receives Mercado Pago payment notifications (webhook)
 *
 * Idempotency design:
 *   ▸ Fetch payment from MP API before the transaction.
 *   ▸ Inside a Firestore transaction, read payment_logs/{paymentId}
 *     AND users/{userId} atomically.
 *   ▸ If the log doc already exists → return early (no writes = no-op).
 *   ▸ Only then update the user doc and create the log doc.
 *   ▸ `transaction.create()` doubles as a safety net — if by some
 *     race a concurrent txn got there first, create throws, aborting
 *     the whole transaction. No double credit possible.
 */
exports.handlePaymentWebhook = functions.runWith({ maxInstances: 5 }).https.onRequest(async (req, res) => {
  try {
    const { type, data } = req.body;

    functions.logger.info('Webhook received', { type, data });

    if (type !== 'payment' || !data?.id) {
      return res.status(200).send('OK');
    }

    // ── VERIFY WEBHOOK SIGNATURE ───────────────────────────────
    const WEBHOOK_SECRET = functions.config().mercadopago?.webhook_secret;
    if (!WEBHOOK_SECRET) {
      functions.logger.error('MERCADOPAGO_WEBHOOK_SECRET not configured — rejecting webhook');
      return res.status(500).send('Error de configuración del servidor');
    }
    const signature = req.headers['x-signature'] || '';
    const parts = {};
    for (const part of signature.split(';')) {
      const [k, v] = part.split('=');
      if (k && v) parts[k.trim()] = v.trim();
    }
    const ts = parts['ts'];
    const v1 = parts['v1'];
    if (!ts || !v1) {
      functions.logger.warn('Webhook missing signature', { paymentId: data.id });
      return res.status(401).send('No autorizado');
    }
    const rawBody = req.rawBody ? req.rawBody.toString('utf8') : JSON.stringify(req.body);
    const expected = crypto.createHmac('sha256', WEBHOOK_SECRET)
      .update(`ts${ts}req${rawBody}`)
      .digest('hex');

    // Validate hex before comparing to prevent timingSafeEqual crash
    const isValidHex = /^[0-9a-f]{64}$/i.test(v1);
    if (!isValidHex) {
      functions.logger.warn('Webhook invalid hex signature', { paymentId: data.id });
      return res.status(401).send('No autorizado');
    }
    if (!crypto.timingSafeEqual(Buffer.from(v1, 'hex'), Buffer.from(expected, 'hex'))) {
      functions.logger.warn('Webhook signature mismatch', { paymentId: data.id });
      return res.status(401).send('No autorizado');
    }

    const paymentId = data.id.toString();

    // ── FETCH PAYMENT FROM MP API ─────────────────────────────
    const response = await fetch(
      `https://api.mercadopago.com/v1/payments/${paymentId}`,
      {
        headers: {
          Authorization: `Bearer ${MERCADOPAGO_ACCESS_TOKEN}`,
        },
      }
    );

    if (!response.ok) {
      functions.logger.error('Failed to fetch payment', {
        paymentId,
        status: response.status,
      });
      return res.status(200).send('OK');
    }

    const payment = await response.json();

    const externalRef = payment.external_reference || '';
    // Extract userId from metadata (preferred) or fallback to externalRef parsing
    const extParts = externalRef.split('|');
    const userId = payment.metadata?.userId || extParts[0] || '';
    const amount = parseInt(
      payment.metadata?.amount || extParts[1],
      10,
    );
    const productId = payment.metadata?.productId || extParts[2] || null;

    if (payment.status !== 'approved') {
      // Si está pending, registrar en pending_payments para seguimiento
      if (payment.status === 'pending' || payment.status === 'in_process') {
        const pendingRef = admin.firestore().collection('pending_payments').doc(paymentId);
        const pendingDoc = await pendingRef.get();
        if (!pendingDoc.exists) {
          await pendingRef.set({
            userId,
            paymentMethod: 'mercadopago',
            operationId: paymentId,
            amount: payment.transaction_amount || 0,
            productId: productId,
            status: payment.status,
            externalRef,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: admin.firestore.Timestamp.fromDate(
              new Date(Date.now() + 48 * 60 * 60 * 1000),
            ),
          });
          functions.logger.info('Pending payment registered from webhook', { paymentId, userId });
        }
      }
      functions.logger.info('Payment not approved', {
        paymentId,
        status: payment.status,
      });
      return res.status(200).send('OK');
    }

    if (!userId || isNaN(amount) || amount <= 0) {
      functions.logger.error('Invalid userId or amount', { userId, amount });
      return res.status(200).send('OK');
    }

    const userRef = admin.firestore().doc(`users/${userId}`);
    const logRef = admin.firestore().doc(`payment_logs/${paymentId}`);
    const catalog = await loadCatalog();
    const pkg = catalog[productId];
    const bonuses = pkg ? pkg.bonuses : [];

    // ── ATOMIC TRANSACTION with idempotency INSIDE ────────────
    // Read user + log in the same transaction so no two concurrent
    // webhooks can both pass the idempotency gate.
    await admin.firestore().runTransaction(async (transaction) => {
      const [userDoc, logDoc] = await Promise.all([
        transaction.get(userRef),
        transaction.get(logRef),
      ]);

      // If log already exists, payment was already processed
      if (logDoc.exists) {
        functions.logger.info('Payment already processed (transaction idempotent)', { paymentId });
        return; // no writes = no-op commit
      }

      if (!userDoc.exists) {
        functions.logger.error('User not found in transaction', { userId });
        return;
      }

      const userData = userDoc.data() || {};
      const currentDonated = userData.totalDonated || 0;

      const updateData = {
        totalDonated: currentDonated + amount,
        lastPaymentAt: admin.firestore.FieldValue.serverTimestamp(),
        lastPaymentMethod: 'mercadopago',
        lastPaymentAmount: amount,
        _ts_totalDonated: admin.firestore.FieldValue.serverTimestamp(),
      };

      applyProductBonuses(updateData, userData, bonuses);

      transaction.update(userRef, updateData);

      // Create log with paymentId as doc ID — `transaction.create`
      // throws if the doc already exists, aborting this transaction
      // so no double-spending is possible.
      transaction.create(logRef, {
        userId,
        amount,
        productId: productId || null,
        bonuses: bonuses,
        paymentAmount: payment.transaction_amount || 0,
        currency: payment.currency_id || 'PEN',
        paymentId,
        paymentMethod: payment.payment_method_id || 'unknown',
        status: payment.status,
        externalRef,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    functions.logger.info('Payment processed atomically', {
      userId, amount, productId: productId || 'none', bonuses: bonuses.length,
    });

    return res.status(200).send('OK');
  } catch (error) {
    functions.logger.error('Webhook handler error', error);
    return res.status(200).send('OK');
  }
});

/**
 * HTTP endpoint: Admin manual donation crediting for WhatsApp/Yape/Plin payments
 *
 * Idempotency design:
 *   ▸ The client generates a unique `idempotencyKey` (e.g. SHA-256 of
 *     `userId|amount|productId|timestamp`) and sends it with the request.
 *   ▸ Inside a Firestore transaction, read payment_logs/{idempotencyKey} and
 *     users/{userId} atomically.
 *   ▸ If the log doc already exists → return the previous result (no-op).
 *   ▸ Only then update the user doc and create the log doc.
 *   ▸ `transaction.create()` on the log doc prevents any race-condition
 *     double-credit even if called concurrently with the same key.
 */
exports.adminCreditDonation = functions.runWith({ maxInstances: 3 }).https.onCall(async (data, context) => {
  const { userId, amount, paymentMethod, productId, idempotencyKey } = data;

  // Uso context.auth en vez de adminSecret
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated', 'Debes iniciar sesión para usar esta función'
    );
  }
  const callerUid = context.auth.uid;

  // Solo admins pueden llamar esta función
  const adminDoc = await admin.firestore().doc(`admins/${callerUid}`).get();
  if (!adminDoc.exists) {
    throw new functions.https.HttpsError(
      'permission-denied', 'No tienes permisos de administrador'
    );
  }

  // Rate limit para admins (30 req/min)
  await checkRateLimit(callerUid, 30, 60000);

  if (!userId || !amount || amount <= 0) {
    throw new functions.https.HttpsError(
      'invalid-argument', 'userId y amount requeridos'
    );
  }

  if (!idempotencyKey) {
    throw new functions.https.HttpsError(
      'invalid-argument', 'idempotencyKey requerido'
    );
  }

  const logRef = admin.firestore().doc(`payment_logs/${idempotencyKey}`);
  const userRef = admin.firestore().doc(`users/${userId}`);
  const method = paymentMethod || 'whatsapp';

  // ── ATOMIC TRANSACTION with idempotency ─────────────────────
  try {
    const result = await admin.firestore().runTransaction(async (transaction) => {
      const [logDoc, userDoc] = await Promise.all([
        transaction.get(logRef),
        transaction.get(userRef),
      ]);

      // If log already exists, this request was already processed
      if (logDoc.exists) {
        functions.logger.info('Admin credit already processed (idempotent)', { idempotencyKey, userId });
        const existingData = logDoc.data() || {};
        return {
          success: true,
          duplicate: true,
          newBalance: existingData.postBalance || 0,
          bonuses: existingData.bonuses || [],
        };
      }

      if (!userDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
      }

      const userData = userDoc.data() || {};
      const currentDonated = userData.totalDonated || 0;

      const updateData = {
        totalDonated: currentDonated + amount,
        lastManualCreditAt: admin.firestore.FieldValue.serverTimestamp(),
        lastManualCreditMethod: method,
        lastManualCreditAmount: amount,
        _ts_totalDonated: admin.firestore.FieldValue.serverTimestamp(),
      };

      const catalog = await loadCatalog();
      const pkg = catalog[productId];
      const bonuses = pkg ? pkg.bonuses : [];

      applyProductBonuses(updateData, userData, bonuses);

      transaction.update(userRef, updateData);
      transaction.create(logRef, {
        userId,
        amount,
        productId: productId || null,
        bonuses: bonuses,
        method: 'manual_' + method,
        creditedBy: 'admin',
        postBalance: currentDonated + amount,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      let resultBonuses = bonuses.map(b => ({ ...b }));
      if (productId === 'bundle_protector') {
        const newShields = (userData.shop_streak_shields || 0) +
          Math.min(bonuses.find(b => b.type === 'streakProtector')?.quantity || 0,
            getStreakShieldSlots(userData.shop_streak_shields || 0));
        resultBonuses = resultBonuses.map(b =>
          b.type === 'streakProtector'
            ? { ...b, quantity: newShields - (userData.shop_streak_shields || 0) }
            : b
        );
      }

      return {
        success: true,
        duplicate: false,
        newBalance: currentDonated + amount,
        bonuses: resultBonuses,
      };
    });

    functions.logger.info('Manual donation credited', { userId, amount, method, productId, duplicate: result.duplicate });

    return result;
  } catch (error) {
    functions.logger.error('Manual credit error', error);
    throw new functions.https.HttpsError('internal', 'Error al acreditar donación');
  }
});

/**
 * HTTPS Callable: Server-side gem balance validation before purchase.
 * Returns a signed token that the client must include in the spend request.
 * The token expires after 60 seconds.
 */
exports.validatePurchase = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }
  await checkRateLimit(context.auth.uid);

  const { cost, itemId } = data;
  if (!cost || cost <= 0 || !itemId) {
    throw new functions.https.HttpsError('invalid-argument', 'cost e itemId requeridos');
  }

  const userId = context.auth.uid;
  const userRef = admin.firestore().doc(`users/${userId}`);

  try {
    const userDoc = await userRef.get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Usuario no encontrado');
    }

    const userData = userDoc.data() || {};
    const balance = userData.totalDonated || 0;

    if (balance < cost) {
      throw new functions.https.HttpsError(
        'failed-precondition', 'Donación insuficiente',
      );
    }

    // Generar token firmado que expira en 60 segundos
    const payload = JSON.stringify({
      userId,
      itemId,
      cost,
      ts: Date.now(),
      exp: Date.now() + 60000,
    });
    const secret = functions.config().app?.purchase_secret;
    if (!secret) {
      functions.logger.error('purchase_secret not configured');
      throw new functions.https.HttpsError('internal', 'Error de configuración del servidor');
    }
    const hmac = crypto.createHmac('sha256', secret).update(payload).digest('hex');
    const token = Buffer.from(JSON.stringify({ payload, sig: hmac })).toString('base64');

    functions.logger.info('Purchase validation token issued', { userId, itemId, cost });

    return { valid: true, totalDonated: balance, token };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('validatePurchase error', error);
    throw new functions.https.HttpsError('internal', 'Error al validar la compra');
  }
});

/**
 * HTTPS Callable: Register a pending payment (WhatsApp/Yape/Plin).
 * Saves to pending_payments collection for admin review.
 */
exports.registerPendingPayment = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }
  await checkRateLimit(context.auth.uid);

  const { paymentMethod, operationId, amount, productId } = data;
  if (!paymentMethod || !operationId) {
    throw new functions.https.HttpsError('invalid-argument', 'paymentMethod y operationId requeridos');
  }

  const validMethods = ['whatsapp', 'yape', 'plin'];
  if (!validMethods.includes(paymentMethod)) {
    throw new functions.https.HttpsError('invalid-argument', 'Método de pago no válido');
  }

  const userId = context.auth.uid;

  // Use operationId as doc ID to prevent duplicate pending payments
  const pendingRef = admin.firestore().doc(`pending_payments/${userId}_${operationId}`);
  const pendingDoc = await pendingRef.get();

  if (pendingDoc.exists) {
    return { success: true, pendingPaymentId: pendingRef.id, duplicate: true };
  }

  await pendingRef.set({
    userId,
    paymentMethod,
    operationId,
    amount: amount || 0,
    productId: productId || null,
    status: 'pending',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 horas
    ),
  });

  functions.logger.info('Pending payment registered', {
    userId, paymentMethod, operationId, pendingId: pendingRef.id,
  });

  return { success: true, pendingPaymentId: pendingRef.id, duplicate: false };
});

/**
 * Health check endpoint
 */
exports.health = functions.runWith({ maxInstances: 2 }).https.onRequest(async (req, res) => {
  res.json({
    status: 'ok',
    project: process.env.GCLOUD_PROJECT || 'unknown',
  });
});

/**
 * HTTPS Callable: Check pending payment status (WhatsApp/Yape/Plin).
 * Returns the current status of a pending payment for client polling.
 */
exports.checkPendingPaymentStatus = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }

  const { pendingPaymentId } = data;
  if (!pendingPaymentId || typeof pendingPaymentId !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'pendingPaymentId requerido');
  }

  const userId = context.auth.uid;
  const pendingRef = admin.firestore().doc(`pending_payments/${pendingPaymentId}`);
  const pendingDoc = await pendingRef.get();

  if (!pendingDoc.exists) {
    return { status: 'not_found' };
  }

  const pendingData = pendingDoc.data();
  if (pendingData.userId !== userId) {
    throw new functions.https.HttpsError('permission-denied', 'No tienes acceso a este pago');
  }

  return {
    status: pendingData.status || 'pending',
    createdAt: pendingData.createdAt?.toDate?.()?.toISOString() || null,
    expiresAt: pendingData.expiresAt?.toDate?.()?.toISOString() || null,
    isExpired: pendingData.expiresAt?.toDate?.()?.getTime() < Date.now(),
    serverBalance: (await admin.firestore().doc(`users/${userId}`).get()).data()?.totalDonated ?? null,
  };
});

/**
 * Scheduled Function: Clean up expired pending payments.
 * Runs daily at 03:00 UTC. Deletes pending payments older than 24 hours.
 */
exports.cleanupExpiredPendingPayments = functions.runWith({ maxInstances: 3 }).pubsub.schedule('0 3 * * *').onRun(async (context) => {
  const now = admin.firestore.Timestamp.now();
  const expiredRef = admin.firestore().collection('pending_payments')
    .where('expiresAt', '<', now);

  const snapshot = await expiredRef.get();
  if (snapshot.empty) {
    functions.logger.info('No expired pending payments to clean up');
    return null;
  }

  const batch = admin.firestore().batch();
  let count = 0;
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    count++;
    if (count >= 500) {
      await batch.commit();
      break;
    }
  }
  if (count <= 500) {
    await batch.commit();
  }

  functions.logger.info(`Cleaned up ${count} expired pending payments`);
  return null;
});

// ── Economic Functions (server-authoritative) ──
const economic = require('./economic');
exports.addXp = economic.addXp;
exports.incrementStreak = economic.incrementStreak;
exports.completeLesson = economic.completeLesson;

// ── Gamification Functions (server-authoritative daily claims) ──
const gamification = require('./gamification');
exports.claimDailyChest = gamification.claimDailyChest;
exports.earnSagenPassSP = gamification.earnSagenPassSP;
exports.claimSagenPassReward = gamification.claimSagenPassReward;
exports.claimAdReward = gamification.claimAdReward;
exports.rollChestDrop = gamification.rollChestDrop;
exports.getSagenPassSeason = gamification.getSagenPassSeason;

// ── Gem Economy (server-authoritative, anti-farm) ────────────────
const gems = require('./gems');
exports.earnGems = gems.earnGems;
exports.spendGems = gems.spendGems;
exports.getGemsBalance = gems.getGemsBalance;

// ── AI Streaming (CRIT-2) ──────────────────────────────────────────
const aiStreaming = require('./ai_streaming');
exports.generateContentStream = aiStreaming.generateContentStream;

// ── Server-side Gacha (CRIT-5) ─────────────────────────────────────
const gacha = require('./gacha');
exports.rollChestEvolution = gacha.rollChestEvolution;

// ── Offline Sync (CRIT-6) ──────────────────────────────────────────
const sync = require('./sync');
exports.syncLessonCompletions = sync.syncLessonCompletions;

// ── Gemini AI Proxy (SEC-001: API key never exposed to client) ─────
const GEMINI_API_KEY = functions.config().gemini?.api_key;
const GEMINI_MODEL = 'gemini-2.5-flash';
const GEMINI_MAX_OUTPUT_TOKENS = 8192;
const GEMINI_TEMPERATURE = 0.85;
const GEMINI_TOP_K = 40;
const GEMINI_TOP_P = 0.95;

/**
 * HTTPS Callable: Generate AI response via Gemini proxy.
 * The API key stays server-side only. Client sends prompt, receives response.
 */
exports.generateContent = functions.runWith({ maxInstances: 3 }).https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Debes iniciar sesión');
  }
  await checkRateLimit(context.auth.uid);

  if (!GEMINI_API_KEY) {
    throw new functions.https.HttpsError('failed-precondition', 'Clave API de Gemini no configurada');
  }

  const { contents, systemInstruction } = data;
  if (!contents || !Array.isArray(contents) || contents.length === 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Se requiere un arreglo contents');
  }

  // Rate limit: max 30 requests per user per minute (distributed via Firestore)
  await checkRateLimit(context.auth.uid, 30, 60000);

  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`;

    const body = {
      contents: contents.map(c => ({
        role: ['user', 'model'].includes(c.role) ? c.role : 'user',
        parts: c.parts || [{ text: (c.text || '').slice(0, 10000) }],
      })),
      generationConfig: {
        maxOutputTokens: GEMINI_MAX_OUTPUT_TOKENS,
        temperature: GEMINI_TEMPERATURE,
        topK: GEMINI_TOP_K,
        topP: GEMINI_TOP_P,
      },
      safetySettings: [
        { category: 'HARM_CATEGORY_HARASSMENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        { category: 'HARM_CATEGORY_HATE_SPEECH', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        { category: 'HARM_CATEGORY_SEXUALLY_EXPLICIT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
        { category: 'HARM_CATEGORY_DANGEROUS_CONTENT', threshold: 'BLOCK_MEDIUM_AND_ABOVE' },
      ],
    };

    if (systemInstruction) {
      body.systemInstruction = { parts: [{ text: systemInstruction }] };
    }

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': GEMINI_API_KEY,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errText = await response.text();
      functions.logger.error('Gemini API error', { status: response.status, body: errText });
      throw new functions.https.HttpsError('internal', 'Error al contactar Gemini');
    }

    const result = await response.json();
    const text = result.candidates?.[0]?.content?.parts?.[0]?.text || '';

    if (!text.trim()) {
      throw new functions.https.HttpsError('internal', 'Gemini devolvió respuesta vacía');
    }

    return { text };
  } catch (e) {
    if (e instanceof functions.https.HttpsError) throw e;
    functions.logger.error('generateContent error', e);
    throw new functions.https.HttpsError('internal', 'Error interno del servidor');
  }
});
