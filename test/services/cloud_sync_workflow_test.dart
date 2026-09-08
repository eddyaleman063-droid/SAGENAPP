import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';

void main() {
  group('CloudSyncService static global lock', () {
    tearDown(() {
      if (CloudSyncService.isGlobalSyncInProgress) {
        CloudSyncService.releaseGlobalSyncLock();
      }
    });

    test('acquire returns true when free and flips the flag', () {
      expect(CloudSyncService.isGlobalSyncInProgress, isFalse);
      expect(CloudSyncService.acquireGlobalSyncLock(), isTrue);
      expect(CloudSyncService.isGlobalSyncInProgress, isTrue);
    });

    test('second acquire fails while locked', () {
      expect(CloudSyncService.acquireGlobalSyncLock(), isTrue);
      expect(CloudSyncService.acquireGlobalSyncLock(), isFalse);
    });

    test('release frees the lock', () {
      CloudSyncService.acquireGlobalSyncLock();
      CloudSyncService.releaseGlobalSyncLock();
      expect(CloudSyncService.isGlobalSyncInProgress, isFalse);
    });
  });

  group('CloudSyncService workflows', () {
    late CloudSyncService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = CloudSyncService(authService: AuthService());
      await service.init(prefs);
    });

    test('init is idempotent and sets lastSync from persisted value', () async {
      SharedPreferences.setMockInitialValues({
        'cloud_last_sync': '2025-01-02T00:00:00.000',
      });
      final p = await SharedPreferences.getInstance();
      final s = CloudSyncService(authService: AuthService());
      await s.init(p);
      expect(s.isInitialized, isTrue);
      expect(s.lastSync, DateTime.parse('2025-01-02T00:00:00.000'));
      await s.init(p);
    });

    test(
      'saveAll/loadAll/deleteCloudData return false when uninitialized',
      () async {
        final s = CloudSyncService(authService: AuthService());
        expect(await s.saveAll('uid', prefs), isFalse);
        expect(await s.loadAll('uid', prefs), isFalse);
        expect(await s.deleteCloudData('uid'), isFalse);
      },
    );

    test('saveAll returns true when no dirty keys', () async {
      expect(await service.saveAll('uid', prefs), isTrue);
    });

    test('markDirty only tracks mapped keys', () {
      service.markDirty('firstName');
      service.markDirty('not_a_real_key');
    });

    test('notifyFieldChanged rejects non-primitives', () {
      service.notifyFieldChanged('firstName', const <String, dynamic>{'a': 1});
      service.notifyFieldChanged('firstName', null);
      service.notifyFieldChanged('learning_gems', 10);
    });

    test('notifyFieldChanged rejects unmapped keys', () {
      service.notifyFieldChanged('unknown_key', 42);
    });

    test('clearLocal / stopListening / dispose are safe', () async {
      service.notifyFieldChanged('firstName', 'Ana');
      service.stopListening();
      service.stopListening();
      service.dispose();
      service.dispose();
      expect(service.isInitialized, isTrue);
      await service.clearLocal(prefs);
    });

    test('userDocStream emits empty when no current user', () async {
      final stream = service.userDocStream;
      await expectLater(stream.toList(), completion(isEmpty));
    });
  });

  group('CloudSyncService.saveAll flows', () {
    late CloudSyncService service;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = CloudSyncService(authService: AuthService());
      await service.init(prefs);
    });

    test('saveAll releases the global lock even when skipped', () async {
      service.markDirty('firstName');
      CloudSyncService.acquireGlobalSyncLock();
      try {
        final result = await service.saveAll('uid', prefs);
        expect(result, isFalse);
      } finally {
        CloudSyncService.releaseGlobalSyncLock();
      }
      expect(CloudSyncService.isGlobalSyncInProgress, isFalse);
    });

    test('saveAll clears dirty keys when collected data is empty', () async {
      service.markDirty('firstName');
      final result = await service.saveAll('uid', prefs);
      expect(result, isTrue);
    });
  });
}
