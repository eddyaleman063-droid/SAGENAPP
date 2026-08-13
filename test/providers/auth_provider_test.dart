import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthService extends Mock implements AuthService {}

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

        final notifier = container.read(authProvider.notifier);
        await notifier.checkEmailVerified();

        final state = container.read(authProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.pendingVerification, false);
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
    });
  });
}
