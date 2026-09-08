import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/reward_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/ui/screens/mini_game/pattern_trace_screen.dart';
import '../../../helpers/mini_game_harness.dart';

void main() {
  final harness = MiniGameHarness();

  Future<AppLocalizations> pumpGame(WidgetTester tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      harness.app(
        const PatternTraceScreen(
          config: MiniGameConfig(type: MiniGameType.patternTrace),
        ),
      ),
    );
    await tester.pump();
    return AppLocalizations.of(
      tester.element(find.byType(PatternTraceScreen)),
    )!;
  }

  bool isHighlighted(Widget w) {
    if (w is! AnimatedContainer) return false;
    final d = w.decoration;
    return d is BoxDecoration &&
        d.shape == BoxShape.circle &&
        d.border is Border &&
        (d.border as Border).top.width == 3;
  }

  /// Lee el indice del punto resaltado en este instante (borde ancho 3).
  int highlightedIndex(WidgetTester tester) {
    return tester
        .widgetList(find.byType(AnimatedContainer))
        .toList()
        .indexWhere(isHighlighted);
  }

  /// Avanza el reloj 600ms (un paso de la pauta) y devuelve el indice
  /// resaltado en ese tick.
  Future<int> nextHighlight(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
    return highlightedIndex(tester);
  }

  Finder dotFinder(AppLocalizations l, int n) => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        w.properties.label == l.dot(n) &&
        w.properties.button == true,
  );

  testWidgets('muestra la pauta (Ver) y luego pide el turno del usuario', (
    tester,
  ) async {
    final l = await pumpGame(tester);

    expect(find.text(l.miniGameRound), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
    expect(find.text(l.miniGameWatch), findsOneWidget);

    // Ronda 1: pauta de 3 puntos -> 3*600ms + margen para pasar al turno.
    final highlighted = <int>[];
    for (var i = 0; i < 3; i++) {
      highlighted.add(await nextHighlight(tester));
    }
    expect(highlighted, hasLength(3));
    expect(highlighted.toSet(), hasLength(3), reason: 'sin indices repetidos');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.textContaining(l.miniGameYourTurn), findsOneWidget);
    await teardownGame(tester);
  });

  testWidgets('reproducir las 5 pautas gana el juego', (tester) async {
    final l = await pumpGame(tester);

    for (var round = 0; round < 5; round++) {
      final pattern = <int>[];
      for (var i = 0; i < 3 + round; i++) {
        pattern.add(await nextHighlight(tester));
      }
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 700));
      for (final index in pattern) {
        await tester.tap(dotFinder(l, index + 1), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 40));
      }
      await tester.pump(const Duration(milliseconds: 700));
    }

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text(l.miniGameComplete), findsOneWidget);
    expect(find.text('${l.miniGameScore}: 100'), findsOneWidget);
    expect(harness.addXpCalls, 1);
    expect(harness.gemAwardCalls, 1);
    expect(harness.lastXpAmount, RewardConstants.miniGameXp);
    await tester.pump(const Duration(seconds: 2));
    await teardownGame(tester);
  });

  testWidgets('equivocarse en la pauta acaba con miniGameOver', (tester) async {
    final l = await pumpGame(tester);

    // Ronda 1: pauta de 3 puntos; capturamos la pauta completa.
    final pattern = <int>[];
    for (var i = 0; i < 3; i++) {
      pattern.add(await nextHighlight(tester));
    }
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 700));

    // Elegimos un punto que NO este en la pauta (siempre hay 5-3=2 falsos).
    var wrongDot = 0;
    for (var dot = 1; dot <= 5; dot++) {
      if (!pattern.contains(dot - 1)) {
        wrongDot = dot;
        break;
      }
    }
    await tester.tap(dotFinder(l, wrongDot));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text(l.miniGameOver), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await teardownGame(tester);
  });
}
