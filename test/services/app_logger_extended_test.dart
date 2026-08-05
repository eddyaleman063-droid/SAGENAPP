import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/app_logger.dart';

void main() {
  group('LogLevel enum', () {
    test('has all expected values', () {
      expect(LogLevel.values.length, equals(4));
      expect(LogLevel.values, contains(LogLevel.debug));
      expect(LogLevel.values, contains(LogLevel.info));
      expect(LogLevel.values, contains(LogLevel.warning));
      expect(LogLevel.values, contains(LogLevel.error));
    });
  });

  group('AppLogger singleton behavior', () {
    test('multiple instances share state', () {
      final logger1 = AppLogger();
      final logger2 = AppLogger();

      logger1.info('shared test');
      // Both instances should share the same underlying state
      expect(logger1.recentErrors.length, logger2.recentErrors.length);
    });
  });

  group('AppLogger production mode', () {
    test('setProductionMode does not throw', () {
      final logger = AppLogger();
      expect(() => logger.setProductionMode(true), returnsNormally);
      expect(() => logger.setProductionMode(false), returnsNormally);
    });
  });

  group('AppLogger error recording', () {
    test('error with exception and stack records correctly', () {
      final logger = AppLogger();
      final initialCount = logger.recentErrors.length;
      logger.error(
        'test error',
        Exception('bad'),
        StackTrace.current,
      );

      expect(logger.recentErrors.length, greaterThanOrEqualTo(initialCount + 1));
      expect(logger.recentErrors.last['message'], contains('test error'));
    });

    test('error without exception still records', () {
      final logger = AppLogger();
      final initialCount = logger.recentErrors.length;
      logger.error('simple error');

      expect(logger.recentErrors.length, greaterThanOrEqualTo(initialCount + 1));
    });

    test('recentErrors returns immutable list', () {
      final logger = AppLogger();
      logger.error('test');
      final errors = logger.recentErrors;
      errors.clear(); // Should not affect internal state
      expect(logger.recentErrors, isNotEmpty);
    });
  });
}
