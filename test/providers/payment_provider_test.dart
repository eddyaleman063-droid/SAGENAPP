import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/models/product.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/mercado_pago_service.dart';

class _MockMp extends Mock implements MercadoPagoService {}

class _FakeAuth extends AuthNotifier {
  final String? userId;
  final bool nullToken;

  _FakeAuth(this.userId, {this.nullToken = false});

  @override
  AuthState build() => AuthState(
    status: AuthStatus.authenticated,
    uid: userId,
    email: 'x@y.dev',
  );

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return nullToken ? null : 'token-$userId';
  }
}

class _FakeLearning extends LearningNotifier {
  final double donated;
  final bool failReload;

  _FakeLearning(this.donated, {this.failReload = false});

  @override
  LearningState build() => LearningState(totalDonated: donated);

  @override
  Future<void> reload() async {
    if (failReload) throw Exception('reload boom');
  }
}

class _FakeGem extends GemNotifier {
  @override
  GemState build() => const GemState(balance: 1200, totalEarned: 2000);

  @override
  Future<void> syncBalanceFromServer() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockMp mp;

  setUp(() {
    mp = _MockMp();
    PaymentNotifier.overrideMpService = mp;
  });

  tearDown(() {
    PaymentNotifier.overrideMpService = null;
  });

  const product = Product(
    id: 'p1',
    title: 'Donación',
    description: 'Apoyo',
    price: 5,
    supporterLevel: 1,
  );

