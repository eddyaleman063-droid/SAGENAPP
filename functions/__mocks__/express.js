/**
 * Express stub for contract tests that load the Vercel API (api/index.js).
 * Records registered route handlers so tests can invoke them directly.
 */

const noop = () => {};

const handlers = {
  use: [],
  post: {},
  get: {},
  all: {},
};

const app = {
  use: (fn) => { handlers.use.push(fn); },
  post: (path, ...fns) => { handlers.post[path] = fns; },
  get: (path, ...fns) => { handlers.get[path] = fns; },
  all: (path, ...fns) => { handlers.all[path] = fns; },
  _handlers: handlers,
  loadCatalog: null,
  getProductDetails: null,
};

module.exports = () => app;
module.exports.json = () => noop;
