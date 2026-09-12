import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/screens/dashboard/dashboard_home_screen.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/ui/widgets/shimmer_loading.dart';
import 'package:sagen/ui/widgets/shimmer_scope.dart';

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

class _FakeDashboardNotifier extends DashboardNotifier {
  _FakeDashboardNotifier(this._state);

  final DashboardState _state;

  @override
  DashboardState build() => _state;
}

class _FakeLearningNotifier extends LearningNotifier {
  _FakeLearningNotifier(this._state);

  final LearningState _state;

  @override
  LearningState build() => _state;

  @override
  Future<void> reload() async {
    state = state.copyWith(
      errorMessage: () => 'Error cargando de nuevo el progreso.',
    );
  }
}

class _FakeGemNotifier extends GemNotifier {
  _FakeGemNotifier(this._state);

  final GemState _state;

  @override
  GemState build() => _state;
}

Lesson _lesson(String id, {String title = 'Leccion', bool completed = false}) {
  return Lesson(
    id: id,
    title: title,
    subtitle: 'Sub',
    challenges: const [],
    completed: completed,
    estimatedMinutes: 5,
  );
}

Stage _stage(
  String id,
  String title,
  List<Lesson> lessons, {
  bool unlocked = true,
}) {
  return Stage(
    id: id,
    title: title,
    subtitle: 'Sub $title',
    accent: const Color(0xFF3366CC),
    icon: Icons.shield_rounded,
    lessons: lessons,
    unlocked: unlocked,
  );
}

Lesson get _heroLesson => _lesson('l2', title: 'Introducción a la seguridad');

List<Stage> get _threeStages => [
  _stage('st1', 'Etapa 1', [_lesson('l1', completed: true)]),
  _stage('st2', 'Etapa 2', [_lesson('l2')]),
  _stage('st3', 'Etapa 3', [_lesson('l3')], unlocked: false),
];

GoRouter _router() {
  return GoRouter(
    initialLocation: '/dash',
    routes: [
      GoRoute(
        path: '/dash',
        name: 'dash',
        builder: (context, state) => const DashboardHomeScreen(),
      ),
      GoRoute(
        path: '/lessons',
        name: 'lessons',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LESSONS_SENTINEL'))),
      ),
      GoRoute(
        path: '/lesson-session/:stageId/:lessonId',
        name: 'lesson-session',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('LESSON_SENTINEL'))),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('MAIN_SENTINEL'))),
      ),
    ],
  );
}

