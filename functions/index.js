const functions = require('firebase-functions');
const admin = require('firebase-admin');
const crypto = require('crypto');
const { MercadoPagoConfig, Preference } = require('mercadopago');
const { requireVerifiedUser } = require('./auth_guard');

admin.initializeApp();

// TODO(migrar-secretos): los valores siguen en functions.config() (siguen
// soportados en runtime Node 22). Al habilitar Secret Manager en el proyecto:
// migrar a defineSecret + attach en runWith({secrets}) y borrar estos reads.
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

const hardcodedCatalog = require('./catalog');
const SAGEN_PASS_GEMS = hardcodedCatalog.SAGEN_PASS_GEMS;
const catalogService = hardcodedCatalog.createCatalog(admin, functions.logger);

const loadCatalog = () => catalogService.loadCatalog();
const getProductDetails = (productId) => catalogService.getProductDetails(productId);

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

/**
 * Reverts the benefits granted by an approved payment when Mercado Pago
 * reports a refund or chargeback (status `refunded`/`charged_back`).
 *
 * Idempotency: payment_logs/{id} carries the CURRENT status. Only logs still
 * in status 'approved' get reverted; after the first reversal the log moves to
 * `refunded`/`charged_back`, so concurrent or replayed webhooks become no-ops.
 *
 * The reversal uses the `granted` deltas persisted at credit time (the
 * effective increments after cap clamping). Legacy logs created before that
 * field fall back to the catalog bonuses, always clamped at zero so balances
 * woned through other means are never corrupted.
 */
