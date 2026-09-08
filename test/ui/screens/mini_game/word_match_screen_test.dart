import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/reward_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/ui/screens/mini_game/word_match_screen.dart';
import '../../../helpers/mini_game_harness.dart';

void main() {
  final harness = MiniGameHarness();

  Future<AppLocalizations> pumpGame(WidgetTester tester) async {
    await useTallViewport(tester);
    await tester.pumpWidget(
      harness.app(
        const WordMatchScreen(
          config: MiniGameConfig(type: MiniGameType.wordMatch),
        ),
      ),
    );
    await tester.pump();
    return AppLocalizations.of(tester.element(find.byType(WordMatchScreen)))!;
  }

  Future<void> matchPair(
    WidgetTester tester,
    AppLocalizations l,
    String term,
    String def,
  ) async {
    await tester.tap(find.text(term), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text(def), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 250));
  }

  testWidgets('ganar: emparejar las 6 definiciones completa el juego', (
    tester,
  ) async {
    final l = await pumpGame(tester);

    final pairs = [
      (l.miniGamePhishingTerm, l.miniGamePhishingDef),
      (l.miniGameMalwareTerm, l.miniGameMalwareDef),
      (l.miniGameFirewallTerm, l.miniGameFirewallDef),
      (l.miniGameEncryptionTerm, l.miniGameEncryptionDef),
      (l.miniGameVpnTerm, l.miniGameVpnDef),
      (l.miniGameBackupTerm, l.miniGameBackupDef),
    ];

    for (final p in pairs) {
      await matchPair(tester, l, p.$1, p.$2);
    }
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(l.miniGameComplete), findsOneWidget);
    expect(
      find.text('${l.miniGameMatches}: 6/6  |  ${l.miniGameMistakes}: 0'),
      findsOneWidget,
    );
    expect(find.text(l.miniGamePlayAgain), findsOneWidget);
    expect(harness.addXpCalls, 1);
    expect(harness.gemAwardCalls, 1);
    expect(harness.lastXpAmount, RewardConstants.miniGameXp);
    await tester.pump(const Duration(seconds: 2));
    await teardownGame(tester);
  });

  testWidgets('emparejar mal cuenta un error', (tester) async {
    final l = await pumpGame(tester);

    await tester.tap(find.text(l.miniGamePhishingTerm), warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.text(l.miniGameMalwareDef), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('1'), findsOneWidget);
    await teardownGame(tester);
  });
}
