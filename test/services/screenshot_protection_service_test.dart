import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/screenshot_protection_service.dart';

const _channel = MethodChannel('com.sagen/secure');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enableSecure sends setSecure with true', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
      captured = call;
      return null;
    });
    await ScreenshotProtectionService().enableSecure();
    expect(captured?.method, 'setSecure');
    expect(captured?.arguments, {'secure': true});
  });

  test('disableSecure sends setSecure with false', () async {
    MethodCall? captured;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
      captured = call;
      return null;
    });
    await ScreenshotProtectionService().disableSecure();
    expect(captured?.method, 'setSecure');
    expect(captured?.arguments, {'secure': false});
  });

  test('enableSecure swallows platform errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
      throw PlatformException(code: 'not_implemented');
    });
    await expectLater(
      ScreenshotProtectionService().enableSecure(),
      completes,
    );
  });

  test('disableSecure swallows platform errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (MethodCall call) async {
      throw PlatformException(code: 'not_implemented');
    });
    await expectLater(
      ScreenshotProtectionService().disableSecure(),
      completes,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });
}
