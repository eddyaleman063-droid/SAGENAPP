import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/ui/widgets/paywall_bottom_sheet.dart';

class _MockPayment extends PaymentNotifier {
  final PaymentStatus status;

  _MockPayment(this.status);

  @override
  PaymentState build() => PaymentState(status: status);
}

void main() {
  Widget buildApp({PaymentStatus status = PaymentStatus.idle}) {
    return ProviderScope(
      overrides: [paymentProvider.overrideWith(() => _MockPayment(status))],
      child: const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: PaywallBottomSheet()),
      ),
    );
  }

  testWidgets('renders all three donation packages with MercadoPago buttons', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    expect(find.byType(PaywallBottomSheet), findsOneWidget);
    final l = AppLocalizations.of(
      tester.element(find.byType(PaywallBottomSheet)),
    )!;
    expect(find.text(l.paywallSupportUs), findsOneWidget);
    expect(find.text(l.paywallPackageLabel('básico')), findsOneWidget);
    expect(find.text(l.paywallPackageLabel('popular')), findsOneWidget);
    expect(find.text(l.paywallPackageLabel('premium')), findsOneWidget);
    expect(find.text(l.paywallMercadoPago), findsNWidgets(3));
    expect(find.text(l.paywallPaymentMethods), findsOneWidget);
  });

  testWidgets('disables payment buttons while creating a preference', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(status: PaymentStatus.creatingPreference));
    await tester.pump();
    final buttons = tester
        .widgetList<TextButton>(find.byType(TextButton))
        .toList();
    expect(buttons, isNotEmpty);
    for (final b in buttons) {
      expect(b.onPressed, isNull);
    }
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
