import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/ui/screens/payment/payment_failed_screen.dart';

class _MockPaymentNotifier extends PaymentNotifier {
  int resetCalls = 0;

  @override
  PaymentState build() => const PaymentState();

  @override
  void reset() {
    resetCalls++;
  }
}

void main() {
  Widget buildApp(_MockPaymentNotifier notifier, {String? error}) {
    return ProviderScope(
      overrides: [paymentProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/payment-failed',
          routes: [
            GoRoute(
              name: 'payment-failed',
              path: '/payment-failed',
              builder: (context, state) => PaymentFailedScreen(error: error),
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

  testWidgets('renders failure UI with the provided error message', (
    tester,
  ) async {
    final notifier = _MockPaymentNotifier();
    await tester.pumpWidget(buildApp(notifier, error: 'Código de error'));
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentFailedScreen)),
    )!;
    expect(find.text(l.paymentNotCompleted), findsOneWidget);
    expect(find.text('Código de error'), findsOneWidget);
    expect(find.text(l.paymentTryAgain), findsOneWidget);
    expect(find.text(l.paymentGoHome), findsOneWidget);
  });

  testWidgets('go home resets the payment provider and navigates', (
    tester,
  ) async {
    final notifier = _MockPaymentNotifier();
    await tester.pumpWidget(buildApp(notifier));
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentFailedScreen)),
    )!;
    await tester.tap(find.text(l.paymentGoHome));
    await tester.pumpAndSettle();

    expect(notifier.resetCalls, 1);
    expect(find.text('main'), findsOneWidget);
  });
}
