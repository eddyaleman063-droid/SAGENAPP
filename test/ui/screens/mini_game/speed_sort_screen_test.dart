import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/reward_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/ui/screens/mini_game/speed_sort_screen.dart';
import '../../../helpers/mini_game_harness.dart';

void main() {
  final harness = MiniGameHarness();

  Finder acceptButtons(AppLocalizations l) => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        w.properties.label == l.correct &&
        w.properties.button == true,
  );

  Finder rejectButtons(AppLocalizations l) => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        w.properties.label == l.incorrect &&
        w.properties.button == true,
  );

  Future<AppLocalizations> pumpGame(WidgetTester tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      harness.app(
        const SpeedSortScreen(
          config: MiniGameConfig(type: MiniGameType.speedSort),
        ),
      ),
    );
    await tester.pump();
    return AppLocalizations.of(tester.element(find.byType(SpeedSortScreen)))!;
  }

  testWidgets('render inicial: 4 items con boton de aceptar', (tester) async {
    final l = await pumpGame(tester);

    expect(find.text(l.miniGameSortInstruction), findsOneWidget);
    expect(acceptButtons(l), findsNWidgets(4));
    expect(rejectButtons(l), findsNWidgets(4));
    await teardownGame(tester);
  });

  testWidgets('aceptar todo gana: 3 correctos (la trampa queda marcada)', (
    tester,
  ) async {
    final l = await pumpGame(tester);

    // Los 4 items son 3 correctos (de una misma categoria) + 1 trampa
    // (de otra categoria). Identificamos la trampa porque es el unico item
    // presente cuya categoria aparece una sola vez, y aceptamos solo los
    // correctos: el juego termina al aceptar el 3ro.
    final scam = [
      l.speedSortFakeEmail,
      l.speedSortFraudulentCall,
      l.speedSortSmsLink,
    ];
    final security = [
      l.speedSortStrongPassword,
      l.speedSort2fa,
      l.speedSortDataEncryption,
    ];
    final protection = [
      l.speedSortFirewall,
      l.speedSortVpn,
      l.speedSortAntivirus,
    ];
    final groups = [scam, security, protection];
    final present = (scam + security + protection)
        .where((v) => find.text(v).evaluate().isNotEmpty)
        .toList();
    // Los 3 correctos estan todos en la MISMA categoria; la trampa es el
    // unico item cuya categoria aporta exactamente 1 de los presentes.
    int countInCategory(String v) {
      final category = groups.firstWhere((g) => g.contains(v));
      return present.where((u) => category.contains(u)).length;
    }

    final trap = present.firstWhere((v) => countInCategory(v) == 1);
    final corrects = present.where((v) => v != trap).toList();

    Finder rowOf(String v) =>
        find.ancestor(of: find.text(v), matching: find.byType(Row)).first;
    Finder acceptGestureOf(String v) => find
        .descendant(
          of: find.descendant(of: rowOf(v), matching: acceptButtons(l)).first,
          matching: find.byType(GestureDetector),
        )
        .first;

    for (final v in corrects) {
      final gd = acceptGestureOf(v);
      if (gd.evaluate().isNotEmpty) {
        await tester.tap(gd);
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(l.miniGameComplete), findsOneWidget);
    expect(find.textContaining('${l.miniGameCorrect}: 3'), findsOneWidget);
    expect(harness.addXpCalls, 1);
    expect(harness.gemAwardCalls, 1);
    expect(harness.lastXpAmount, RewardConstants.miniGameXp);
    await tester.pump(const Duration(seconds: 2));
    await teardownGame(tester);
  });
}
