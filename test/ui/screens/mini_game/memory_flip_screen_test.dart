import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/reward_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/ui/screens/mini_game/memory_flip_screen.dart';
import '../../../helpers/mini_game_harness.dart';

void main() {
  final harness = MiniGameHarness();

  Future<AppLocalizations> pumpGame(WidgetTester tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      harness.app(
        const MemoryFlipScreen(
          config: MiniGameConfig(type: MiniGameType.memoryFlip),
        ),
      ),
    );
    await tester.pump();
    return AppLocalizations.of(tester.element(find.byType(MemoryFlipScreen)))!;
  }

  testWidgets('render inicial: 12 cartas ocultas, 60s y 0 aciertos', (
    tester,
  ) async {
    final l = await pumpGame(tester);

    expect(l.miniGameMoves, isNotEmpty);
    expect(l.miniGameMatches, isNotEmpty);
    expect(l.miniGameHiddenCard, isNotEmpty);
    expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(12));
    expect(find.text('60'), findsOneWidget);
    await teardownGame(tester);
  });

  testWidgets('flip de una carta la revela', (tester) async {
    final l = await pumpGame(tester);
    final hiddenCard = find.byWidgetPredicate(
      (w) =>
          w is Semantics &&
          w.properties.label == l.miniGameHiddenCard &&
          w.properties.button == true,
    );
    final gd = find
        .descendant(
          of: hiddenCard.first,
          matching: find.byType(GestureDetector),
        )
        .first;

    await tester.tap(gd);
    await tester.pump(const Duration(milliseconds: 500));

    // La carta revelada cambia su label de "Carta oculta" al termino;
    // quedan 11 bajo el label oculto (independiente del AnimatedSwitcher).
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == l.miniGameHiddenCard,
      ),
      findsNWidgets(11),
    );
    await teardownGame(tester);
  });

  testWidgets('al agotarse el tiempo se acaba con miniGameOver y recompensa', (
    tester,
  ) async {
    final l = await pumpGame(tester);

    await tester.pump(const Duration(seconds: 61));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(l.miniGameOver), findsOneWidget);
    expect(find.text(l.miniGamePlayAgain), findsOneWidget);
    expect(harness.addXpCalls, 1);
    expect(harness.gemAwardCalls, 1);
    expect(harness.lastXpAmount, RewardConstants.miniGameXp);
    await tester.pump(const Duration(seconds: 2));
    await teardownGame(tester);
  });
}
