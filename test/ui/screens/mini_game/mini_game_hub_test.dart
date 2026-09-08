import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/ui/screens/mini_game/memory_flip_screen.dart';
import 'package:sagen/ui/screens/mini_game/mini_game_hub.dart';
import 'package:sagen/ui/screens/mini_game/pattern_trace_screen.dart';
import 'package:sagen/ui/screens/mini_game/speed_sort_screen.dart';
import 'package:sagen/ui/screens/mini_game/word_match_screen.dart';
import 'package:sagen/ui/widgets/common/exit_confirmation_wrapper.dart';

Widget _gameFor(MiniGameType type) {
  switch (type) {
    case MiniGameType.memoryFlip:
      return const MemoryFlipScreen(
        config: MiniGameConfig(type: MiniGameType.memoryFlip),
      );
    case MiniGameType.wordMatch:
      return const WordMatchScreen(
        config: MiniGameConfig(type: MiniGameType.wordMatch),
      );
    case MiniGameType.speedSort:
      return const SpeedSortScreen(
        config: MiniGameConfig(type: MiniGameType.speedSort),
      );
    case MiniGameType.patternTrace:
      return const PatternTraceScreen(
        config: MiniGameConfig(type: MiniGameType.patternTrace),
      );
  }
}

Widget buildHub() {
  final router = GoRouter(
    initialLocation: '/mini-games',
    routes: [
      GoRoute(path: '/mini-games', builder: (c, s) => const MiniGameHub()),
      GoRoute(
        path: '/mini-game/:type',
        builder: (c, s) {
          final type = MiniGameType.values.firstWhere(
            (t) => t.name == s.pathParameters['type'],
            orElse: () => MiniGameType.memoryFlip,
          );
          return _gameFor(type);
        },
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(buildHub());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('hub muestra las 4 tarjetas de juegos', (tester) async {
    await pump(tester);
    final l = AppLocalizations.of(tester.element(find.byType(MiniGameHub)))!;
    expect(find.text(l.miniGameMemory), findsOneWidget);
    expect(find.text(l.miniGameWord), findsOneWidget);
    expect(find.text(l.miniGameSpeed), findsOneWidget);
    expect(find.text(l.miniGamePattern), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('tocar una tarjeta navega al juego correspondiente', (
    tester,
  ) async {
    await pump(tester);
    final l = AppLocalizations.of(tester.element(find.byType(MiniGameHub)))!;
    await tester.tap(find.text(l.miniGameMemory));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MemoryFlipScreen), findsOneWidget);
    await teardown(tester);
  });

  testWidgets('el juego abierto queda dentro de la confirmacion de exit', (
    tester,
  ) async {
    await pump(tester);
    final l = AppLocalizations.of(tester.element(find.byType(MiniGameHub)))!;
    await tester.tap(find.text(l.miniGameWord));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(WordMatchScreen), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(WordMatchScreen),
        matching: find.byType(ExitConfirmationWrapper),
      ),
      findsOneWidget,
    );
    await teardown(tester);
  });
}
