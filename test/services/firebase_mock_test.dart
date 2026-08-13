import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('Firebase Mocking Infrastructure - Self-contained', () {
    test('Mock classes can be created and stubbed', () {
      final mock = _MockFirestore();
      when(() => mock.collection('users')).thenReturn(_MockCollection());
      expect(mock.collection('users'), isNotNull);
    });

    test('FakeUser has correct properties', () {
      final user = _FakeUser(
        uid: 'uid_123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(user.uid, equals('uid_123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
    });

    test('FakeUserCredential returns user', () {
      final user = _FakeUser(uid: 'uid_123');
      final credential = _FakeUserCredential(user: user);
      expect(credential.user?.uid, equals('uid_123'));
    });
  });

  group('Firebase Auth Mocking - Self-contained', () {
    test('signInWithEmailAndPassword can be mocked', () async {
      final mockAuth = _MockAuth();
      final fakeUser = _FakeUser(uid: 'uid_1', email: 'test@test.com');
      final fakeCredential = _FakeUserCredential(user: fakeUser);

      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => fakeCredential);

      final result = await mockAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: 'password123',
      );

      expect(result.user?.uid, equals('uid_1'));
    });

    test('createUserWithEmailAndPassword can be mocked', () async {
      final mockAuth = _MockAuth();
      final fakeUser = _FakeUser(uid: 'uid_new', email: 'new@test.com');
      final fakeCredential = _FakeUserCredential(user: fakeUser);

      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => fakeCredential);

      final result = await mockAuth.createUserWithEmailAndPassword(
        email: 'new@test.com',
        password: 'password123',
      );

      expect(result.user?.uid, equals('uid_new'));
    });

    test('signOut can be mocked', () async {
      final mockAuth = _MockAuth();
      when(() => mockAuth.signOut()).thenAnswer((_) async {});
      expect(() => mockAuth.signOut(), returnsNormally);
    });

    test('currentUser can be mocked', () {
      final mockAuth = _MockAuth();
      final fakeUser = _FakeUser(uid: 'uid_current');
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      expect(mockAuth.currentUser?.uid, equals('uid_current'));
    });

    test('authStateChanges can be mocked', () {
      final mockAuth = _MockAuth();
      final fakeUser = _FakeUser(uid: 'uid_stream');
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(fakeUser));
      expect(mockAuth.authStateChanges(), isA<Stream>());
    });
  });

  group('Firestore Mocking - Self-contained', () {
    test('collection operations can be mocked', () {
      final mockDb = _MockFirestore();
      final mockCollection = _MockCollection();
      when(() => mockDb.collection('users')).thenReturn(mockCollection);

      final result = mockDb.collection('users');
      expect(result, isNotNull);
    });

    test('document set can be mocked', () async {
      final mockDoc = _MockDocument();
      when(() => mockDoc.set(any())).thenAnswer((_) async {});

      await mockDoc.set({'firstName': 'Test'});
      verify(() => mockDoc.set({'firstName': 'Test'})).called(1);
    });

    test('document update can be mocked', () async {
      final mockDoc = _MockDocument();
      when(() => mockDoc.update(any())).thenAnswer((_) async {});

      await mockDoc.update({'firstName': 'Updated'});
      verify(() => mockDoc.update({'firstName': 'Updated'})).called(1);
    });

    test('document get can be mocked', () async {
      final mockDoc = _MockDocument();
      when(() => mockDoc.get()).thenAnswer((_) async => _FakeDocSnapshot());

      final result = await mockDoc.get();
      expect(result.exists, isTrue);
    });
  });
}

// Self-contained mock/fake classes

class _MockFirestore extends Mock {
  _MockCollection collection(String path);
}

class _MockCollection extends Mock {
  _MockDocument doc(String id);
}

class _MockDocument extends Mock {
  Future<void> set(Map<String, dynamic> data);
  Future<void> update(Map<String, dynamic> data);
  Future<_FakeDocSnapshot> get();
  String get id;
}

class _MockAuth extends Mock {
  Future<_FakeUserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<_FakeUserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  _FakeUser? get currentUser;
  Stream<_FakeUser?> authStateChanges();
}

class _FakeUser {
  final String uid;
  final String? email;
  final String? displayName;

  _FakeUser({required this.uid, this.email, this.displayName});
}

class _FakeUserCredential {
  final _FakeUser? user;
  _FakeUserCredential({this.user});
}

class _FakeDocSnapshot {
  final bool exists = true;
  final Map<String, dynamic> data = {'firstName': 'Test'};
}
