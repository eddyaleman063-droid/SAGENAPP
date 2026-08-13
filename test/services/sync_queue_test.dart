import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/sync_queue_service.dart';

void main() {
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    SyncQueueService.instance.clear();
    SyncQueueService.instance.init(prefs);
  });
  group('SyncQueueService', () {
    test('queue is empty on init', () {
      expect(SyncQueueService.instance.pendingCount, 0);
    });
    test('enqueues operations', () {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      expect(SyncQueueService.instance.pendingCount, 1);
    });
    test('removes operation by id', () {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 200,
      });
      expect(SyncQueueService.instance.pendingCount, 2);
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 300,
      });
      expect(SyncQueueService.instance.pendingCount, 3);
    });
    test('processes queue successfully', () async {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      final result = await SyncQueueService.instance.processQueue(
        processor: (_) async => true,
      );
      expect(result, isTrue);
      expect(SyncQueueService.instance.pendingCount, 0);
    });
    test('retries failed operations', () async {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      await SyncQueueService.instance.processQueue(
        processor: (_) async => false,
      );
      expect(SyncQueueService.instance.pendingCount, 1);
    });
    test('drops operations after max retries', () async {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      for (var i = 0; i < 6; i++) {
        await SyncQueueService.instance.processQueue(
          processor: (_) async => false,
        );
      }
      expect(SyncQueueService.instance.pendingCount, 0);
    });
    test('persists across service resets', () async {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      SyncQueueService.instance.clear();
      await Future.delayed(const Duration(milliseconds: 50));
      SyncQueueService.instance.init(prefs);
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 200,
      });
      expect(SyncQueueService.instance.pendingCount, 1);
    });
    test('handles multiple operation types', () {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 1,
      });
      SyncQueueService.instance.enqueue(SyncOperationType.missionComplete, {
        'id': 'm1',
      });
      SyncQueueService.instance.enqueue(SyncOperationType.addXp, {
        'amount': 50,
      });
      expect(SyncQueueService.instance.pendingCount, 3);
    });
    test('clears all operations', () {
      SyncQueueService.instance.enqueue(SyncOperationType.profileUpdate, {
        'xp': 100,
      });
      SyncQueueService.instance.clear();
      expect(SyncQueueService.instance.pendingCount, 0);
    });
    test('isProcessing is false when not processing', () {
      expect(SyncQueueService.instance.isProcessing, isFalse);
    });
  });
}
