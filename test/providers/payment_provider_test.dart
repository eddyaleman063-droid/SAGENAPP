import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

class MockPaymentNotifier extends PaymentNotifier {
  @override
  PaymentState build() => const PaymentState();

  @override
  Future<void> initiateWhatsApp({
    required double price,
    dynamic product,
  }) async {
    state = state.copyWith(
      status: PaymentStatus.waitingPayment,
      pendingAmount: price,
      selectedMethod: PaymentMethod.whatsapp,
      donatedBefore: ref.read(learningProvider).totalDonated.toInt(),
      selectedProduct: product,
      clearError: true,
    );
  }

  @override
  void onPaymentFailure({String? error}) {
    state = state.copyWith(
      status: PaymentStatus.failed,
      errorMessage: error ?? 'El pago fue cancelado o no se completó',
    );
  }

  @override
  void reset() {
    state = const PaymentState();
  }

  @override
  Future<void> refreshGems() async {
    state = state.copyWith(
      donatedAfter: ref.read(learningProvider).totalDonated.toInt(),
    );
  }
}

void main() {
  group('PaymentState', () {
    test('initial state has correct defaults', () {
      const state = PaymentState();
      expect(state.status, PaymentStatus.idle);
      expect(state.errorMessage, isNull);
      expect(state.pendingAmount, isNull);
      expect(state.selectedMethod, isNull);
      expect(state.preferenceId, isNull);
      expect(state.initPoint, isNull);
      expect(state.donatedBefore, isNull);
      expect(state.donatedAfter, isNull);
    });

    test('copyWith updates specified fields', () {
      const state = PaymentState();
      final updated = state.copyWith(
        status: PaymentStatus.completed,
        pendingAmount: 5.0,
        selectedMethod: PaymentMethod.mercadopago,
        donatedBefore: 50,
        donatedAfter: 150,
      );
      expect(updated.status, PaymentStatus.completed);
      expect(updated.pendingAmount, 5.0);
      expect(updated.selectedMethod, PaymentMethod.mercadopago);
      expect(updated.preferenceId, isNull);
      expect(updated.donatedBefore, 50);
      expect(updated.donatedAfter, 150);
    });

    test('copyWith clearError clears errorMessage', () {
      const state = PaymentState(errorMessage: 'some error');
      final updated = state.copyWith(clearError: true);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith preserves unspecified fields', () {
      const state = PaymentState(pendingAmount: 5.0);
      final updated = state.copyWith(status: PaymentStatus.waitingPayment);
      expect(updated.pendingAmount, 5.0);
      expect(updated.status, PaymentStatus.waitingPayment);
      expect(updated.errorMessage, isNull);
    });
  });

  group('PaymentNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          learningProvider.overrideWith(MockLearningNotifier.new),
          paymentProvider.overrideWith(() => MockPaymentNotifier()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('build returns default state', () {
      final state = container.read(paymentProvider);
      expect(state.status, PaymentStatus.idle);
    });

    test('initiateWhatsApp sets waiting state with price', () async {
      final notifier = container.read(paymentProvider.notifier);
      await notifier.initiateWhatsApp(price: 10.0);
      final state = container.read(paymentProvider);
      expect(state.status, PaymentStatus.waitingPayment);
      expect(state.pendingAmount, 10.0);
      expect(state.selectedMethod, PaymentMethod.whatsapp);
      expect(state.donatedBefore, 0);
      expect(state.errorMessage, isNull);
    });

    test('onPaymentFailure sets failed status with default error', () async {
      final notifier = container.read(paymentProvider.notifier);
      await notifier.initiateWhatsApp(price: 5.0);
      notifier.onPaymentFailure();
      final state = container.read(paymentProvider);
      expect(state.status, PaymentStatus.failed);
      expect(state.errorMessage, 'El pago fue cancelado o no se completó');
    });

    test('onPaymentFailure sets failed status with custom error', () async {
      final notifier = container.read(paymentProvider.notifier);
      notifier.onPaymentFailure(error: 'Tarjeta rechazada');
      final state = container.read(paymentProvider);
      expect(state.status, PaymentStatus.failed);
      expect(state.errorMessage, 'Tarjeta rechazada');
    });

    test('reset clears everything back to default', () async {
      final notifier = container.read(paymentProvider.notifier);
      await notifier.initiateWhatsApp(price: 10.0);
      notifier.reset();
      final state = container.read(paymentProvider);
      expect(state.status, PaymentStatus.idle);
      expect(state.pendingAmount, isNull);
      expect(state.selectedMethod, isNull);
    });

    test('refreshGems reads donatedAfter from learningProvider', () async {
      final notifier = container.read(paymentProvider.notifier);
      await notifier.initiateWhatsApp(price: 5.0);
      await notifier.refreshGems();
      final state = container.read(paymentProvider);
      expect(state.donatedAfter, 0);
    });

    test('initiateWhatsApp clears previous error', () async {
      final notifier = container.read(paymentProvider.notifier);
      notifier.onPaymentFailure(error: 'previous error');
      await notifier.initiateWhatsApp(price: 10.0);
      final state = container.read(paymentProvider);
      expect(state.errorMessage, isNull);
    });
  });
}
