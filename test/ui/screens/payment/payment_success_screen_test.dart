import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/ui/screens/payment/payment_success_screen.dart';

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
  Widget buildApp(_MockPaymentNotifier notifier, {required double amount}) {
    return ProviderScope(
      overrides: [paymentProvider.overrideWith(() => notifier)],
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: GoRouter(
          initialLocation: '/payment-success',
          routes: [
            GoRoute(
              name: 'payment-success',
              path: '/payment-success',
              builder: (context, state) =>
                  PaymentSuccessScreen(donationAmount: amount),
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

  testWidgets('renders the donated amount and the continue button', (
    tester,
  ) async {
    final notifier = _MockPaymentNotifier();
    await tester.pumpWidget(buildApp(notifier, amount: 12.5));
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentSuccessScreen)),
    )!;
    expect(find.text('\$12.50'), findsOneWidget);
    expect(find.text(l.continueText), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('continue resets the payment provider without crashing', (
    tester,
  ) async {
    final notifier = _MockPaymentNotifier();
    await tester.pumpWidget(buildApp(notifier, amount: 5.0));
    await tester.pumpAndSettle();

    final l = AppLocalizations.of(
      tester.element(find.byType(PaymentSuccessScreen)),
    )!;
    await tester.tap(find.text(l.continueText));
    await tester.pumpAndSettle();

    expect(notifier.resetCalls, 1);
  });
}
