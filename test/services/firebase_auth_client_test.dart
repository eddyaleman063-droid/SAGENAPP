import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/services/firebase_auth_client.dart';

import '../helpers/mock_firebase_auth.dart';

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class _MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class _MockUser extends Mock implements User {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
  });

  group('FirebaseAuthClient', () {
    late MockFirebaseAuth mockAuth;
    late FirebaseAuthClient client;
    late FirebaseAuthClient emptyClient;
    late _MockGoogleSignIn mockGoogle;

    setUp(() {
      mockGoogle = _MockGoogleSignIn();
      mockAuth = MockFirebaseAuth();
      client = FirebaseAuthClient(auth: mockAuth, googleSignIn: mockGoogle);
      emptyClient = FirebaseAuthClient();
    });

    group('availability and streams', () {
      test('isAvailable reflects a non-null auth', () {
        expect(client.isAvailable, isTrue);
        expect(emptyClient.isAvailable, isFalse);
      });

      test('isGoogleAvailable requires both auth and googleSignIn', () {
        expect(client.isGoogleAvailable, isTrue);
        final noGoogle = FirebaseAuthClient(auth: MockFirebaseAuth());
        expect(noGoogle.isGoogleAvailable, isFalse);
      });

      test('authStateChanges is empty when auth is null', () async {
        final events = <User?>[];
        final sub = emptyClient.authStateChanges.listen(events.add);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();
        expect(events, isEmpty);
      });

      test('firebaseUser is null when auth is null', () {
        expect(emptyClient.firebaseUser, isNull);
      });

      test('init catches auth initialization failures', () {
        // No firebase mocks installed, so FirebaseAuth.instance throws.
        FirebaseAuthClient().init();
        expect(emptyClient.isAvailable, isFalse);
      });
    });

    group('signInWithGoogle', () {
      test(
        'throws firebase_unavailable when google is not configured',
        () async {
          final noGoogle = FirebaseAuthClient(auth: mockAuth);
          await expectLater(
            noGoogle.signInWithGoogle(),
            throwsA(
              isA<AuthException>().having(
                (e) => e.code,
                'code',
                'firebase_unavailable',
              ),
            ),
          );
        },
      );

      test('throws firebase_unavailable when auth is null', () async {
        final noAuth = FirebaseAuthClient(googleSignIn: _MockGoogleSignIn());
        await expectLater(
          noAuth.signInWithGoogle(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'firebase_unavailable',
            ),
          ),
        );
      });

      test('maps a canceled google sign-in to canceled', () async {
        when(() => mockGoogle.signIn()).thenAnswer((_) async => null);
        await expectLater(
          client.signInWithGoogle(),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'canceled'),
          ),
        );
      });

      test('maps a firebase auth exception', () async {
        when(
          () => mockGoogle.signIn(),
        ).thenThrow(FirebaseAuthException(code: 'user-not-found'));
        await expectLater(
          client.signInWithGoogle(),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'not_found'),
          ),
        );
      });

      test('maps unexpected google errors to unknown', () async {
        when(() => mockGoogle.signIn()).thenThrow(Exception('boom'));
        await expectLater(
          client.signInWithGoogle(),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'unknown'),
          ),
        );
      });

      test('returns the mapped user on success', () async {
        final account = _MockGoogleSignInAccount();
        final authentication = _MockGoogleSignInAuthentication();
        when(() => mockGoogle.signIn()).thenAnswer((_) async => account);
        when(
          () => account.authentication,
        ).thenAnswer((_) async => authentication);
        when(() => authentication.accessToken).thenReturn('access-token');
        when(() => authentication.idToken).thenReturn('id-token');
        when(() => mockAuth.signInWithCredential(any())).thenAnswer(
          (_) async => FakeUserCredential(
            user: FakeUser(uid: 'google-1', email: 'g@test.com'),
          ),
        );
        final appUser = await client.signInWithGoogle();
        expect(appUser.uid, 'google-1');
        expect(appUser.email, 'g@test.com');
        verify(() => mockGoogle.signIn()).called(1);
      });

      test('maps a null firebase user to null_user', () async {
        when(() => mockGoogle.signIn()).thenThrow(Exception('never'));
        when(() => mockGoogle.signIn()).thenAnswer((_) async {
          final account = _MockGoogleSignInAccount();
          final authentication = _MockGoogleSignInAuthentication();
          when(
            () => account.authentication,
          ).thenAnswer((_) async => authentication);
          when(() => authentication.accessToken).thenReturn('at');
          when(() => authentication.idToken).thenReturn('it');
          return account;
        });
        when(
          () => mockAuth.signInWithCredential(any()),
        ).thenAnswer((_) async => FakeUserCredential(user: null));
        await expectLater(
          client.signInWithGoogle(),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'null_user'),
          ),
        );
      });
    });

    group('signInWithFacebook', () {
      test('throws firebase_unavailable when auth is null', () async {
        await expectLater(
          emptyClient.signInWithFacebook(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'firebase_unavailable',
            ),
          ),
        );
      });

      test('unknown error maps to unknown (plugin unavailable)', () async {
        // FacebookAuth.instance has no platform handler in tests -> the
        // generic catch turns it into AuthException('unknown').
        await expectLater(
          client.signInWithFacebook(),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'unknown'),
          ),
        );
      });
    });

    group('signUpWithEmail', () {
      test('throws firebase_unavailable when auth is null', () async {
        await expectLater(
          emptyClient.signUpWithEmail(
            email: 'a@b.com',
            password: '123456',
            displayName: 'Ana',
          ),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'firebase_unavailable',
            ),
          ),
        );
      });

      test('returns the created user and maps fields', () async {
        when(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => FakeUserCredential(
            user: FakeUser(
              uid: 'new-1',
              email: 'ana@test.com',
              displayName: 'name-will-be-updated',
            ),
          ),
        );
        final appUser = await client.signUpWithEmail(
          email: 'ana@test.com',
          password: '123456',
          displayName: '  Ana  ',
        );
        expect(appUser.uid, 'new-1');
        expect(appUser.displayName, 'name-will-be-updated');
        verify(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).called(1);
      });

      test('maps email-already-in-use', () async {
        when(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
        await expectLater(
          client.signUpWithEmail(
            email: 'a@b.com',
            password: '123456',
            displayName: 'Ana',
          ),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'email_in_use'),
          ),
        );
      });

      test('maps unexpected errors to unknown', () async {
        when(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('boom'));
        await expectLater(
          client.signUpWithEmail(
            email: 'a@b.com',
            password: '123456',
            displayName: 'Ana',
          ),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'unknown'),
          ),
        );
      });
    });

    group('signInWithEmail', () {
      test('throws firebase_unavailable when auth is null', () async {
        await expectLater(
          emptyClient.signInWithEmail(email: 'a@b.com', password: 'x'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'firebase_unavailable',
            ),
          ),
        );
      });

      test('returns the signed-in user and reloads', () async {
        final mockUser = _MockUser();
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => FakeUserCredential(user: mockUser));
        when(() => mockUser.uid).thenReturn('u-1');
        when(() => mockUser.email).thenReturn('u@test.com');
        when(() => mockUser.displayName).thenReturn('User');
        when(() => mockUser.emailVerified).thenReturn(true);
        when(() => mockUser.reload()).thenAnswer((_) async {});

        final appUser = await client.signInWithEmail(
          email: 'u@test.com',
          password: 'x',
        );
        expect(appUser.uid, 'u-1');
        expect(appUser.isEmailVerified, isTrue);
        verify(() => mockUser.reload()).called(1);
      });

      test('null user maps to null_user', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => FakeUserCredential(user: null));
        await expectLater(
          client.signInWithEmail(email: 'a@b.com', password: 'x'),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'null_user'),
          ),
        );
      });

      test('maps wrong-password', () async {
        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));
        await expectLater(
          client.signInWithEmail(email: 'a@b.com', password: 'x'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'wrong_password',
            ),
          ),
        );
      });
    });

    group('verification and recovery', () {
      test('sendEmailVerification no-ops when auth is null', () async {
        await emptyClient.sendEmailVerification();
      });

      test(
        'sendEmailVerification throws not_authenticated without user',
        () async {
          when(() => mockAuth.currentUser).thenReturn(null);
          await expectLater(
            client.sendEmailVerification(),
            throwsA(
              isA<AuthException>().having(
                (e) => e.code,
                'code',
                'not_authenticated',
              ),
            ),
          );
        },
      );

      test('sendEmailVerification maps firebase errors', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.sendEmailVerification(),
        ).thenThrow(FirebaseAuthException(code: 'too-many-requests'));
        await expectLater(
          client.sendEmailVerification(),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'too_many_requests',
            ),
          ),
        );
      });

      test('reloadUser returns false when auth is null', () async {
        expect(await emptyClient.reloadUser(), isFalse);
      });

      test('reloadUser returns false without a user', () async {
        when(() => mockAuth.currentUser).thenReturn(null);
        expect(await client.reloadUser(), isFalse);
      });

      test('reloadUser reports emailVerified after reload', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenAnswer((_) async {});
        when(() => mockUser.emailVerified).thenReturn(true);
        expect(await client.reloadUser(), isTrue);
      });

      test('reloadUser returns false when reload throws', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.reload()).thenThrow(Exception('net'));
        expect(await client.reloadUser(), isFalse);
      });

      test(
        'sendPasswordResetEmail throws firebase_unavailable without auth',
        () async {
          await expectLater(
            emptyClient.sendPasswordResetEmail('a@b.com'),
            throwsA(
              isA<AuthException>().having(
                (e) => e.code,
                'code',
                'firebase_unavailable',
              ),
            ),
          );
        },
      );

      test('sendPasswordResetEmail maps invalid-email', () async {
        when(
          () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
        ).thenThrow(FirebaseAuthException(code: 'invalid-email'));
        await expectLater(
          client.sendPasswordResetEmail('a@b.com'),
          throwsA(
            isA<AuthException>().having((e) => e.code, 'code', 'invalid_email'),
          ),
        );
      });
    });

    group('reauthenticate', () {
      late _MockUser mockUser;

      setUp(() {
        mockUser = _MockUser();
      });

      test('returns null when auth is null', () async {
        expect(await emptyClient.reauthenticate('a@b.com', 'x'), isNull);
      });

      test('returns null without a user', () async {
        when(() => mockAuth.currentUser).thenReturn(null);
        expect(await client.reauthenticate('a@b.com', 'x'), isNull);
      });

      test('returns the reauthenticated user', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        final reauthUser = FakeUser(uid: 'r-1', email: 'r@test.com');
        when(
          () => mockUser.reauthenticateWithCredential(any()),
        ).thenAnswer((_) async => FakeUserCredential(user: reauthUser));
        final user = await client.reauthenticate('r@test.com', 'x');
        expect(user?.uid, 'r-1');
      });

      test('maps firebase reauth errors', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(
          () => mockUser.reauthenticateWithCredential(any()),
        ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));
        await expectLater(
          client.reauthenticate('a@b.com', 'x'),
          throwsA(
            isA<AuthException>().having(
              (e) => e.code,
              'code',
              'invalid_credential',
            ),
          ),
        );
      });
    });

    group('getIdToken', () {
      late _MockUser mockUser;

      setUp(() {
        mockUser = _MockUser();
      });

      test('returns null when auth is null', () async {
        expect(await emptyClient.getIdToken(), isNull);
      });

      test('returns null without a user', () async {
        when(() => mockAuth.currentUser).thenReturn(null);
        expect(await client.getIdToken(), isNull);
      });

      test('returns the token with forceRefresh', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.getIdToken(any())).thenAnswer((_) async => 'tok');
        expect(await client.getIdToken(forceRefresh: true), 'tok');
        verify(() => mockUser.getIdToken(true)).called(1);
      });

      test('returns null when token fetch fails', () async {
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.getIdToken(any())).thenThrow(Exception('net'));
        expect(await client.getIdToken(), isNull);
      });
    });

    group('signOutFirebase and deleteFirebaseUser', () {
      test('signOutFirebase signs out of google, facebook and auth', () async {
        when<void>(() => mockGoogle.signOut()).thenAnswer((_) async {});
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        await client.signOutFirebase();
        verify<void>(() => mockGoogle.signOut()).called(1);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('signOutFirebase tolerates google sign-out failures', () async {
        when<void>(() => mockGoogle.signOut()).thenThrow(Exception('gs'));
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        await client.signOutFirebase();
        verify(() => mockAuth.signOut()).called(1);
      });

      test('signOutFirebase skips google when not configured', () async {
        final authOnly = FirebaseAuthClient(auth: mockAuth);
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        await authOnly.signOutFirebase();
        verify(() => mockAuth.signOut()).called(1);
      });

      test(
        'deleteFirebaseUser deletes the auth user and disconnects google',
        () async {
          final mockUser = _MockUser();
          when(() => mockAuth.currentUser).thenReturn(mockUser);
          when(() => mockUser.delete()).thenAnswer((_) async {});
          when<void>(() => mockGoogle.disconnect()).thenAnswer((_) async {});
          await client.deleteFirebaseUser();
          verify(() => mockUser.delete()).called(1);
          verify<void>(() => mockGoogle.disconnect()).called(1);
        },
      );

      test('deleteFirebaseUser rethrows user deletion failures', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.delete()).thenThrow(Exception('denied'));
        await expectLater(client.deleteFirebaseUser(), throwsException);
      });

      test('deleteFirebaseUser tolerates google disconnect failures', () async {
        final mockUser = _MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.delete()).thenAnswer((_) async {});
        when<void>(() => mockGoogle.disconnect()).thenThrow(Exception('net'));
        await client.deleteFirebaseUser();
      });
    });

    group('exception mapping', () {
      const cases = <String, String>{
        'user-not-found': 'not_found',
        'wrong-password': 'wrong_password',
        'invalid-credential': 'invalid_credential',
        'email-already-in-use': 'email_in_use',
        'weak-password': 'weak_password',
        'invalid-email': 'invalid_email',
        'too-many-requests': 'too_many_requests',
        'network-request-failed': 'network_error',
        'some-custom-code': 'some-custom-code',
      };

      cases.forEach((firebaseCode, expectedCode) {
        test('maps $firebaseCode -> $expectedCode', () async {
          when(
            () => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ),
          ).thenThrow(FirebaseAuthException(code: firebaseCode));
          await expectLater(
            client.signInWithEmail(email: 'a@b.com', password: 'x'),
            throwsA(
              isA<AuthException>().having((e) => e.code, 'code', expectedCode),
            ),
          );
        });
      });
    });
  });
}
