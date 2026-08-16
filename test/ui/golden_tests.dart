import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/store/buy_button.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('Golden Tests - BuyButton', () {
    testWidgets('BuyButton enabled golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapInApp(BuyButton(cost: 150, canBuy: true, onBuy: () {})),
      );

      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(BuyButton),
        matchesGoldenFile('goldens/buy_button_enabled.png'),
      );
    });

    testWidgets('BuyButton disabled golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapInApp(BuyButton(cost: 150, canBuy: false, onBuy: () {})),
      );

      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(BuyButton),
        matchesGoldenFile('goldens/buy_button_disabled.png'),
      );
    });
  });
}
