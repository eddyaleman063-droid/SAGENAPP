import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('singleton returns same instance', () {
      final a = ConnectivityService.instance;
      final b = ConnectivityService.instance;
      expect(identical(a, b), isTrue);
    });

    test('online defaults to false before start', () {
      final service = ConnectivityService.instance;
      expect(service.online.value, isFalse);
    });

    test('offlineSaveCount defaults to 0', () {
      final service = ConnectivityService.instance;
      expect(service.offlineSaveCount.value, 0);
    });

    test('offlineSavedForLater returns current count', () {
      final service = ConnectivityService.instance;
      expect(service.offlineSavedForLater, 0);
    });

    test('start does not throw', () {
      final service = ConnectivityService.instance;
      expect(() => service.start(), returnsNormally);
      service.stop();
    });

    test('stop is idempotent', () {
      final service = ConnectivityService.instance;
      service.start();
      service.stop();
      service.stop();
    });
  });
}
