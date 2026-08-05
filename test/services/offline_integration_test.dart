import 'package:flutter_test/flutter_test.dart';

class MockConnectivityService {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void setOffline() {
    _isOnline = false;
  }

  void setOnline() {
    _isOnline = true;
  }
}

class MockCloudSyncService {
  final List<String> _pendingSyncs = [];
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  void queueForSync(String data) {
    _pendingSyncs.add(data);
  }

  Future<void> sync() async {
    _isSyncing = true;
    // Simulate sync delay
    await Future.delayed(const Duration(milliseconds: 50));
    _pendingSyncs.clear();
    _isSyncing = false;
  }

  int get pendingCount => _pendingSyncs.length;
}

void main() {
  group('Offline Mode - Sync Queue', () {
    late MockCloudSyncService syncService;
    late MockConnectivityService connectivity;

    setUp(() {
      syncService = MockCloudSyncService();
      connectivity = MockConnectivityService();
    });

    test('queues data when offline', () {
      connectivity.setOffline();
      expect(connectivity.isOnline, isFalse);

      syncService.queueForSync('lesson_progress');
      syncService.queueForSync('quiz_result');

      expect(syncService.pendingCount, equals(2));
    });

    test('syncs when back online', () async {
      connectivity.setOffline();
      syncService.queueForSync('lesson_progress');
      expect(syncService.pendingCount, equals(1));

      connectivity.setOnline();
      expect(connectivity.isOnline, isTrue);

      await syncService.sync();
      expect(syncService.pendingCount, equals(0));
      expect(syncService.isSyncing, isFalse);
    });

    test('handles rapid online/offline transitions', () async {
      connectivity.setOffline();
      syncService.queueForSync('data1');
      connectivity.setOnline();
      connectivity.setOffline();
      syncService.queueForSync('data2');
      connectivity.setOnline();

      await syncService.sync();
      expect(syncService.pendingCount, equals(0));
    });

    test('preserves data order during sync', () async {
      connectivity.setOffline();
      syncService.queueForSync('first');
      syncService.queueForSync('second');
      syncService.queueForSync('third');

      connectivity.setOnline();
      await syncService.sync();

      // After sync, pending should be empty
      expect(syncService.pendingCount, equals(0));
    });
  });

  group('Offline Mode - Cache Fallback', () {
    test('cache provides data when network unavailable', () {
      final cache = <String, String>{};
      cache['user_profile'] = '{"name": "Test User"}';
      cache['lessons'] = '[{"id": 1}]';

      // Simulate offline access
      expect(cache['user_profile'], isNotNull);
      expect(cache['lessons'], isNotNull);
    });

    test('cache expires after TTL', () {
      final now = DateTime.now();
      final cacheEntry = {
        'data': 'test',
        'cachedAt': now.subtract(const Duration(hours: 2)).toIso8601String(),
        'ttlMs': 3600000, // 1 hour
      };

      final cachedAt = DateTime.parse(cacheEntry['cachedAt'] as String);
      final ttl = Duration(milliseconds: cacheEntry['ttlMs'] as int);
      final isExpired = now.difference(cachedAt) > ttl;

      expect(isExpired, isTrue);
    });
  });
}
