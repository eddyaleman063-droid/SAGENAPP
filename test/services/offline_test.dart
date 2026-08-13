import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/connectivity_service.dart';
import 'package:sagen/services/smart_cache.dart';

void main() {
  group('Offline Mode - ConnectivityService', () {
    test('online defaults to false', () {
      final service = ConnectivityService.instance;
      expect(service.online.value, isFalse);
    });

    test('online value can be read', () {
      final service = ConnectivityService.instance;
      expect(service.online, isNotNull);
    });
  });

  group('Offline Mode - Cache Behavior', () {
    test('CacheEntry preserves data when offline', () {
      final entry = CacheEntry<String>(
        data: 'offline_data',
        cachedAt: DateTime.now(),
        ttl: const Duration(hours: 1),
      );

      expect(entry.data, equals('offline_data'));
      expect(entry.isExpired, isFalse);
    });

    test('CacheEntry expires after TTL', () {
      final entry = CacheEntry<String>(
        data: 'old_data',
        cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ttl: const Duration(hours: 1),
      );

      expect(entry.isExpired, isTrue);
    });
  });

  group('Offline Mode - SmartCache', () {
    test('SmartCache.get returns null when not initialized', () {
      // SmartCache._instance is null by default in tests
      final result = SmartCache.instance.get<String>(
        'test',
        (data) => data as String,
      );
      expect(result, isNull);
    });

    test('SmartCache.set is no-op when not initialized', () async {
      // Should not throw
      await SmartCache.instance.set<String>('key', 'value');
    });

    test('SmartCache.invalidate is no-op when not initialized', () async {
      // Should not throw
      await SmartCache.instance.invalidate('key');
    });
  });
}
