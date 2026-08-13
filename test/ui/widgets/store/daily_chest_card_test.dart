import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/store/daily_chest_card.dart';

class _MockGamification extends GamificationNotifier {
  final bool unclaimed;
  final int claimResult;
  int claimCalls = 0;

  _MockGamification({required this.unclaimed, this.claimResult = 10});

  @override
  GamificationState build() => GamificationState(hasUnclaimedChest: unclaimed);

  @override
  Future<int> claimDailyChest() async {
    claimCalls++;
    return claimResult;
  }
}

Widget _wrap(_MockGamification notifier) {
  return ProviderScope(
    overrides: [gamificationProvider.overrideWith(() => notifier)],
    child: MaterialApp(
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: DailyChestCard()),
    ),
  );
}

void main() {
  testWidgets('hidden when there is no unclaimed chest', (tester) async {
    await tester.pumpWidget(_wrap(_MockGamification(unclaimed: false)));
    await tester.pump();
    expect(find.text('Cofre diario'), findsNothing);
    expect(find.text('Reclamar'), findsNothing);
  });

  testWidgets('shows claim card when chest is unclaimed', (tester) async {
    await tester.pumpWidget(_wrap(_MockGamification(unclaimed: true)));
    await tester.pump();
    expect(find.text('Cofre diario'), findsOneWidget);
    expect(find.text('Reclamar'), findsOneWidget);
  });

  testWidgets('claiming rewards XP and shows success notification', (
    tester,
  ) async {
    final mock = _MockGamification(unclaimed: true, claimResult: 10);
    await tester.pumpWidget(_wrap(mock));
    await tester.pump();
    await tester.tap(find.text('Reclamar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(mock.claimCalls, 1);
    expect(find.text('¡+10 XP!'), findsOneWidget);
  });
}
