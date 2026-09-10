// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/learning_stage_service.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockDocSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late _MockFirestore db;
  late _MockCollection collection;
  late _MockQuery query;
  late _MockQuerySnapshot snapshot;
  late _MockDocSnapshot doc;
  late LearningStageService service;

  setUp(() {
    db = _MockFirestore();
    collection = _MockCollection();
    query = _MockQuery();
    snapshot = _MockQuerySnapshot();
    doc = _MockDocSnapshot();
    service = LearningStageService()..overrideDbInstance = db;
  });

  group('LearningStageService.fetchStages', () {
    test('fetches and maps stage documents', () async {
      when(() => db.collection('learning_stages')).thenReturn(collection);
      when(() => collection.orderBy(FieldPath.documentId)).thenReturn(query);
      when(
        () => query.get(const GetOptions(source: Source.serverAndCache)),
      ).thenAnswer((_) async => snapshot);
      when(() => snapshot.docs).thenReturn([doc]);
      when(() => doc.data()).thenReturn({
        'id': 'stage_1',
        'title': 'Introduction',
        'subtitle': 'Basics',
        'accent': 0xFF00FF00,
        'icon': 'shield',
        'unlocked': true,
      });

      final stages = await service.fetchStages();

      expect(stages, hasLength(1));
      expect(stages.first.id, 'stage_1');
      expect(stages.first.title, 'Introduction');
      expect(stages.first.unlocked, isTrue);
      verify(() => db.collection('learning_stages')).called(1);
      verify(() => collection.orderBy(FieldPath.documentId)).called(1);
      verify(
        () => query.get(const GetOptions(source: Source.serverAndCache)),
      ).called(1);
    });

    test('maps an empty collection to an empty list', () async {
      when(() => db.collection('learning_stages')).thenReturn(collection);
      when(() => collection.orderBy(FieldPath.documentId)).thenReturn(query);
      when(
        () => query.get(const GetOptions(source: Source.serverAndCache)),
      ).thenAnswer((_) async => snapshot);
      when(() => snapshot.docs).thenReturn([]);

      final stages = await service.fetchStages();

      expect(stages, isEmpty);
    });

    test('wraps firestore errors in a descriptive Exception', () async {
      when(() => db.collection('learning_stages')).thenReturn(collection);
      when(() => collection.orderBy(FieldPath.documentId)).thenReturn(query);
      when(
        () => query.get(const GetOptions(source: Source.serverAndCache)),
      ).thenThrow(
        FirebaseException(
          code: 'permission-denied',
          plugin: 'mock-firestore',
          message: 'denied',
        ),
      );

      expect(
        service.fetchStages(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to fetch learning stages'),
          ),
        ),
      );
    });
  });
}
