import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/api_client.dart';
import 'package:sagen/services/mercado_pago_service.dart';

class MockApiSender extends Mock implements ApiSender {}

void main() {
  late MockApiSender mockSender;
  late MercadoPagoService service;

  setUp(() {
    mockSender = MockApiSender();
    service = MercadoPagoService(sender: mockSender);
  });

  setUpAll(() {
    registerFallbackValue(ApiRequest(
      method: 'GET',
      uri: Uri.parse('https://fallback.test'),
    ));
  });

  group('MercadoPagoPreference', () {
    test('stores all fields correctly', () {
      const pref = MercadoPagoPreference(
        preferenceId: 'pref_abc',
        initPoint: 'https://mercadopago.com/checkout',
        externalRef: 'ref_123',
      );
      expect(pref.preferenceId, 'pref_abc');
      expect(pref.initPoint, 'https://mercadopago.com/checkout');
      expect(pref.externalRef, 'ref_123');
    });

    test('handles empty strings', () {
      const pref = MercadoPagoPreference(
        preferenceId: '',
        initPoint: '',
        externalRef: '',
      );
      expect(pref.preferenceId, isEmpty);
      expect(pref.initPoint, isEmpty);
      expect(pref.externalRef, isEmpty);
    });
  });

  group('MercadoPagoException', () {
    test('stores message and toString returns it', () {
      const e = MercadoPagoException('Error de pago');
      expect(e.message, 'Error de pago');
      expect(e.toString(), 'Error de pago');
    });

    test('is an Exception', () {
      const e = MercadoPagoException('test');
      expect(e, isA<Exception>());
    });
  });

  group('createPreference', () {
    test('returns preference on success', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: '{"result":{"preferenceId":"pref_1","initPoint":"https://mp.com/checkout","externalRef":"ref_1"}}',
        ),
      );

      final result = await service.createPreference(
        amount: 50,
        productId: 'donation_basic',
        idToken: 'token_abc',
      );

      expect(result.preferenceId, 'pref_1');
      expect(result.initPoint, 'https://mp.com/checkout');
      expect(result.externalRef, 'ref_1');

      final captured = verify(() => mockSender.send(captureAny())).captured;
      final request = captured.last as ApiRequest;
      expect(request.method, 'POST');
      expect(request.headers?['Authorization'], 'Bearer token_abc');
      expect((request.body as Map<String, dynamic>)['amount'], 50);
      expect((request.body as Map<String, dynamic>)['productId'], 'donation_basic');
    });

    test('includes price when provided', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: '{"result":{"preferenceId":"p","initPoint":"i","externalRef":"e"}}',
        ),
      );

      await service.createPreference(
        amount: 100,
        productId: 'donation_standard',
        idToken: 'token',
        price: 29.99,
      );

      final captured = verify(() => mockSender.send(captureAny())).captured;
      final request = captured.last as ApiRequest;
      expect((request.body as Map<String, dynamic>)['price'], 29.99);
    });

    test('throws MercadoPagoException on invalid JSON', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(statusCode: 200, body: 'not json'),
      );

      expect(
        () => service.createPreference(amount: 10, productId: 'p', idToken: 't'),
        throwsA(isA<MercadoPagoException>()),
      );
    });

    test('throws MercadoPagoException when result is missing', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(statusCode: 200, body: '{"other":"data"}'),
      );

      expect(
        () => service.createPreference(amount: 10, productId: 'p', idToken: 't'),
        throwsA(isA<MercadoPagoException>()),
      );
    });

    test('wraps ApiException into MercadoPagoException', () async {
      when(() => mockSender.send(any())).thenThrow(
        const ApiException(ApiErrorType.network, 'Connection refused'),
      );

      expect(
        () => service.createPreference(amount: 10, productId: 'p', idToken: 't'),
        throwsA(isA<MercadoPagoException>().having(
          (e) => e.message,
          'message',
          contains('network'),
        )),
      );
    });

    test('wraps generic exceptions into MercadoPagoException', () async {
      when(() => mockSender.send(any())).thenThrow(Exception('unexpected'));

      expect(
        () => service.createPreference(amount: 10, productId: 'p', idToken: 't'),
        throwsA(isA<MercadoPagoException>()),
      );
    });
  });

  group('checkHealth', () {
    test('returns true when server responds 200', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(statusCode: 200, body: '{}'),
      );

      final result = await service.checkHealth();
      expect(result, true);
    });

    test('returns false when server responds non-200', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(statusCode: 500, body: 'error'),
      );

      final result = await service.checkHealth();
      expect(result, false);
    });

    test('returns false on exception', () async {
      when(() => mockSender.send(any())).thenThrow(Exception('timeout'));

      final result = await service.checkHealth();
      expect(result, false);
    });
  });

  group('validatePurchase', () {
    test('returns result on success', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: '{"result":{"gemsAdded":50}}',
        ),
      );

      final result = await service.validatePurchase(
        cost: 29,
        itemId: 'gems_50',
        idToken: 'token',
      );

      expect(result['gemsAdded'], 50);
    });

    test('returns empty map when result is missing', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(statusCode: 200, body: '{}'),
      );

      final result = await service.validatePurchase(
        cost: 29,
        itemId: 'gems_50',
        idToken: 'token',
      );

      expect(result, isEmpty);
    });

    test('propagates ApiException', () async {
      when(() => mockSender.send(any())).thenThrow(
        const ApiException(ApiErrorType.server, 'Server error'),
      );

      expect(
        () => service.validatePurchase(cost: 29, itemId: 'i', idToken: 't'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('registerPendingPayment', () {
    test('returns result on success', () async {
      when(() => mockSender.send(any())).thenAnswer(
        (_) async => const ApiResponse(
          statusCode: 200,
          body: '{"result":{"paymentId":"pay_123"}}',
        ),
      );

      final result = await service.registerPendingPayment(
        paymentMethod: 'mercadopago',
        operationId: 'op_1',
        idToken: 'token',
        amount: 29,
        productId: 'gems_50',
      );

      expect(result['paymentId'], 'pay_123');
    });

    test('propagates ApiException', () async {
      when(() => mockSender.send(any())).thenThrow(
        const ApiException(ApiErrorType.network, 'No connection'),
      );

      expect(
        () => service.registerPendingPayment(
          paymentMethod: 'mp',
          operationId: 'op',
          idToken: 'token',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
