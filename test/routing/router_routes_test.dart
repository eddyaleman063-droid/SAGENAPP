import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/router/app_router.dart';
import 'package:sagen/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StaticAuthNotifier extends AuthNotifier {
  _StaticAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;
}

class _StaticGemNotifier extends GemNotifier {
  final _gems = StreamController<int>.broadcast();
  final _milestones = StreamController<int>.broadcast();
  final _caps = StreamController<void>.broadcast();

  @override
  Stream<int> get onGemsEarned => _gems.stream;

  @override
  Stream<int> get onGemMilestone => _milestones.stream;

  @override
  Stream<void> get onCapWarning => _caps.stream;

  @override
  GemState build() => const GemState();
}

class _StaticStreakNotifier extends StreakNotifier {
  @override
  StreakState build() => const StreakState(
    status: StreakStatus(
      currentStreak: 3,
      longestStreak: 5,
      streakFreezes: 1,
      isAtRisk: false,
      message: 'ok',
      tier: 'bronze',
    ),
    totalCheckIns: 10,
    perfectWeeks: 1,
    missionCompleted: false,
    weeklyStats: {},
    heatmapData: {},
    monthlyData: {},
    streakHistory: [],
    emotionalMessages: [],
  );
}

Future<ProviderContainer> _container({required AuthState auth}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      authProvider.overrideWith(() => _StaticAuthNotifier(auth)),
      gemProvider.overrideWith(() => _StaticGemNotifier()),
      streakProvider.overrideWith(() => _StaticStreakNotifier()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester,
  ProviderContainer container, {
  required String initialLocation,
}) async {
  final router = buildAppRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: initialLocation,
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  return router;
}

Future<void> _go(WidgetTester tester, GoRouter router, String path) async {
  router.go(path);
  await tester.pump();
  await tester.pump(const Duration(seconds: 6));
  expect(router.state.matchedLocation, path);
}

Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  const authedOnboard = AuthState(
    status: AuthStatus.authenticated,
    uid: 'u1',
    profileLoaded: true,
    onboardingCompleted: true,
  );

  group('AppRouter routes (authenticated) build', () {
    testWidgets('privacy-policy se construye', (tester) async {
      final container = await _container(auth: authedOnboard);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/privacy-policy',
      );
      expect(find.byType(Text), findsWidgets);
      expect(router.state.matchedLocation, '/privacy-policy');
      await _finish(tester);
    });

    testWidgets('mini-games hub se construye', (tester) async {
      final container = await _container(auth: authedOnboard);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/mini-games',
      );
      expect(router.state.matchedLocation, '/mini-games');
      await _finish(tester);
    });

    testWidgets('mini-game memoryFlip se construye', (tester) async {
      final container = await _container(auth: authedOnboard);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/mini-game/memoryFlip',
      );
      expect(router.state.matchedLocation, '/mini-game/memoryFlip');
      await _finish(tester);
    });

    testWidgets('review-summary sin resultado muestra el fallback', (
      tester,
    ) async {
      final container = await _container(auth: authedOnboard);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/review-summary',
      );
      expect(find.text('BACK'), findsOneWidget);
      expect(router.state.matchedLocation, '/review-summary');
      await _finish(tester);
    });

    testWidgets('gem-history se construye', (tester) async {
      final container = await _container(auth: authedOnboard);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/gem-history',
      );
      await _go(tester, router, '/streak');
      expect(router.state.matchedLocation, '/streak');
      await _finish(tester);
    });

    testWidgets('payment success con amount', (tester) async {
      final container = await _container(auth: authedOnboard);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/payment/success?amount=12.5',
      );
      expect(router.state.matchedLocation, '/payment/success');
      await _finish(tester);
    });

    testWidgets('errorBuilder captura rutas no encontradas', (tester) async {
      final container = await _container(auth: authedOnboard);
      await _pumpRouter(tester, container, initialLocation: '/does-not-exist');
      await tester.pump(const Duration(seconds: 6));
      expect(find.text('404'), findsOneWidget);
      await _finish(tester);
    });
  });

  group('AppRouter public routes (unauth) build', () {
    const unauth = AuthState(status: AuthStatus.unauthenticated);

    testWidgets('welcome, login, forgot-password', (tester) async {
      final container = await _container(auth: unauth);
      final router = await _pumpRouter(
        tester,
        container,
        initialLocation: '/welcome',
      );
      for (final path in ['/login', '/forgot-password']) {
        await _go(tester, router, path);
      }
      await _finish(tester);
    });
  });
}
