import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/lesson/lesson_session_screen.dart';

class _MockLearningNotifier extends LearningNotifier {
  _MockLearningNotifier(this._state);

  final LearningState _state;

  @override
  LearningState build() => _state;
}

/// Notifier controlado: permite arrancar en cualquier fase y reaccionar a las
/// mutaciones de la UI sin arrastrar bancos de preguntas reales.
class _ControlledSessionNotifier extends SessionNotifier {
  _ControlledSessionNotifier(this._initial);

  SessionState _initial;
  bool offerResume = false;
  final List<String> log = [];

  @override
  SessionState build() => _initial;

  void emit(SessionState next) {
    _initial = next;
    state = next;
  }

  @override
  Future<void> startSession(
    String stageId,
    String lessonId, {
    int count = 15,
    bool resume = false,
  }) async {
    log.add('startSession$resume');
  }

  @override
  Future<bool> hasResumableProgress(String stageId, String lessonId) async {
    log.add('hasResumableProgress');
    return offerResume;
  }

  @override
  Future<void> discardResume(String stageId, String lessonId) async {
    log.add('discardResume');
    offerResume = false;
  }
}

Challenge _challenge({int id = 0}) {
  return Challenge(
    id: 'ch_$id',
    lessonId: 'ac_s1_ses1_l1',
    question: '¿Qué es la ingeniería social?',
    type: LessonType.multipleChoice,
    options: ['Opc. A', 'Opc. B', 'Opc. C', 'Opc. D'],
    correctIndex: 2,
    explanation: 'La ingeniería social manipula a las personas.',
  );
}

Widget _buildApp({required SessionNotifier session, SharedPreferences? prefs}) {
  final router = GoRouter(
    initialLocation: '/lesson/ac_st1/ac_s1_ses1_l1',
    routes: [
      GoRoute(
        path: '/',
        name: 'lessons',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('MAP_CHILD'))),
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
      GoRoute(
        path: '/lesson/:stageId/:lessonId/results',
        name: 'lesson-results',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('RESULTS_CHILD'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      sessionProvider.overrideWith(() => session),
      if (prefs != null) prefsProvider.overrideWithValue(prefs),
      learningProvider.overrideWith(
        () => _MockLearningNotifier(
          LearningState(
            isLoading: false,
            stages: [
              Stage(
                id: 'ac_st1',
                title: 'Fundamentos',
                subtitle: '',
                accent: Colors.blue,
                icon: Icons.shield_rounded,
                unlocked: true,
                lessons: [],
              ),
            ],
          ),
        ),
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

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('LessonSessionScreen flujo completo', () {
    testWidgets('fase gameOver muestra overlay con reintentar y volver', (
      tester,
    ) async {
      final session = _ControlledSessionNotifier(
        const SessionState(
          currentChallenge: null,
          challenges: [],
          currentIndex: 0,
          lives: 0,
          correctCount: 3,
          wrongCount: 2,
          totalQuestions: 5,
          phase: SessionPhase.gameOver,
        ),
      );
      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Vidas agotadas'), findsOneWidget);
      expect(find.text('Vuelve a intentarlo'), findsNothing);
      expect(find.text('3/5 correctas'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.text('Volver al mapa'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(session.log, contains('startSessionfalse'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fase feedback correcto muestra acierto y Siguiente avanza', (
      tester,
    ) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          correctCount: 1,
          wrongCount: 0,
          totalQuestions: 1,
          feedbackSelected: 2,
          feedbackCorrect: true,
          phase: SessionPhase.feedback,
        ),
      );
      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('¡Correcto!'), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      expect(find.text('Selecciona una respuesta'), findsNothing);

      // onFeedbackDismissed + nextQuestion -> completed -> navega a resultados.
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('RESULTS_CHILD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fase feedback incorrecto muestra la respuesta correcta', (
      tester,
    ) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          correctCount: 0,
          wrongCount: 1,
          totalQuestions: 1,
          feedbackSelected: 0,
          feedbackCorrect: false,
          phase: SessionPhase.feedback,
        ),
      );
      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('Incorrecto'), findsOneWidget);
      expect(find.text('Respuesta correcta: Opc. C'), findsOneWidget);
      expect(
        find.text('La ingeniería social manipula a las personas.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('responder una opción envía submitAnswer con el tópico', (
      tester,
    ) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          correctCount: 0,
          wrongCount: 0,
          totalQuestions: 1,
          phase: SessionPhase.playing,
        ),
      );

      final spy = _SpySubscribeNotifier(session);

      await tester.pumpWidget(_buildApp(session: spy, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('¿Qué es la ingeniería social?'), findsOneWidget);
      await tester.tap(find.text('Opc. B'));
      await tester.pumpAndSettle();

      expect(spy.log, contains('submit:1'));
      expect(spy.state.phase, SessionPhase.feedback);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ofrece resume y continuar reanuda la sesión', (tester) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          totalQuestions: 3,
          phase: SessionPhase.playing,
        ),
      );
      session.offerResume = true;

      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('¿Reanudar cuestionario?'), findsOneWidget);
      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(session.log, contains('hasResumableProgress'));
      expect(session.log, contains('startSessiontrue'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('ofrece resume y empezar de nuevo descarta el progreso', (
      tester,
    ) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          totalQuestions: 3,
          phase: SessionPhase.playing,
        ),
      );
      session.offerResume = true;

      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('¿Reanudar cuestionario?'), findsOneWidget);
      await tester.tap(find.text('Empezar de nuevo'));
      await tester.pumpAndSettle();

      expect(session.log, contains('discardResume'));
      expect(session.log, contains('startSessionfalse'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin resume no muestra el diálogo de reanudar', (tester) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          totalQuestions: 3,
          phase: SessionPhase.playing,
        ),
      );

      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      expect(find.text('¿Reanudar cuestionario?'), findsNothing);
      expect(find.text('¿Qué es la ingeniería social?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('descartar la sesión con la X muestra el diálogo de salida', (
      tester,
    ) async {
      final ch = _challenge();
      final session = _ControlledSessionNotifier(
        SessionState(
          currentChallenge: ch,
          challenges: [ch],
          currentIndex: 0,
          lives: 3,
          totalQuestions: 1,
          phase: SessionPhase.playing,
        ),
      );
      await tester.pumpWidget(_buildApp(session: session, prefs: prefs));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text('¿Seguro que quieres salir del cuestionario?'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Salir'));
      await tester.pumpAndSettle();
      expect(find.text('MAP_CHILD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Envuelve un notifier controlado para interceptar submitAnswer: registra el
/// índice elegido (en [log] heredado) y aplica la transición real a feedback
/// (igual que el notifier de producción) sin depender de services externos.
class _SpySubscribeNotifier extends _ControlledSessionNotifier {
  _SpySubscribeNotifier(SuperControlledSession session)
    : super(session._initial);

  @override
  void submitAnswer(int selectedIndex, {String? topicForReview}) {
    log.add('submit:$selectedIndex');
    final ch = state.currentChallenge!;
    final correct = selectedIndex == ch.effectiveCorrectIndex;
    final newLives = correct
        ? state.lives
        : (state.lives > 0 ? state.lives - 1 : 0);
    emit(
      state.copyWith(
        feedbackSelected: selectedIndex,
        feedbackCorrect: correct,
        correctCount: correct ? state.correctCount + 1 : state.correctCount,
        wrongCount: correct ? state.wrongCount : state.wrongCount + 1,
        lives: newLives,
        phase: SessionPhase.feedback,
      ),
    );
  }
}

typedef SuperControlledSession = _ControlledSessionNotifier;
