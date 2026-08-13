import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/utils/retry.dart';

void main() {
  group('retry', () {
    test('succeeds on first attempt', () async {
      final result = await retry(() async => 42);
      expect(result, 42);
    });

    test('succeeds after transient failure', () async {
      var attempts = 0;
      final result = await retry(() async {
        attempts++;
        if (attempts < 3) throw Exception('fail');
        return 'ok';
      });
      expect(result, 'ok');
      expect(attempts, 3);
    });

    test('throws after maxRetries exceeded', () async {
      var attempts = 0;
      try {
        await retry(() async {
          attempts++;
          throw Exception('always fail');
        }, config: const RetryConfig(maxRetries: 2));
        // ignore: dead_code
        fail('Should have thrown');
      } catch (_) {
        // expected
      }
      expect(attempts, 3);
    });

    test('respects shouldRetry returning false', () async {
      var attempts = 0;
      try {
        await retry(() async {
          attempts++;
          throw Exception('no retry');
        }, config: RetryConfig(maxRetries: 5, shouldRetry: (_) => false));
        // ignore: dead_code
        fail('Should have thrown');
      } catch (_) {
        // expected
      }
      expect(attempts, 1);
    });

    test('fixed delay policy retries correct number of times', () async {
      var attempts = 0;
      await retry(
        () async {
          attempts++;
          if (attempts < 3) throw Exception('fail');
        },
        config: const RetryConfig(
          maxRetries: 5,
          baseDelay: Duration.zero,
          policy: RetryPolicy.fixed,
        ),
      );
      expect(attempts, 3);
    });

    test('linearBackoff retries correct number of times', () async {
      var attempts = 0;
      await retry(
        () async {
          attempts++;
          if (attempts < 3) throw Exception('fail');
        },
        config: const RetryConfig(
          maxRetries: 5,
          baseDelay: Duration.zero,
          policy: RetryPolicy.linearBackoff,
        ),
      );
      expect(attempts, 3);
    });

    test('exponentialBackoff retries correct number of times', () async {
      var attempts = 0;
      await retry(
        () async {
          attempts++;
          if (attempts < 3) throw Exception('fail');
        },
        config: const RetryConfig(
          maxRetries: 5,
          baseDelay: Duration.zero,
          policy: RetryPolicy.exponentialBackoff,
        ),
      );
      expect(attempts, 3);
    });

    test('default config has maxRetries=3', () {
      const cfg = RetryConfig();
      expect(cfg.maxRetries, 3);
      expect(cfg.policy, RetryPolicy.linearBackoff);
    });
  });
}