Widget _wrap(List<Override> overrides, {GoRouter? router}) {
  final navigator = router != null
      ? MaterialApp.router(
          routerConfig: router,
          theme: ThemeData(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        )
      : MaterialApp(
          theme: ThemeData(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardHomeScreen(),
        );
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      ...overrides,
    ],
    child: navigator,
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

String _expectedGreeting(AppLocalizations l) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l.greetingMorning;
  if (hour < 18) return l.greetingAfternoon;
  return l.greetingEvening;
}

void main() {
  group('DashboardHomeScreen', () {
    testWidgets('cabecera y estado vacio con mascota curiosa', (tester) async {
      _setTallViewport(tester);
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            const DashboardState(
              displayName: 'Ana',
              currentStreak: 3,
              isLoading: false,
            ),
          ),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(
            const LearningState(
              stages: [],
              totalDonated: 12.0,
              isLoading: false,
            ),
          ),
        ),
        gemProvider.overrideWith(
          () => _FakeGemNotifier(const GemState(balance: 250)),
        ),
      ];
      await tester.pumpWidget(_wrap(overrides));
      await _settle(tester);

      final l = await AppLocalizations.delegate.load(const Locale('es'));
      expect(find.text(_expectedGreeting(l)), findsOneWidget);
      expect(find.text('Ana'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
      expect(find.text('Ruta de aprendizaje'), findsOneWidget);
      expect(find.text('No hay lecciones disponibles'), findsOneWidget);
      expect(find.byType(SageEmotionWidget), findsOneWidget);
    });

    testWidgets('shimmer mientras carga', (tester) async {
      _setTallViewport(tester);
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(const DashboardState(isLoading: true)),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(const LearningState(isLoading: true)),
        ),
        gemProvider.overrideWith(() => _FakeGemNotifier(const GemState())),
      ];
      await tester.pumpWidget(_wrap(overrides));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ShimmerScope), findsOneWidget);
      expect(find.byType(ShimmerLoading), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('estado de error con retry que recarga', (tester) async {
      _setTallViewport(tester);
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(const DashboardState(isLoading: false)),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(
            const LearningState(errorMessage: 'Error 500', isLoading: false),
          ),
        ),
        gemProvider.overrideWith(() => _FakeGemNotifier(const GemState())),
      ];
      await tester.pumpWidget(_wrap(overrides));
      await _settle(tester);

      expect(find.text('Error 500'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      await tester.tap(find.text('Conéctate e inténtalo nuevamente.'));
      await tester.pump();
      await tester.pump();
    });

    testWidgets('Lista de etapas con status y navegacion a lessons', (
      tester,
    ) async {
      _setTallViewport(tester);
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            const DashboardState(displayName: 'Ana', isLoading: false),
          ),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(
            LearningState(stages: _threeStages, isLoading: false),
          ),
        ),
        gemProvider.overrideWith(() => _FakeGemNotifier(const GemState())),
      ];
      final router = _router();
      await tester.pumpWidget(_wrap(overrides, router: router));
      await _settle(tester);

      expect(find.text('Etapa 1'), findsOneWidget);
      expect(find.text('Etapa 2'), findsOneWidget);
      expect(find.text('Etapa 3'), findsOneWidget);

      await tester.tap(find.text('Etapa 1'));
      await _settle(tester);
      expect(find.text('LESSONS_SENTINEL'), findsOneWidget);
    });

    testWidgets('hero con leccion disponible navega a lesson-session', (
      tester,
    ) async {
      _setTallViewport(tester);
      final hero = _heroLesson;
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            DashboardState(
              displayName: 'Ana',
              isLoading: false,
              nextLesson: hero,
              nextLessonStageTitle: 'Etapa 2',
            ),
          ),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(
            LearningState(stages: _threeStages, isLoading: false),
          ),
        ),
        gemProvider.overrideWith(() => _FakeGemNotifier(const GemState())),
      ];
      final router = _router();
      await tester.pumpWidget(_wrap(overrides, router: router));
      await _settle(tester);

      expect(find.text('Introducción a la seguridad'), findsOneWidget);
      expect(find.text('Seguir'), findsOneWidget);

      await tester.tap(find.text('Seguir'));
      await _settle(tester);
      expect(find.text('LESSON_SENTINEL'), findsOneWidget);
    });

    testWidgets('hero sin etapa encontrada no navega', (tester) async {
      _setTallViewport(tester);
      Lesson ghost(String title) => _lesson('ghost', title: title);
      final noStage = ghost('Leccion fantasma');
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            DashboardState(
              displayName: 'Ana',
              isLoading: false,
              nextLesson: noStage,
              nextLessonStageTitle: 'Etapa 9',
            ),
          ),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(
            LearningState(stages: _threeStages, isLoading: false),
          ),
        ),
        gemProvider.overrideWith(() => _FakeGemNotifier(const GemState())),
      ];
      final router = _router();
      await tester.pumpWidget(_wrap(overrides, router: router));
      await _settle(tester);

      await tester.tap(find.text('Seguir'));
      await _settle(tester);
      expect(find.text('Ruta de aprendizaje'), findsOneWidget);
      expect(find.text('LESSON_SENTINEL'), findsNothing);
      expect(find.text('LESSONS_SENTINEL'), findsNothing);
      expect(find.text('MAIN_SENTINEL'), findsNothing);
    });

    testWidgets('hero sin siguiente leccion navega a main', (tester) async {
      _setTallViewport(tester);
      final overrides = [
        dashboardProvider.overrideWith(
          () => _FakeDashboardNotifier(
            const DashboardState(displayName: 'Ana', isLoading: false),
          ),
        ),
        learningProvider.overrideWith(
          () => _FakeLearningNotifier(
            LearningState(stages: _threeStages, isLoading: false),
          ),
        ),
        gemProvider.overrideWith(() => _FakeGemNotifier(const GemState())),
      ];
      final router = _router();
      await tester.pumpWidget(_wrap(overrides, router: router));
      await _settle(tester);

      expect(find.text('¡Todo completo!'), findsOneWidget);

      await tester.tap(find.text('Ver logros'));
      await _settle(tester);
      expect(find.text('MAIN_SENTINEL'), findsOneWidget);
    });
  });
}
