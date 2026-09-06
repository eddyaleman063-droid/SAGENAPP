import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/streak_service.dart';
import 'package:sagen/ui/screens/lesson/lesson_results_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSessionNotifier extends SessionNotifier {
  _MockSessionNotifier(this.initialState);

  final SessionState initialState;

  @override
  SessionState build() => initialState;
}

class _MockLearningNotifier extends LearningNotifier {
  _MockLearningNotifier(this.initialState, this.log);

  final LearningState initialState;
  final List<String> log;

  @override
  LearningState build() => initialState;

  @override
  Future<void> completeLesson(
    String stageId,
    String lessonId, {
    bool perfectLesson = false,
    int correctAnswers = 0,
    int totalQuestions = 0,
  }) async {
    log.add('completeLesson');
  }
}

class _MockStreakNotifier extends StreakNotifier {
  _MockStreakNotifier(this.log);

  final List<String> log;

  @override
  StreakState build() => const StreakState(
    status: StreakStatus(
      currentStreak: 9,
      longestStreak: 9,
      streakFreezes: 0,
      isAtRisk: false,
      message: '',
      tier: 'basic',
    ),
    totalCheckIns: 0,
    perfectWeeks: 0,
    missionCompleted: false,
    weeklyStats: {},
    heatmapData: {},
    monthlyData: {},
    streakHistory: [],
    emotionalMessages: [],
  );

  @override
  void checkIn() {
    log.add('checkIn');
  }
}

SessionState _completedSession() => const SessionState(
  phase: SessionPhase.completed,
  lives: 3,
  correctCount: 15,
  wrongCount: 0,
  totalQuestions: 15,
);

List<Stage> _createStages() => [
  Stage(
    id: 'ac_st1',
    title: 'Fundamentos',
    subtitle: 'Aprende lo básico',
    accent: Colors.blue,
    icon: Icons.shield_rounded,
    unlocked: true,
    lessons: [
      Lesson(
        id: 'lesson_1_1',
        title: 'Introducción a la seguridad',
        subtitle: 'Primeros pasos',
        challenges: const [
          Challenge(
            id: 'ch_1',
            question: '¿Qué es la seguridad digital?',
            type: LessonType.multipleChoice,
            options: ['Proteger datos', 'Navegar web', 'Usar redes', 'Enviar'],
            correctIndex: 0,
            explanation: 'Protege nuestros datos.',
          ),
        ],
        estimatedMinutes: 5,
      ),
    ],
  ),
];

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildApp({
    required SharedPreferences prefs,
    required List<String> log,
    SessionNotifier? session,
  }) {
    final learning = _MockLearningNotifier(
      LearningState(stages: _createStages()),
      log,
    );
    final streak = _MockStreakNotifier(log);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LessonResultsScreen(
            stageId: 'ac_st1',
            lessonId: 'lesson_1_1',
          ),
        ),
        GoRoute(
          path: '/lessons',
          name: 'lessons',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Mapa de lecciones'))),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        reduceAnimationsProvider.overrideWithValue(false),
        learningProvider.overrideWith(() => learning),
        streakProvider.overrideWith(() => streak),
        sessionProvider.overrideWith(
          () => session ?? _MockSessionNotifier(_completedSession()),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  group('LessonResultsScreen', () {
    testWidgets('shows the XP snapshot from the CURRENT streak multiplier', (
      tester,
    ) async {
      // Racha 9 -> multiplicador 1.0 -> la lección vale +15 (no 17 del 1.1).
      await tester.pumpWidget(buildApp(prefs: prefs, log: []));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('+15'), findsOneWidget);
      expect(find.text('+17'), findsNothing);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets(
      'completes the lesson BEFORE the streak check-in so the awarded XP '
      'uses the same multiplier shown in the badge',
      (tester) async {
        final log = <String>[];
        await tester.pumpWidget(buildApp(prefs: prefs, log: log));
        await tester.pump();

        final l = AppLocalizations.of(
          tester.element(find.byType(LessonResultsScreen)),
        )!;
        await tester.tap(find.text(l.continueText));
        await tester.pumpAndSettle();

        // Sin crash de pop: se vuelve determinísticamente al mapa.
        expect(find.text('Mapa de lecciones'), findsOneWidget);
        expect(log, ['completeLesson', 'checkIn']);
        await tester.pump(const Duration(seconds: 5));
      },
    );
  });
}
