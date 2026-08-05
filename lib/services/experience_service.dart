import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';
import 'device_tier.dart';
import 'feedback_coordinator.dart';

/// Manages device performance adaptation and UX animations.
///
/// Detects low-end devices via [LowEndDeviceDetector], adapts animation
/// durations and quality settings accordingly, and provides haptic
/// and visual feedback coordination.
class ExperienceService {
  final LowEndDeviceDetector _detector;

  ExperienceService({
    LowEndDeviceDetector? detector,
  })  : _detector = detector ?? LowEndDeviceDetector.instance;

  static final ExperienceService instance = ExperienceService();

  SharedPreferences? _prefs;

  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _reduceAnimations = false;
  double _fontSizeScale = 1.2;
  bool _notificationsEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get reduceAnimations => _reduceAnimations || _detector.reduceAnimations;
  bool get reduceBlur => _detector.reduceBlur;
  bool get reduceShadows => _detector.reduceShadows;
  bool get reduceGlow => _detector.reduceGlow;
  double get fontSizeScale => _fontSizeScale;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Reads the system text scale factor from the OS.
  /// Returns 1.2 as fallback if unavailable.
  double _getSystemTextScaleFactor() {
    try {
      final dispatcher = ui.PlatformDispatcher.instance;
      final view = dispatcher.views.isNotEmpty ? dispatcher.views.first : null;
      if (view == null) return 1.2;
      try {
        // ignore: avoid_dynamic_calls
        final dynamic viewDynamic = view;
        final dynamic scaler = viewDynamic.textScaler;
        if (scaler != null) {
          final scaledAt14 = (scaler as dynamic).scale(14.0) as num;
          return (scaledAt14 / 14.0).toDouble().clamp(0.8, 1.5);
        }
      } catch (e) {
        AppLogger().warning('ExperienceService: text scaler read failed: $e');
      }
      final dpi = view.devicePixelRatio;
      if (dpi <= 1.5) return 0.85;
      if (dpi <= 2.0) return 1.0;
      if (dpi <= 2.5) return 1.1;
      if (dpi <= 3.0) return 1.2;
      return 1.3;
    } catch (e) {
      AppLogger().warning('Error in _getSystemTextScaleFactor: $e');
      return 1.2;
    }
  }

  /// Initialize with shared SharedPreferences instance.
  /// Never call SharedPreferences.getInstance() internally.
  Future<void> init([SharedPreferences? prefs]) async {
    _detector.init();
    _prefs = prefs ?? await SharedPreferences.getInstance();
    final p = _prefs;
    if (p == null) return;
    _soundEnabled = p.getBool('sound_enabled') ?? true;
    _hapticEnabled = p.getBool('haptic_enabled') ?? true;
    _reduceAnimations = p.getBool('reduce_animations') ?? false;

    // FIX 20.11: Respect system text scale factor on first launch.
    // If user has never set a custom scale, use the OS setting.
    if (p.containsKey('font_scale')) {
      _fontSizeScale = p.getDouble('font_scale')!;
    } else {
      _fontSizeScale = _getSystemTextScaleFactor();
    }

    _notificationsEnabled = p.getBool('notifications_enabled') ?? true;
  }

  Future<void> setSoundEnabled(bool v) async {
    _soundEnabled = v;
    final p = _prefs;
    if (p == null) return;
    await p.setBool('sound_enabled', v);
  }

  Future<void> setHapticEnabled(bool v) async {
    _hapticEnabled = v;
    final p = _prefs;
    if (p == null) return;
    await p.setBool('haptic_enabled', v);
  }

  Future<void> setReduceAnimations(bool v) async {
    _reduceAnimations = v;
    final p = _prefs;
    if (p == null) return;
    await p.setBool('reduce_animations', v);
  }

  Future<void> setFontSizeScale(double value) async {
    _fontSizeScale = value.clamp(0.8, 1.5);
    final p = _prefs;
    if (p == null) return;
    await p.setDouble('font_scale', _fontSizeScale);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final p = _prefs;
    if (p == null) return;
    await p.setBool('notifications_enabled', value);
  }

  void lightHaptic() {
    if (!_hapticEnabled) return;
    HapticFeedback.lightImpact();
  }

  void mediumHaptic() {
    if (!_hapticEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void successHaptic() => FeedbackCoordinator.instance.success();
  void errorHaptic() => FeedbackCoordinator.instance.error();
  void chestOpenHaptic() => FeedbackCoordinator.instance.chestOpen();
  void chestEvolveHaptic() => FeedbackCoordinator.instance.chestEvolve();
  void chestFailHaptic() => FeedbackCoordinator.instance.chestFail();

  Duration get fast => _reduceAnimations ? Duration.zero : const Duration(milliseconds: 150);
  Duration get normal => _reduceAnimations ? Duration.zero : const Duration(milliseconds: 300);
  Duration get medium => _reduceAnimations ? Duration.zero : const Duration(milliseconds: 500);
  Duration get slow => _reduceAnimations ? Duration.zero : const Duration(milliseconds: 800);
  Duration get celebration => _reduceAnimations ? const Duration(milliseconds: 200) : const Duration(milliseconds: 1200);
}
