import 'package:mocktail/mocktail.dart';

class MockFirebaseFirestore extends Mock {}
class MockDocumentReference extends Mock {}
class MockCollectionReference extends Mock {}
class MockQuerySnapshot extends Mock {}
class MockQueryDocumentSnapshot extends Mock {}
class MockDocumentSnapshot extends Mock {}
class MockQuery extends Mock {}
class MockWriteBatch extends Mock {}
class MockTransaction extends Mock {}

class FakeFieldValue {
  final dynamic value;
  FakeFieldValue(this.value);
}

void registerFallbackValues() {
  registerFallbackValue(FakeFieldValue(''));
  registerFallbackValue(<String, dynamic>{});
}
