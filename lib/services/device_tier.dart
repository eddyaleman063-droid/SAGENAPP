import 'dart:io';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

enum DeviceTier { lowEnd, midRange, highEnd }

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
  } catch (e) {
    AppLogger().warning('DeviceTier: failed to read CPU core count: $e');
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
///
/// NUEVO-fix (ronda 19): extiende [ChangeNotifier] y notifica al terminar la
/// detección. Antes el tier quedaba en el valor por defecto (highEnd) hasta que
/// el compute resolvía, pero los Providers de hardware que lo leían NO se
/// invalidaban: en devices low-end la app se quedaba "para siempre" con
/// animaciones/partículas de gama alta. Ahora `init()` cachea su Future y
/// `notifyListeners()` dispara la invalidación en `lowEndDeviceDetectorProvider`.
class LowEndDeviceDetector extends ChangeNotifier {
  static final LowEndDeviceDetector instance = LowEndDeviceDetector._();
  LowEndDeviceDetector._();

  DeviceTier _tier = DeviceTier.highEnd;
  Future<void>? _initFuture;

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

  /// Starts (or joins) async detection. Concurrent callers share the same
  /// future so a fire-and-forget call no longer blocks later awaits.
  Future<void> init() => _initFuture ??= _detect();

  Future<void> _detect() async {
    if (kIsWeb) {
      _tier = DeviceTier.highEnd;
      return;
    }

    try {
      _tier = await compute(_detectTierFromSystem, null as dynamic);
    } catch (e) {
      AppLogger().warning(
        'DeviceTier: failed to detect device tier from system, defaulting to midRange: $e',
      );
      _tier = DeviceTier.midRange;
    }
    notifyListeners();
  }

  /// Test-only override to deterministically exercise tier changes.
  @visibleForTesting
  void debugOverrideTier(DeviceTier tier) {
    _tier = tier;
    notifyListeners();
  }
}
