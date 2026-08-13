import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/smart_cache.dart';

void main() {
  group('CacheEntry', () {
    test('isExpired returns false when within TTL', () {
      final entry = CacheEntry<String>(
        data: 'test',
        cachedAt: DateTime.now(),
        ttl: const Duration(minutes: 5),
      );
      expect(entry.isExpired, isFalse);
    });

    test('isExpired returns true when past TTL', () {
      final entry = CacheEntry<String>(
        data: 'test',
        cachedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        ttl: const Duration(minutes: 5),
      );
      expect(entry.isExpired, isTrue);
    });

    test('isExpired returns true for zero TTL', () {
      final entry = CacheEntry<String>(
        data: 'test',
        cachedAt: DateTime.now().subtract(const Duration(milliseconds: 1)),
        ttl: Duration.zero,
      );
      expect(entry.isExpired, isTrue);
    });

    test('toJson produces correct structure', () {
      final now = DateTime(2024, 1, 15, 12, 0, 0);
      final entry = CacheEntry<String>(
        data: 'hello',
        cachedAt: now,
        ttl: const Duration(minutes: 5),
      );

      final json = entry.toJson();
      expect(json['data'], equals('hello'));
      expect(json['cachedAt'], equals(now.toIso8601String()));
      expect(json['ttlMs'], equals(300000)); // 5 * 60 * 1000
    });

    test('toJson handles non-string data', () {
      final entry = CacheEntry<int>(
        data: 42,
        cachedAt: DateTime(2024, 1, 15),
        ttl: const Duration(minutes: 5),
      );

      final json = entry.toJson();
      expect(json['data'], isNotNull);
    });

    test('fromJson restores string data correctly', () {
      final now = DateTime(2024, 1, 15, 12, 0, 0);
      final json = {
        'data': 'hello',
        'cachedAt': now.toIso8601String(),
        'ttlMs': 300000,
      };

      final entry = CacheEntry<String>.fromJson(json, (data) => data as String);
      expect(entry.data, equals('hello'));
      expect(entry.ttl, equals(const Duration(minutes: 5)));
    });

    test('fromJson defaults ttlMs to 300000 when missing', () {
      final json = {
        'data': 'test',
        'cachedAt': DateTime.now().toIso8601String(),
      };

      final entry = CacheEntry<String>.fromJson(json, (data) => data as String);
      expect(entry.ttl, equals(const Duration(minutes: 5)));
    });
  });

  group('SmartCache — NoOp behavior', () {
    test('instance returns no-op cache when not initialized', () {
      expect(SmartCache.isInitialized, isFalse);
      final result = SmartCache.instance.get<String>(
        'key',
        (data) => data as String,
      );
      expect(result, isNull);
    });

    test('set is no-op when not initialized', () async {
      await SmartCache.instance.set<String>('key', 'value');
      // Should not throw
    });

    test('invalidate is no-op when not initialized', () async {
      await SmartCache.instance.invalidate('key');
      // Should not throw
    });

    test('invalidateAll is no-op when not initialized', () async {
      await SmartCache.instance.invalidateAll();
      // Should not throw
    });
  });

  group('SmartCache — Initialized', () {
    late SharedPreferences prefs;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      await SmartCache.init(prefs);
    });
    tearDown(() async {
      await SmartCache.instance.invalidateAll();
    });

    test('stores and retrieves string values', () async {
      await SmartCache.instance.set('test_key', 'hello');
      final result = SmartCache.instance.get<String>(
        'test_key',
        SmartCache.stringData,
      );
      expect(result, 'hello');
    });

    test('returns null for missing keys', () {
      final result = SmartCache.instance.get<String>(
        'missing',
        SmartCache.stringData,
      );
      expect(result, isNull);
    });

    test('respects TTL expiration', () async {
      await SmartCache.instance.set(
        'expires_soon',
        'data',
        ttl: const Duration(milliseconds: 1),
      );
      await Future.delayed(const Duration(milliseconds: 10));
      final result = SmartCache.instance.get<String>(
        'expires_soon',
        SmartCache.stringData,
      );
      expect(result, isNull);
    });

    test('invalidates single key', () async {
      await SmartCache.instance.set('key_a', 'a');
      await SmartCache.instance.set('key_b', 'b');
      await SmartCache.instance.invalidate('key_a');
      expect(
        SmartCache.instance.get<String>('key_a', SmartCache.stringData),
        isNull,
      );
      expect(
        SmartCache.instance.get<String>('key_b', SmartCache.stringData),
        'b',
      );
    });

    test('invalidates all keys', () async {
      await SmartCache.instance.set('k1', 'v1');
      await SmartCache.instance.set('k2', 'v2');
      await SmartCache.instance.invalidateAll();
      expect(
        SmartCache.instance.get<String>('k1', SmartCache.stringData),
        isNull,
      );
      expect(
        SmartCache.instance.get<String>('k2', SmartCache.stringData),
        isNull,
      );
    });

    test('stores and retrieves int values', () async {
      await SmartCache.instance.set('int_key', 42);
      final result = SmartCache.instance.get<int>(
        'int_key',
        SmartCache.intData,
      );
      expect(result, 42);
    });

    test('persists in SharedPreferences', () async {
      await SmartCache.instance.set('persist', 'stored');
      await Future.delayed(const Duration(milliseconds: 300));
      final raw = prefs.getString('smart_cache_persist');
      expect(raw, isNotNull);
      expect(raw, contains('stored'));
    });

    test('respects maxMemoryEntries limit', () async {
      // Fill beyond the default limit of 100
      for (int i = 0; i < 105; i++) {
        await SmartCache.instance.set('key_$i', 'value_$i');
      }
      // Should not throw, oldest entries should be evicted from memory
      final result = SmartCache.instance.get<String>(
        'key_104',
        SmartCache.stringData,
      );
      expect(result, 'value_104');
    });
  });
}
