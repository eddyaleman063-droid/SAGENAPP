import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:safe_device/safe_device.dart';
import 'app_logger.dart';

/// Detects jailbroken/rooted devices and restricts access.
class DeviceIntegrityService {
  static final DeviceIntegrityService instance = DeviceIntegrityService._();
  DeviceIntegrityService._();
  final AppLogger _logger = AppLogger();

  bool _isCompromised = false;
  bool _checked = false;
  String? _compromisedReason;

  bool get isDeviceCompromised => _isCompromised;
  bool get hasBeenChecked => _checked;
  String? get compromisedReason => _compromisedReason;

  /// Whether the app should restrict sensitive operations
  bool get shouldRestrictAccess {
    if (kDebugMode) return false;
    return _isCompromised;
  }

  /// Known root indicator paths (multiple layers)
  static final List<String> _rootPaths = [
    '/system/app/Superuser.apk',
    '/system/xbin/su',
    '/system/bin/su',
    '/system/sbin/su',
    '/vendor/bin/su',
    '/data/local/xbin/su',
    '/data/local/bin/su',
    '/sdcard/xbin/su',
    '/sdcard/bin/su',
    '/system/app/SuperSU.apk',
    '/system/app/BusyBox.apk',
    '/system/framework/res.apk',
    '/system/build.prop',
  ];

  Future<void> check() async {
    try {
      final jailBroken = await SafeDevice.isJailBroken;
      final isRealDevice = await SafeDevice.isRealDevice;
      final isEmulator = !isRealDevice;

      // Additional file-system based root detection (bypasses safe_device spoofing)
      bool fsRootDetected = false;
      if (!jailBroken && !isEmulator) {
        final exists = await Future.wait(
          _rootPaths.map((path) => File(path).exists()),
        );
        final idx = exists.indexWhere((e) => e);
        if (idx != -1) {
          fsRootDetected = true;
          _compromisedReason = 'Root indicator found: ${_rootPaths[idx]}';
        }
      }

      _isCompromised = jailBroken || isEmulator || fsRootDetected;
      _checked = true;

      if (jailBroken) {
        _compromisedReason = 'Jailbreak/root device detected';
        _logger.warning('DeviceIntegrity: $_compromisedReason');
      }
      if (isEmulator) {
        _compromisedReason = 'Emulator detected';
        _logger.warning('DeviceIntegrity: $_compromisedReason');
      }
      if (fsRootDetected) {
        _logger.warning('DeviceIntegrity: $_compromisedReason');
      }

      if (!jailBroken && !isEmulator && !fsRootDetected) {
        _compromisedReason = null;
        _logger.info('DeviceIntegrity: device is clean');
      }
    } catch (e) {
      _logger.error('DeviceIntegrity: check failed, assuming compromised', e);
      _isCompromised = true;
      _compromisedReason = 'Integrity verification error';
      _checked = true;
    }
  }
}
