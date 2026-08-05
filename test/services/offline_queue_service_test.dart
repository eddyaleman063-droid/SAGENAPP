import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/offline_queue_service.dart';

void main() {
  group('OfflineQueueService', () {
    test('singleton returns same instance', () {
      final a = OfflineQueueService.instance;
      final b = OfflineQueueService.instance;
      expect(identical(a, b), isTrue);
    });

    test('initial state has empty queue', () {
      final service = OfflineQueueService.instance;
      expect(service.queue, isEmpty);
    });

    test('pendingCount is 0 initially', () {
      final service = OfflineQueueService.instance;
      expect(service.pendingCount, 0);
    });

    test('isSyncing is false initially', () {
      final service = OfflineQueueService.instance;
      expect(service.isSyncing, isFalse);
    });

    test('queue returns unmodifiable list', () {
      final service = OfflineQueueService.instance;
      expect(() => service.queue.add({'test': true}), throwsUnsupportedError);
    });

    test('clear does not throw', () async {
      final service = OfflineQueueService.instance;
      await service.clear();
      expect(service.queue, isEmpty);
    });

    test('dispose does not throw', () {
      final service = OfflineQueueService.instance;
      service.dispose();
    });
  });
}
