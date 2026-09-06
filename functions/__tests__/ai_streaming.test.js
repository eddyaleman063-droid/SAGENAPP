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
  on() { return this; },
  once() { return this; },
  removeListener() { return this; },
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

const okResponse = (chunks = []) => ({
  ok: true,
  status: 200,
  body: {
    getReader: () => ({
      read: async () => {
        if (chunks.length === 0) return { done: true };
        return { done: false, value: new TextEncoder().encode(chunks.shift()) };
      },
    }),
  },
});

const aChunk = (text) => `data: ${JSON.stringify({ candidates: [{ content: { parts: [{ text }] } }] })}\n\n`;

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

  test('lets a 49/50 user through pre-check and consumes quota on first real token', async () => {
    admin._setDoc(usageKey(), { count: 49 });
    global.fetch.mockResolvedValue(okResponse([aChunk('hola'), '\n']));
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.status).toBeNull();
    expect(res.calls.writes.join('')).toContain('"text":"hola"');
    expect(res.calls.writes.join('')).toContain('data: [DONE]');
    // Primer token real entregado → contador 49 → 50.
    expect(admin._getDoc(usageKey()).count).toBe(50);
  });

  test('does NOT consume quota when stream ends before any real token (disconnect before first chunk)', async () => {
    admin._setDoc(usageKey(), { count: 49 });
    // Gemini acepta el request pero el stream termina sin un solo token
    // (el cliente se desconectó / upstream devolvió vacío). No se quema cuota.
    global.fetch.mockResolvedValue(okResponse([]));
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.writes.join('')).toContain('data: [DONE]');
    expect(admin._getDoc(usageKey()).count).toBe(49);
  });

  test('forwards streamed text and skips malformed lines', async () => {
    global.fetch.mockResolvedValue(
      okResponse(['data: {not-json}\n\n', aChunk('primero'), aChunk(' segundo'), '\n'])
    );
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    const stream = res.calls.writes.join('');
    expect(stream).toContain('"text":"primero"');
    expect(stream).toContain('"text":" segundo"');
    expect(stream).toContain('data: [DONE]');
    expect(admin._getDoc(usageKey()).count).toBe(1);
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

    // Fallo upstream: se cierra la conexión sin tocar el flujo de chunks.
    expect(res.calls.ended).toBe(true);
    expect(res.calls.writes).toEqual([]);
    // Entrega no real → sin consumo de la cuota del día.
    expect(admin._getDoc(usageKey())).toBeNull();
  });

  test('still rejects with 429 even when a previous day was used', async () => {
    admin._setDoc(`sage_usage/${UID}_1999-01-01`, { count: 50 });
    global.fetch.mockResolvedValue(okResponse([aChunk('hola')]));
    const req = makeReq();
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.status).toBeNull();
    expect(admin._getDoc(usageKey()).count).toBe(1);
  });

  test('aborts upstream and ends when the client disconnects mid-stream', async () => {
    const abortSpy = jest.fn();
    global.fetch.mockResolvedValue({
      ok: true,
      status: 200,
      body: {
        getReader: () => ({
          read: async () => {
            // Simula el corte del cliente: se dispara req.close → controller.abort().
            await new Promise((resolve) => setTimeout(resolve, 5));
            req.emit('close');
            return Promise.reject(new Error('aborted'));
          },
        }),
      },
    });
    const req = makeReq();
    req.on = req.once = (event, cb) => {
      if (event === 'close') req._onClose = cb;
      return req;
    };
    req.emit = (event) => {
      if (event === 'close' && req._onClose) return req._onClose();
    };
    const res = makeRes();

    await generateContentStream(req, res);

    expect(res.calls.ended).toBe(true);
  });
});