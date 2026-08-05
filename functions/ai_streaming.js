const functions = require('firebase-functions');
const admin = require('firebase-admin');

const GEMINI_API_KEY = functions.config().gemini?.api_key;
const GEMINI_MODEL = 'gemini-2.5-flash';
const GEMINI_MAX_OUTPUT_TOKENS = 8192;
const GEMINI_TEMPERATURE = 0.85;
const GEMINI_TOP_K = 40;
const GEMINI_TOP_P = 0.95;

const ALLOWED_ORIGINS = [
  'https://sagen-bdd3f.web.app',
  'https://sagen-bdd3f.firebaseapp.com',
];

const RATE_LIMIT_WINDOW = 60 * 1000;
const RATE_LIMIT_MAX = 15;

async function checkStreamRateLimit(uid) {
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW;
  const bucketRef = admin.firestore().doc(`rate_limits/${uid}`);

  try {
    await admin.firestore().runTransaction(async (transaction) => {
      const doc = await transaction.get(bucketRef);
      const data = doc.data() || {};
      const timestamps = (data.stream_timestamps || []).filter(t => t > windowStart);
      if (timestamps.length >= RATE_LIMIT_MAX) {
        throw new Error('Límite de solicitudes excedido');
      }
      timestamps.push(now);
      transaction.set(bucketRef, { stream_timestamps: timestamps }, { merge: true });
    });
  } catch (e) {
    if (e.message === 'Límite de solicitudes excedido') {
      throw new functions.https.HttpsError('resource-exhausted', 'Demasiadas solicitudes. Intenta de nuevo.');
    }
    functions.logger.error('Stream rate limit check failed, rejecting', { uid, error: e.message });
    throw new functions.https.HttpsError('resource-exhausted', 'Servicio temporalmente no disponible. Intenta de nuevo.');
  }
}

/**
 * HTTPS Streaming: Generate AI response via Gemini with real token streaming.
 * Uses HTTP function with chunked response for true streaming.
 * The API key stays server-side only.
 */
exports.generateContentStream = functions.runWith({ maxInstances: 3 }).https.onRequest(async (req, res) => {
  const origin = req.headers.origin || '';
  const allowed = ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0];

  res.set('Access-Control-Allow-Origin', allowed);
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    return res.status(204).send('');
  }

  if (!ALLOWED_ORIGINS.includes(origin)) {
    return res.status(403).json({ error: 'Origen no permitido' });
  }

  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Método no permitido' });
  }

  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  let uid;
  try {
    const token = authHeader.split('Bearer ')[1];
    const decoded = await admin.auth().verifyIdToken(token);
    uid = decoded.uid;
  } catch (e) {
    return res.status(401).json({ error: 'Token inválido' });
  }

  try {
    await checkStreamRateLimit(uid);
  } catch (e) {
    if (e instanceof functions.https.HttpsError) {
      return res.status(429).json({ error: e.message });
    }
  }

  if (!GEMINI_API_KEY) {
    return res.status(500).json({ error: 'Clave API de Gemini no configurada' });
  }

  const { contents, systemInstruction } = req.body;
  if (!contents || !Array.isArray(contents) || contents.length === 0) {
    return res.status(400).json({ error: 'Se requiere un arreglo contents' });
  }
  if (contents.length > 20) {
    return res.status(400).json({ error: 'Máximo 20 partes de contents permitidas' });
  }

  try {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:streamGenerateContent?alt=sse`;

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

    if (systemInstruction && typeof systemInstruction === 'string') {
      const sanitizedInstruction = systemInstruction.slice(0, 5000);
      body.systemInstruction = { parts: [{ text: sanitizedInstruction }] };
    }

    res.set({
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no',
    });

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
      functions.logger.error('Gemini streaming error', { status: response.status, body: errText });
      res.write(`data: ${JSON.stringify({ error: 'Error de la API de Gemini' })}\n\n`);
      res.write('data: [DONE]\n\n');
      return res.end();
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let buffer = '';

    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      buffer += decoder.decode(value, { stream: true });
      const lines = buffer.split('\n');
      buffer = lines.pop() || '';

      for (const line of lines) {
        if (line.startsWith('data: ')) {
          const data = line.slice(6).trim();
          if (data === '[DONE]') {
            res.write('data: [DONE]\n\n');
            continue;
          }
          try {
            const parsed = JSON.parse(data);
            const text = parsed.candidates?.[0]?.content?.parts?.[0]?.text || '';
            if (text) {
              res.write(`data: ${JSON.stringify({ text })}\n\n`);
            }
          } catch (e) {
            // Skip malformed JSON chunks
          }
        }
      }
    }

    if (buffer.trim()) {
      if (buffer.startsWith('data: ')) {
        const data = buffer.slice(6).trim();
        if (data && data !== '[DONE]') {
          try {
            const parsed = JSON.parse(data);
            const text = parsed.candidates?.[0]?.content?.parts?.[0]?.text || '';
            if (text) {
              res.write(`data: ${JSON.stringify({ text })}\n\n`);
            }
          } catch (e) {}
        }
      }
    }

    res.write('data: [DONE]\n\n');
    res.end();
  } catch (e) {
    functions.logger.error('generateContentStream error', e);
    if (!res.headersSent) {
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.write(`data: ${JSON.stringify({ error: 'Error de conexión' })}\n\n`);
      res.write('data: [DONE]\n\n');
      res.end();
    }
  }
});
