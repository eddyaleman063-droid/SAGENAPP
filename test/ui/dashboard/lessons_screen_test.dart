import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/dashboard/lessons_screen.dart';
import 'package:sagen/ui/screens/lesson/lesson_session_screen.dart';
import 'package:sagen/ui/widgets/shimmer_loading.dart';

class _MockSessionNotifier extends SessionNotifier {
  _MockSessionNotifier();

  String? lastStageId;
  String? lastLessonId;

  @override
  SessionState build() => const SessionState();

  @override
  Future<void> startSession(
    String stageId,
    String lessonId, {
    int count = 5,
    bool resume = false,
  }) async {
    lastStageId = stageId;
    lastLessonId = lessonId;
  }
}

class _MockLearningNotifier extends LearningNotifier {
  _MockLearningNotifier(this._state);

  final LearningState _state;

  @override
  LearningState build() => _state;
}

class _MockReviewNotifier extends ReviewNotifier {
  _MockReviewNotifier(this._state);

  final ReviewState _state;

  @override
  ReviewState build() => _state;
}

List<Stage> _createTestStages() => [
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
      Lesson(
        id: 'lesson_1_2',
        title: 'Contraseñas seguras',
        subtitle: 'Protege tus cuentas',
        challenges: const [],
        estimatedMinutes: 10,
      ),
    ],
  ),
  Stage(
    id: 'ac_st2',
    title: 'Nivel Avanzado',
    subtitle: 'Contenido avanzado',
    accent: Colors.green,
    icon: Icons.shield_rounded,
    unlocked: false,
    lessons: [
      Lesson(
        id: 'lesson_2_1',
        title: 'Phishing',
        subtitle: 'Identifica estafas',
        challenges: const [],
        estimatedMinutes: 8,
      ),
    ],
  ),
];

Widget createTestApp({
  required SharedPreferences prefs,
  required LearningNotifier learning,
  SessionNotifier? session,
  ReviewNotifier? review,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'lessons',
        builder: (context, state) => const LessonsScreen(),
      ),
      GoRoute(
        path: '/learning/:stageId/:lessonId',
        name: 'lesson-session',
        builder: (context, state) => LessonSessionScreen(
          stageId: state.pathParameters['stageId']!,
          lessonId: state.pathParameters['lessonId']!,
          lessonTitle: '',
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      learningProvider.overrideWith(() => learning),
      sessionProvider.overrideWith(() => session ?? _MockSessionNotifier()),
      reviewProvider.overrideWith(
        () => review ?? _MockReviewNotifier(const ReviewState()),
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
  group('LessonsScreen', () {
    testWidgets('renders screen title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        LearningState(isLoading: false, stages: _createTestStages()),
      );

      await tester.pumpWidget(createTestApp(prefs: prefs, learning: learning));
      await tester.pumpAndSettle();

      expect(find.text('Tu ruta de aprendizaje'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders stage titles from provider data', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        LearningState(isLoading: false, stages: _createTestStages()),
      );

      await tester.pumpWidget(createTestApp(prefs: prefs, learning: learning));
      await tester.pumpAndSettle();

      expect(find.text('Fundamentos'), findsOneWidget);
      expect(find.text('Nivel Avanzado'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('shows lesson titles within stages', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        LearningState(isLoading: false, stages: _createTestStages()),
      );

      await tester.pumpWidget(createTestApp(prefs: prefs, learning: learning));
      await tester.pumpAndSettle();

      expect(find.text('Introducción a la seguridad'), findsOneWidget);
      expect(find.text('Contraseñas seguras'), findsOneWidget);
      expect(find.text('Phishing'), findsNothing);
      await tester.pumpAndSettle();
    });

    testWidgets('shows shimmer loading state initially', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        const LearningState(isLoading: true),
      );

      await tester.pumpWidget(createTestApp(prefs: prefs, learning: learning));
      await tester.pump();

      expect(find.byType(ShimmerLoading), findsWidgets);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('shows empty state when no stages', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        const LearningState(isLoading: false),
      );

      await tester.pumpWidget(createTestApp(prefs: prefs, learning: learning));
      await tester.pump();

      expect(find.text('No hay lecciones disponibles'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('tapping lesson starts session and navigates', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async => null,
          );

      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        LearningState(isLoading: false, stages: _createTestStages()),
      );
      final session = _MockSessionNotifier();

      await tester.pumpWidget(
        createTestApp(prefs: prefs, learning: learning, session: session),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Introducción a la seguridad'));
      await tester.pumpAndSettle();

      expect(session.lastStageId, 'ac_st1');
      expect(session.lastLessonId, 'lesson_1_1');
      await tester.pumpAndSettle();
    });

    testWidgets('shows review card when reviewable questions exist', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        LearningState(isLoading: false, stages: _createTestStages()),
      );
      final review = _MockReviewNotifier(
        const ReviewState(questionFailures: {'q1': 1}),
      );

      await tester.pumpWidget(
        createTestApp(prefs: prefs, learning: learning, review: review),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repaso inteligente'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('hides review card when no reviewable questions exist', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final learning = _MockLearningNotifier(
        LearningState(isLoading: false, stages: _createTestStages()),
      );
      final review = _MockReviewNotifier(const ReviewState());

      await tester.pumpWidget(
        createTestApp(prefs: prefs, learning: learning, review: review),
      );
      await tester.pumpAndSettle();

      expect(find.text('Repaso inteligente'), findsNothing);
      await tester.pumpAndSettle();
    });
  });
}
