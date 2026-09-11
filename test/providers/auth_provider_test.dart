import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthService extends Mock implements AuthService {}

class MockFirebaseUser extends Mock implements firebase.User {}

class MockCloudSyncService extends Mock implements CloudSyncService {}

class FakeSharedPreferences extends Fake implements SharedPreferences {}

class FakeAppUser extends Fake implements AppUser {
  @override
  final String uid;
  @override
  final String displayName;
  @override
  final String email;
  @override
  final String? photoUrl;
  @override
  final bool isEmailVerified;

  FakeAppUser({
    this.uid = 'test-uid',
    this.displayName = 'Test User',
    this.email = 'test@example.com',
    this.photoUrl,
    this.isEmailVerified = true,
  });
}

void main() {
  late MockCloudSyncService mockCloudSync;

  setUpAll(() {
    registerFallbackValue(FakeAppUser());
    registerFallbackValue(FakeSharedPreferences());
  });

  setUp(() {
    mockCloudSync = MockCloudSyncService();
    when(
      () => mockCloudSync.startListening(any(), any()),
    ).thenAnswer((_) async {});
    when(() => mockCloudSync.stopListening()).thenReturn(null);
    when(
      () => mockCloudSync.saveAll(any(), any()),
    ).thenAnswer((_) async => true);
    when(() => mockCloudSync.clearLocal(any())).thenAnswer((_) async {});
    when(
      () => mockCloudSync.loadAll(any(), any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockCloudSync.deleteCloudData(any()),
    ).thenAnswer((_) async => true);
  });

  group('AuthState', () {
    test('initial state is uninitialized', () {
      const state = AuthState();
      expect(state.status, AuthStatus.uninitialized);
      expect(state.isAuthenticated, false);
      expect(state.displayName, '');
      expect(state.email, '');
      expect(state.uid, isNull);
      expect(state.pendingVerification, false);
    });

    test('copyWith updates only specified fields', () {
      const state = AuthState();
      final updated = state.copyWith(
        status: AuthStatus.authenticated,
        uid: () => 'test-uid',
        displayName: 'Test User',
      );
      expect(updated.status, AuthStatus.authenticated);
      expect(updated.uid, 'test-uid');
      expect(updated.displayName, 'Test User');
      expect(updated.email, '');
      expect(updated.pendingVerification, false);
    });

    test('isAuthenticated is true only for authenticated status', () {
      const unauthenticated = AuthState(status: AuthStatus.unauthenticated);
      const authenticated = AuthState(status: AuthStatus.authenticated);
      const loading = AuthState(status: AuthStatus.loading);
      const error = AuthState(status: AuthStatus.error);
      expect(unauthenticated.isAuthenticated, false);
      expect(authenticated.isAuthenticated, true);
      expect(loading.isAuthenticated, false);
      expect(error.isAuthenticated, false);
    });

    test('showVerificationScreen is true when pendingVerification', () {
      const pending = AuthState(pendingVerification: true);
      const notPending = AuthState();
      expect(pending.showVerificationScreen, true);
      expect(notPending.showVerificationScreen, false);
    });

    test('isLoading is true only for loading status', () {
      const loading = AuthState(status: AuthStatus.loading);
      const other = AuthState(status: AuthStatus.authenticated);
      expect(loading.isLoading, true);
      expect(other.isLoading, false);
    });

    test('isUninitialized is true only for uninitialized status', () {
      const uninitialized = AuthState(status: AuthStatus.uninitialized);
      const other = AuthState(status: AuthStatus.authenticated);
      expect(uninitialized.isUninitialized, true);
      expect(other.isUninitialized, false);
    });
  });

  group('AuthNotifier', () {
    late ProviderContainer container;
    late MockAuthService mockAuth;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      mockAuth = MockAuthService();
      when(() => mockAuth.currentUser).thenReturn(null);
      when(
        () => mockAuth.authStateChanges,
      ).thenAnswer((_) => const Stream.empty());
      container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWith((ref) => mockAuth),
          cloudSyncServiceProvider.overrideWithValue(mockCloudSync),
          prefsProvider.overrideWithValue(prefs),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial auth state has correct defaults', () {
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, false);
    });

    group('signInWithGoogle', () {
      test('sets loading then authenticated on success', () async {
        final fakeUser = FakeAppUser(uid: 'google-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenAnswer((_) async => fakeUser);

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithGoogle();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.uid, 'google-uid');
        expect(state.displayName, 'Test User');
        expect(state.email, 'test@example.com');
      });

      test('sets unauthenticated on canceled exception', () async {
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenThrow(const AuthException('canceled'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithGoogle();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
      });

      test('sets error state on non-canceled AuthException', () async {
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenThrow(const AuthException('network_error'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithGoogle();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'network_error');
      });

      test('sets error state on generic exception', () async {
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenThrow(Exception('network error'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithGoogle();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'unknown');
      });
    });

    group('signUpWithEmail', () {
      test('sets authenticated state on success', () async {
        final fakeUser = FakeAppUser(uid: 'new-uid', isEmailVerified: false);
        when(
          () => mockAuth.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenAnswer((_) async => fakeUser);

        final notifier = container.read(authProvider.notifier);
        await notifier.signUpWithEmail(
          displayName: 'New User',
          email: 'new@example.com',
          password: 'password123',
        );

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.pendingVerification, true);
        expect(state.uid, 'new-uid');
      });

      test('sets error state on AuthException', () async {
        when(
          () => mockAuth.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenThrow(const AuthException('email_in_use'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signUpWithEmail(
          displayName: 'New User',
          email: 'existing@example.com',
          password: 'password123',
        );

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'email_in_use');
      });
    });

    group('signInWithEmail', () {
      test('sets loading then authenticated on success', () async {
        final fakeUser = FakeAppUser(uid: 'email-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => fakeUser);

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmail(
          email: 'user@example.com',
          password: 'password123',
        );

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.uid, 'email-uid');
      });

      test('sets error on wrong password', () async {
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException('wrong_password'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmail(
          email: 'user@example.com',
          password: 'wrong',
        );

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'wrong_password');
      });

      test('sets unauthenticated when email not verified', () async {
        final fakeUser = FakeAppUser(
          uid: 'unverified-uid',
          isEmailVerified: false,
        );
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => fakeUser);

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithEmail(
          email: 'unverified@example.com',
          password: 'password123',
        );

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.pendingVerification, true);
      });
    });

    group('signOut', () {
      test('clears state and calls signOut on service', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        await notifier.signOut();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.uid, isNull);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('signs out even if service throws', () async {
        when(() => mockAuth.signOut()).thenThrow(Exception('network error'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signOut();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
      });

      test(
        'clears pending gem earns so next user cannot replay previous earns',
        () async {
          when(() => mockAuth.signOut()).thenAnswer((_) async {});
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('gems_pending_earn_queue', [
            'lesson|2026-09-03T00:00:00|{}|abc',
          ]);

          await container.read(authProvider.notifier).signOut();

          final remaining = prefs.getStringList('gems_pending_earn_queue');
          expect(remaining, isNull);
        },
      );

      test('clears per-user game state on sign out', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('gems_pending_earn_queue', [
          'lesson|2026-09-03T00:00:00|{}|abc',
        ]);
        await prefs.setInt('energy_current', 80);
        await prefs.setString('streak_history', '2026-09-01');

        await container.read(authProvider.notifier).signOut();

        expect(prefs.getInt('energy_current'), isNull);
        expect(prefs.getString('streak_history'), isNull);
        expect(prefs.getStringList('gems_pending_earn_queue'), isNull);
      });
    });

    group('sendPasswordResetEmail', () {
      test('sets unauthenticated on success', () async {
        when(
          () => mockAuth.sendPasswordResetEmail('user@example.com'),
        ).thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        await notifier.sendPasswordResetEmail('user@example.com');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
      });

      test('sets error on failure', () async {
        when(
          () => mockAuth.sendPasswordResetEmail('user@example.com'),
        ).thenThrow(const AuthException('not_found'));

        final notifier = container.read(authProvider.notifier);
        await notifier.sendPasswordResetEmail('user@example.com');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'not_found');
      });
    });

    group('clearError', () {
      test('clears error message', () async {
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenThrow(const AuthException('network_error'));

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithGoogle();
        expect(container.read(authProvider).errorMessage, 'network_error');

        notifier.clearError();
        expect(container.read(authProvider).errorMessage, isNull);
      });
    });

    group('getIdToken', () {
      test('returns token on success', () async {
        when(() => mockAuth.getIdToken()).thenAnswer((_) async => 'test-token');

        final notifier = container.read(authProvider.notifier);
        final token = await notifier.getIdToken();
        expect(token, 'test-token');
      });

      test('returns null on failure', () async {
        when(() => mockAuth.getIdToken()).thenThrow(Exception('error'));

        final notifier = container.read(authProvider.notifier);
        final token = await notifier.getIdToken();
        expect(token, isNull);
      });
    });

    group('checkEmailVerified', () {
      test('sets authenticated when verified', () async {
        when(() => mockAuth.reloadUser()).thenAnswer((_) async => true);
        // Tras verificar, el token se fuerza a reemitirse para refrescar el
        // claim email_verified; el test verifica que se pide con forceRefresh.
        when(
          () => mockAuth.getIdToken(
            forceRefresh: any(named: 'forceRefresh', that: isTrue),
          ),
        ).thenAnswer((_) async => 'fresh-token');

        final notifier = container.read(authProvider.notifier);
        await notifier.checkEmailVerified();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.pendingVerification, false);
        verify(() => mockAuth.getIdToken(forceRefresh: true)).called(1);
      });

      test('sets unauthenticated when not verified', () async {
        when(() => mockAuth.reloadUser()).thenAnswer((_) async => false);

        final notifier = container.read(authProvider.notifier);
        await notifier.checkEmailVerified();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.errorMessage, 'not_verified');
      });
    });

    group('authStateChanges stream', () {
      test('updates state when stream emits authenticated user', () async {
        final controller = StreamController<AppUser?>();
        when(
          () => mockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        container.dispose();
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final newMockAuth = MockAuthService();
        when(() => newMockAuth.currentUser).thenReturn(null);
        when(
          () => newMockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);
        container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWith((ref) => newMockAuth),
            cloudSyncServiceProvider.overrideWithValue(mockCloudSync),
            prefsProvider.overrideWithValue(prefs),
          ],
        );

        container.read(authProvider);
        await Future<void>.delayed(Duration.zero);

        controller.add(FakeAppUser(uid: 'stream-uid', isEmailVerified: true));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.uid, 'stream-uid');

        controller.close();
      });

      test('sets unauthenticated when stream emits null', () async {
        final controller = StreamController<AppUser?>();
        when(
          () => mockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        container.dispose();
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final newMockAuth = MockAuthService();
        when(() => newMockAuth.currentUser).thenReturn(null);
        when(
          () => newMockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);
        container = ProviderContainer(
          overrides: [
            authServiceProvider.overrideWith((ref) => newMockAuth),
            cloudSyncServiceProvider.overrideWithValue(mockCloudSync),
            prefsProvider.overrideWithValue(prefs),
          ],
        );

        controller.add(null);
        await Future<void>.delayed(Duration.zero);

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);

        controller.close();
      });

      test('onError del stream marca estado de error', () async {
        final controller = StreamController<AppUser?>();
        when(
          () => mockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        container.read(authProvider);
        await Future<void>.delayed(Duration.zero);

        controller.addError('stream boom');
        await Future<void>.delayed(Duration.zero);

        final state = container.read(authProvider);
        expect(state.errorMessage, 'Error in auth stream');

        controller.close();
      });

      test('transición authenticated -> null detiene el sync', () async {
        final controller = StreamController<AppUser?>();
        when(
          () => mockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        container.read(authProvider);
        await Future<void>.delayed(Duration.zero);

        controller.add(FakeAppUser(uid: 'sync-uid', isEmailVerified: true));
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(container.read(authProvider).status, AuthStatus.authenticated);

        controller.add(null);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
        verify(() => mockCloudSync.stopListening()).called(1);

        controller.close();
      });

      test('usuario sin verificar arranca el auto-check y verifica', () async {
        when(() => mockAuth.reloadUser()).thenAnswer((_) async => true);
        final controller = StreamController<AppUser?>();
        when(
          () => mockAuth.authStateChanges,
        ).thenAnswer((_) => controller.stream);

        container.read(authProvider);
        await Future<void>.delayed(Duration.zero);

        controller.add(FakeAppUser(uid: 'verify-uid', isEmailVerified: false));
        await Future<void>.delayed(Duration.zero);
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
        expect(container.read(authProvider).pendingVerification, true);

        await Future<void>.delayed(const Duration(seconds: 6));
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.pendingVerification, false);

        controller.close();
      });
    });

    group('signInWithFacebook', () {
      test('sets loading then authenticated on success', () async {
        final fakeUser = FakeAppUser(uid: 'fb-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithFacebook(),
        ).thenAnswer((_) async => fakeUser);

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithFacebook();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.uid, 'fb-uid');
        expect(state.displayName, 'Test User');
      });

      test('sets unauthenticated on canceled exception', () async {
        when(
          () => mockAuth.signInWithFacebook(),
        ).thenThrow(const AuthException('canceled'));

        await container.read(authProvider.notifier).signInWithFacebook();
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      });

      test('sets error state on non-canceled AuthException', () async {
        when(
          () => mockAuth.signInWithFacebook(),
        ).thenThrow(const AuthException('fb_network_error'));

        await container.read(authProvider.notifier).signInWithFacebook();
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'fb_network_error');
      });

      test('sets error state on generic exception', () async {
        when(() => mockAuth.signInWithFacebook()).thenThrow(Exception('boom'));

        await container.read(authProvider.notifier).signInWithFacebook();
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'unknown');
      });
    });

    group('rate limiting', () {
      test('bloquea segundo intento dentro del cooldown', () async {
        final fakeUser = FakeAppUser(uid: 'rl-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenAnswer((_) async => fakeUser);

        final notifier = container.read(authProvider.notifier);
        await notifier.signInWithGoogle();
        expect(container.read(authProvider).status, AuthStatus.authenticated);

        await notifier.signInWithGoogle();
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'rate_limited');
      });

      test('bloquea reintento tras errores consecutivos', () async {
        when(
          () => mockAuth.signInWithGoogle(),
        ).thenThrow(const AuthException('flaky'));

        final notifier = container.read(authProvider.notifier);
        for (var i = 0; i < 5; i++) {
          await notifier.signInWithGoogle();
          // Deja expirar el cooldown entre errores para poder acumularlos.
          await Future<void>.delayed(const Duration(seconds: 3));
        }
        expect(container.read(authProvider).status, AuthStatus.error);

        await notifier.signInWithGoogle();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'rate_limited');
      });
    });

    group('resendVerificationEmail', () {
      test('no cambia el estado en éxito', () async {
        when(() => mockAuth.sendEmailVerification()).thenAnswer((_) async {});

        final notifier = container.read(authProvider.notifier);
        await notifier.resendVerificationEmail();

        expect(container.read(authProvider).errorMessage, isNull);
      });

      test('marca errores ante AuthException y propaga', () async {
        when(
          () => mockAuth.sendEmailVerification(),
        ).thenThrow(const AuthException('too_many_requests'));

        final notifier = container.read(authProvider.notifier);
        await expectLater(
          notifier.resendVerificationEmail(),
          throwsA(isA<AuthException>()),
        );
        expect(container.read(authProvider).errorMessage, 'too_many_requests');
      });

      test('marca resend_error ante error genérico y propaga', () async {
        when(
          () => mockAuth.sendEmailVerification(),
        ).thenThrow(Exception('boom'));

        final notifier = container.read(authProvider.notifier);
        await expectLater(
          notifier.resendVerificationEmail(),
          throwsA(isA<Exception>()),
        );
        expect(container.read(authProvider).errorMessage, 'resend_error');
      });
    });

    group('reauthenticate', () {
      test('resultado null -> reauth_error', () async {
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenAnswer((_) async => null);

        final notifier = container.read(authProvider.notifier);
        await notifier.reauthenticate('a@b.com', 'pw');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'reauth_error');
      });

      test('AuthException propaga su código', () async {
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenThrow(const AuthException('wrong_password'));

        final notifier = container.read(authProvider.notifier);
        await notifier.reauthenticate('a@b.com', 'pw');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'wrong_password');
      });

      test('error genérico -> reauth_error', () async {
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenThrow(Exception('boom'));

        final notifier = container.read(authProvider.notifier);
        await notifier.reauthenticate('a@b.com', 'pw');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'reauth_error');
      });
    });

    group('deleteAccount', () {
      MockFirebaseUser fbUser = MockFirebaseUser();

      Future<void> signInFirst() async {
        final fakeUser = FakeAppUser(uid: 'del-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => fakeUser);
        await container
            .read(authProvider.notifier)
            .signInWithEmail(email: 'del@example.com', password: 'password123');
        expect(container.read(authProvider).uid, 'del-uid');
      }

      test('OAuth sin password elimina y resetea estado', () async {
        when(() => mockAuth.deleteAccount()).thenAnswer((_) async {});

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com');
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      });

      test('con password: reauth null -> reauth_required_for_delete', () async {
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenAnswer((_) async => null);

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com', password: 'pw');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'reauth_required_for_delete');
      });

      test('con password: reauth AuthException -> código', () async {
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenThrow(const AuthException('wrong_password'));

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com', password: 'pw');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'wrong_password');
      });

      test('con password: reauth genérico -> reauth_error', () async {
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenThrow(Exception('boom'));

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com', password: 'pw');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'reauth_error');
      });

      test('con password y reauth ok elimina con sync de datos', () async {
        await signInFirst();
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenAnswer((_) async => fbUser);
        when(() => mockAuth.deleteAccount()).thenAnswer((_) async {});

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com', password: 'pw');
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
        verify(() => mockCloudSync.deleteCloudData(any())).called(1);
      });

      test('delete falla en OAuth -> reauth_required_for_delete', () async {
        when(() => mockAuth.deleteAccount()).thenThrow(Exception('boom'));

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'reauth_required_for_delete');
      });

      test('delete falla con password -> delete_account_failed', () async {
        await signInFirst();
        when(
          () => mockAuth.reauthenticate(any(), any()),
        ).thenAnswer((_) async => fbUser);
        when(() => mockAuth.deleteAccount()).thenThrow(Exception('boom'));

        await container
            .read(authProvider.notifier)
            .deleteAccount(email: 'del@example.com', password: 'pw');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.errorMessage, 'delete_account_failed');
      });
    });

    group('signOut con sesión', () {
      test('guarda sync y limpia estado con uid + prefs', () async {
        final fakeUser = FakeAppUser(uid: 'so-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => fakeUser);
        await container
            .read(authProvider.notifier)
            .signInWithEmail(email: 'so@example.com', password: 'password123');
        expect(container.read(authProvider).uid, 'so-uid');

        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        await container.read(authProvider.notifier).signOut();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        verify(() => mockCloudSync.saveAll(any(), any())).called(1);
        verify(() => mockCloudSync.stopListening()).called(1);
      });
    });

    group('refreshCurrentUser', () {
      test('aplica el usuario actual al estado', () async {
        container.read(authProvider);
        when(
          () => mockAuth.currentUser,
        ).thenReturn(FakeAppUser(uid: 'cur-uid', isEmailVerified: true));

        await container.read(authProvider.notifier).refreshCurrentUser();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.uid, 'cur-uid');
      });

      test('usuario null -> unauthenticated', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        await container.read(authProvider.notifier).refreshCurrentUser();
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      });
    });

    group('enterDemoMode', () {
      test('activa modo demo con usuario local', () async {
        final notifier = container.read(authProvider.notifier);
        notifier.enterDemoMode(displayName: 'Demo');

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.demo);
        expect(state.uid, 'demo_user_001');
        expect(state.displayName, 'Demo');
        expect(state.onboardingCompleted, true);
        expect(state.profileLoaded, true);
      });

      test('usa nombre por defecto si no se provee', () async {
        final notifier = container.read(authProvider.notifier);
        notifier.enterDemoMode();

        expect(container.read(authProvider).displayName, 'Demo Student');
      });
    });

    group('markOnboardingCompleted', () {
      test('sin usuario no hace nada', () async {
        await container.read(authProvider.notifier).markOnboardingCompleted();
        expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      });

      test('con usuario captura fallo de Firestore sin romper', () async {
        final fakeUser = FakeAppUser(uid: 'moc-uid', isEmailVerified: true);
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => fakeUser);
        await container
            .read(authProvider.notifier)
            .signInWithEmail(email: 'moc@example.com', password: 'password123');

        await container.read(authProvider.notifier).markOnboardingCompleted();

        final state = container.read(authProvider);
        expect(state.onboardingCompleted, false);
        expect(state.status, AuthStatus.authenticated);
      });
    });

    group('ramas de error de métodos existentes', () {
      test('signInWithEmail ante error genérico -> unknown', () async {
        when(
          () => mockAuth.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('boom'));

        await container
            .read(authProvider.notifier)
            .signInWithEmail(email: 'a@b.com', password: 'pw');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'unknown');
      });

      test('signUpWithEmail ante error genérico -> unknown', () async {
        when(
          () => mockAuth.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          ),
        ).thenThrow(Exception('boom'));

        await container
            .read(authProvider.notifier)
            .signUpWithEmail(
              displayName: 'X',
              email: 'a@b.com',
              password: 'pw',
            );
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'unknown');
      });

      test('sendPasswordResetEmail ante error genérico -> unknown', () async {
        when(
          () => mockAuth.sendPasswordResetEmail('a@b.com'),
        ).thenThrow(Exception('boom'));

        await container
            .read(authProvider.notifier)
            .sendPasswordResetEmail('a@b.com');
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'unknown');
      });

      test('checkEmailVerified ante error -> verify_error', () async {
        when(() => mockAuth.reloadUser()).thenThrow(Exception('boom'));

        await container.read(authProvider.notifier).checkEmailVerified();
        final state = container.read(authProvider);
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.errorMessage, 'verify_error');
      });
    });
  });
}
