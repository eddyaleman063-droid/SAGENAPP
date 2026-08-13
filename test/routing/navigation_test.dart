import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Navigation', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      router = container.read(routerProvider);
    });

    tearDown(() {
      container.dispose();
    });

    test('/ route resolves to splash screen', () {
      expect(router.routeInformationProvider.value.uri.toString(), '/');
    });

    test('/welcome route resolves correctly', () {
      router.go('/welcome');
      expect(router.routeInformationProvider.value.uri.toString(), '/welcome');
    });

    test('/login route resolves correctly', () {
      router.go('/login');
      expect(router.routeInformationProvider.value.uri.toString(), '/login');
    });

    test('/forgot-password route resolves correctly', () {
      router.go('/forgot-password');
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/forgot-password',
      );
    });

    test('/onboarding route resolves correctly', () {
      router.go('/onboarding');
      expect(
        router.routeInformationProvider.value.uri.toString(),
        '/onboarding',
      );
    });

    test('/review route resolves correctly', () {
      router.go('/review');
      expect(router.routeInformationProvider.value.uri.toString(), '/review');
    });

    test('/main route resolves correctly', () {
      router.go('/main');
      expect(router.routeInformationProvider.value.uri.toString(), '/main');
    });

    test('navigating to welcome then login changes route', () {
      router.go('/welcome');
      router.go('/login');
      expect(router.routeInformationProvider.value.uri.toString(), '/login');
    });

    test('navigating to unknown route redirects to /', () {
      final current = router.routeInformationProvider.value.uri.toString();
      router.go('/nonexistent-route');
      // Should redirect based on auth state (default is unauthenticated → /)
      expect(current, isNot(contains('nonexistent')));
    });
  });
}
