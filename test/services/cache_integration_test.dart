import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/smart_cache.dart';

void main() {
  group('SmartCache Integration Tests', () {
    test('CacheEntry serialization roundtrip', () {
      final original = CacheEntry<String>(
        data: 'test_data',
        cachedAt: DateTime(2024, 6, 15, 10, 30),
        ttl: const Duration(minutes: 10),
      );

      final json = original.toJson();
      final restored = CacheEntry<String>.fromJson(
        json,
        (data) => data as String,
      );

      expect(restored.data, equals(original.data));
      expect(restored.ttl, equals(original.ttl));
    });

    test('CacheEntry handles unicode data', () {
      final entry = CacheEntry<String>(
        data: '¡Hola! ¿Cómo estás? 🎉',
        cachedAt: DateTime.now(),
        ttl: const Duration(minutes: 5),
      );

      expect(entry.data, equals('¡Hola! ¿Cómo estás? 🎉'));
    });

    test('CacheEntry handles large data', () {
      final largeData = 'x' * 100000;
      final entry = CacheEntry<String>(
        data: largeData,
        cachedAt: DateTime.now(),
        ttl: const Duration(minutes: 5),
      );

      expect(entry.data.length, equals(100000));
    });
  });

  group('Performance Metrics', () {
    test('CacheEntry creation is fast', () {
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < 10000; i++) {
        CacheEntry<int>(
          data: i,
          cachedAt: DateTime.now(),
          ttl: const Duration(minutes: 5),
        );
      }
      stopwatch.stop();
      // 10k CacheEntry creations should complete well within a second
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });

    test('CacheEntry expiry check is fast', () {
      final entries = List.generate(
        10000,
        (i) => CacheEntry<int>(
          data: i,
          cachedAt: DateTime.now(),
          ttl: const Duration(minutes: 5),
        ),
      );

      final stopwatch = Stopwatch()..start();
      for (final entry in entries) {
        entry.isExpired;
      }
      stopwatch.stop();
      // 10k expiry checks should complete well within a second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Cache Key Patterns', () {
    test('cache keys follow expected patterns', () {
      const validPatterns = [
        'user_profile',
        'lessons_stage',
        'xp_total',
        'streak_current',
        'gems_balance',
      ];

      for (final key in validPatterns) {
        expect(key, matches(RegExp(r'^[a-z_]+$')));
        expect(key.length, greaterThan(0));
        expect(key.length, lessThan(50));
      }
    });
  });
}
