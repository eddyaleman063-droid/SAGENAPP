/**
 * Tests for economic.js — Server-authoritative economic functions.
 * Covers: processDonation, addXp, incrementStreak, completeLesson,
 * and the daily XP cap helpers (checkDailyXpCap, computeCappedXp).
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const admin = require('firebase-admin');
const economic = require('../economic');

const AUTH_UID = 'test-user-123';
const makeContext = (uid = AUTH_UID) => ({ auth: { uid, token: { email_verified: true } } });
const NO_AUTH = {};
const makeUnverifiedContext = (uid = AUTH_UID) => ({ auth: { uid, token: { email_verified: false } } });

beforeEach(() => {
  admin._resetFirestore();
});

function setUserDoc(uid, data) {
  admin._setDoc(`users/${uid}`, data);
}

// Día calendario UTC (YYYY-MM-DD) desplazado [offsetDays] desde hoy.
function isoDay(offsetDays) {
  const d = new Date();
  d.setUTCDate(d.getUTCDate() + offsetDays);
  return d.toISOString().split('T')[0];
}

// Última actividad del server como ISO YYYY-MM-DD desplazada [offsetDays].
function lastActivityAt(offsetDays) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return { toDate: () => d };
}

describe('computeCappedXp', () => {
  test('caps XP at MAX_DAILY_XP (500)', () => {
    const result = economic.computeCappedXp(480, 50);
    expect(result.cappedXp).toBe(20);
    expect(result.remaining).toBe(20);
  });

  test('returns full amount when under cap', () => {
    const result = economic.computeCappedXp(0, 50);
    expect(result.cappedXp).toBe(50);
    expect(result.remaining).toBe(500);
  });

  test('returns zero when cap reached', () => {
    const result = economic.computeCappedXp(500, 50);
    expect(result.cappedXp).toBe(0);
    expect(result.remaining).toBe(0);
  });
});

describe('checkDailyXpCap', () => {
  test('allows when under cap', async () => {
    const result = await economic.checkDailyXpCap(AUTH_UID, 30);
    expect(result.allowed).toBe(true);
    expect(result.cappedXp).toBe(30);
  });

  test('blocks when cap exhausted', async () => {
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${new Date().toISOString().split('T')[0]}`, { total: 500 });
    const result = await economic.checkDailyXpCap(AUTH_UID, 30);
    expect(result.allowed).toBe(false);
    expect(result.cappedXp).toBe(0);
  });
});

describe('processDonation', () => {
  test('credits donation to user balance (wallet insta-credit)', async () => {
    setUserDoc(AUTH_UID, { total_donated: 100, walletBalance: 200 });
    const result = await economic.processDonation(
      { amount: 25, method: 'wallet', idempotencyKey: 'donation-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.total_donated).toBe(125);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.walletBalance).toBe(175);
    expect(user.is_supporter).toBe(true);
  });

  test('NUEVO-fix (decisión de producto): método no-wallet registra pending payment sin acreditar supporter', async () => {
    setUserDoc(AUTH_UID, { total_donated: 100 });
    const result = await economic.processDonation(
      { amount: 25, method: 'mercadopago', idempotencyKey: 'donation-nw-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.pending).toBe(true);
    expect(result.pendingPaymentId).toBe(`test-user-123_donation-nw-1`);
    expect(result.total_donated).toBe(100);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.total_donated).toBe(100);
    expect(user.is_supporter).not.toBe(true);
    const pending = admin._getDoc(`pending_payments/test-user-123_donation-nw-1`);
    expect(pending.status).toBe('pending');
    expect(pending.paymentMethod).toBe('mercadopago');
    // El retry con la misma clave es duplicate, sin crear un segundo pending.
    const replay = await economic.processDonation(
      { amount: 25, method: 'mercadopago', idempotencyKey: 'donation-nw-1' },
      makeContext()
    );
    expect(replay.duplicate).toBe(true);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('rejects unverified user (requiere email_verified)', async () => {
    setUserDoc(AUTH_UID, {});
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, makeUnverifiedContext())
    ).rejects.toThrow(expect.objectContaining({ code: 'failed-precondition' }));
  });

  test('rejects amount <= 0', async () => {
    setUserDoc(AUTH_UID, {});
    await expect(
      economic.processDonation({ amount: 0, method: 'wallet', idempotencyKey: 'k' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, {});
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet' }, makeContext())
    ).rejects.toThrow();
  });

  test('rejects insufficient wallet balance', async () => {
    setUserDoc(AUTH_UID, { walletBalance: 5 });
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, makeContext())
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { total_donated: 100, walletBalance: 200 });
    await economic.processDonation(
      { amount: 25, method: 'wallet', idempotencyKey: 'donation-dup' },
      makeContext()
    );
    const result = await economic.processDonation(
      { amount: 25, method: 'wallet', idempotencyKey: 'donation-dup' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.total_donated).toBe(125);
  });

  test('NUEVO-fix: rejects a key created by another user (no silent swallow)', async () => {
    setUserDoc(AUTH_UID, { walletBalance: 50, total_donated: 0 });
    setUserDoc('other-user', { walletBalance: 50, total_donated: 0 });
    await economic.processDonation(
      { amount: 10, method: 'wallet', idempotencyKey: 'shared-key' },
      makeContext(AUTH_UID)
    );
    // Usuario B reenvía la misma clave: colisión/replay, nunca un duplicado
    // legítimo del propio usuario. La donación no se traga en silencio.
    await expect(
      economic.processDonation(
        { amount: 10, method: 'wallet', idempotencyKey: 'shared-key' },
        makeContext('other-user')
      )
    ).rejects.toThrow(expect.objectContaining({ code: 'already-exists' }));
  });

  test('rejects non-existent user', async () => {
    await expect(
      economic.processDonation({ amount: 10, method: 'wallet', idempotencyKey: 'k' }, makeContext('ghost'))
    ).rejects.toThrow();
  });
});

describe('recordDonation (NUEVO-fix idempotencia)', () => {
  test('NUEVO-fix: wallet debits real balance and credits supporter', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0, walletBalance: 100 });
    const result = await economic.recordDonation(
      { amount: 25, method: 'wallet', idempotencyKey: 'don-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.total_donated).toBe(25);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.walletBalance).toBe(75);
    expect(user.is_supporter).toBe(true);
  });

  test('NUEVO-fix (decisión de producto): manual methods register a pending payment without auto-supporting', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    const result = await economic.recordDonation(
      { amount: 25, method: 'whatsapp', idempotencyKey: 'don-manual-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.pending).toBe(true);
    // Un método manual NO acredita al supporter al instante (aprobación admin).
    expect(result.total_donated).toBe(0);
    expect(admin._getDoc(`users/${AUTH_UID}`).is_supporter).not.toBe(true);
    const pending = admin._getDoc(`pending_payments/${AUTH_UID}_don-manual-1`);
    expect(pending.status).toBe('pending');
    expect(pending.paymentMethod).toBe('whatsapp');
    const replay = await economic.recordDonation(
      { amount: 25, method: 'whatsapp', idempotencyKey: 'don-manual-1' },
      makeContext()
    );
    expect(replay.duplicate).toBe(true);
  });

  test('NUEVO-fix: retry keyless de la misma donación no duplica (clave determinista)', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    const first = await economic.recordDonation(
      { amount: 15, method: 'yape' },
      makeContext()
    );
    expect(first.duplicate).toBe(false);
    expect(first.pending).toBe(true);
    expect(first.total_donated).toBe(0);
    // Timeout de red re-enviado (mismo día, monto y método): la clave derivada
    // coincide y el retry es duplicate (antes, Date.now() = doble crédito).
    const second = await economic.recordDonation(
      { amount: 15, method: 'yape' },
      makeContext()
    );
    expect(second.duplicate).toBe(true);
    expect(admin._getDoc(`users/${AUTH_UID}`).total_donated).toBe(0);
  });

  test('NUEVO-fix: monto distinto el mismo día recibe su propia clave', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    await economic.recordDonation({ amount: 10, method: 'whatsapp' }, makeContext());
    const second = await economic.recordDonation({ amount: 20, method: 'whatsapp' }, makeContext());
    expect(second.duplicate).toBe(false);
    expect(second.pending).toBe(true);
  });

  test('NUEVO-fix: rechaza una clave creada por otro usuario', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    setUserDoc('other-user-rd', { total_donated: 0 });
    await economic.recordDonation(
      { amount: 5, method: 'plin', idempotencyKey: 'rf-key' },
      makeContext(AUTH_UID)
    );
    await expect(
      economic.recordDonation(
        { amount: 5, method: 'plin', idempotencyKey: 'rf-key' },
        makeContext('other-user-rd')
      )
    ).rejects.toThrow(expect.objectContaining({ code: 'already-exists' }));
  });

  test('R10: reject a donation when the per-user rate limit window is exhausted', async () => {
    const uid = 'rl-user-a';
    setUserDoc(uid, { total_donated: 0, walletBalance: 100 });
    const now = Date.now();
    // Pre-cargar 5 ticks dentro de la ventana de 60s (donation_timestamps).
    admin._setDoc(`rate_limits/${uid}`, {
      donation_timestamps: [now, now, now, now, now],
    });
    await expect(
      economic.recordDonation(
        { amount: 5, method: 'wallet', idempotencyKey: 'rl-don-1' },
        makeContext(uid)
      )
    ).rejects.toThrow(expect.objectContaining({ code: 'resource-exhausted' }));
  });

  test('R10: processDonation honors the same per-user donation rate limiter', async () => {
    const uid = 'rl-user-b';
    setUserDoc(uid, { total_donated: 0, walletBalance: 100 });
    const now = Date.now();
    admin._setDoc(`rate_limits/${uid}`, {
      donation_timestamps: [now, now, now, now, now],
    });
    await expect(
      economic.processDonation(
        { amount: 5, method: 'mercadopago', idempotencyKey: 'rl-don-1' },
        makeContext(uid)
      )
    ).rejects.toThrow(expect.objectContaining({ code: 'resource-exhausted' }));
  });

  test('R10: donations still pass when the limit window has not been reached', async () => {
    const uid = 'rl-user-c';
    setUserDoc(uid, { total_donated: 0, walletBalance: 100 });
    const now = Date.now();
    // Un solo tick en la ventana (por debajo del máximo de 5).
    admin._setDoc(`rate_limits/${uid}`, {
      donation_timestamps: [now],
    });
    const result = await economic.recordDonation(
      { amount: 5, method: 'wallet', idempotencyKey: 'rl-don-ok' },
      makeContext(uid)
    );
    expect(result.duplicate).toBe(false);
  });
});

describe('R12: progression rate limits (completeLesson/addXp)', () => {
  test('completeLesson: rejects when the per-user window is exhausted', async () => {
    const uid = 'rl-prog-user-a';
    const now = Date.now();
    setUserDoc(uid, { learning_total_xp: 100, learning_level: 2 });
    admin._setDoc(`rate_limits/${uid}`, {
      complete_lesson_timestamps: Array(60).fill(now),
    });
    await expect(
      economic.completeLesson({ lessonId: 'rl-lesson-1' }, makeContext(uid))
    ).rejects.toThrow(expect.objectContaining({ code: 'resource-exhausted' }));
  });

  test('addXp: rejects when the per-user window is exhausted', async () => {
    const uid = 'rl-prog-user-b';
    const now = Date.now();
    setUserDoc(uid, { learning_total_xp: 0, learning_level: 1 });
    admin._setDoc(`rate_limits/${uid}`, {
      add_xp_timestamps: Array(60).fill(now),
    });
    await expect(
      economic.addXp(
        { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'rl-xp-1' },
        makeContext(uid)
      )
    ).rejects.toThrow(expect.objectContaining({ code: 'resource-exhausted' }));
  });

  test('progression still passes when ticks are below the max', async () => {
    const uid = 'rl-prog-user-c';
    const now = Date.now();
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(uid, {
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    admin._setDoc(`rate_limits/${uid}`, {
      complete_lesson_timestamps: [now],
      add_xp_timestamps: [now],
    });
    const lesson = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext(uid)
    );
    expect(lesson.success).toBe(true);
    expect(lesson.duplicate).toBe(false);
    const xp = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'lesson-1', idempotencyKey: 'rl-xp-ok' },
      makeContext(uid)
    );
    expect(xp.success).toBe(true);
    expect(xp.duplicate).toBe(false);
  });
});

describe('addXp', () => {
  test('adds XP using server-authoritative reason reward', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(15);
    expect(result.level).toBe(1);
    expect(result.leveledUp).toBe(false);
    expect(result.duplicate).toBe(false);
  });

  test('detects level up', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 90, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-level' },
      makeContext()
    );
    expect(result.totalXp).toBe(105);
    expect(result.level).toBe(2);
    expect(result.leveledUp).toBe(true);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.addXp({ reason: 'lesson_reward', idempotencyKey: 'addXp-noauth' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('rejects missing idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0 });
    await expect(
      economic.addXp({ reason: 'lesson_reward' }, makeContext())
    ).rejects.toThrow();
  });

  test('is idempotent for same idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 50, learning_level: 1 });
    await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-dup' },
      makeContext()
    );
    const result = await economic.addXp(
      { reason: 'lesson_reward', lessonId: 'l1', idempotencyKey: 'addXp-dup' },
      makeContext()
    );
    expect(result.duplicate).toBe(true);
    expect(result.totalXp).toBe(65);
  });

  test('uses default reward for unknown reason', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'unknown_reason', idempotencyKey: 'addXp-unk' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(5);
  });

  test('NUEVO-fix: a dot-path reason cannot inject nested fields (field-path injection)', async () => {
    const uid = 'test-inject-reason';
    setUserDoc(uid, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'a.b.c', idempotencyKey: 'addXp-inject-1' },
      makeContext(uid)
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(5);
    const daily = admin._getDoc(
      `daily_xp_sources/${uid}_${new Date().toISOString().split('T')[0]}`
    );
    // El reason se whitelistea a 'unknown' y se escribe como campo plano; un
    // reason con puntos no puede crear campos anidados en daily_xp_sources.
    expect(daily.unknown).toBe(5);
    expect(daily).not.toHaveProperty('a');
  });

  test('NUEVO-fix: awards the real per-achievement XP when achievementId is provided', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      {
        reason: 'achievement',
        achievementId: 'all_stages',
        idempotencyKey: 'addXp-ach-allstages',
      },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(200);
  });

  test('NUEVO-fix: awards mid-tier achievement XP (five_lessons = 25)', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      {
        reason: 'achievement',
        achievementId: 'five_lessons',
        idempotencyKey: 'addXp-ach-five',
      },
      makeContext()
    );
    expect(result.totalXp).toBe(25);
  });

  test('falls back to flat 10 XP for achievement with unknown/invalid achievementId', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      {
        reason: 'achievement',
        achievementId: '../not_valid',
        idempotencyKey: 'addXp-ach-invalid',
      },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(10);
  });

  test('falls back to flat 10 XP for achievement without achievementId', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      { reason: 'achievement', idempotencyKey: 'addXp-ach-empty' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.totalXp).toBe(10);
  });

  test('NUEVO-fix: pays achievement XP only once (claim-once doc)', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const first = await economic.addXp(
      {
        reason: 'achievement',
        achievementId: 'streak_7',
        idempotencyKey: 'addXp-ach-claim1',
      },
      makeContext()
    );
    expect(first.success).toBe(true);
    expect(first.totalXp).toBe(50);
    const claim = admin._getDoc(`users/${AUTH_UID}/achievements/streak_7`);
    expect(claim.xpClaimed).toBe(true);

    // Segunda reclamación, idempotencyKey DISTINTA (ofertón/timer del cliente):
    // no debe otorgar XP extra. Shape igual al duplicate (no-op en el cliente).
    const second = await economic.addXp(
      {
        reason: 'achievement',
        achievementId: 'streak_7',
        idempotencyKey: 'addXp-ach-claim2',
      },
      makeContext()
    );
    expect(second.success).toBe(true);
    expect(second.alreadyClaimed).toBe(true);
    expect(second.totalXp).toBe(50);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.learning_total_xp).toBe(50);
  });

  test('NUEVO-fix: keeps the achievement claim open when the daily cap cuts the XP', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    // Cap diario casi agotado: solo quedan 50 de 500 para un logro de 200 XP.
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${isoDay(0)}`, { total: 450 });
    const first = await economic.addXp(
      { reason: 'achievement', achievementId: 'all_stages', idempotencyKey: 'addXp-ach-partial-1' },
      makeContext()
    );
    expect(first.totalXp).toBe(50);
    // Sellar con pago parcial convertiría la pérdida en permanente: reclamación
    // abierta (sin doc de claim o sin la marca xpClaimed).
    const claimPartial = admin._getDoc(`users/${AUTH_UID}/achievements/all_stages`) || {};
    expect(claimPartial).not.toHaveProperty('xpClaimed');

    // Mismo día, cap agotado: el saldo restante no se puede reclamar hoy.
    await expect(
      economic.addXp(
        { reason: 'achievement', achievementId: 'all_stages', idempotencyKey: 'addXp-ach-partial-2' },
        makeContext()
      )
    ).rejects.toThrow(expect.objectContaining({ code: 'resource-exhausted' }));

    // "Día siguiente": presupuesto fresco -> se paga el logro COMPLETO y se sella.
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${isoDay(0)}`, { total: 0 });
    const second = await economic.addXp(
      { reason: 'achievement', achievementId: 'all_stages', idempotencyKey: 'addXp-ach-partial-3' },
      makeContext()
    );
    expect(second.totalXp).toBe(250); // 50 (parcial) + 200 (completo)
    const claimFinal = admin._getDoc(`users/${AUTH_UID}/achievements/all_stages`);
    expect(claimFinal.xpClaimed).toBe(true);
  });

  test('NUEVO-fix: rejects a forged mislabeled achievementId (no claim doc)', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    const result = await economic.addXp(
      {
        reason: 'achievement',
        achievementId: 'injected-0', // no está en ACHIEVEMENT_REWARDS
        idempotencyKey: 'addXp-ach-forged',
      },
      makeContext()
    );
    expect(result.totalXp).toBe(10); // flat fallback, no acredita el real
    expect(
      admin._getDoc(`users/${AUTH_UID}/achievements/injected-0`)
    ).toBeNull();
  });

  test('throws resource-exhausted when daily XP cap reached', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 490, learning_level: 1 });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today}`, { total: 500 });
    await expect(
      economic.addXp({ reason: 'lesson_reward', idempotencyKey: 'addXp-cap' }, makeContext())
    ).rejects.toThrow(/Limite diario/);
  });

  test('rejects non-existent user', async () => {
    await expect(
      economic.addXp({ reason: 'lesson_reward', idempotencyKey: 'addXp-nouser' }, makeContext('ghost'))
    ).rejects.toThrow();
  });
});

describe('incrementStreak', () => {
  test('increments streak for consecutive day', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      currentStreak: 5,
      longestStreak: 10,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.success).toBe(true);
    expect(result.currentStreak).toBe(6);
    expect(result.alreadyCheckedIn).toBe(false);
  });

  test('returns alreadyCheckedIn if same day', async () => {
    const now = new Date();
    setUserDoc(AUTH_UID, {
      currentStreak: 5,
      longestStreak: 10,
      streak_last_activity: { toDate: () => now },
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.alreadyCheckedIn).toBe(true);
    expect(result.currentStreak).toBe(5);
  });

  test('NUEVO-fix H1: sync mode (checkIn:false) never advances the streak', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      currentStreak: 5,
      longestStreak: 10,
      streak_last_activity: { toDate: () => yesterday },
    });
    const result = await economic.incrementStreak(
      { checkIn: false },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.synced).toBe(true);
    expect(result.currentStreak).toBe(5);
    expect(result.longestStreak).toBe(10);
    expect(result.alreadyCheckedIn).toBe(false);
    expect(admin._getDoc(`users/${AUTH_UID}`).currentStreak).toBe(5);
  });

  test('NUEVO-fix H1: sync mode never burns a shield nor breaks a gapped streak', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 2,
    });
    const result = await economic.incrementStreak(
      { checkIn: false },
      makeContext()
    );
    expect(result.currentStreak).toBe(10);
    expect(result.freezeConsumed).toBeUndefined();
    expect(result.streakBroken).toBeUndefined();
    expect(result.shieldsRemaining).toBe(2);
    const doc = admin._getDoc(`users/${AUTH_UID}`);
    expect(doc.currentStreak).toBe(10);
    expect(doc.streak_shields).toBe(2);
  });

  test('resets streak if gap > 1 day', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.currentStreak).toBe(1);
    expect(result.streakBroken).toBe(true);
    expect(result.previousStreak).toBe(10);
  });

  describe('NUEVO-fix: streak backfill de días offline', () => {
    test('recupera 1 día offline probado por el cliente (no colapsa a 1)', async () => {
      setUserDoc(AUTH_UID, {
        currentStreak: 5,
        longestStreak: 10,
        streak_last_activity: lastActivityAt(-2),
      });
      const result = await economic.incrementStreak(
        { activityDay: isoDay(-1), activityStreak: 6 },
        makeContext()
      );
      // server(5) + 1 día offline + check-in de hoy = 7.
      expect(result.currentStreak).toBe(7);
      expect(result.backfilledDays).toBe(1);
      expect(result.alreadyCheckedIn).toBe(false);
      expect(admin._getDoc(`users/${AUTH_UID}`).currentStreak).toBe(7);
    });

    test('recupera hasta 3 días offline consecutivos', async () => {
      setUserDoc(AUTH_UID, {
        currentStreak: 5,
        longestStreak: 10,
        streak_last_activity: lastActivityAt(-4),
      });
      const result = await economic.incrementStreak(
        { activityDay: isoDay(-1), activityStreak: 8 },
        makeContext()
      );
      expect(result.currentStreak).toBe(9);
      expect(result.backfilledDays).toBe(3);
      expect(result.streakBroken).toBeUndefined();
    });

    test('rechaza una racha inflada (ecuación de continuidad rota) y rompe', async () => {
      setUserDoc(AUTH_UID, {
        currentStreak: 5,
        longestStreak: 10,
        streak_last_activity: lastActivityAt(-2),
      });
      const result = await economic.incrementStreak(
        { activityDay: isoDay(-1), activityStreak: 99 },
        makeContext()
      );
      expect(result.streakBroken).toBe(true);
      expect(result.currentStreak).toBe(1);
    });

    test('rechaza un activityDay futuro (reloj adelantado)', async () => {
      setUserDoc(AUTH_UID, {
        currentStreak: 5,
        longestStreak: 10,
        streak_last_activity: lastActivityAt(-2),
      });
      const result = await economic.incrementStreak(
        { activityDay: isoDay(1), activityStreak: 6 },
        makeContext()
      );
      expect(result.streakBroken).toBe(true);
      expect(result.currentStreak).toBe(1);
    });

    test('rechaza un activityDay anterior al historial del server (regresivo)', async () => {
      setUserDoc(AUTH_UID, {
        currentStreak: 5,
        longestStreak: 10,
        streak_last_activity: lastActivityAt(-2),
      });
      // El día declarado es más viejo que el último conocido: sin backfill.
      const result = await economic.incrementStreak(
        { activityDay: isoDay(-5), activityStreak: 6 },
        makeContext()
      );
      expect(result.streakBroken).toBe(true);
      expect(result.currentStreak).toBe(1);
    });

    test('no backfillea si el día declarado es el mismo del server (días saltados)', async () => {
      setUserDoc(AUTH_UID, {
        currentStreak: 5,
        longestStreak: 10,
        streak_last_activity: lastActivityAt(-2),
      });
      // El cliente no avanzó más allá del último día del server: el gap real
      // (2 días) sigue el flujo freeze/romper, nunca se "repetall".
      const result = await economic.incrementStreak(
        { activityDay: isoDay(-2), activityStreak: 6 },
        makeContext()
      );
      expect(result.currentStreak).toBe(1);
      expect(result.streakBroken).toBe(true);
    });

    test('acepta el baseline local en el primer contacto (usuario fresco)', async () => {
      setUserDoc(AUTH_UID, { currentStreak: 0, longestStreak: 0 });
      const result = await economic.incrementStreak(
        { activityDay: isoDay(0), activityStreak: 0 },
        makeContext()
      );
      expect(result.currentStreak).toBe(1);
      expect(result.backfilledDays).toBe(0);
      expect(result.streakBroken).toBeUndefined();
    });

    test('compatibilidad: clientes viejos sin activityDay mantienen el comportamiento', async () => {
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
      setUserDoc(AUTH_UID, {
        currentStreak: 10,
        longestStreak: 15,
        streak_last_activity: { toDate: () => threeDaysAgo },
      });
      const result = await economic.incrementStreak({}, makeContext());
      expect(result.currentStreak).toBe(1);
      expect(result.streakBroken).toBe(true);
    });
  });

  test('keeps streak alive and debits a shield when freeze is honored', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 2,
    });
    const result = await economic.incrementStreak(
      { freezeUsed: true },
      makeContext()
    );
    expect(result.currentStreak).toBe(11);
    expect(result.freezeConsumed).toBe(true);
    expect(result.streakBroken).toBeUndefined();
    expect(result.shieldsRemaining).toBe(1);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(1);
  });

  test('honors shop streak shields when streak_shields is zero', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 0,
      shop_streak_shields: 1,
    });
    const result = await economic.incrementStreak(
      { freezeUsed: true },
      makeContext()
    );
    expect(result.freezeConsumed).toBe(true);
    expect(result.shieldsRemaining).toBe(0);
    expect(admin._getDoc(`users/${AUTH_UID}`).shop_streak_shields).toBe(0);
  });

  test('denies freeze and breaks streak when no shields owned', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    const result = await economic.incrementStreak(
      { freezeUsed: true },
      makeContext()
    );
    expect(result.currentStreak).toBe(1);
    expect(result.streakBroken).toBe(true);
    expect(result.freezeDenied).toBe(true);
    expect(result.previousStreak).toBe(10);
  });

  test('starts streak at 1 if no previous activity', async () => {
    setUserDoc(AUTH_UID, {
      currentStreak: 0,
      longestStreak: 0,
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.currentStreak).toBe(1);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.incrementStreak({}, NO_AUTH)
    ).rejects.toThrow();
  });

  test('NUEVO-fix: honors the freeze from server shields even without the client freezeUsed flag', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 1,
    });
    // El servidor decide por los escudos que posee, no por el flag del cliente.
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.currentStreak).toBe(11);
    expect(result.freezeConsumed).toBe(true);
    expect(result.streakBroken).toBeUndefined();
    expect(result.shieldsRemaining).toBe(0);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(0);
  });

  test('returns authoritative shieldsRemaining on a normal consecutive check-in', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      currentStreak: 4,
      longestStreak: 10,
      streak_last_activity: { toDate: () => yesterday },
      streak_shields: 2,
    });
    const result = await economic.incrementStreak({}, makeContext());
    expect(result.currentStreak).toBe(5);
    expect(result.alreadyCheckedIn).toBe(false);
    expect(result.shieldsRemaining).toBe(2);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(2);
  });

  test('NUEVO-fix H5: titanium shield keeps the streak alive and is consumed server-side', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: { titaniumShield: 1 },
      cosmetics: [],
    });
    const result = await economic.incrementStreak(
      { itemUsed: 'titaniumShield' },
      makeContext()
    );
    expect(result.currentStreak).toBe(11);
    expect(result.itemConsumed).toBe(true);
    expect(result.itemUsed).toBe('titaniumShield');
    expect(result.streakBroken).toBeUndefined();
    expect(result.freezeConsumed).toBeUndefined();
    expect(
      admin._getDoc(`users/${AUTH_UID}/inventory/state`).specialItems.titaniumShield
    ).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.currentStreak).toBe(11);
    expect(user.streak_shields || 0).toBe(0);
  });

  test('NUEVO-fix H5: phoenix feather revives the streak (keeps previous value)', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: { phoenixFeather: 1 },
      cosmetics: [],
    });
    const result = await economic.incrementStreak(
      { itemUsed: 'phoenixFeather' },
      makeContext()
    );
    expect(result.currentStreak).toBe(10);
    expect(result.revived).toBe(true);
    expect(result.itemConsumed).toBe(true);
    expect(
      admin._getDoc(`users/${AUTH_UID}/inventory/state`).specialItems.phoenixFeather
    ).toBe(0);
  });

  test('NUEVO-fix H5: denies the item and breaks when inventory is empty', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
    });
    const result = await economic.incrementStreak(
      { itemUsed: 'titaniumShield' },
      makeContext()
    );
    expect(result.currentStreak).toBe(1);
    expect(result.streakBroken).toBe(true);
    expect(result.itemDenied).toBe(true);
    expect(result.itemConsumed).toBeUndefined();
  });

  test('NUEVO-fix H5: real shields protect first and the item is NOT consumed', async () => {
    const threeDaysAgo = new Date();
    threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);
    setUserDoc(AUTH_UID, {
      currentStreak: 10,
      longestStreak: 15,
      streak_last_activity: { toDate: () => threeDaysAgo },
      streak_shields: 1,
    });
    admin._setDoc(`users/${AUTH_UID}/inventory/state`, {
      specialItems: { titaniumShield: 1 },
      cosmetics: [],
    });
    const result = await economic.incrementStreak(
      { itemUsed: 'titaniumShield' },
      makeContext()
    );
    expect(result.currentStreak).toBe(11);
    expect(result.freezeConsumed).toBe(true);
    expect(result.itemConsumed).toBeUndefined();
    expect(
      admin._getDoc(`users/${AUTH_UID}/inventory/state`).specialItems.titaniumShield
    ).toBe(1);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(0);
  });
});

describe('claimFreeStreakShield', () => {
  const today = () => new Date().toISOString().split('T')[0];

  test('claims a free streak shield server-side', async () => {
    setUserDoc(AUTH_UID, { streak_shields: 0 });
    const result = await economic.claimFreeStreakShield({}, makeContext());
    expect(result.claimed).toBe(true);
    expect(result.shields).toBe(1);
    const doc = admin._getDoc(`users/${AUTH_UID}`);
    expect(doc.streak_shields).toBe(1);
    expect(doc.last_free_shield_claim).toBe(today());
  });

  test('increments shields from an existing balance', async () => {
    setUserDoc(AUTH_UID, { streak_shields: 1 });
    const result = await economic.claimFreeStreakShield({}, makeContext());
    expect(result.claimed).toBe(true);
    expect(result.shields).toBe(2);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(2);
  });

  test('rejects a second claim on the same day (anti-farm)', async () => {
    setUserDoc(AUTH_UID, { streak_shields: 1, last_free_shield_claim: today() });
    const result = await economic.claimFreeStreakShield({}, makeContext());
    expect(result.claimed).toBe(false);
    expect(result.alreadyClaimedToday).toBe(true);
    expect(result.shields).toBe(1);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(1);
  });

  test('rejects when the shield cap is reached', async () => {
    setUserDoc(AUTH_UID, { streak_shields: 3 });
    const result = await economic.claimFreeStreakShield({}, makeContext());
    expect(result.claimed).toBe(false);
    expect(result.atCap).toBe(true);
    expect(result.shields).toBe(3);
    expect(admin._getDoc(`users/${AUTH_UID}`).streak_shields).toBe(3);
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.claimFreeStreakShield({}, NO_AUTH)
    ).rejects.toThrow();
  });

  test('rejects missing user document', async () => {
    await expect(
      economic.claimFreeStreakShield({}, makeContext())
    ).rejects.toThrow();
  });
});

describe('completeLesson', () => {
  test('completes lesson with server-authoritative rewards', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.success).toBe(true);
    expect(result.duplicate).toBe(false);
    expect(result.xp.added).toBe(15);
    expect(result.xp.totalXp).toBe(115);
    expect(result.streak.current).toBe(4);
    expect(result.lessonsCompleted).toBe(6);
  });

  test('ignores client-specified rewards, uses server rewards', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', gemsEarned: 9999, xpEarned: 9999 },
      makeContext()
    );
    expect(result.xp.added).toBe(15);
    expect(result.xp.totalXp).toBe(15);
  });

  test('applies bonus XP for _l6 lessons', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'ac_s1_ses1_l6' },
      makeContext()
    );
    expect(result.xp.added).toBe(20);
  });

  test('applies the streak multiplier to lesson XP (streak 10 = 1.1x)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 10,
      longestStreak: 10,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    // 15 * 1.1 = 16.5 -> round 17
    expect(result.xp.added).toBe(17);
    expect(result.xp.totalXp).toBe(17);
  });

  test('honors a purchased XP boost: 2x XP and consumes one (NUEVO-boost)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      shop_purchased_xp_boosts: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.xp.added).toBe(30);
    expect(result.xp.totalXp).toBe(30);
    expect(result.xpBoost.applied).toBe(true);
    expect(result.xpBoost.consumed).toBe(true);
    expect(result.xpBoost.remaining).toBe(0);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.shop_purchased_xp_boosts).toBe(0);
  });

  test('does not consume the boost when no boost is available', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      shop_purchased_xp_boosts: 0,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.xp.added).toBe(15);
    expect(result.xpBoost.applied).toBe(false);
    expect(result.xpBoost.consumed).toBe(false);
    expect(result.xpBoost.remaining).toBe(0);
  });

  test('does not consume a boost when the daily cap truncates XP', async () => {
    // Pre-cargar el cap diario de XP a tope: el XP de la lección se recorta a 0
    // y el boost NO debe gastarse (full-payment pattern).
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      shop_purchased_xp_boosts: 2,
      lessonsCompleted: 0,
    });
    // Cap diario agotado (500). Sembramos el doc diario con el total al tope.
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today}`, { total: 500 });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.xp.added).toBeLessThanOrEqual(0);
    expect(result.xpBoost.applied).toBe(true);
    expect(result.xpBoost.consumed).toBe(false);
    expect(result.xpBoost.remaining).toBe(2);
    const user = admin._getDoc(`users/${AUTH_UID}`);
    expect(user.shop_purchased_xp_boosts).toBe(2);
  });

  test('consumes exactly one boost and keeps the rest for the next lesson', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      shop_purchased_xp_boosts: 3,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.xp.added).toBe(30);
    expect(result.xpBoost.consumed).toBe(true);
    expect(result.xpBoost.remaining).toBe(2);
    // Una segunda lección (distinta) consume el siguiente boost.
    const second = await economic.completeLesson(
      { lessonId: 'lesson-2' },
      makeContext()
    );
    expect(second.xp.added).toBe(30);
    expect(second.xpBoost.remaining).toBe(1);
  });

  test('caps the streak multiplier at 2.0', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 100,
      longestStreak: 100,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    // 15 * 2.0 = 30
    expect(result.xp.added).toBe(30);
  });

  test('streak multiplier is not applied below streak 10', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 9,
      longestStreak: 9,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1' },
      makeContext()
    );
    expect(result.xp.added).toBe(15);
  });

  test('rejects missing lessonId', async () => {
    setUserDoc(AUTH_UID, { learning_gems: 0 });
    await expect(
      economic.completeLesson({}, makeContext())
    ).rejects.toThrow();
  });

  test('rejects unauthenticated user', async () => {
    await expect(
      economic.completeLesson({ lessonId: 'l1' }, NO_AUTH)
    ).rejects.toThrow();
  });

  test('is idempotent for same lessonId', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 100,
      learning_level: 2,
      currentStreak: 3,
      longestStreak: 7,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 5,
    });
    await economic.completeLesson({ lessonId: 'lesson-dup' }, makeContext());
    const result = await economic.completeLesson({ lessonId: 'lesson-dup' }, makeContext());
    expect(result.duplicate).toBe(true);
    expect(result.xp.added).toBe(0);
  });

  test('caps daily XP at 500', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today}`, { total: 495 });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.xp.added).toBe(5);
    expect(result.xp.totalXp).toBe(5);
  });

  test('awards Sagen Pass SP from a server-verified lesson', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.sagenPass).toBeTruthy();
    expect(result.sagenPass.spAdded).toBe(10);
    expect(result.sagenPass.sp).toBe(10);
    expect(result.sagenPass.level).toBe(1);
  });

  test('awards perfect_lesson SP bonus when the lesson is perfect', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: 15, totalQuestions: 15 },
      makeContext()
    );
    // 10 (lesson) + 15 (perfect_lesson)
    expect(result.sagenPass.spAdded).toBe(25);
    expect(result.sagenPass.sp).toBe(25);
  });

  test('ignores perfect claim without a consistent answer set (anti-farm)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      learning_gems: 0,
      sagen_pass_level: 1,
    });
    // perfect=true but totalQuestions missing / inconsistent: bonus must NOT apply
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: 15, totalQuestions: 10 },
      makeContext()
    );
    expect(result.gems.perfect).toBe(false);
    expect(result.sagenPass.spAdded).toBe(10); // lesson SP only
    expect(result.sagenPass.sp).toBe(10);
  });

  test('NUEVO-fix ronda 7: perfect 30/30 awards perfect bonus + SP (clamp no rompe el perfect)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    // Legítima: 30/30 (el clamp a 20 afecta SOLO las gemas, no el veredicto).
    // <30/30 sigue siendo anti-farm aunque el total supere 20.
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: 30, totalQuestions: 30 },
      makeContext()
    );
    expect(result.gems.perfect).toBe(true);
    expect(result.sagenPass.spAdded).toBe(25); // 10 lesson + 15 perfect_lesson
  });

  test('NUEVO-fix ronda 7: lesson with XP clipped by the daily cap is NOT sealed (recoverable)', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_xp_sources/${AUTH_UID}_${today}`, { total: 495 });
    const result = await economic.completeLesson({ lessonId: 'lesson-recover' }, makeContext());
    expect(result.xp.added).toBe(5); // 15 clipping a 5
    expect(result.duplicate).toBe(false);
    // NO se selló: el replay no es duplicate y la lección queda abierta para
    // cobrar el XP restante otro día.
    expect(admin._getDoc(`transaction_logs/${AUTH_UID}_lesson-recover`)).toBeNull();
    const r2 = await economic.completeLesson({ lessonId: 'lesson-recover' }, makeContext());
    expect(r2.duplicate).toBe(false);
    expect(r2.xp.added).toBe(0); // cap ya agotado hoy
  });

  test('NUEVO-fix ronda 7: seals the lesson only when XP is paid in full', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
    });
    const result = await economic.completeLesson({ lessonId: 'lesson-seal' }, makeContext());
    expect(result.xp.added).toBe(15); // pago completo
    const log = admin._getDoc(`transaction_logs/${AUTH_UID}_lesson-seal`);
    expect(log).toBeTruthy();
    expect(log.xpAdded).toBe(15);
    const r2 = await economic.completeLesson({ lessonId: 'lesson-seal' }, makeContext());
    expect(r2.duplicate).toBe(true);
  });

  test('NUEVO-fix ronda 7: first_lesson_of_day bonus seal respects the daily gem cap', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      learning_gems: 0,
    });
    const today = new Date().toISOString().split('T')[0];
    // Cap de gems 'lesson' = 50 diario. 48 ya gastados hoy -> solo 2 disponibles.
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today}`, { total: 48 });
    const result = await economic.completeLesson({ lessonId: 'lesson-gcap' }, makeContext());
    expect(result.gems.dailyCapped).toBe(true);
    // El bonus NO quedó sellado: sin sellar, recuperable mañana con cap nuevo.
    expect(admin._getDoc(`daily_gem_sources/${AUTH_UID}_${today}`).first_lesson_of_day).toBeUndefined();

    // Sin cap (día nuevo, total 0) el bonus se paga completo y se sella.
    admin._setDoc(`daily_gem_sources/${AUTH_UID}_${today}`, { total: 0 });
    const r2 = await economic.completeLesson({ lessonId: 'lesson-gcap-2' }, makeContext());
    expect(r2.gems.dailyCapped).toBe(false);
    expect(admin._getDoc(`daily_gem_sources/${AUTH_UID}_${today}`).first_lesson_of_day).toBe(true);
  });

  test('completeLesson SP respects the daily cap', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today}`, { total: 95 });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.sagenPass.spAdded).toBe(5);
    expect(result.sagenPass.dailyCapped).toBe(true);
  });

  test('completeLesson does not award SP on duplicates', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
    });
    await economic.completeLesson({ lessonId: 'lesson-sp-dup' }, makeContext());
    const result = await economic.completeLesson({ lessonId: 'lesson-sp-dup' }, makeContext());
    expect(result.duplicate).toBe(true);
    expect(result.sagenPass).toBeNull();
  });

  test('completeLesson pass holders earn unlimited SP', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 1,
      longestStreak: 1,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      sagen_pass_sp: 0,
      sagen_pass_level: 1,
      sagen_pass_active: true,
    });
    const today = new Date().toISOString().split('T')[0];
    admin._setDoc(`daily_sp_sources/${AUTH_UID}_${today}`, { total: 100 });
    const result = await economic.completeLesson({ lessonId: 'lesson-1' }, makeContext());
    expect(result.sagenPass.spAdded).toBe(10);
    expect(result.sagenPass.dailyCapped).toBe(false);
    expect(result.sagenPass.premium).toBe(true);
  });

  test('addXp rejects path-injecting idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    await expect(
      economic.addXp(
        { reason: 'lesson_reward', idempotencyKey: 'a/b/c' },
        makeContext()
      )
    ).rejects.toThrow();
  });

  test('completeLesson rejects malicious lessonId with path chars', async () => {
    setUserDoc(AUTH_UID, { learning_total_xp: 0, learning_level: 1 });
    await expect(
      economic.completeLesson({ lessonId: 'lesson/../admin' }, makeContext())
    ).rejects.toThrow();
  });

  test('completeLesson treats non-integer correctCount as non-perfect', async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    setUserDoc(AUTH_UID, {
      learning_total_xp: 0,
      learning_level: 1,
      currentStreak: 0,
      longestStreak: 0,
      streak_last_activity: { toDate: () => yesterday },
      lessonsCompleted: 0,
      learning_gems: 0,
    });
    const result = await economic.completeLesson(
      { lessonId: 'lesson-1', perfect: true, correctCount: '15x', totalQuestions: '15y' },
      makeContext()
    );
    expect(result.gems.perfect).toBe(false);
    // Only the first-lesson-of-day bonus applies — string answers earn nothing.
    expect(result.gems.added).toBe(10);
  });

  test('processDonation rejects path-injecting idempotencyKey', async () => {
    setUserDoc(AUTH_UID, { total_donated: 0 });
    await expect(
      economic.processDonation(
        { amount: 25, method: 'mercadopago', idempotencyKey: 'donation/../x' },
        makeContext()
      )
    ).rejects.toThrow();
  });
});
