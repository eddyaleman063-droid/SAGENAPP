import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/ui/screens/payment/payment_pending_screen.dart';

class _MockPaymentNotifier extends PaymentNotifier {
  _MockPaymentNotifier([this.initial = const PaymentState()]);

  final PaymentState initial;
  int resetCalls = 0;

  @override
  PaymentState build() => initial;

  @override
  void reset() {
    resetCalls++;
  }
}

void main() {
  Widget buildApp(_MockPaymentNotifier notifier) {
    return ProviderScope(
      overrides: [paymentProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/payment-pending',
          routes: [
            GoRoute(
              name: 'payment-pending',
              path: '/payment-pending',
              builder: (context, state) => const PaymentPendingScreen(),
            ),
            GoRoute(
              name: 'main',
              path: '/main',
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('main'))),
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('renders the polling state with remaining seconds', (
    tester,
  ) async {
    final notifier = _MockPaymentNotifier(
      const PaymentState(status: PaymentStatus.waitingPayment, pollAttempts: 2),
    );
    await tester.pumpWidget(buildApp(notifier));
    await tester.pump(const Duration(milliseconds: 500));

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentPendingScreen)),
    )!;
    expect(find.text(l.paymentPending), findsOneWidget);
    expect(find.text(l.paymentPendingDescription), findsOneWidget);
    expect(find.text('10s'), findsOneWidget);
    expect(find.byIcon(Icons.hourglass_top_rounded), findsWidgets);
    expect(find.text(l.paymentGoHome), findsOneWidget);
  });

  testWidgets('renders failure state with the retry button', (tester) async {
    final notifier = _MockPaymentNotifier(
      const PaymentState(
        status: PaymentStatus.failed,
        errorMessage: 'ERROR_NETWORK',
      ),
    );
    await tester.pumpWidget(buildApp(notifier));
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentPendingScreen)),
    )!;
    expect(find.text(l.paymentNotCompleted), findsOneWidget);
    expect(find.text(l.paymentTryAgain), findsOneWidget);
    expect(find.text('10s'), findsNothing);
  });

  testWidgets('go home resets the payment provider and navigates', (
    tester,
  ) async {
    final notifier = _MockPaymentNotifier(
      const PaymentState(status: PaymentStatus.waitingPayment),
    );
    await tester.pumpWidget(buildApp(notifier));
    await tester.pump(const Duration(milliseconds: 500));

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentPendingScreen)),
    )!;
    await tester.tap(find.text(l.paymentGoHome));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(notifier.resetCalls, 1);
    expect(find.text('main'), findsOneWidget);
  });
}
