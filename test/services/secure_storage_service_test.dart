import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/secure_storage_service.dart';

void main() {
  late SecureStorageService service;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    service = SecureStorageService.instance;
  });

  group('SecureStorageService', () {
    test('write then read round-trips a value with a prefixed key', () async {
      await service.write('theme', 'dark');

      expect(await service.read('theme'), 'dark');
      expect(await service.containsKey('theme'), true);
    });

    test('read returns null for a missing key', () async {
      expect(await service.read('missing'), isNull);
      expect(await service.containsKey('missing'), false);
    });

    test('delete removes only the requested key', () async {
      await service.write('a', '1');
      await service.write('b', '2');
      await service.delete('a');

      expect(await service.read('a'), isNull);
      expect(await service.read('b'), '2');
    });

    test('deleteAll removes only app-prefixed keys', () async {
      FlutterSecureStorage.setMockInitialValues({
        'ss_session': 'abc',
        'other_plugin_data': '3',
      });
      await service.deleteAll();

      const storage = FlutterSecureStorage();
      expect(await service.read('session'), isNull);
      expect(await storage.read(key: 'other_plugin_data'), '3');
    });

    test('delete of a missing key does not throw', () async {
      await expectLater(() => service.delete('never_written'), returnsNormally);
    });

    test('deleteAll does not throw on empty storage', () async {
      await expectLater(() => service.deleteAll(), returnsNormally);
    });
  });
}
