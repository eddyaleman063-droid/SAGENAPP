import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockAuthCredential extends Mock implements AuthCredential {}

class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool emailVerified;

  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
  });

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeUserCredential implements UserCredential {
  @override
  final User? user;
  @override
  final AdditionalUserInfo? additionalUserInfo;

  FakeUserCredential({this.user, this.additionalUserInfo});

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
