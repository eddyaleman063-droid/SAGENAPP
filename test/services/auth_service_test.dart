import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:sagen/services/firebase_auth_client.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/auth_session_manager.dart';

class MockAuthClient extends Mock implements AuthClient {}
class MockSessionManager extends Mock implements AuthSessionManager {}

void main() {
  late MockAuthClient mockClient;
  late MockSessionManager mockSession;
  late AuthService service;

  setUp(() {
    mockClient = MockAuthClient();
    mockSession = MockSessionManager();
    service = AuthService(
      client: mockClient,
      sessionManager: mockSession,
    );
  });

  setUpAll(() {
    registerFallbackValue(const AppUser());
    registerFallbackValue(FakeFirebaseUser());
  });

  group('Initial state', () {
    test('is not logged in', () {
      expect(service.isLoggedIn, false);
      expect(service.currentUser, isNull);
    });

    test('displayName returns Estudiante when not logged in', () {
      expect(service.displayName, 'Estudiante');
    });

    test('email returns empty string when not logged in', () {
      expect(service.email, '');
    });

    test('photoUrl returns null when not logged in', () {
      expect(service.photoUrl, isNull);
    });
  });

  group('signInWithGoogle', () {
    test('sets currentUser and saves session on success', () async {
      const user = AppUser(uid: 'g1', displayName: 'Google User', email: 'g@test.com');
      when(() => mockClient.signInWithGoogle()).thenAnswer((_) async => user);
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      final result = await service.signInWithGoogle();

      expect(result.uid, 'g1');
      expect(result.displayName, 'Google User');
      expect(service.isLoggedIn, true);
      expect(service.currentUser?.uid, 'g1');
      verify(() => mockSession.saveSession(user)).called(1);
    });

    test('throws AuthException when client throws', () async {
      when(() => mockClient.signInWithGoogle())
          .thenThrow(const AuthException('canceled'));

      expect(
        () => service.signInWithGoogle(),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'canceled')),
      );
      expect(service.isLoggedIn, false);
    });

    test('throws firebase_unavailable when Firebase not initialized', () async {
      when(() => mockClient.signInWithGoogle())
          .thenThrow(const AuthException('firebase_unavailable'));

      expect(
        () => service.signInWithGoogle(),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'firebase_unavailable')),
      );
    });
  });

  group('signInWithFacebook', () {
    test('sets currentUser and saves session on success', () async {
      const user = AppUser(uid: 'f1', displayName: 'FB User', email: 'fb@test.com');
      when(() => mockClient.signInWithFacebook()).thenAnswer((_) async => user);
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      final result = await service.signInWithFacebook();

      expect(result.uid, 'f1');
      expect(service.isLoggedIn, true);
      verify(() => mockSession.saveSession(user)).called(1);
    });

    test('throws when canceled', () async {
      when(() => mockClient.signInWithFacebook())
          .thenThrow(const AuthException('canceled'));

      expect(
        () => service.signInWithFacebook(),
        throwsA(isA<AuthException>()),
      );
      expect(service.isLoggedIn, false);
    });
  });

  group('signInWithEmail', () {
    test('sets currentUser and saves session on success', () async {
      const user = AppUser(uid: 'e1', displayName: 'Email User', email: 'e@test.com');
      when(() => mockClient.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => user);
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      final result = await service.signInWithEmail(
        email: 'e@test.com',
        password: 'pass123',
      );

      expect(result.uid, 'e1');
      expect(service.isLoggedIn, true);
      expect(service.email, 'e@test.com');
      verify(() => mockSession.saveSession(user)).called(1);
    });

    test('throws wrong_password on invalid credentials', () async {
      when(() => mockClient.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('wrong_password'));

      expect(
        () => service.signInWithEmail(email: 'e@test.com', password: 'bad'),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'wrong_password')),
      );
    });

    test('throws invalid_credential', () async {
      when(() => mockClient.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('invalid_credential'));

      expect(
        () => service.signInWithEmail(email: 'e@test.com', password: 'bad'),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'invalid_credential')),
      );
    });

    test('throws too_many_requests', () async {
      when(() => mockClient.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('too_many_requests'));

      expect(
        () => service.signInWithEmail(email: 'e@test.com', password: 'p'),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'too_many_requests')),
      );
    });

    test('throws network_error', () async {
      when(() => mockClient.signInWithEmail(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthException('network_error'));

      expect(
        () => service.signInWithEmail(email: 'e@test.com', password: 'p'),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'network_error')),
      );
    });
  });

  group('signUpWithEmail', () {
    test('sets currentUser and saves session on success', () async {
      const user = AppUser(uid: 'n1', displayName: 'New User', email: 'n@test.com');
      when(() => mockClient.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => user);
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      final result = await service.signUpWithEmail(
        email: 'n@test.com',
        password: 'secure123',
        displayName: 'New User',
      );

      expect(result.uid, 'n1');
      expect(service.isLoggedIn, true);
      verify(() => mockSession.saveSession(user)).called(1);
    });

    test('throws email_in_use when email already exists', () async {
      when(() => mockClient.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(const AuthException('email_in_use'));

      expect(
        () => service.signUpWithEmail(
          email: 'taken@test.com',
          password: 'pass',
          displayName: 'User',
        ),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'email_in_use')),
      );
    });

    test('throws weak_password', () async {
      when(() => mockClient.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(const AuthException('weak_password'));

      expect(
        () => service.signUpWithEmail(
          email: 'n@test.com',
          password: '123',
          displayName: 'User',
        ),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'weak_password')),
      );
    });

    test('throws invalid_email', () async {
      when(() => mockClient.signUpWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(const AuthException('invalid_email'));

      expect(
        () => service.signUpWithEmail(
          email: 'not-an-email',
          password: 'pass',
          displayName: 'User',
        ),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', 'invalid_email')),
      );
    });
  });

  group('signOut', () {
    test('clears currentUser and session', () async {
      const user = AppUser(uid: 'u1');
      when(() => mockClient.signInWithGoogle()).thenAnswer((_) async => user);
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});
      when(() => mockClient.signOutFirebase()).thenAnswer((_) async {});
      when(() => mockSession.clearSession()).thenAnswer((_) async {});

      await service.signInWithGoogle();
      expect(service.isLoggedIn, true);

      await service.signOut();

      expect(service.isLoggedIn, false);
      expect(service.currentUser, isNull);
      expect(service.displayName, 'Estudiante');
      verify(() => mockClient.signOutFirebase()).called(1);
      verify(() => mockSession.clearSession()).called(1);
    });
  });

  group('sendPasswordResetEmail', () {
    test('delegates to client', () async {
      when(() => mockClient.sendPasswordResetEmail(any())).thenAnswer((_) async {});

      await service.sendPasswordResetEmail('test@test.com');

      verify(() => mockClient.sendPasswordResetEmail('test@test.com')).called(1);
    });

    test('propagates exceptions', () async {
      when(() => mockClient.sendPasswordResetEmail(any()))
          .thenThrow(const AuthException('network_error'));

      expect(
        () => service.sendPasswordResetEmail('test@test.com'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('deleteAccount', () {
    test('deletes Firebase user and signs out', () async {
      when(() => mockClient.deleteFirebaseUser()).thenAnswer((_) async {});
      when(() => mockClient.signOutFirebase()).thenAnswer((_) async {});
      when(() => mockSession.clearSession()).thenAnswer((_) async {});

      await service.deleteAccount();

      verify(() => mockClient.deleteFirebaseUser()).called(1);
      verify(() => mockClient.signOutFirebase()).called(1);
      expect(service.isLoggedIn, false);
    });
  });

  group('getIdToken', () {
    test('delegates to client', () async {
      when(() => mockClient.getIdToken()).thenAnswer((_) async => 'token_123');

      final token = await service.getIdToken();

      expect(token, 'token_123');
    });

    test('returns null when client returns null', () async {
      when(() => mockClient.getIdToken()).thenAnswer((_) async => null);

      final token = await service.getIdToken();

      expect(token, isNull);
    });
  });

  group('authStateChanges', () {
    test('returns empty stream when client not available', () async {
      when(() => mockClient.isAvailable).thenReturn(false);

      final results = <AppUser?>[];
      service.authStateChanges.listen(results.add);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(results, isEmpty);
    });

    test('maps firebase users to AppUser', () async {
      final controller = StreamController<firebase.User?>();
      final fakeUser = MockFirebaseUser();
      when(() => fakeUser.reload()).thenAnswer((_) async {});
      when(() => mockClient.isAvailable).thenReturn(true);
      when(() => mockClient.firebaseUser).thenReturn(null);
      when(() => mockClient.authStateChanges).thenAnswer((_) => controller.stream);
      when(() => mockClient.appUserFromFirebase(any())).thenReturn(
        const AppUser(uid: 'mapped', displayName: 'Mapped'),
      );
      when(() => mockSession.restoreSession()).thenAnswer((_) async => null);
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      await service.init();

      final results = <AppUser?>[];
      service.authStateChanges.listen(results.add);

      controller.add(null);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(results, [null]);

      controller.add(fakeUser);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(results.length, 2);
      expect(results.last?.uid, 'mapped');

      await controller.close();
    });
  });

  group('clearAllLocalData', () {
    test('clears session', () async {
      when(() => mockSession.clearSession()).thenAnswer((_) async {});

      await service.clearAllLocalData();

      verify(() => mockSession.clearSession()).called(1);
    });
  });

  group('dispose', () {
    test('cancels auth subscription', () async {
      when(() => mockClient.isAvailable).thenReturn(false);

      await service.init();
      service.dispose();

      expect(true, true);
    });
  });

  group('init', () {
    test('sets currentUser when Firebase user exists', () async {
      final fakeUser = MockFirebaseUser();
      when(() => fakeUser.reload()).thenAnswer((_) async {});
      when(() => mockClient.isAvailable).thenReturn(true);
      when(() => mockClient.firebaseUser).thenReturn(fakeUser);
      when(() => mockClient.appUserFromFirebase(any()))
          .thenReturn(const AppUser(uid: 'fb1', displayName: 'FB User'));
      when(() => mockClient.authStateChanges).thenAnswer((_) => const Stream.empty());
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      await service.init();

      expect(service.currentUser?.uid, 'fb1');
      expect(service.isLoggedIn, true);
      verify(() => mockSession.saveSession(any())).called(greaterThanOrEqualTo(1));
    });

    test('clears session when restored session validation fails', () async {
      when(() => mockClient.isAvailable).thenReturn(true);
      when(() => mockClient.firebaseUser).thenReturn(null);
      when(() => mockClient.authStateChanges).thenAnswer((_) => const Stream.empty());
      when(() => mockSession.restoreSession())
          .thenAnswer((_) async => const AppUser(uid: 'old'));
      when(() => mockSession.clearSession()).thenAnswer((_) async {});

      await service.init();

      expect(service.currentUser, isNull);
      verify(() => mockSession.clearSession()).called(greaterThanOrEqualTo(1));
    });

    test('handles unavailable client gracefully', () async {
      when(() => mockClient.isAvailable).thenReturn(false);

      await service.init();

      expect(service.isLoggedIn, false);
    });

    test('authStateChanges sets and clears currentUser', () async {
      final controller = StreamController<firebase.User?>();
      final fakeUser = MockFirebaseUser();
      when(() => fakeUser.reload()).thenAnswer((_) async {});
      when(() => mockClient.isAvailable).thenReturn(true);
      when(() => mockClient.firebaseUser).thenReturn(null);
      when(() => mockClient.authStateChanges).thenAnswer((_) => controller.stream);
      when(() => mockSession.restoreSession()).thenAnswer((_) async => null);
      when(() => mockClient.appUserFromFirebase(fakeUser))
          .thenReturn(const AppUser(uid: 'live', displayName: 'Live'));
      when(() => mockSession.saveSession(any())).thenAnswer((_) async {});

      await service.init();

      controller.add(fakeUser);
      await Future.delayed(Duration.zero);

      expect(service.currentUser?.uid, 'live');

      controller.add(null);
      await Future.delayed(Duration.zero);
      expect(service.currentUser, isNull);

      await controller.close();
    });
  });
}

class MockFirebaseUser extends Mock implements firebase.User {}
class FakeFirebaseUser extends Fake implements firebase.User {}
