import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/result.dart';

void main() {
  group('AppResult.ok', () {
    test('stores value', () {
      final result = AppResult.ok(42);
      expect(result, isA<AppOk<int>>());
      expect(result.value, 42);
    });

    test('isOk returns true', () {
      final result = AppResult.ok('hello');
      expect(result.isOk, true);
      expect(result.isError, false);
    });

    test('value returns value', () {
      final result = AppResult.ok(10);
      expect(result.value, 10);
    });

    test('error returns null', () {
      final result = AppResult.ok(10);
      expect(result.error, isNull);
    });
  });

  group('AppResult.error', () {
    test('stores error', () {
      final error = Exception('fail');
      final result = AppResult.error(error);
      expect(result, isA<AppError>());
      expect(result.error, error);
    });

    test('isError returns true', () {
      final result = AppResult.error(Exception('fail'));
      expect(result.isError, true);
      expect(result.isOk, false);
    });

    test('value returns null', () {
      final result = AppResult.error(Exception('fail'));
      expect(result.value, isNull);
    });
  });

  group('orElse', () {
    test('returns value for Ok', () {
      final result = AppResult.ok(5);
      expect(result.orElse(0), 5);
    });

    test('returns fallback for Error', () {
      final result = AppResult.error(Exception('fail'));
      expect(result.orElse(99), 99);
    });
  });

  group('orElseGet', () {
    test('returns value for Ok', () {
      final result = AppResult.ok(5);
      expect(result.orElseGet((e) => 0), 5);
    });

    test('calls function for Error', () {
      final error = Exception('fail');
      final result = AppResult.error(error);
      expect(result.orElseGet((e) => 42), 42);
      expect(result.orElseGet((e) => identical(e, error)), true);
    });
  });

  group('map', () {
    test('transforms Ok value', () {
      final result = AppResult.ok(3);
      final mapped = result.map((v) => v * 2);
      expect(mapped, isA<AppOk<int>>());
      expect(mapped.value, 6);
    });

    test('returns Error unchanged', () {
      final error = Exception('fail');
      final result = AppResult.error(error);
      final mapped = result.map((v) => v * 2);
      expect(mapped, isA<AppError>());
      expect(mapped.error, error);
    });
  });

  group('resultOf', () {
    test('wraps success', () async {
      final result = await resultOf(() async => 42);
      expect(result.isOk, true);
      expect(result.value, 42);
    });

    test('wraps exception', () async {
      final result = await resultOf<int>(() async => throw Exception('boom'));
      expect(result.isError, true);
      expect((result.error as Exception).toString(), contains('boom'));
    });
  });

  group('resultOfSync', () {
    test('wraps success', () {
      final result = resultOfSync(() => 42);
      expect(result.isOk, true);
      expect(result.value, 42);
    });

    test('wraps exception', () {
      final result = resultOfSync<int>(() => throw Exception('boom'));
      expect(result.isError, true);
      expect((result.error as Exception).toString(), contains('boom'));
    });
  });

  group('toString', () {
    test('AppOk.toString', () {
      final result = AppResult.ok(42);
      expect(result.toString(), 'AppResult.ok(42)');
    });

    test('AppError.toString', () {
      final error = Exception('fail');
      final result = AppResult.error(error);
      expect(result.toString(), 'AppResult.error($error)');
    });
  });

  group('pattern matching with switch', () {
    test('matches AppOk', () {
      final result = AppResult.ok(10);
      final description = switch (result) {
        AppOk(:final value) => 'ok: $value',
        AppError(:final error) => 'error: $error',
      };
      expect(description, 'ok: 10');
    });

    test('matches AppError', () {
      final result = AppResult.error(Exception('fail'));
      final description = switch (result) {
        AppOk(:final value) => 'ok: $value',
        AppError(:final error) => 'error: $error',
      };
      expect(description, contains('error:'));
    });
  });
}
