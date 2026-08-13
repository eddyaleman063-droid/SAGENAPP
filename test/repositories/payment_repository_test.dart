import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/repositories/payment_repository.dart';

void main() {
  late SharedPreferences prefs;
  late PaymentRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = PaymentRepositoryImpl(prefs);
  });

  group('PaymentRepository — empty state', () {
    test('starts with no pending payments and no history', () {
      expect(repo.pendingPayments, isEmpty);
      expect(repo.purchaseHistory, isEmpty);
    });
  });

  group('PaymentRepository — pending payments', () {
    test('addPendingPayment stores an entry', () async {
      await repo.addPendingPayment(
        productId: 'donation_3',
        amount: 3.0,
        method: 'mercadopago',
      );
      final pending = repo.pendingPayments;
      expect(pending, hasLength(1));
      expect(pending.first['productId'], 'donation_3');
      expect(pending.first['amount'], 3.0);
      expect(pending.first['method'], 'mercadopago');
      expect(pending.first['createdAt'], isA<String>());
    });

    test('removePendingPayment removes by productId', () async {
      await repo.addPendingPayment(productId: 'a', amount: 1, method: 'mp');
      await repo.addPendingPayment(productId: 'b', amount: 2, method: 'mp');
      await repo.removePendingPayment('a');
      final pending = repo.pendingPayments;
      expect(pending, hasLength(1));
      expect(pending.first['productId'], 'b');
    });

    test('clearPendingPayments empties the list', () async {
      await repo.addPendingPayment(productId: 'a', amount: 1, method: 'mp');
      repo.clearPendingPayments();
      expect(repo.pendingPayments, isEmpty);
    });
  });

  group('PaymentRepository — purchase history', () {
    test('addPurchase stores an entry with status', () async {
      await repo.addPurchase(
        productId: 'donation_10',
        amount: 10.0,
        method: 'yape',
        status: 'completed',
      );
      final history = repo.purchaseHistory;
      expect(history, hasLength(1));
      expect(history.first['status'], 'completed');
      expect(history.first['amount'], 10.0);
    });

    test('history is capped at 50 entries', () async {
      for (var i = 0; i < 60; i++) {
        await repo.addPurchase(
          productId: 'p$i',
          amount: 1.0,
          method: 'mp',
          status: 'completed',
        );
      }
      expect(repo.purchaseHistory, hasLength(50));
    });

    test('clearHistory empties purchase history', () async {
      await repo.addPurchase(
        productId: 'a',
        amount: 1,
        method: 'mp',
        status: 'completed',
      );
      repo.clearHistory();
      expect(repo.purchaseHistory, isEmpty);
    });
  });

  group('PaymentRepository — data robustness', () {
    test('corrupt pending JSON is ignored', () {
      prefs.setString('payment_pending', 'oops');
      expect(repo.pendingPayments, isEmpty);
    });

    test('corrupt history JSON is ignored', () {
      prefs.setString('payment_history', 'oops');
      expect(repo.purchaseHistory, isEmpty);
    });
  });

  group('PaymentRepository — concurrency', () {
    test('concurrent adds do not lose entries', () async {
      await Future.wait([
        repo.addPendingPayment(productId: '1', amount: 1, method: 'mp'),
        repo.addPendingPayment(productId: '2', amount: 1, method: 'mp'),
        repo.addPendingPayment(productId: '3', amount: 1, method: 'mp'),
      ]);
      expect(repo.pendingPayments, hasLength(3));
    });
  });
}
