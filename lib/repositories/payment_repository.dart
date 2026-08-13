import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/app_logger.dart';

/// Repository for payment-related data persistence.
/// Tracks purchase history and pending payments for reconciliation.
abstract class PaymentRepository {
  List<Map<String, dynamic>> get pendingPayments;
  List<Map<String, dynamic>> get purchaseHistory;

  Future<void> addPendingPayment({
    required String productId,
    required double amount,
    required String method,
  });

  Future<void> removePendingPayment(String productId);

  Future<void> addPurchase({
    required String productId,
    required double amount,
    required String method,
    required String status,
  });

  void clearPendingPayments();
  void clearHistory();
}

class PaymentRepositoryImpl implements PaymentRepository {
  final SharedPreferences _prefs;
  Completer<void>? _mutex;

  static const _keyPending = 'payment_pending';
  static const _keyHistory = 'payment_history';

  PaymentRepositoryImpl(this._prefs);

  Future<void> _acquireLock() async {
    Completer<void>? current;
    while ((current = _mutex) != null) {
      await current!.future;
    }
    _mutex = Completer<void>();
  }

  void _releaseLock() {
    _mutex?.complete();
    _mutex = null;
  }

  @override
  List<Map<String, dynamic>> get pendingPayments {
    final raw = _prefs.getString(_keyPending);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      AppLogger().warning(
        'PaymentRepository: failed to decode pending payments',
      );
      return [];
    }
  }

  @override
  List<Map<String, dynamic>> get purchaseHistory {
    final raw = _prefs.getString(_keyHistory);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      AppLogger().warning(
        'PaymentRepository: failed to decode purchase history',
      );
      return [];
    }
  }

  @override
  Future<void> addPendingPayment({
    required String productId,
    required double amount,
    required String method,
  }) async {
    await _acquireLock();
    try {
      final payments = pendingPayments;
      payments.add({
        'productId': productId,
        'amount': amount,
        'method': method,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _prefs.setString(_keyPending, jsonEncode(payments));
    } finally {
      _releaseLock();
    }
  }

  @override
  Future<void> removePendingPayment(String productId) async {
    await _acquireLock();
    try {
      final payments = pendingPayments;
      payments.removeWhere((p) => p['productId'] == productId);
      await _prefs.setString(_keyPending, jsonEncode(payments));
    } finally {
      _releaseLock();
    }
  }

  @override
  Future<void> addPurchase({
    required String productId,
    required double amount,
    required String method,
    required String status,
  }) async {
    await _acquireLock();
    try {
      final history = purchaseHistory;
      history.add({
        'productId': productId,
        'amount': amount,
        'method': method,
        'status': status,
        'createdAt': DateTime.now().toIso8601String(),
      });
      if (history.length > 50) {
        history.removeRange(0, history.length - 50);
      }
      await _prefs.setString(_keyHistory, jsonEncode(history));
    } finally {
      _releaseLock();
    }
  }

  @override
  void clearPendingPayments() {
    _prefs.remove(_keyPending);
  }

  @override
  void clearHistory() {
    _prefs.remove(_keyHistory);
  }
}
