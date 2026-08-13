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
  group('SagenPassScreen', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
    }

    testWidgets('renders season header with level and progress', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('Pase SAGEN'), findsOneWidget);
      expect(find.text('Nivel 6'), findsOneWidget);
      expect(find.text('SP: 30 / 90'), findsOneWidget);
      expect(find.text('Recompensas (1/50)'), findsOneWidget);
      expect(find.textContaining('Quedan'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('shows how-to-earn tips and legend', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Cómo ganar SP'), findsOneWidget);
      expect(find.text('Bloqueado'), findsOneWidget);
      expect(find.text('Alcanzado'), findsOneWidget);
      expect(find.text('Reclamado'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('claiming a reached level shows success notification', (
      tester,
    ) async {
      await pumpScreen(tester);

      // Level 5 is reached (5 <= currentLevel) and not yet claimed.
      await tester.tap(find.byKey(const ValueKey('pass_tile_5')));
      await tester.pumpAndSettle();

      expect(find.text('¡Recompensa reclamada! 100 XP'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
    });
  });
}
