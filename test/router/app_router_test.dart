import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/auth_provider.dart';
import 'package:sagen/router/app_router.dart';

void main() {
  AuthState auth({
    AuthStatus status = AuthStatus.uninitialized,
    String? uid,
    bool pendingVerification = false,
    bool onboardingCompleted = false,
    bool profileLoaded = false,
  }) {
    return AuthState(
      status: status,
      uid: uid,
      pendingVerification: pendingVerification,
      onboardingCompleted: onboardingCompleted,
      profileLoaded: profileLoaded,
    );
  }

  group('resolveRedirect Â· Phase 1 (loading/uninitialized)', () {
    test('loading en routes permitidas no redirige', () {
      expect(resolveRedirect(auth(status: AuthStatus.loading), '/'), isNull);
      expect(
        resolveRedirect(auth(status: AuthStatus.loading), '/onboarding'),
        isNull,
      );
      expect(
        resolveRedirect(auth(status: AuthStatus.loading), '/onboarding/flow'),
        isNull,
      );
    });

    test('loading fuerza splash en el resto', () {
      expect(resolveRedirect(auth(status: AuthStatus.loading), '/main'), '/');
      expect(
        resolveRedirect(auth(status: AuthStatus.loading), '/welcome'),
        '/',
      );
      expect(resolveRedirect(auth(status: AuthStatus.loading), '/login'), '/');
    });

    test('uninitialized tambien fuerza splash', () {
      expect(
        resolveRedirect(auth(status: AuthStatus.uninitialized), '/main'),
        '/',
      );
      expect(
        resolveRedirect(auth(status: AuthStatus.uninitialized), '/'),
        isNull,
      );
    });
  });

  group('resolveRedirect Â· Phase 2 (not authenticated)', () {
    test('sin pendingVerification: raiz va a /welcome', () {
      expect(
        resolveRedirect(auth(status: AuthStatus.unauthenticated), '/'),
        '/welcome',
      );
    });

    test('rutas publicas se permiten', () {
      for (final route in [
        '/welcome',
        '/login',
        '/forgot-password',
        '/onboarding',
        '/onboarding/flow',
        '/payment/success',
        '/payment/failure',
        '/payment/pending',
      ]) {
        expect(
          resolveRedirect(auth(status: AuthStatus.unauthenticated), route),
          isNull,
          reason: '$route deberia ser publica',
        );
      }
    });

    test('rutas privadas redirigen a /welcome', () {
      for (final route in [
        '/main',
        '/lessons',
        '/streak',
        '/pass',
        '/gem-history',
        '/mini-games',
        '/profile/u1',
        '/verify-email',
      ]) {
        expect(
          resolveRedirect(auth(status: AuthStatus.unauthenticated), route),
          '/welcome',
          reason: '$route no es publica',
        );
      }
    });

    test('pendingVerification con uid fuerza /verify-email', () {
      final v = auth(
        status: AuthStatus.unauthenticated,
        uid: 'u1',
        pendingVerification: true,
      );
      expect(resolveRedirect(v, '/main'), '/verify-email');
      expect(resolveRedirect(v, '/'), '/verify-email');
      expect(resolveRedirect(v, '/verify-email'), isNull);
      expect(resolveRedirect(v, '/login'), '/verify-email');
    });

    test('pendingVerification respeta las rutas de onboarding', () {
      final v = auth(
        status: AuthStatus.unauthenticated,
        uid: 'u1',
        pendingVerification: true,
      );
      expect(resolveRedirect(v, '/onboarding'), isNull);
      expect(resolveRedirect(v, '/onboarding/flow'), isNull);
    });
  });

  group('resolveRedirect Â· Phase 3 (authenticated)', () {
    test('sin profileLoaded: las gated routes van a splash', () {
      final a = auth(status: AuthStatus.authenticated, uid: 'u1');
      expect(resolveRedirect(a, '/main'), '/');
      expect(resolveRedirect(a, '/lessons'), '/');
      expect(resolveRedirect(a, '/profile/u1'), '/');
      expect(resolveRedirect(a, '/'), isNull);
      expect(resolveRedirect(a, '/login'), isNull);
      expect(resolveRedirect(a, '/welcome'), isNull);
    });

    test('preAuth routes: main si onboarding completo', () {
      final done = auth(
        status: AuthStatus.authenticated,
        uid: 'u1',
        profileLoaded: true,
        onboardingCompleted: true,
      );
      for (final route in [
        '/',
        '/welcome',
        '/login',
        '/forgot-password',
        '/verify-email',
        '/onboarding',
        '/onboarding/flow',
      ]) {
        expect(resolveRedirect(done, route), '/main', reason: route);
      }
    });

    test('preAuth routes: onboarding/flow si falta onboarding', () {
      final pending = auth(
        status: AuthStatus.authenticated,
        uid: 'u1',
        profileLoaded: true,
      );
      for (final route in ['/', '/login', '/verify-email']) {
        expect(resolveRedirect(pending, route), '/onboarding/flow');
      }
    });

    test('authenticated sin onboarding no alcanza rutas de app', () {
      final pending = auth(
        status: AuthStatus.authenticated,
        uid: 'u1',
        profileLoaded: true,
      );
      expect(resolveRedirect(pending, '/main'), '/onboarding/flow');
      expect(resolveRedirect(pending, '/lessons'), '/onboarding/flow');
      expect(resolveRedirect(pending, '/profile/u1'), '/onboarding/flow');
    });

    test('onboarding full: el resto queda como esta', () {
      final done = auth(
        status: AuthStatus.authenticated,
        uid: 'u1',
        profileLoaded: true,
        onboardingCompleted: true,
      );
      for (final route in [
        '/main',
        '/lessons',
        '/streak',
        '/pass',
        '/gem-history',
        '/mini-games',
        '/privacy-policy',
      ]) {
        expect(resolveRedirect(done, route), isNull, reason: route);
      }
    });

    test('demo cuenta como autenticado', () {
      final demo = auth(
        status: AuthStatus.demo,
        uid: 'demo1',
        profileLoaded: true,
        onboardingCompleted: true,
      );
      expect(resolveRedirect(demo, '/main'), isNull);
      expect(resolveRedirect(demo, '/'), '/main');
    });

    test('payment/success no es preAuth: no redirige con perfil completo', () {
      final done = auth(
        status: AuthStatus.authenticated,
        uid: 'u1',
        profileLoaded: true,
        onboardingCompleted: true,
      );
      expect(resolveRedirect(done, '/payment/success'), isNull);
    });
  });
}
