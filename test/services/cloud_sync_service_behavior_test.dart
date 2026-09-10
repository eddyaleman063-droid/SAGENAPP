// ignore_for_file: subtype_of_sealed_class

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:sagen/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuth extends Mock implements AuthService {}

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDocRef extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockDocSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAuth auth;
  late _MockFirestore db;
  late _MockCollection coll;
  late _MockDocRef docRef;
  late _MockDocSnapshot docSnapshot;
  late SharedPreferences prefs;
  late CloudSyncService service;

  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(SetOptions(merge: true));

  setUp(() async {
    auth = _MockAuth();
    db = _MockFirestore();
    coll = _MockCollection();
    docRef = _MockDocRef();
    docSnapshot = _MockDocSnapshot();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = CloudSyncService(
      authService: auth,
      firestoreService: FirestoreService.instance,
    )..overrideFirestoreInstance = db;
    FirestoreService.instance.overrideDbInstance = db;

    when(() => db.collection('users')).thenReturn(coll);
    when(() => coll.doc(any<String>())).thenReturn(docRef);
    when(() => auth.currentUser).thenReturn(const AppUser(uid: 'u1'));
  });

  tearDown(() async {
    FirestoreService.instance.overrideDbInstance = null;
    service.dispose();
  });

  group('CloudSyncService.userDocStream', () {
    test('is empty when there is no signed-in user', () async {
      when(() => auth.currentUser).thenReturn(null);
      final events = await service.userDocStream.toList();
      expect(events, isEmpty);
    });

    test('forwards the user document stream for the current uid', () async {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);

      final received = <DocumentSnapshot>[];
      final sub = service.userDocStream.listen(received.add);
      addTearDown(() => sub.cancel);

      controller.add(docSnapshot);
      await Future<void>.delayed(Duration.zero);

      expect(received, [docSnapshot]);
      verify(() => coll.doc('u1')).called(1);
    });
  });

  group('CloudSyncService.listen lifecycle', () {
    test(
      'startListening cancels the previous subscription on user switch',
      () async {
        final controller =
            StreamController<
              DocumentSnapshot<Map<String, dynamic>>
            >.broadcast();
        addTearDown(controller.close);
        when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);

        service.startListening('u1', prefs);
        service.startListening('u2', prefs);

        await Future<void>.delayed(Duration.zero);
        verify(() => coll.doc('u1')).called(1);
        verify(() => coll.doc('u2')).called(1);
      },
    );

    test('does not resubscribe when listening to the same uid', () async {
      when(() => docRef.snapshots()).thenAnswer(
        (_) => const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty(),
      );
      service.startListening('u1', prefs);
      service.startListening('u1', prefs);
      verify(() => coll.doc('u1')).called(1);
    });

    test('stopListening cancels the subscription', () async {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);
      service.startListening('u1', prefs);
      service.stopListening();
      expect(controller.hasListener, isFalse);
    });

    test('snapshot stream errors are logged, not thrown', () async {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);
      service.startListening('u1', prefs);
      controller.addError(StateError('boom'));
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('CloudSyncService remote-to-local apply', () {
    test('applies typed values and skips private non-timestamp keys', () async {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);
      when(() => docSnapshot.exists).thenReturn(true);
      when(() => docSnapshot.data()).thenReturn({
        'firstName': 'Ana',
        'age': 30,
        'onboardingCompleted': true,
        '_hidden': 'skip-me',
        '_ts_age': Timestamp.fromDate(DateTime.utc(2026, 1, 1).toLocal()),
      });

      service.startListening('u1', prefs);
      controller.add(docSnapshot);
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getString('firstName'), 'Ana');
      expect(prefs.getInt('age'), 30);
      expect(prefs.getBool('onboardingCompleted'), isTrue);
      expect(prefs.getString('_hidden'), isNull);
      expect(prefs.getString('_ts_age'), isNot(contains('Timestamp')));
    });

    test('does not overwrite a local value that is newer than cloud', () async {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);
      when(() => docSnapshot.exists).thenReturn(true);
      when(() => docSnapshot.data()).thenReturn({
        'firstName': 'cloud-old',
        '_ts_firstName': Timestamp.fromDate(DateTime.utc(2020, 1, 1).toLocal()),
      });
      prefs.setString(
        '_ts_firstName',
        DateTime.utc(2026, 1, 1).toIso8601String(),
      );
      prefs.setString('firstName', 'local-new');

      service.startListening('u1', prefs);
      controller.add(docSnapshot);
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getString('firstName'), 'local-new');
    });

    test('_isCloudNewer treats missing timestamps as cloud-newest', () async {
      final controller =
          StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
      addTearDown(controller.close);
      when(() => docRef.snapshots()).thenAnswer((_) => controller.stream);
      when(() => docSnapshot.exists).thenReturn(true);
      when(() => docSnapshot.data()).thenReturn({'firstName': 'cloud-x'});
      prefs.setString('firstName', 'local-y');

      service.startListening('u1', prefs);
      controller.add(docSnapshot);
      await Future<void>.delayed(Duration.zero);

      expect(prefs.getString('firstName'), 'cloud-x');
    });
  });

  group('CloudSyncService.notifyFieldChanged + debounced flush', () {
    Future<void> pumpDebounce() =>
        Future<void>.delayed(const Duration(milliseconds: 700));

    test('rejects non-primitive and server-only or unknown fields', () async {
      service.notifyFieldChanged('firstName', Object());
      service.notifyFieldChanged('learning_gems', 100);
      service.notifyFieldChanged('no_such_key', 'x');
      await pumpDebounce();
      verifyNever(() => docRef.update(any()));
    });

    test('flushes a primed pending write through FirestoreService', () async {
      when(() => docRef.update(any())).thenAnswer((_) async {});
      await service.init(prefs);

      service.notifyFieldChanged('firstName', 'Ana');
      await pumpDebounce();

      final captured =
          verify(() => docRef.update(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(captured['firstName'], 'Ana');
      expect(captured.keys.where((k) => k.startsWith('_ts_')), isNotEmpty);
    });

    test('clears pending writes when the user signs out', () async {
      when(() => auth.currentUser).thenReturn(null);
      await service.init(prefs);
      service.notifyFieldChanged('firstName', 'Ana');
      await pumpDebounce();
      verifyNever(() => docRef.update(any()));
      expect(prefs.getString('cloud_pending_writes'), isNull);
    });

    test('re-queues writes and retries when the flush fails', () async {
      when(() => docRef.update(captureAny())).thenAnswer((_) async {});
      when(() => docRef.update(captureAny())).thenThrow(
        FirebaseException(
          code: 'unavailable',
          plugin: 'mock',
          message: 'network',
        ),
      );
      when(() => docRef.update(captureAny())).thenAnswer((_) async {});
      await service.init(prefs);

      service.notifyFieldChanged('firstName', 'Ana');
      await pumpDebounce();

      service.notifyFieldChanged('firstName', 'Ana');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      expect(verify(() => docRef.update(captureAny())).captured, isNotEmpty);
    });

    test('dispose cancels the debounce timer', () async {
      when(() => docRef.update(any())).thenAnswer((_) async {});
      await service.init(prefs);
      service.notifyFieldChanged('firstName', 'Ana');
      service.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      verifyNever(() => docRef.update(any()));
    });
  });

  group('CloudSyncService.saveAll', () {
    test('returns false when not initialized', () async {
      expect(await service.saveAll('u1', prefs), isFalse);
    });

    test('returns true when there are no dirty keys', () async {
      await service.init(prefs);
      expect(await service.saveAll('u1', prefs), isTrue);
    });

    test('persists dirty keys merged into the user document', () async {
      when(() => docRef.set(any(), any())).thenAnswer((_) async {});
      await service.init(prefs);
      prefs.setString('firstName', 'Ana');
      service.markDirty('firstName');

      final ok = await service.saveAll('u1', prefs);

      expect(ok, isTrue);
      final captured =
          verify(() => docRef.set(captureAny(), any())).captured.single
              as Map<String, dynamic>;
      expect(captured['firstName'], 'Ana');
      expect(prefs.getString('cloud_last_sync'), isNotNull);
      expect(service.isSyncing, isFalse);
      expect(service.lastSync, isNotNull);
    });

    test('returns false when another sync holds the global lock', () async {
      await service.init(prefs);
      service.markDirty('firstName');
      expect(CloudSyncService.acquireGlobalSyncLock(), isTrue);
      expect(await service.saveAll('u1', prefs), isFalse);
      CloudSyncService.releaseGlobalSyncLock();
    });

    test(
      'releases the global lock and returns false after repeated failures',
      () async {
        when(
          () => docRef.set(any(), any()),
        ).thenThrow(FirebaseException(code: 'unavailable', plugin: 'mock'));
        await service.init(prefs);
        service.markDirty('firstName');
        expect(prefs.getString('firstName'), isNull);
        // Fuerza un valor para que el data no esté vacío.
        prefs.setString('firstName', 'Ana');
        expect(await service.saveAll('u1', prefs), isFalse);
        expect(CloudSyncService.isGlobalSyncInProgress, isFalse);
      },
    );
  });

  group('CloudSyncService.loadAll', () {
    test('returns false when not initialized', () async {
      expect(await service.loadAll('u1', prefs), isFalse);
    });

    test('returns true and flags an initial re-checksum load', () async {
      when(() => docRef.get()).thenAnswer((_) async => docSnapshot);
      when(() => docSnapshot.exists).thenReturn(true);
      when(
        () => docSnapshot.data(),
      ).thenReturn({'firstName': 'Ana', 'age': 30});
      await service.init(prefs);

      final ok = await service.loadAll('u1', prefs);

      expect(ok, isTrue);
      expect(prefs.getString('firstName'), 'Ana');
      expect(prefs.getBool('learning_needs_rechecksum'), isTrue);
    });

    test('returns false when the document does not exist', () async {
      when(() => docRef.get()).thenAnswer((_) async => docSnapshot);
      when(() => docSnapshot.exists).thenReturn(false);
      await service.init(prefs);
      expect(await service.loadAll('u1', prefs), isFalse);
    });

    test('returns false when the document has no data', () async {
      when(() => docRef.get()).thenAnswer((_) async => docSnapshot);
      when(() => docSnapshot.exists).thenReturn(true);
      when(() => docSnapshot.data()).thenReturn(null);
      await service.init(prefs);
      expect(await service.loadAll('u1', prefs), isFalse);
    });
  });

  group('CloudSyncService.deleteCloudData', () {
    test('returns false when not initialized', () async {
      expect(await service.deleteCloudData('u1'), isFalse);
    });

    test('deletes the user document', () async {
      when(() => docRef.delete()).thenAnswer((_) async {});
      await service.init(prefs);
      expect(await service.deleteCloudData('u1'), isTrue);
      verify(() => docRef.delete()).called(1);
    });

    test('returns false when the delete fails', () async {
      when(
        () => docRef.delete(),
      ).thenThrow(FirebaseException(code: 'unavailable', plugin: 'mock'));
      await service.init(prefs);
      expect(await service.deleteCloudData('u1'), isFalse);
    });
  });

  group('CloudSyncService.pending writes persistence', () {
    test('restores pending writes from local storage on init', () async {
      when(() => docRef.update(any())).thenAnswer((_) async {});
      SharedPreferences.setMockInitialValues({
        'cloud_pending_writes': jsonEncode({
          'firstName': 'Ana',
          '_ts_firstName': '2026-01-01T00:00:00.000',
        }),
        'cloud_last_sync': '2026-01-02T00:00:00.000',
      });
      prefs = await SharedPreferences.getInstance();
      service = CloudSyncService(
        authService: auth,
        firestoreService: FirestoreService.instance,
      )..overrideFirestoreInstance = db;
      FirestoreService.instance.overrideDbInstance = db;

      await service.init(prefs);

      expect(service.lastSync, isNotNull);
      // Un notifyFieldChanged posterior arma el timer y flushea todo,
      // incluidos los writes restaurados del storage.
      service.notifyFieldChanged('motivation', 'Disciplina');
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final restored =
          verify(() => docRef.update(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(restored['firstName'], 'Ana');
      expect(restored['motivation'], 'Disciplina');
    });

    test('tolerates a corrupted pending-writes payload', () async {
      SharedPreferences.setMockInitialValues({
        'cloud_pending_writes': 'not-json{{{',
      });
      prefs = await SharedPreferences.getInstance();
      service = CloudSyncService(
        authService: auth,
        firestoreService: FirestoreService.instance,
      )..overrideFirestoreInstance = db;
      FirestoreService.instance.overrideDbInstance = db;
      await service.init(prefs);
    });
  });
}
