import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sagen/services/whats_new_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'SAGEN',
      packageName: 'com.sagen.app',
      version: '5.1.2',
      buildNumber: '9',
      buildSignature: '',
    );
  });

  test('returns false on first launch and remembers the version', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = WhatsNewService(prefs);
    expect(await service.shouldShow(), isFalse);
    expect(prefs.getString('whats_new_last_version'), '5.1.2');
  });

  test('returns false when the version has not changed', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = WhatsNewService(prefs);
    expect(await service.shouldShow(), isFalse);
    expect(await service.shouldShow(), isFalse);
  });

  test('returns true when the app version has changed', () async {
    final prefs = await SharedPreferences.getInstance();
    final service = WhatsNewService(prefs);
    await service.shouldShow();
    PackageInfo.setMockInitialValues(
      appName: 'SAGEN',
      packageName: 'com.sagen.app',
      version: '5.2.0',
      buildNumber: '9',
      buildSignature: '',
    );
    expect(await service.shouldShow(), isTrue);
  });

  test('returns true when a previous version was stored', () async {
    SharedPreferences.setMockInitialValues({'whats_new_last_version': '4.0.0'});
    final prefs = await SharedPreferences.getInstance();
    final service = WhatsNewService(prefs);
    expect(await service.shouldShow(), isTrue);
    expect(prefs.getString('whats_new_last_version'), '5.1.2');
  });

  test('updates stored version after showing', () async {
    SharedPreferences.setMockInitialValues({'whats_new_last_version': '4.0.0'});
    final prefs = await SharedPreferences.getInstance();
    final service = WhatsNewService(prefs);
    expect(await service.shouldShow(), isTrue);
    expect(await service.shouldShow(), isFalse);
  });
}