async function revertApprovedPayment(paymentId, payment) {
  const logRef = admin.firestore().doc(`payment_logs/${paymentId}`);
  try {
    return await admin.firestore().runTransaction(async (transaction) => {
      const logDoc = await transaction.get(logRef);
      if (!logDoc.exists) return 'no-log';
      const logData = logDoc.data() || {};
      if (logData.status !== 'approved') return 'already-reverted';

      const userId = logData.userId;
      if (!userId) return 'no-user-id';
      const userRef = admin.firestore().doc(`users/${userId}`);
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return 'user-missing';
      const userData = userDoc.data() || {};

      const granted = logData.granted || {};
      const revertedAmount =
        granted.total_donated || logData.amount || payment.transaction_amount || 0;
      const newTotalDonated = Math.max(
        0,
        (userData.total_donated || 0) - revertedAmount,
      );

      const updateData = {
        total_donated: newTotalDonated,
        is_supporter: newTotalDonated > 0,
        _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
      };

      const bonuses = Array.isArray(logData.bonuses) ? logData.bonuses : [];
      for (const bonus of bonuses) {
        if (bonus.type === 'streakProtector') {
          updateData.shop_streak_shields = Math.max(
            0,
            (userData.shop_streak_shields || 0) -
              (granted.shop_streak_shields || bonus.quantity || 0),
          );
        } else if (bonus.type === 'xpBoost') {
          updateData.shop_purchased_xp_boosts = Math.max(
            0,
            (userData.shop_purchased_xp_boosts || 0) -
              (granted.shop_purchased_xp_boosts || bonus.quantity || 0),
          );
        } else if (bonus.type === 'xpMultiplier') {
          updateData.shop_purchased_xp_multipliers = Math.max(
            0,
            (userData.shop_purchased_xp_multipliers || 0) -
              (granted.shop_purchased_xp_multipliers || bonus.quantity || 0),
          );
        } else if (bonus.type === 'luckBoost') {
          updateData.shop_purchased_luck_boosts = Math.max(
            0,
            (userData.shop_purchased_luck_boosts || 0) -
              (granted.shop_purchased_luck_boosts || bonus.quantity || 0),
          );
        } else if (bonus.type === 'sagenPass') {
          const gemsGranted = granted.learning_gems || bonus.gems || SAGEN_PASS_GEMS;
          updateData.learning_gems = Math.max(
            0,
            (userData.learning_gems || 0) - gemsGranted,
          );
          if (newTotalDonated <= 0) {
            // Los flags de PASS solo se revocan si no quedan donaciones
            // activas; un PASS con otro pago vigente se conserva (no revocar
            // acceso legítimo).
            updateData.sagen_pass_active = false;
            updateData.premium_question_bank = false;
          }
        }
      }

      transaction.update(userRef, updateData);
      transaction.update(logRef, {
        status: payment.status,
        revertReason: payment.status,
        revertedAmount,
        revertedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return 'reverted';
    });
  } catch (error) {
    functions.logger.error('revertApprovedPayment error', { paymentId, error });
    return 'error';
  }
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

    // NUEVO-fix: regla de oro del proyecto — las mutaciones monetarias solo
    // con email verificado (auth_guard.js). Era el único endpoint de pago real
    // que no lo exigía.
    if (decoded.email_verified !== true) {
      return res.status(403).json({ error: 'Necesitas un correo verificado para realizar pagos' });
    }

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
    // Algoritmo oficial de Mercado Pago (HMAC-SHA256 WEBHOOK_SECRET):
    //  1. x-signature llega como `ts=<ts>,v1=<hmac>` (separador: coma).
    //  2. Se firma el manifest `id:<data.id>;request-id:<x-request-id>;ts:<ts>;`
    //     donde <data.id> es el QUERY PARAM (no el body), en minúsculas si es
    //     alfanumérico, omitiendo las secciones ausentes (id/request-id).
    //  3. digest hex comparado en tiempo constante + ventana de freshness.
    const WEBHOOK_SECRET = functions.config().mercadopago?.webhook_secret;
    if (!WEBHOOK_SECRET) {
      functions.logger.error('MERCADOPAGO_WEBHOOK_SECRET not configured — rejecting webhook');
      return res.status(500).send('Error de configuración del servidor');
    }
    const dataIdRaw = String(req.query?.['data.id'] || '').trim();
    const dataId = /^[a-zA-Z0-9]+$/.test(dataIdRaw) ? dataIdRaw.toLowerCase() : dataIdRaw;
    const xRequestId = String(req.headers['x-request-id'] || '').trim();
    const signature = String(req.headers['x-signature'] || '');
    const parts = {};
    for (const part of signature.split(',')) {
      const [k, v] = part.split('=');
      if (k && v) parts[k.trim()] = v.trim();
    }
    const ts = parts['ts'];
    const v1 = parts['v1'];
    if (!ts || !v1 || !dataId || !xRequestId) {
      functions.logger.warn('Webhook missing signature parts', {
        paymentId: dataId,
        hasTs: !!ts,
        hasV1: !!v1,
        hasDataId: !!dataId,
        hasRequestId: !!xRequestId,
      });
      return res.status(401).send('No autorizado');
    }

    // Freshness window: MP envía ts en segundos o milisegundos. Se rechazan
    // firmas con >10 min de antigüedad o futuras para mitigar replay/clock skew.
    const tsNum = Number(ts);
    if (Number.isFinite(tsNum) && tsNum > 0) {
      const tsMs = tsNum > 1e12 ? tsNum : tsNum * 1000;
      const driftMs = Math.abs(Date.now() - tsMs);
      if (driftMs > 10 * 60 * 1000) {
        functions.logger.warn('Webhook signature timestamp out of window', { paymentId: dataId });
        return res.status(401).send('No autorizado');
      }
    }

    let manifest = '';
    if (dataId) manifest += `id:${dataId};`;
    if (xRequestId) manifest += `request-id:${xRequestId};`;
    manifest += `ts:${ts};`;

    const expected = crypto.createHmac('sha256', WEBHOOK_SECRET)
      .update(manifest)
      .digest('hex');

    // Validate hex before comparing to prevent timingSafeEqual crash
    const isValidHex = /^[0-9a-f]{64}$/i.test(v1);
    if (!isValidHex) {
      functions.logger.warn('Webhook invalid hex signature', { paymentId: dataId });
      return res.status(401).send('No autorizado');
    }
    const provided = Buffer.from(v1, 'hex');
    const computed = Buffer.from(expected, 'hex');
    if (provided.length !== computed.length ||
        !crypto.timingSafeEqual(provided, computed)) {
      functions.logger.warn('Webhook signature mismatch', { paymentId: dataId });
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
      // Return non-2xx so MercadoPago retries: an approved payment must never
      // be silently dropped because of a transient API failure.
      return res.status(502).send('Failed to fetch payment from MercadoPago');
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
      // NUEVO-fix (A2): un reembolso/chargeback revierte exactamente lo
      // concedido por el pago aprobado (payment_logs/{id} en status approved).
      // Si la reversión falla se responde 5xx para que MercadoPago reintente.
      if (payment.status === 'refunded' || payment.status === 'charged_back') {
        const outcome = await revertApprovedPayment(paymentId, payment);
        if (outcome === 'error') {
          functions.logger.error('Payment reversal failed — returning 5xx for retry', {
            paymentId, status: payment.status,
          });
          return res.status(500).send('Internal error');
        }
        functions.logger.info('Payment reversal processed', {
          paymentId, status: payment.status, outcome,
        });
        return res.status(200).send('OK');
      }
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
      // NUEVO-fix: never silently swallow an approved payment without the
      // metadata needed to credit the user. Log details and return a
      // non-2xx so MercadoPago retries / flags the webhook for review.
      functions.logger.error('Approved payment missing userId/amount — NOT credited', {
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
      const currentDonated = userData.total_donated || 0;

      const updateData = {
        total_donated: currentDonated + amount,
        is_supporter: true,
        lastPaymentAt: admin.firestore.FieldValue.serverTimestamp(),
        lastPaymentMethod: 'mercadopago',
        lastPaymentAmount: amount,
        _ts_total_donated: admin.firestore.FieldValue.serverTimestamp(),
      };

      applyProductBonuses(updateData, userData, bonuses);

      // NUEVO-fix (A2): se persisten los deltas EFECTIVOS concedidos (tras el
      // cap de escudos, etc.) para que un reembolso/chargeback pueda revertir
      // exactamente lo concedido sin tocar saldos ganados por otros medios.
      const granted = {
        total_donated: amount,
        is_supporter: true,
        shop_streak_shields: updateData.shop_streak_shields !== undefined
          ? updateData.shop_streak_shields - (userData.shop_streak_shields || 0)
          : 0,
        shop_purchased_xp_boosts: updateData.shop_purchased_xp_boosts !== undefined
          ? updateData.shop_purchased_xp_boosts - (userData.shop_purchased_xp_boosts || 0)
          : 0,
        shop_purchased_xp_multipliers: updateData.shop_purchased_xp_multipliers !== undefined
          ? updateData.shop_purchased_xp_multipliers - (userData.shop_purchased_xp_multipliers || 0)
          : 0,
        shop_purchased_luck_boosts: updateData.shop_purchased_luck_boosts !== undefined
          ? updateData.shop_purchased_luck_boosts - (userData.shop_purchased_luck_boosts || 0)
          : 0,
        learning_gems: updateData.learning_gems !== undefined
          ? updateData.learning_gems - (userData.learning_gems || 0)
          : 0,
        sagen_pass_granted: updateData.sagen_pass_active === true,
      };

      transaction.update(userRef, updateData);

      // Create log with paymentId as doc ID — `transaction.create`
      // throws if the doc already exists, aborting this transaction
      // so no double-spending is possible.
      transaction.create(logRef, {
        userId,
        amount,
        productId: productId || null,
        bonuses: bonuses,
        granted: granted,
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
    // Return non-2xx so MercadoPago retries the webhook instead of silently
    // swallowing an approved payment. 4xx paths above already returned, so any
    // exception reaching here is transient/internal.
    functions.logger.error('Webhook handler error', error);
    return res.status(500).send('Internal error');
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
  const { userId, paymentMethod, productId, idempotencyKey } = data || {};

  // Uso context.auth en vez de adminSecret
  requireVerifiedUser(context);
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

  // NUEVO-fix: coerce amount to a real number BEFORE any arithmetic so a
  // string payload cannot produce "105" from amount="10"+"5" concatenation.
  const rawAmount = data && data.amount;
  const amount = typeof rawAmount === 'number'
    ? rawAmount
    : parseFloat(String(rawAmount ?? '').replace(',', '.'));

  if (!userId || !Number.isFinite(amount) || amount <= 0) {
    throw new functions.https.HttpsError(
      'invalid-argument', 'userId y amount (número) requeridos'
    );
  }
  if (amount > 100000) {
    throw new functions.https.HttpsError(
      'invalid-argument', `El monto excede el límite de 100000`
    );
  }
  if (!/^[A-Za-z0-9_-]{1,128}$/.test(userId)) {
    throw new functions.https.HttpsError(
      'invalid-argument', 'userId invalido'
    );
  }

  if (!idempotencyKey || !/^[A-Za-z0-9_-]{1,128}$/.test(idempotencyKey)) {
    throw new functions.https.HttpsError(
      'invalid-argument', 'idempotencyKey invalido'
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
      const currentDonated = userData.total_donated || 0;

      const updateData = {
        total_donated: currentDonated + amount,
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
/**
 * HTTPS Callable: Register a pending payment (WhatsApp/Yape/Plin).
 * Saves to pending_payments collection for admin review.
 */
exports.registerPendingPayment = functions.runWith({ maxInstances: 5 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);
  await checkRateLimit(context.auth.uid);

  const { paymentMethod, operationId, amount, productId } = data || {};
  if (!paymentMethod || typeof paymentMethod !== 'string' || !operationId) {
    throw new functions.https.HttpsError('invalid-argument', 'paymentMethod y operationId requeridos');
  }

  const validMethods = ['whatsapp', 'yape', 'plin'];
  if (!validMethods.includes(paymentMethod)) {
    throw new functions.https.HttpsError('invalid-argument', 'Método de pago no válido');
  }

  if (typeof amount !== 'number' || !Number.isFinite(amount) || amount <= 0 || amount > 100000) {
    throw new functions.https.HttpsError('invalid-argument', 'El monto debe ser un número mayor a 0');
  }
  // Sanitize against path injection into the document id
  // (`pending_payments/{userId}_{operationId}` must stay a single segment).
  if (typeof operationId !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(operationId)) {
    throw new functions.https.HttpsError('invalid-argument', 'operationId invalido');
  }

  const userId = context.auth.uid;

  try {
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
      amount,
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
  } catch (error) {
    if (error instanceof functions.https.HttpsError) throw error;
    functions.logger.error('registerPendingPayment error', error);
    throw new functions.https.HttpsError('internal', 'Error al registrar el pago');
  }
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
  requireVerifiedUser(context);

  const { pendingPaymentId } = data || {};
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
    serverBalance: (await admin.firestore().doc(`users/${userId}`).get()).data()?.total_donated ?? null,
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
exports.processDonation = economic.processDonation;
exports.recordDonation = economic.recordDonation;
exports.claimFreeStreakShield = economic.claimFreeStreakShield;

// ── Gamification Functions (server-authoritative daily claims) ──
const gamification = require('./gamification');
  exports.claimDailyChest = gamification.claimDailyChest;
  exports.claimSagenPassReward = gamification.claimSagenPassReward;
exports.claimAdReward = gamification.claimAdReward;
exports.rollChestDrop = gamification.rollChestDrop;
exports.getSagenPassSeason = gamification.getSagenPassSeason;
exports.getDailyChestStatus = gamification.getDailyChestStatus;

// ── Gem Economy (server-authoritative, anti-farm) ────────────────
const gems = require('./gems');
exports.earnGems = gems.earnGems;
exports.spendGems = gems.spendGems;
exports.getGemsBalance = gems.getGemsBalance;

// ── Inventory (server-authoritative items & cosmetics, NUEVO-08) ──
const inventory = require('./inventory');
exports.getInventory = inventory.getInventory;
exports.useInventoryItem = inventory.useInventoryItem;

// ── AI Streaming (CRIT-2) ──────────────────────────────────────────
const aiStreaming = require('./ai_streaming');
exports.generateContentStream = aiStreaming.generateContentStream;

// ── Server-side Gacha (CRIT-5) ─────────────────────────────────────
const gacha = require('./gacha');
exports.rollChestEvolution = gacha.rollChestEvolution;

// ── Gemini AI Proxy (SEC-001: API key never exposed to client) ─────
const GEMINI_API_KEY = functions.config().gemini?.api_key;
const GEMINI_MODEL = 'gemini-2.5-flash';
const GEMINI_MAX_OUTPUT_TOKENS = 8192;
const GEMINI_TEMPERATURE = 0.85;
const GEMINI_TOP_K = 40;
const GEMINI_TOP_P = 0.95;

/**
 * HTTPS Callable: Generate AI response via Gemini proxy (non-streaming).
 * The API key stays server-side only. Client sends prompt, receives response.
 *
 * @deprecated The app uses the streaming path (generateContentStream) from
 * ai_streaming.js. This non-streaming variant is kept only as a fallback for
 * clients that cannot use streaming; it is not called by current production
 * code. Do not add new features here — extend ai_streaming.js instead.
 */
exports.generateContent = functions.runWith({ maxInstances: 3 }).https.onCall(async (data, context) => {
  requireVerifiedUser(context);
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
