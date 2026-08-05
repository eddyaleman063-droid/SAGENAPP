import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

enum DeviceTier {
  lowEnd,
  midRange,
  highEnd,
}

/// Top-level function for compute isolate — reads /proc/meminfo
int _readMemTotalKBSync() {
  try {
    final file = File('/proc/meminfo');
    if (!file.existsSync()) return 0;
    final lines = file.readAsLinesSync();
    for (final line in lines) {
      if (line.startsWith('MemTotal:')) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length >= 2) return int.tryParse(parts[1]) ?? 0;
      }
      }
    } catch (e) {
      AppLogger().warning('DeviceTier: failed to read /proc/meminfo: $e');
    }
  return 0;
}

/// Top-level function for compute isolate — reads CPU cores
int _readCpuCoresSync() {
  try {
    final cpus = <int>[];
    final dir = Directory('/sys/devices/system/cpu/');
    if (!dir.existsSync()) return 0;
    for (final entity in dir.listSync()) {
      final name = entity.uri.pathSegments.last;
      final match = RegExp(r'^cpu(\d+)$').firstMatch(name);
      if (match != null) {
        cpus.add(int.parse(match.group(1)!));
      }
    }
    return cpus.isNotEmpty ? cpus.length : 0;
  } catch (_) {
    AppLogger().warning('DeviceTier: failed to read CPU core count');
    return 0;
  }
}

/// Combined detection function for compute isolate
DeviceTier _detectTierFromSystem(_) {
  if (Platform.isIOS) return DeviceTier.highEnd;
  final ramKB = _readMemTotalKBSync();
  if (ramKB > 0) {
    final ramMB = ramKB ~/ 1024;
    if (ramMB < 2048) return DeviceTier.lowEnd;
    if (ramMB < 4096) return DeviceTier.midRange;
    if (ramMB < 6144) return DeviceTier.midRange;
    return DeviceTier.highEnd;
  }

  final cpuCores = _readCpuCoresSync();
  if (cpuCores > 0 && cpuCores <= 4) return DeviceTier.lowEnd;
  if (cpuCores > 4 && cpuCores <= 6) return DeviceTier.midRange;

  return DeviceTier.midRange;
}

/// Detects device hardware tier to adapt UI animations and quality.
class LowEndDeviceDetector {
  static final LowEndDeviceDetector instance = LowEndDeviceDetector._();
  LowEndDeviceDetector._();

  DeviceTier _tier = DeviceTier.highEnd;
  bool _initialized = false;

  DeviceTier get tier => _tier;
  bool get isLowEnd => _tier == DeviceTier.lowEnd;
  bool get isMidRange => _tier == DeviceTier.midRange;

  bool get reduceAnimations => _tier == DeviceTier.lowEnd;
  bool get reduceBlur => _tier != DeviceTier.highEnd;
  bool get reduceShadows => _tier == DeviceTier.lowEnd;
  bool get reduceGlow => _tier != DeviceTier.highEnd;
  bool get reduceParticles => _tier == DeviceTier.lowEnd;
  bool get reduceTransparency => _tier != DeviceTier.highEnd;
  bool get useSimpleAnimations => _tier != DeviceTier.highEnd;
  bool get disableParallax => _tier == DeviceTier.lowEnd;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      _tier = DeviceTier.highEnd;
      return;
    }

    try {
      _tier = await compute(_detectTierFromSystem, null as dynamic);
    } catch (_) {
      AppLogger().warning('DeviceTier: failed to detect device tier from system, defaulting to midRange');
      _tier = DeviceTier.midRange;
    }
  }
}
