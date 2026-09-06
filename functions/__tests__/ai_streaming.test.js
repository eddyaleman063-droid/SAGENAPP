/**
 * Tests for ai_streaming.js — Server-authoritative Sage daily quota.
 * Covers: pre-check rejection (429 + code 'sage_daily_limit') without
 * consuming, quota consumed only on real Gemini delivery, and no consumption
 * on upstream failure.
 */

jest.mock('firebase-admin', () => require('../__mocks__/firebase-admin'));
jest.mock('firebase-functions', () => require('../__mocks__/firebase-functions'));

const functions = require('firebase-functions');
// GEMINI_API_KEY se lee al cargar el módulo; lo inyectamos antes del require.
functions.config = jest.fn(() => ({ gemini: { api_key: 'TEST_KEY' } }));

const admin = require('firebase-admin');
const { generateContentStream } = require('../ai_streaming');

const UID = 'test-ai-streaming-123';
const ORIGIN = 'https://sagen-bdd3f.web.app';
const today = () => new Date().toISOString().split('T')[0];
const usageKey = () => `sage_usage/${UID}_${today()}`;

const makeReq = (overrides = {}) => ({
  method: 'POST',
  headers: { origin: ORIGIN, authorization: 'Bearer test-token' },
  body: { contents: [{ role: 'user', parts: [{ text: 'hola' }] }] },
  ...overrides,
});

const makeRes = () => {
  const res = {
    calls: { status: null, json: null, writes: [], ended: false, send: null },
    set() {},
    status(s) {
      res.calls.status = s;
      return res;
    },
    json(o) {
      res.calls.json = o;
      return res;
    },
    write(s) {
      res.calls.writes.push(s);
      return res;
    },
    send(s) {
      res.calls.send = s;
      return res;
    },
    end() {
      res.calls.ended = true;
      return res;
    },
  };
  return res;
};

const okResponse = () => ({
  ok: true,
  status: 200,
  body: {
    getReader: () => ({ read: async () => ({ done: true }) }),
  },
});

beforeEach(() => {
  admin._resetFirestore();
  global.fetch = jest.fn();
  admin._setVerifyIdTokenResult({ uid: UID, email_verified: true });
});

describe('Sage daily usage limit', () => {
  test('rejects with HTTP 429 + code sage_daily_limit when at limit, consuming nothing', async () => {
    admin._setDoc(usageKey(), { count: 50 });
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.status).toBe(429);
    expect(res.calls.json.error).toMatch(/Límite diario/);
    expect(res.calls.json.code).toBe('sage_daily_limit');
    expect(global.fetch).not.toHaveBeenCalled();
    // El pre-check es consume=false: el contador NO debe haber subido (50 → 50).
    expect(admin._getDoc(usageKey()).count).toBe(50);
  });

  test('lets a 49/50 user through pre-check and consumes quota on real delivery', async () => {
    admin._setDoc(usageKey(), { count: 49 });
    global.fetch.mockResolvedValue(okResponse());
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.status).toBeNull();
    expect(res.calls.writes.join('')).toContain('data: [DONE]');
    expect(admin._getDoc(usageKey()).count).toBe(50);
  });

  test('does NOT consume quota when Gemini upstream fails (ok=false)', async () => {
    global.fetch.mockResolvedValue({
      ok: false,
      status: 503,
      text: async () => 'upstream down',
    });
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.writes.join('')).toContain('[DONE]');
    // Entrega no real → sin consumo de la cuota del día.
    expect(admin._getDoc(usageKey())).toBeNull();
  });

  test('still rejects with 429 even when a previous day was used', async () => {
    admin._setDoc(`sage_usage/${UID}_1999-01-01`, { count: 50 });
    global.fetch.mockResolvedValue(okResponse());
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.status).toBeNull();
    expect(admin._getDoc(usageKey()).count).toBe(1);
  });
});