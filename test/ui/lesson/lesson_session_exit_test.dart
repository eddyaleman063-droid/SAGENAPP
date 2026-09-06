import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/lesson/lesson_session_screen.dart';

class _MockSessionNotifier extends SessionNotifier {
  @override
  SessionState build() {
    return const SessionState(
      challenges: [
        Challenge(
          id: 'ch_1',
          lessonId: 'ac_s1_ses1_l1',
          question: '¿Qué es la ingeniería social?',
          type: LessonType.multipleChoice,
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          explanation: 'Explicación',
        ),
      ],
      currentIndex: 0,
      currentChallenge: Challenge(
        id: 'ch_1',
        lessonId: 'ac_s1_ses1_l1',
        question: '¿Qué es la ingeniería social?',
        type: LessonType.multipleChoice,
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        explanation: 'Explicación',
      ),
      lives: 3,
      totalQuestions: 1,
      phase: SessionPhase.playing,
    );
  }

  @override
  Future<void> startSession(
    String stageId,
    String lessonId, {
    int count = 15,
    bool resume = false,
  }) async {}
}

/// Pantalla mínima de "mapa" para verificar que 'Salir' abandona la sesión
/// sin arrastrar el grafo completo de providers de LessonsScreen.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('MAP_CHILD')));
}

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/lesson/ac_st1/ac_s1_ses1_l1',
    routes: [
      GoRoute(
        path: '/',
        name: 'lessons',
        builder: (context, state) => const _MapPlaceholder(),
      ),
      GoRoute(
        path: '/lesson/:stageId/:lessonId',
        name: 'lesson-session',
        builder: (context, state) => LessonSessionScreen(
          stageId: state.pathParameters['stageId']!,
          lessonId: state.pathParameters['lessonId']!,
          lessonTitle: 'Intro',
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [sessionProvider.overrideWith(_MockSessionNotifier.new)],
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  group('LessonSessionScreen exit dialog', () {
    testWidgets('Cancelar dismisses the dialog and stays in the session', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text('¿Seguro que quieres salir del cuestionario?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(
        find.text('¿Seguro que quieres salir del cuestionario?'),
        findsNothing,
      );
      expect(find.text('MAP_CHILD'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Salir dismisses the dialog and navigates to the map', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Salir'));
      await tester.pumpAndSettle();
      expect(find.text('MAP_CHILD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
