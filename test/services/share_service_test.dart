import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/share_service.dart';

void main() {
  group('ShareService', () {
    test('is a singleton', () {
      final a = ShareService.instance;
      final b = ShareService.instance;
      expect(a, same(b));
    });

    test('shareImage returns false when platform unavailable', () async {
      final service = ShareService.instance;
      final result = await service.shareImage(Uint8List(0), text: 'test');
      expect(result, false);
    });
  });
}
