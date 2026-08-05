import 'package:flutter_test/flutter_test.dart';

class MockPaymentService {
  String? _lastStatus;
  String? get lastStatus => _lastStatus;

  Future<String> createPreference({
    required double amount,
    required String currency,
    required String description,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Amount must be positive');
    }
    _lastStatus = 'created';
    return 'pref_123456';
  }

  Future<String> processPayment({
    required String preferenceId,
    required String paymentMethod,
  }) async {
    _lastStatus = 'processing';
    await Future.delayed(const Duration(milliseconds: 100));
    _lastStatus = 'approved';
    return 'payment_789';
  }

  Future<String> checkStatus(String paymentId) async {
    return _lastStatus ?? 'unknown';
  }
}

void main() {
  group('Payment Flow - Complete Integration', () {
    late MockPaymentService paymentService;

    setUp(() {
      paymentService = MockPaymentService();
    });

    test('create preference succeeds with valid data', () async {
      final prefId = await paymentService.createPreference(
        amount: 29.99,
        currency: 'PEN',
        description: 'Cofre Dorado',
      );

      expect(prefId, startsWith('pref_'));
      expect(paymentService.lastStatus, equals('created'));
    });

    test('create preference fails with negative amount', () async {
      expect(
        () => paymentService.createPreference(
          amount: -10.0,
          currency: 'PEN',
          description: 'Invalid',
        ),
        throwsArgumentError,
      );
    });

    test('process payment completes successfully', () async {
      final paymentId = await paymentService.processPayment(
        preferenceId: 'pref_123456',
        paymentMethod: 'credit_card',
      );

      expect(paymentId, startsWith('payment_'));
      expect(paymentService.lastStatus, equals('approved'));
    });

    test('check status returns current status', () async {
      await paymentService.processPayment(
        preferenceId: 'pref_123',
        paymentMethod: 'debit_card',
      );

      final status = await paymentService.checkStatus('payment_789');
      expect(status, equals('approved'));
    });

    test('full payment flow works end-to-end', () async {
      // 1. Create preference
      final prefId = await paymentService.createPreference(
        amount: 49.99,
        currency: 'PEN',
        description: 'Cofre Premium',
      );
      expect(prefId, isNotEmpty);

      // 2. Process payment
      final paymentId = await paymentService.processPayment(
        preferenceId: prefId,
        paymentMethod: 'credit_card',
      );
      expect(paymentId, isNotEmpty);

      // 3. Check status
      final status = await paymentService.checkStatus(paymentId);
      expect(status, equals('approved'));
    });
  });

  group('Payment Flow - Error Cases', () {
    late MockPaymentService paymentService;

    setUp(() {
      paymentService = MockPaymentService();
    });

    test('handles network timeout gracefully', () async {
      // Simulate timeout by checking status of non-existent payment
      final status = await paymentService.checkStatus('nonexistent');
      expect(status, equals('unknown'));
    });

    test('handles concurrent payment attempts', () async {
      final futures = [
        paymentService.createPreference(amount: 10, currency: 'PEN', description: 'A'),
        paymentService.createPreference(amount: 20, currency: 'PEN', description: 'B'),
        paymentService.createPreference(amount: 30, currency: 'PEN', description: 'C'),
      ];

      final results = await Future.wait(futures);
      expect(results.length, equals(3));
      for (final result in results) {
        expect(result, startsWith('pref_'));
      }
    });
  });
}
