import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/screens/onboarding/motivation_screen.dart';
import 'package:sagen/ui/screens/onboarding/post_onboarding_flow.dart';
import 'package:sagen/ui/screens/onboarding/post_onboarding_welcome_screen.dart';
import 'package:sagen/ui/screens/onboarding/projection_screen.dart';
import 'package:sagen/ui/screens/onboarding/route_selection_screen.dart';
import 'package:sagen/ui/screens/onboarding/starting_point_screen.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoPrecacheSageEmotionService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState();
}

class _SeededWizardBridge extends WizardBridge {
  final Map<int, dynamic> data;
  _SeededWizardBridge(this.data);

  @override
  Map<int, dynamic> build() => Map<int, dynamic>.from(data);
}

SageEmotion _mascotEmotion(WidgetTester tester) {
  return tester
      .widget<SageEmotionWidget>(find.byType(SageEmotionWidget))
      .emotion;
}

void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

Widget _wrapWithRouter(Widget child, {List<Override> overrides = const []}) {
  final router = GoRouter(
    initialLocation: '/onboarding/flow',
    routes: [
      GoRoute(
        path: '/onboarding/flow',
        name: 'onboarding-flow',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('MAIN_SENTINEL'))),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(
        _NoPrecacheSageEmotionService(),
      ),
      ...overrides,
    ],
    child: MaterialApp.router(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Future<void> _step(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  group('PostOnboardingWelcomeScreen', () {
    testWidgets('renderiza mensaje, boton y mascota', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(_wrap(const PostOnboardingWelcomeScreen()));
      await _step(tester);

      expect(
        find.text(
          '¡Hola! Soy Sagen. Estoy aquí para entrenarte, proteger tu '
          'entorno digital y hacerte un experto.',
        ),
        findsOneWidget,
      );
      expect(find.text('Continuar'), findsOneWidget);
      expect(_mascotEmotion(tester), SageEmotion.excitedWave);
      await _settle(tester);
    });

    testWidgets('continuar invoca onContinue', (tester) async {
      _setTallViewport(tester);
      var continued = false;
      await tester.pumpWidget(
        _wrap(PostOnboardingWelcomeScreen(onContinue: () => continued = true)),
      );
      await _step(tester);

      await tester.tap(find.text('Continuar'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(continued, isTrue);
      await _settle(tester);
    });

    testWidgets('atras invoca onBack', (tester) async {
      _setTallViewport(tester);
      var wentBack = false;
      await tester.pumpWidget(
        _wrap(PostOnboardingWelcomeScreen(onBack: () => wentBack = true)),
      );
      await _step(tester);

      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(wentBack, isTrue);
      await _settle(tester);
    });
  });

  group('PostOnboardingFlow', () {
    testWidgets('camina pasos 0-4 y vuelve atras', (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(_wrap(const PostOnboardingFlow()));
      await _step(tester);

      expect(find.byType(PostOnboardingWelcomeScreen), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.tap(find.text('Continuar'));
      await _step(tester);
      expect(find.byType(RouteSelectionScreen), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);

      await tester.tap(find.text('Fundamentos primero'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continuar'));
      await _step(tester);
      expect(find.byType(MotivationScreen), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('motivation_0')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Continuar'));
      await _step(tester);
      expect(find.byType(ProjectionScreen), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await _step(tester);
      expect(find.byType(StartingPointScreen), findsOneWidget);

      await tester.tap(find.text('Empieza desde cero y forja tu escudo'));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byTooltip('Atrás'));
      await _step(tester);
      expect(find.byType(ProjectionScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Atrás'));
      await _step(tester);
      expect(find.byType(MotivationScreen), findsOneWidget);

      await tester.tap(find.byTooltip('Atrás'));
      await _step(tester);
      expect(find.byType(RouteSelectionScreen), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      await _settle(tester);
    });

    testWidgets('atras en el primer paso lleva a main en modo demo', (
      tester,
    ) async {
      _setTallViewport(tester);
      await tester.pumpWidget(
        _wrapWithRouter(
          const PostOnboardingFlow(),
          overrides: [authProvider.overrideWith(() => _FakeAuthNotifier())],
        ),
      );
      await _step(tester);

      await tester.tap(find.byTooltip('Atrás'));
      await _step(tester);

      expect(find.text('MAIN_SENTINEL'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.text('MAIN_SENTINEL')),
      );
      expect(container.read(authProvider).status, AuthStatus.demo);
      expect(container.read(registrationFunnelProvider).isGuest, isTrue);
      await _settle(tester);
    });

    testWidgets('puentea datos del wizard al flow', (tester) async {
      _setTallViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        _wrap(
          const PostOnboardingFlow(),
          overrides: [
            wizardBridgeProvider.overrideWith(
              () => _SeededWizardBridge({
                2: '3',
                6: '10',
                1: 'amigo',
                3: ['a', 'b'],
                4: 'libros',
                5: 'visual',
                7: 'total',
              }),
            ),
            prefsProvider.overrideWithValue(prefs),
          ],
        ),
      );
      await tester.pump();
      await _step(tester);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(PostOnboardingFlow)),
      );
      expect(container.read(assessmentLevelProvider), 2);
      expect(container.read(dashboardProvider).dailyGoalMinutes, 10);
      expect(container.read(wizardBridgeProvider), isEmpty);
      await _settle(tester);
    });
  });
}
