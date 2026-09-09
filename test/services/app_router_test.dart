import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StaticAuthNotifier extends AuthNotifier {
  _StaticAuthNotifier(this._initial);

  final AuthState _initial;

  @override
  AuthState build() => _initial;
}

Future<ProviderContainer> _container({AuthState? authState}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final overrides = <Override>[
    prefsProvider.overrideWithValue(prefs),
    if (authState != null)
      authProvider.overrideWith(() => _StaticAuthNotifier(authState)),
  ];
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final router = container.read(routerProvider);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ),
  );
  await tester.pump();
  return router;
}

Future<void> _navigate(
  WidgetTester tester,
  GoRouter router,
  String path,
  String expected,
) async {
  router.go(path);
  await tester.pump();
  expect(router.state.matchedLocation, expected);
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  group('AppRouter', () {
    late ProviderContainer container;

    setUp(() async {
      container = await _container();
    });

    tearDown(() {
      container.dispose();
    });

    test('routerProvider creates a valid GoRouter', () {
      final router = container.read(routerProvider);
      expect(router, isNotNull);
    });

    test('routerProvider returns same instance on repeated reads', () {
      final router1 = container.read(routerProvider);
      final router2 = container.read(routerProvider);
      expect(router1, same(router2));
    });
  });

  group('AppRouter redirect', () {
    testWidgets('unauth user landing on gated route is sent to /welcome', (
      tester,
    ) async {
      final container = await _container(
        authState: const AuthState(status: AuthStatus.unauthenticated),
      );
      final router = await _pumpRouter(tester, container);
      await _navigate(tester, router, '/lessons', '/welcome');
    });

    testWidgets('loading state forces splash for gated routes', (tester) async {
      final container = await _container(
        authState: const AuthState(status: AuthStatus.loading),
      );
      final router = await _pumpRouter(tester, container);
      await _navigate(tester, router, '/lessons', '/');
    });

    testWidgets('loading state keeps onboarding routes', (tester) async {
      final container = await _container(
        authState: const AuthState(status: AuthStatus.loading),
      );
      final router = await _pumpRouter(tester, container);
      await _navigate(tester, router, '/onboarding', '/onboarding');
    });

    testWidgets('pending verification in auth routes goes to verify-email', (
      tester,
    ) async {
      final container = await _container(
        authState: const AuthState(
          status: AuthStatus.unauthenticated,
          uid: 'u1',
          pendingVerification: true,
        ),
      );
      final router = await _pumpRouter(tester, container);
      await _navigate(tester, router, '/login', '/verify-email');
    });

    testWidgets('verified unauth user in public route stays', (tester) async {
      final container = await _container(
        authState: const AuthState(
          status: AuthStatus.unauthenticated,
          uid: 'u1',
        ),
      );
      final router = await _pumpRouter(tester, container);
      await _navigate(tester, router, '/welcome', '/welcome');
    });

    testWidgets('authenticated with profile not loaded gates app screens', (
      tester,
    ) async {
      final container = await _container(
        authState: const AuthState(
          status: AuthStatus.authenticated,
          uid: 'u1',
          profileLoaded: false,
        ),
      );
      final router = await _pumpRouter(tester, container);
      await _navigate(tester, router, '/main', '/');
    });
  });
}
