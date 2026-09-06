import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/level_up_celebration.dart';

void main() {
  Widget buildApp({required VoidCallback onComplete}) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: LevelUpCelebration(newLevel: 7, onComplete: onComplete),
        ),
      ),
    );
  }

  testWidgets('renders the new level and celebration label', (tester) async {
    await tester.pumpWidget(buildApp(onComplete: () {}));
    await tester.pump(const Duration(milliseconds: 100));
    final l = AppLocalizations.of(
      tester.element(find.byType(LevelUpCelebration)),
    )!;
    expect(find.text('7'), findsOneWidget);
    expect(find.text(l.profileLevelValue(7)), findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == l.levelUpCelebrationLabel(7),
      ),
    );
    expect(semantics.properties.liveRegion, isTrue);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('calls onComplete once the celebration window elapses', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(buildApp(onComplete: () => calls++));
    await tester.pump(const Duration(milliseconds: 100));
    expect(calls, 0);
    await tester.pump(const Duration(seconds: 3));
    expect(calls, 1);
  });
}
