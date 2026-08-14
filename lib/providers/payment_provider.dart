import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/app_logger.dart';
import '../services/mercado_pago_service.dart';
import 'providers.dart';

enum PaymentMethod { whatsapp, mercadopago }

enum PaymentStatus {
  idle,
  creatingPreference,
  waitingPayment,
  completed,
  failed,
}

class PaymentState {
  final PaymentStatus status;
  final String? errorMessage;
  final double? pendingAmount;
  final PaymentMethod? selectedMethod;
  final String? preferenceId;
  final String? initPoint;
  final int? donatedBefore;
  final int? donatedAfter;
  final Product? selectedProduct;
  final String? pendingPaymentId;
  final int pollAttempts;
  final DateTime? preferenceCreatedAt;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.errorMessage,
    this.pendingAmount,
    this.selectedMethod,
    this.preferenceId,
    this.initPoint,
    this.donatedBefore,
    this.donatedAfter,
    this.selectedProduct,
    this.pendingPaymentId,
    this.pollAttempts = 0,
    this.preferenceCreatedAt,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? errorMessage,
    double? pendingAmount,
    PaymentMethod? selectedMethod,
    String? preferenceId,
    String? initPoint,
    int? donatedBefore,
    int? donatedAfter,
    Product? selectedProduct,
    String? pendingPaymentId,
    int? pollAttempts,
    bool clearError = false,
    DateTime? preferenceCreatedAt,
  }) {
    return PaymentState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingAmount: pendingAmount ?? this.pendingAmount,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      preferenceId: preferenceId ?? this.preferenceId,
      initPoint: initPoint ?? this.initPoint,
      donatedBefore: donatedBefore ?? this.donatedBefore,
      donatedAfter: donatedAfter ?? this.donatedAfter,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      pendingPaymentId: pendingPaymentId ?? this.pendingPaymentId,
      pollAttempts: pollAttempts ?? this.pollAttempts,
      preferenceCreatedAt: preferenceCreatedAt ?? this.preferenceCreatedAt,
    );
  }
}

class PaymentNotifier extends AutoDisposeNotifier<PaymentState> {
  late final MercadoPagoService _mpService;
  late final AppLogger _logger;
  Timer? _pollTimer;
  bool _polling = false;

  @override
  PaymentState build() {
    _mpService = MercadoPagoService();
    _logger = AppLogger();
    ref.onDispose(() => _pollTimer?.cancel());
    return const PaymentState();
  }

  Future<String?> initiateMercadoPago({
    required double price,
    Product? product,
  }) async {
    if (state.status != PaymentStatus.idle) return null;

    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.read(authProvider);
    final userId = authState.uid;

    if (userId == null || userId.isEmpty) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'You must be signed in to donate',
      );
      return null;
    }

    // PAY-003: Reuse existing preference for same product within 5 minutes
    if (state.preferenceId != null &&
        state.selectedProduct?.id == product?.id) {
      final created = state.preferenceCreatedAt;
      if (created != null && DateTime.now().difference(created).inMinutes < 5) {
        return state.initPoint;
      }
    }

    state = state.copyWith(
      status: PaymentStatus.creatingPreference,
      pendingAmount: price,
      selectedMethod: PaymentMethod.mercadopago,
      donatedBefore: ref.read(learningProvider).totalDonated.toInt(),
      selectedProduct: product,
      clearError: true,
    );

    try {
      final idToken = await authNotifier.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: 'Could not get session. Please sign in again.',
        );
        return null;
      }

      final productId = product?.id;
      if (productId == null || productId.isEmpty) {
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: 'Invalid product',
        );
        return null;
      }

      final pref = await _mpService.createPreference(
        amount: price.toInt(),
        productId: productId,
        idToken: idToken,
      );

      state = state.copyWith(
        status: PaymentStatus.waitingPayment,
        preferenceId: pref.preferenceId,
        initPoint: pref.initPoint,
        preferenceCreatedAt: DateTime.now(),
      );

      return pref.initPoint;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Could not start payment. Please try again.',
      );
      return null;
    }
  }

  Future<void> initiateWhatsApp({
    required double price,
    Product? product,
  }) async {
    if (state.status != PaymentStatus.idle) return;
    final authNotifier = ref.read(authProvider.notifier);
    state = state.copyWith(
      status: PaymentStatus.waitingPayment,
      pendingAmount: price,
      selectedMethod: PaymentMethod.whatsapp,
      donatedBefore: ref.read(learningProvider).totalDonated.toInt(),
      selectedProduct: product,
      clearError: true,
    );
    // Register pending payment on server (requires auth)
    try {
      final idToken = await authNotifier.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        _logger.warning(
          'registerPendingPayment: no idToken, skipping server registration',
        );
        return;
      }
      final opId =
          'wa_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
      final result = await _mpService.registerPendingPayment(
        paymentMethod: 'whatsapp',
        operationId: opId,
        idToken: idToken,
        amount: price.toInt(),
        productId: product?.id,
      );
      final pendingId = result['pendingPaymentId'] as String?;
      if (pendingId != null) {
        state = state.copyWith(pendingPaymentId: pendingId);
        _startPolling(pendingId);
      }
    } catch (e) {
      _logger.error('Failed to register pending payment', e);
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Could not register payment. Please try again.',
      );
    }
  }

  void _startPolling(String pendingPaymentId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _pollPaymentStatus(pendingPaymentId),
    );
  }

  Future<void> _pollPaymentStatus(String pendingPaymentId) async {
    if (_polling) return;
    if (state.pollAttempts >= 60) {
      _pollTimer?.cancel();
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage:
            'Payment verification timed out. Check your payment history or try again.',
        pendingPaymentId: null,
      );
      return;
    }
    _polling = true;
    try {
      state = state.copyWith(pollAttempts: state.pollAttempts + 1);
      final authNotifier = ref.read(authProvider.notifier);
      final idToken = await authNotifier.getIdToken();
      if (idToken == null || idToken.isEmpty) return;
      final result = await _mpService.checkPendingPaymentStatus(
        pendingPaymentId: pendingPaymentId,
        idToken: idToken,
      );
      final status = result['status'] as String?;
      // Both backends flip pending payments to 'completed' (webhook or admin
      // manual credit). Treat it as success; 'confirmed'/'credited' are kept
      // for forward compatibility with other backends.
      if (status == 'completed' ||
          status == 'confirmed' ||
          status == 'credited') {
        _pollTimer?.cancel();
        await refreshGems();
        state = state.copyWith(
          status: PaymentStatus.completed,
          pendingPaymentId: null,
        );
      } else if (status == 'expired' || status == 'not_found') {
        _pollTimer?.cancel();
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: 'Payment expired. Please try again.',
          pendingPaymentId: null,
        );
      }
    } catch (e) {
      _logger.warning('Poll payment status failed: $e');
    } finally {
      _polling = false;
    }
  }

  void onPaymentFailure({String? error}) {
    _pollTimer?.cancel();
    state = state.copyWith(
      status: PaymentStatus.failed,
      errorMessage: error ?? 'Payment was cancelled or did not complete',
    );
  }

  Future<void> refreshGems() async {
    try {
      await ref.read(learningProvider.notifier).reload();
      final currentDonated = ref.read(learningProvider).totalDonated;
      state = state.copyWith(donatedAfter: currentDonated.toInt());
    } catch (e) {
      AppLogger().warning('PaymentNotifier.refreshGems failed: $e');
    }
  }

  void reset() {
    _pollTimer?.cancel();
    state = const PaymentState();
  }
}

final paymentProvider =
    NotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
      PaymentNotifier.new,
    );
