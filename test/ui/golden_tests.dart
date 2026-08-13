import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/glass_card.dart';
import 'package:sagen/ui/widgets/common/error_retry_widget.dart';
import 'package:sagen/ui/widgets/store/buy_button.dart';
import 'package:sagen/ui/widgets/onboarding/onboarding_progress_bar.dart';

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

  group('Golden Tests - GlassCard', () {
    testWidgets('GlassCard renders correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapInApp(
          const GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Glass Card Content',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('This is a real app widget'),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(GlassCard),
        matchesGoldenFile('goldens/glass_card.png'),
      );
    });
  });

  group('Golden Tests - ErrorRetryWidget', () {
    testWidgets('ErrorRetryWidget golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapInApp(
          const ErrorRetryWidget(
            message: 'No se pudo cargar',
            details: 'Verifica tu conexión a internet',
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(ErrorRetryWidget),
        matchesGoldenFile('goldens/error_retry.png'),
      );
    });
  });

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

  group('Golden Tests - OnboardingProgressBar', () {
    testWidgets('OnboardingProgressBar golden', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        wrapInApp(const OnboardingProgressBar(progress: 0.4)),
      );

      await tester.pump(const Duration(milliseconds: 500));

      await expectLater(
        find.byType(OnboardingProgressBar),
        matchesGoldenFile('goldens/onboarding_progress.png'),
      );
    });
  });
}
