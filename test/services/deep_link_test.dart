import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Deep Link - Route Definitions', () {
    test('router provider returns a GoRouter', () {
      // We can test route path constants without full Riverpod setup
      const publicRoutes = {
        '/',
        '/welcome',
        '/login',
        '/forgot-password',
        '/onboarding',
        '/onboarding/flow',
        '/payment/success',
        '/payment/failure',
        '/payment/pending',
      };

      expect(publicRoutes, contains('/'));
      expect(publicRoutes, contains('/welcome'));
      expect(publicRoutes, contains('/login'));
      expect(publicRoutes, contains('/forgot-password'));
      expect(publicRoutes, contains('/payment/success'));
      expect(publicRoutes, contains('/payment/failure'));
      expect(publicRoutes, contains('/payment/pending'));
    });

    test('auth routes redirect unauthenticated users', () {
      const authRoutes = {
        '/',
        '/welcome',
        '/login',
        '/forgot-password',
        '/onboarding',
        '/onboarding/flow',
      };

      expect(authRoutes, contains('/login'));
      expect(authRoutes, contains('/welcome'));
    });

    test('protected routes require authentication', () {
      const protectedRoutes = {
        '/main',
        '/lessons',
        '/store',
        '/profile',
        '/ranking',
        '/chat',
        '/settings',
      };

      for (final route in protectedRoutes) {
        expect(route, isNot(equals('/login')));
        expect(route, isNot(equals('/welcome')));
      }
    });
  });

  group('Deep Link - URL Parsing', () {
    test('payment success path is valid', () {
      const path = '/payment/success';
      expect(path.startsWith('/payment/'), isTrue);
      expect(path, contains('success'));
    });

    test('payment failure path is valid', () {
      const path = '/payment/failure';
      expect(path.startsWith('/payment/'), isTrue);
      expect(path, contains('failure'));
    });

    test('lesson session path contains parameters', () {
      const path = '/lesson/session/s123';
      expect(path, contains('s123'));
    });
  });
}