  ProviderContainer container({String? uid = 'u1', bool nullToken = false}) {
    final c = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => _FakeAuth(uid, nullToken: nullToken)),
        learningProvider.overrideWith(() => _FakeLearning(100)),
        gemProvider.overrideWith(() => _FakeGem()),
      ],
    );
    // Mantiene el notifier autoDispose vivo durante todo el test.
    c.listen(paymentProvider, (_, _) {});
    addTearDown(c.dispose);
    return c;
  }

  PaymentNotifier notifierOf(ProviderContainer c) =>
      c.read(paymentProvider.notifier);

  group('PaymentNotifier.initiateMercadoPago', () {
    test('returns null when a payment is already in progress', () async {
      when(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      ).thenAnswer(
        (_) async => const MercadoPagoPreference(
          preferenceId: 'p1',
          initPoint: 'https://pay/1',
          externalRef: 'r1',
        ),
      );
      final c = container();
      final n = notifierOf(c);

      await n.initiateMercadoPago(price: 5, product: product);
      expect(await n.initiateMercadoPago(price: 10, product: product), isNull);
      verify(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      ).called(1);
    });

    test('returns null and fails when the user is signed out', () async {
      final c = container(uid: null);
      final n = notifierOf(c);

      final result = await n.initiateMercadoPago(price: 5, product: product);

      expect(result, isNull);
      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(c.read(paymentProvider).errorMessage, contains('signed in'));
      verifyNever(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      );
    });

    test('tracks state through a successful preference creation', () async {
      when(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      ).thenAnswer(
        (_) async => const MercadoPagoPreference(
          preferenceId: 'p1',
          initPoint: 'https://pay/1',
          externalRef: 'r1',
        ),
      );
      final c = container();
      final n = notifierOf(c);

      final result = await n.initiateMercadoPago(price: 5, product: product);

      expect(result, 'https://pay/1');
      final state = c.read(paymentProvider);
      expect(state.status, PaymentStatus.waitingPayment);
      expect(state.preferenceId, 'p1');
      expect(state.pendingAmount, 5);
      expect(state.selectedMethod, PaymentMethod.mercadopago);
      expect(state.donatedBefore, 100);
      expect(state.selectedProduct?.id, 'p1');
      expect(state.preferenceCreatedAt, isNotNull);
      expect(state.errorMessage, isNull);
      verify(
        () => mp.createPreference(
          amount: 5.0,
          productId: 'p1',
          idToken: 'token-u1',
        ),
      ).called(1);
    });

    test('fails when the session token cannot be refreshed', () async {
      final c = container(nullToken: true);
      final n = notifierOf(c);

      final result = await n.initiateMercadoPago(price: 5, product: product);

      expect(result, isNull);
      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(c.read(paymentProvider).errorMessage, contains('session'));
      verifyNever(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      );
    });

    test('fails when there is no product selected', () async {
      final c = container();
      final n = notifierOf(c);

      final result = await n.initiateMercadoPago(price: 5);

      expect(result, isNull);
      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(c.read(paymentProvider).errorMessage, contains('Invalid product'));
      verifyNever(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      );
    });

    test('fails gracefully when the backend throws', () async {
      when(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      ).thenThrow(const MercadoPagoException('boom'));
      final c = container();
      final n = notifierOf(c);

      final result = await n.initiateMercadoPago(price: 5, product: product);

      expect(result, isNull);
      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(c.read(paymentProvider).errorMessage, contains('Could not start'));
    });
  });

  group('PaymentNotifier.initiateWhatsApp + polling', () {
    void pump(FakeAsync async) {
      async.elapse(Duration.zero);
      for (var i = 0; i < 20; i++) {
        async.flushMicrotasks();
      }
    }

    test('completes a whatsapp payment when the poll reports completion', () {
      fakeAsync((async) {
        when(
          () => mp.registerPendingPayment(
            amount: any(named: 'amount'),
            productId: any(named: 'productId'),
            paymentMethod: any(named: 'paymentMethod'),
            operationId: any(named: 'operationId'),
            idToken: any(named: 'idToken'),
          ),
        ).thenAnswer((_) async => {'pendingPaymentId': 'pp1'});
        when(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: 'pp1',
            idToken: 'token-u1',
          ),
        ).thenAnswer((_) async => {'status': 'completed'});
        final c = container();
        final n = notifierOf(c);
        var done = false;
        n.initiateWhatsApp(price: 5, product: product).then((_) => done = true);
        pump(async);

        expect(done, isTrue);
        expect(c.read(paymentProvider).status, PaymentStatus.waitingPayment);

        async.elapse(const Duration(seconds: 5));
        pump(async);

        final state = c.read(paymentProvider);
        expect(state.status, PaymentStatus.completed);
        expect(state.pendingPaymentId, isNull);
        expect(state.donatedAfter, 100);
        c.dispose();
      });
    });

    test('fails when authentication has expired', () async {
      final c = container(nullToken: true);
      final n = notifierOf(c);

      await n.initiateWhatsApp(price: 5, product: product);

      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(
        c.read(paymentProvider).errorMessage,
        contains('Authentication expired'),
      );
      verifyNever(
        () => mp.registerPendingPayment(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          paymentMethod: any(named: 'paymentMethod'),
          operationId: any(named: 'operationId'),
          idToken: any(named: 'idToken'),
        ),
      );
    });

    test('fails when the pending payment cannot be registered', () async {
      when(
        () => mp.registerPendingPayment(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          paymentMethod: any(named: 'paymentMethod'),
          operationId: any(named: 'operationId'),
          idToken: any(named: 'idToken'),
        ),
      ).thenThrow(Exception('backend down'));
      final c = container();
      final n = notifierOf(c);

      await n.initiateWhatsApp(price: 5, product: product);

      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(
        c.read(paymentProvider).errorMessage,
        contains('Could not register'),
      );
    });

    test('does not poll when no pending id is returned', () {
      fakeAsync((async) {
        when(
          () => mp.registerPendingPayment(
            amount: any(named: 'amount'),
            productId: any(named: 'productId'),
            paymentMethod: any(named: 'paymentMethod'),
            operationId: any(named: 'operationId'),
            idToken: any(named: 'idToken'),
          ),
        ).thenAnswer((_) async => <String, dynamic>{});
        final c = container();
        final n = notifierOf(c);
        var done = false;
        n.initiateWhatsApp(price: 5, product: product).then((_) => done = true);
        async.elapse(Duration.zero);
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }
        expect(done, isTrue);

        async.elapse(const Duration(seconds: 15));
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }
        verifyNever(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: any(named: 'pendingPaymentId'),
            idToken: any(named: 'idToken'),
          ),
        );
        c.dispose();
      });
    });

    test('times out after 60 polling attempts', () {
      fakeAsync((async) {
        when(
          () => mp.registerPendingPayment(
            amount: any(named: 'amount'),
            productId: any(named: 'productId'),
            paymentMethod: any(named: 'paymentMethod'),
            operationId: any(named: 'operationId'),
            idToken: any(named: 'idToken'),
          ),
        ).thenAnswer((_) async => {'pendingPaymentId': 'pp1'});
        when(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: 'pp1',
            idToken: 'token-u1',
          ),
        ).thenAnswer((_) async => {'status': 'pending'});
        final c = container();
        final n = notifierOf(c);
        n.initiateWhatsApp(price: 5, product: product);
        async.elapse(Duration.zero);
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }

        for (var i = 0; i < 65; i++) {
          async.elapse(const Duration(seconds: 5));
        }

        final state = c.read(paymentProvider);
        expect(state.status, PaymentStatus.failed);
        expect(state.errorMessage, contains('timed out'));
        expect(state.pendingPaymentId, isNull);
        c.dispose();
      });
    });

    test('resets poll attempts when retrying after a timeout', () {
      fakeAsync((async) {
        when(
          () => mp.registerPendingPayment(
            amount: any(named: 'amount'),
            productId: any(named: 'productId'),
            paymentMethod: any(named: 'paymentMethod'),
            operationId: any(named: 'operationId'),
            idToken: any(named: 'idToken'),
          ),
        ).thenAnswer((_) async => {'pendingPaymentId': 'pp1'});
        when(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: 'pp1',
            idToken: 'token-u1',
          ),
        ).thenAnswer((_) async => {'status': 'pending'});
        final c = container();
        final n = notifierOf(c);
        n.initiateWhatsApp(price: 5, product: product);
        pump(async);

        for (var i = 0; i < 65; i++) {
          async.elapse(const Duration(seconds: 5));
        }
        expect(c.read(paymentProvider).status, PaymentStatus.failed);

        n.reset();
        expect(c.read(paymentProvider).status, PaymentStatus.idle);

        when(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: 'pp1',
            idToken: 'token-u1',
          ),
        ).thenAnswer((_) async => {'status': 'completed'});
        n.initiateWhatsApp(price: 5, product: product);
        pump(async);
        expect(c.read(paymentProvider).status, PaymentStatus.waitingPayment);
        expect(c.read(paymentProvider).pollAttempts, 0);

        async.elapse(const Duration(seconds: 5));
        pump(async);
        final state = c.read(paymentProvider);
        expect(state.status, PaymentStatus.completed);
        expect(state.pollAttempts, 1);
        expect(state.pendingPaymentId, isNull);
      });
    });

    test('marks the payment as expired', () {
      fakeAsync((async) {
        when(
          () => mp.registerPendingPayment(
            amount: any(named: 'amount'),
            productId: any(named: 'productId'),
            paymentMethod: any(named: 'paymentMethod'),
            operationId: any(named: 'operationId'),
            idToken: any(named: 'idToken'),
          ),
        ).thenAnswer((_) async => {'pendingPaymentId': 'pp1'});
        when(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: 'pp1',
            idToken: 'token-u1',
          ),
        ).thenAnswer((_) async => {'status': 'expired'});
        final c = container();
        final n = notifierOf(c);
        n.initiateWhatsApp(price: 5, product: product);
        async.elapse(Duration.zero);
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }

        async.elapse(const Duration(seconds: 5));
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }

        final state = c.read(paymentProvider);
        expect(state.status, PaymentStatus.failed);
        expect(state.errorMessage, contains('expired'));
        c.dispose();
      });
    });

    test('survives a poll error and completes on the next attempt', () {
      fakeAsync((async) {
        when(
          () => mp.registerPendingPayment(
            amount: any(named: 'amount'),
            productId: any(named: 'productId'),
            paymentMethod: any(named: 'paymentMethod'),
            operationId: any(named: 'operationId'),
            idToken: any(named: 'idToken'),
          ),
        ).thenAnswer((_) async => {'pendingPaymentId': 'pp1'});
        var attempts = 0;
        when(
          () => mp.checkPendingPaymentStatus(
            pendingPaymentId: 'pp1',
            idToken: 'token-u1',
          ),
        ).thenAnswer((_) async {
          attempts++;
          if (attempts == 1) throw Exception('transient');
          return {'status': 'completed'};
        });
        final c = container();
        final n = notifierOf(c);
        n.initiateWhatsApp(price: 5, product: product);
        async.elapse(Duration.zero);
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }

        async.elapse(const Duration(seconds: 5));
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }
        expect(c.read(paymentProvider).status, PaymentStatus.waitingPayment);

        async.elapse(const Duration(seconds: 5));
        for (var i = 0; i < 20; i++) {
          async.flushMicrotasks();
        }
        expect(c.read(paymentProvider).status, PaymentStatus.completed);
        expect(attempts, 2);
        c.dispose();
      });
    });
  });

  group('PaymentNotifier.control surfaces', () {
    test('onPaymentFailure records the provided message', () {
      final c = container();
      final n = notifierOf(c);
      n.onPaymentFailure(error: 'user cancelled');
      expect(c.read(paymentProvider).status, PaymentStatus.failed);
      expect(c.read(paymentProvider).errorMessage, 'user cancelled');
    });

    test('onPaymentFailure uses a default message', () {
      final c = container();
      final n = notifierOf(c);
      n.onPaymentFailure();
      expect(c.read(paymentProvider).errorMessage, contains('cancelled'));
    });

    test('refreshGems tolerates reload failures', () async {
      final c = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuth('u1')),
          learningProvider.overrideWith(
            () => _FakeLearning(100, failReload: true),
          ),
          gemProvider.overrideWith(() => _FakeGem()),
        ],
      );
      c.listen(paymentProvider, (_, _) {});
      addTearDown(c.dispose);
      final n = notifierOf(c);
      await n.refreshGems();
      expect(c.read(paymentProvider).donatedAfter, isNull);
    });

    test('reset returns to the idle state', () async {
      when(
        () => mp.createPreference(
          amount: any(named: 'amount'),
          productId: any(named: 'productId'),
          idToken: any(named: 'idToken'),
        ),
      ).thenAnswer(
        (_) async => const MercadoPagoPreference(
          preferenceId: 'p1',
          initPoint: 'https://pay/1',
          externalRef: 'r1',
        ),
      );
      final c = container();
      final n = notifierOf(c);
      await n.initiateMercadoPago(price: 5, product: product);
      expect(c.read(paymentProvider).status, PaymentStatus.waitingPayment);

      n.reset();
      expect(c.read(paymentProvider).status, PaymentStatus.idle);
    });
  });
}
