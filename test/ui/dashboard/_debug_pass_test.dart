import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/sagen_pass.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/providers/sagen_pass_provider.dart';
import 'package:sagen/ui/screens/dashboard/sagen_pass_screen.dart';

class _MockPassNotifier extends SagenPassNotifier {
  @override
  SagenPass build() =>
      SagenPass(currentLevel: 5, currentSP: 30, claimedLevels: const [1]);

  @override
  Future<PassLevel?> claimLevel(int level) async {
    final passLevel = SagenPass.allLevels.firstWhere((l) => l.level == level);
    state = state.copyWith(claimedLevels: [...state.claimedLevels, level]);
    return passLevel;
  }
}

Widget createTestApp() {
  return ProviderScope(
    overrides: [sagenPassProvider.overrideWith(() => _MockPassNotifier())],
    child: MaterialApp(
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SagenPassScreen(),
    ),
  );
}

void main() {
  testWidgets('debug dump texts', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    for (final t in texts) {
      debugPrint('TEXT: $t');
    }
    final pass = ProviderScope.containerOf(
      tester.element(find.byType(SagenPassScreen)),
    ).read(sagenPassProvider);
    debugPrint(
      'PASS: currentLevel=${pass.currentLevel} sp=${pass.currentSP} claimed=${pass.claimedLevels}',
    );
    await tester.pump(const Duration(seconds: 5));
  });
}
