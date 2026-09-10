import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/auth/auth_sync_manager.dart';
import 'package:sagen/services/auth/email_verification_manager.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuth extends Mock implements AuthService {}

class _MockCloudSync extends Mock implements CloudSyncService {}

// ignore: subtype_of_sealed_class
class _MockFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockDocRef extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockDocSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _FakePrefs extends Fake implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  registerFallbackValue(_FakePrefs());

  group('EmailVerificationManager', () {
    late _MockAuth auth;
    late EmailVerificationManager manager;

    setUp(() {
      auth = _MockAuth();
      manager = EmailVerificationManager(auth);
      when(() => auth.reloadUser()).thenAnswer((_) async => false);
    });

    tearDown(() => manager.dispose());

    test('notifies once when the user becomes verified', () {
      fakeAsync((async) {
        var verifiedCalls = 0;
        var reloads = 0;
        when(() => auth.reloadUser()).thenAnswer((_) async {
          reloads++;
          return reloads >= 2;
        });
        manager.startAutoCheck((verified) => verifiedCalls++);

        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();
        expect(verifiedCalls, 0);

        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(verifiedCalls, 1);
        // El timer ya fue cancelado: no hay más intentos.
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(verifiedCalls, 1);
      });
    });

    test('stops polling after reaching the max verification attempts', () {
      fakeAsync((async) {
        var verifiedCalls = 0;
        manager.startAutoCheck((verified) => verifiedCalls++);

        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();

        expect(verifiedCalls, 0);
        expect(verify(() => auth.reloadUser()).callCount, 5);
      });
    });

    test('keeps polling when reloadUser throws', () {
      fakeAsync((async) {
        when(() => auth.reloadUser()).thenThrow(Exception('network'));
        manager.startAutoCheck((verified) {});

        async.elapse(const Duration(seconds: 11));
        async.flushMicrotasks();
        expect(verify(() => auth.reloadUser()).callCount, greaterThan(1));
      });
    });

    test('startAutoCheck resets the attempt counter after max attempts', () {
      fakeAsync((async) {
        manager.startAutoCheck((verified) {});
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();

        manager.startAutoCheck((verified) {});
        async.elapse(const Duration(seconds: 6));
        async.flushMicrotasks();

        expect(verify(() => auth.reloadUser()).callCount, 6);
      });
    });

    test('stopAutoCheck stops further reloads', () {
      fakeAsync((async) {
        manager.startAutoCheck((verified) {});
        async.elapse(const Duration(milliseconds: 5500));
        async.flushMicrotasks();

        manager.stopAutoCheck();
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();

        expect(verify(() => auth.reloadUser()).callCount, 1);
      });
    });
  });

  group('AuthSyncManager', () {
    late _MockCloudSync cloudSync;
    late AuthSyncManager manager;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      cloudSync = _MockCloudSync();
      manager = AuthSyncManager(cloudSync);
      when(() => cloudSync.loadAll(any(), any())).thenAnswer((_) async => true);
      when(() => cloudSync.saveAll(any(), any())).thenAnswer((_) async => true);
      when(
        () => cloudSync.deleteCloudData(any()),
      ).thenAnswer((_) async => true);
      when(() => cloudSync.clearLocal(any())).thenAnswer((_) async => 0);
    });

    test('syncAfterLogin returns after a successful sync', () async {
      await manager.syncAfterLogin('u1', prefs);
      verify(() => cloudSync.loadAll('u1', prefs)).called(1);
    });

    test('syncAfterLogin retries until success', () async {
      var calls = 0;
      when(() => cloudSync.loadAll(any(), any())).thenAnswer((_) async {
        calls++;
        if (calls == 1) throw Exception('network');
        return true;
      });
      await manager.syncAfterLogin('u1', prefs);
      expect(calls, 2);
    });

    test(
      'syncAfterLogin gives up after three failures without throwing',
      () async {
        when(
          () => cloudSync.loadAll(any(), any()),
        ).thenThrow(Exception('network'));
        await manager.syncAfterLogin('u1', prefs);
        expect(verify(() => cloudSync.loadAll(any(), any())).callCount, 3);
      },
    );

    test('startListening and stopListening delegate to cloud sync', () {
      manager.startListening('u1', prefs);
      manager.stopListening();
      verify(() => cloudSync.startListening('u1', prefs)).called(1);
      verify(() => cloudSync.stopListening()).called(1);
    });

    test('saveBeforeSignOut saves and clears local data', () async {
      await manager.saveBeforeSignOut('u1', prefs);
      verify(() => cloudSync.saveAll('u1', prefs)).called(1);
      verify(() => cloudSync.clearLocal(prefs)).called(1);
    });

    test('saveBeforeSignOut swallows failures', () async {
      when(() => cloudSync.saveAll(any(), any())).thenThrow(Exception('boom'));
      await manager.saveBeforeSignOut('u1', prefs);
      verifyNever(() => cloudSync.clearLocal(prefs));
    });

    test('deleteCloudData deletes and clears local data', () async {
      await manager.deleteCloudData('u1', prefs);
      verify(() => cloudSync.deleteCloudData('u1')).called(1);
      verify(() => cloudSync.clearLocal(prefs)).called(1);
    });

    test('deleteCloudData swallows failures', () async {
      when(() => cloudSync.deleteCloudData(any())).thenThrow(Exception('boom'));
      await manager.deleteCloudData('u1', prefs);
      verifyNever(() => cloudSync.clearLocal(prefs));
    });
  });

  group('AuthSyncManager.loadOnboardingStatus', () {
    late _MockCloudSync cloudSync;
    late _MockFirestore db;
    late _MockCollection coll;
    late _MockDocRef docRef;
    late _MockDocSnapshot docSnap;
    late AuthSyncManager manager;

    setUp(() {
      cloudSync = _MockCloudSync();
      db = _MockFirestore();
      coll = _MockCollection();
      docRef = _MockDocRef();
      docSnap = _MockDocSnapshot();
      manager = AuthSyncManager(cloudSync)..overrideFirestoreInstance = db;
      when(() => db.collection('users')).thenReturn(coll);
      when(() => coll.doc(any<String>())).thenReturn(docRef);
    });

    test('returns true when onboarding is completed', () async {
      when(() => docRef.get()).thenAnswer((_) async => docSnap);
      when(() => docSnap.exists).thenReturn(true);
      when(() => docSnap.data()).thenReturn({'onboardingCompleted': true});
      expect(await manager.loadOnboardingStatus('u1'), isTrue);
    });

    test('returns false when onboarding is not completed', () async {
      when(() => docRef.get()).thenAnswer((_) async => docSnap);
      when(() => docSnap.exists).thenReturn(true);
      when(() => docSnap.data()).thenReturn({'onboardingCompleted': false});
      expect(await manager.loadOnboardingStatus('u1'), isFalse);
    });

    test('returns false when the document does not exist', () async {
      when(() => docRef.get()).thenAnswer((_) async => docSnap);
      when(() => docSnap.exists).thenReturn(false);
      expect(await manager.loadOnboardingStatus('u1'), isFalse);
    });

    test('returns null when the read fails', () async {
      when(
        () => docRef.get(),
      ).thenThrow(FirebaseException(code: 'unavailable', plugin: 'mock'));
      expect(await manager.loadOnboardingStatus('u1'), isNull);
    });

    test('returns null when a newer load superseded the read', () async {
      final completer = Completer<DocumentSnapshot<Map<String, dynamic>>>();
      when(() => docRef.get()).thenAnswer((_) => completer.future);
      final pending = manager.loadOnboardingStatus('u1');
      manager.cancelInflightLoads();
      completer.complete(docSnap);
      expect(await pending, isNull);
    });

    test('cancelInflightLoads invalidates pending reads', () async {
      final completer = Completer<DocumentSnapshot<Map<String, dynamic>>>();
      when(() => docRef.get()).thenAnswer((_) => completer.future);
      final pending = manager.loadOnboardingStatus('u1');
      manager.cancelInflightLoads();
      completer.complete(docSnap);
      expect(await pending, isNull);
    });
  });
}
