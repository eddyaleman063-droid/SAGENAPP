/**
 * Firebase Functions mock for Cloud Functions tests.
 */

class HttpsError extends Error {
  constructor(code, message, details) {
    super(message);
    this.code = code;
    this.details = details;
    this.HttpsError = true;
  }
}

const https = {
  onCall: (fn) => fn,
  onRequest: (fn) => fn,
  HttpsError,
};

const logger = {
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
  log: jest.fn(),
};

const config = jest.fn(() => ({}));

const pubsub = {
  schedule: (cron) => ({
    onRun: (fn) => fn,
  }),
};

module.exports = {
  https,
  logger,
  config,
  HttpsError,
  pubsub,
};
