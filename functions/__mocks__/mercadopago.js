/**
 * MercadoPago mock for Cloud Functions tests.
 */

const preferenceCreate = jest.fn().mockResolvedValue({
  id: 'mock_preference_id_123',
  init_point: 'https://mock.mercadopago.com/checkout',
  sandbox_init_point: 'https://sandbox.mock.mercadopago.com/checkout',
});

class Preference {
  constructor() {}
  create(data) {
    return preferenceCreate(data);
  }
}

class MercadoPagoConfig {
  constructor(config) {
    this.config = config;
  }
}

module.exports = {
  MercadoPagoConfig,
  Preference,
  _mockPreferenceCreate: preferenceCreate,
  _resetMocks: () => preferenceCreate.mockClear(),
};
