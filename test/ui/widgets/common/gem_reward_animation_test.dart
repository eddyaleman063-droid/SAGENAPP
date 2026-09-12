import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/gem_reward_animation.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Stack(children: [child])),
  );

  testWidgets('muestra la cantidad ganada en el badge', (tester) async {
    await tester.pumpWidget(
      wrap(const GemRewardAnimation(amount: 5, onComplete: null)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+5'), findsOneWidget);
  });

  testWidgets('animacion con locale muestra semantica de gemas', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      wrap(const GemRewardAnimation(amount: 3, onComplete: null)),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final l = AppLocalizations.of(
      tester.element(find.byType(GemRewardAnimation)),
    )!;
    final node = tester.getSemantics(
      find
          .descendant(
            of: find.byType(GemRewardAnimation),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(node.label, startsWith(l.gemRewardEarned(3)));
    handle.dispose();
  });

  testWidgets('onComplete se invoca al terminar la animacion', (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      wrap(GemRewardAnimation(amount: 10, onComplete: () => completed++)),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(completed, 1);
  });

  testWidgets('show inserta el overlay y lo remueve al completar', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const SizedBox.expand()));
    await tester.pump();

    final ctx = tester.element(find.byType(Scaffold));
    GemRewardAnimation.show(ctx, 7);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+7'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('+7'), findsNothing);
  });
}
