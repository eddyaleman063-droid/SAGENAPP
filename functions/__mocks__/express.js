/**
 * Express stub for contract tests that load the Vercel API (api/index.js).
 * Only route registration is needed at require time.
 */

const noop = () => {};

const app = {
  use: noop,
  post: noop,
  get: noop,
  all: noop,
  loadCatalog: null,
  getProductDetails: null,
};

module.exports = () => app;
module.exports.json = () => noop;
