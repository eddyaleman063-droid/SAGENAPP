import 'package:flutter/services.dart';

import 'app_logger.dart';

/// Prevents screenshots on sensitive screens via FLAG_SECURE.
class ScreenshotProtectionService {
  ScreenshotProtectionService();

  static const _channel = MethodChannel('com.sagen/secure');

  Future<void> enableSecure() async {
    try {
      await _channel.invokeMethod('setSecure', {'secure': true});
    } catch (e) {
      AppLogger().error('Failed to enable screenshot protection', e);
    }
  }

  Future<void> disableSecure() async {
    try {
      await _channel.invokeMethod('setSecure', {'secure': false});
    } catch (e) {
      AppLogger().error('Failed to disable screenshot protection', e);
    }
  }
}
