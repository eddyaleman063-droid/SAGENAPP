import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/screens/streak/streak_intro_screen.dart';

void main() {
  Widget buildApp({VoidCallback? onContinue}) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StreakIntroScreen(onContinue: onContinue ?? () {}),
      ),
    );
  }

  testWidgets('renders streak intro benefits and continue button', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 800));
    final l = AppLocalizations.of(
      tester.element(find.byType(StreakIntroScreen)),
    )!;
    expect(find.text(l.streakKeepAlive), findsOneWidget);
    expect(find.text(l.streakRewards), findsOneWidget);
    expect(find.text(l.streakAchievements), findsOneWidget);
    expect(find.text(l.streakGotIt), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('calls onContinue when the continue button is tapped', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(buildApp(onContinue: () => calls++));
    await tester.pump(const Duration(milliseconds: 800));
    final l = AppLocalizations.of(
      tester.element(find.byType(StreakIntroScreen)),
    )!;
    await tester.tap(find.text(l.streakGotIt));
    await tester.pump();
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 6));
  });
}
