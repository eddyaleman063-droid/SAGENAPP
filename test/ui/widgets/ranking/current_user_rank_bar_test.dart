import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/ranking/current_user_rank_bar.dart';

Widget _wrap(CurrentUserRankBar bar) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: bar),
  );
}

void main() {
  testWidgets('shows rank and formatted XP', (tester) async {
    await tester.pumpWidget(
      _wrap(const CurrentUserRankBar(rank: 3, totalXp: 5000, xpToNext: 200)),
    );
    expect(find.text('Tu posición: #3 · 5.0k XP'), findsOneWidget);
    expect(find.text('Te faltan 200 XP para entrar al Top 50'), findsOneWidget);
  });

  testWidgets('formats small XP without suffix', (tester) async {
    await tester.pumpWidget(
      _wrap(const CurrentUserRankBar(rank: 12, totalXp: 480, xpToNext: 0)),
    );
    expect(find.text('Tu posición: #12 · 480 XP'), findsOneWidget);
  });

  testWidgets('hides the next-rank hint when xpToNext is zero', (tester) async {
    await tester.pumpWidget(
      _wrap(const CurrentUserRankBar(rank: 1, totalXp: 900, xpToNext: 0)),
    );
    expect(find.textContaining('Top 50'), findsNothing);
  });
}
