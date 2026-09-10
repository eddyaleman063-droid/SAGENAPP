// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/providers/leaderboard_provider.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFirestore db;
  late _MockCollection coll;
  late _MockQuery query;
  late _MockQuerySnapshot snapshot;

  setUp(() {
    db = _MockFirestore();
    coll = _MockCollection();
    query = _MockQuery();
    snapshot = _MockQuerySnapshot();
    when(() => db.collection('leaderboards')).thenReturn(coll);
    when(
      () => coll.orderBy('learning_total_xp', descending: true),
    ).thenReturn(query);
    when(() => query.limit(50)).thenReturn(query);
  });

  ProviderContainer containerWith(
    Stream<QuerySnapshot<Map<String, dynamic>>> stream,
  ) {
    when(() => query.snapshots()).thenAnswer((_) => stream);
    return ProviderContainer(
      overrides: [leaderboardFirestoreProvider.overrideWithValue(db)],
    );
  }

  _MockDoc doc({required String uid, Map<String, dynamic>? data}) {
    final d = _MockDoc();
    when(() => d.id).thenReturn(uid);
    when(() => d.data()).thenReturn(data ?? {});
    return d;
  }

  void emitSnapshot(List<_MockDoc> docs) {
    when(() => snapshot.docs).thenReturn(docs);
  }

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  test('maps leaderboard documents to entries', () async {
    emitSnapshot([
      doc(
        uid: 'a',
        data: {
          'firstName': 'Ana',
          'lastName': 'Garcia',
          'learning_total_xp': 1200,
          'photoUrl': 'https://x/p.png',
        },
      ),
      doc(uid: 'b', data: {'firstName': 'Luis', 'learning_total_xp': 800}),
      doc(uid: 'c'),
    ]);
    final controller =
        StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
    addTearDown(controller.close);
    final container = containerWith(controller.stream);

    final states = <AsyncValue<List<LeaderboardEntry>>>[];
    container.listen(leaderboardProvider, (_, next) => states.add(next));

    controller.add(snapshot);
    await pump();

    final value = states.last.value!;
    expect(value.length, 3);
    expect(value[0].uid, 'a');
    expect(value[0].displayName, 'Ana Garcia');
    expect(value[0].totalXp, 1200);
    expect(value[0].photoUrl, 'https://x/p.png');
    expect(value[1].displayName, 'Luis');
    expect(value[1].totalXp, 800);
    expect(value[2].displayName, '');
    expect(value[2].totalXp, 0);
    expect(value[2].photoUrl, isNull);
    container.dispose();
  });

  test(
    'records newer snapshots over time from the same subscription',
    () async {
      emitSnapshot([
        doc(uid: 'a', data: {'learning_total_xp': 10}),
      ]);
      final controller =
          StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      final container = containerWith(controller.stream);

      final states = <AsyncValue<List<LeaderboardEntry>>>[];
      container.listen(leaderboardProvider, (_, next) => states.add(next));

      controller.add(snapshot);
      await pump();
      expect(states.last.value!.single.totalXp, 10);

      emitSnapshot([
        doc(uid: 'a', data: {'learning_total_xp': 42}),
      ]);
      controller.add(snapshot);
      await pump();

      expect(states.last.value!.single.totalXp, 42);
      container.dispose();
    },
  );

  test('propagates stream errors into the provider error state', () async {
    final controller =
        StreamController<QuerySnapshot<Map<String, dynamic>>>.broadcast();
    addTearDown(controller.close);
    final container = containerWith(controller.stream);

    final states = <AsyncValue<List<LeaderboardEntry>>>[];
    container.listen(leaderboardProvider, (_, next) => states.add(next));
    controller.addError(StateError('boom'));
    await pump();

    expect(states.last.hasError, isTrue);
    expect(states.last.error, isA<StateError>());
    container.dispose();
  });
}
