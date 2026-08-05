import 'package:flutter/services.dart';
import 'audio_service.dart';
import 'experience_service.dart';

/// Coordinates haptic + audio feedback as a single concern.
/// Decouples the two so callers can trigger either or both independently.
class FeedbackCoordinator {
  final ExperienceService _exp;
  final AudioService _audio;

  FeedbackCoordinator({
    ExperienceService? experience,
    AudioService? audio,
  })  : _exp = experience ?? ExperienceService.instance,
        _audio = audio ?? AudioService.instance;

  static final FeedbackCoordinator instance = FeedbackCoordinator();

  bool get _hapticEnabled => _exp.hapticEnabled;
  bool get _soundEnabled => _exp.soundEnabled;

  // ── Combined feedback (haptic + audio) ──

  void success() {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
    if (_soundEnabled) _audio.playSuccess();
  }

  void error() {
    if (_hapticEnabled) HapticFeedback.heavyImpact();
    if (_soundEnabled) _audio.playError();
  }

  void chestOpen() {
    if (!_hapticEnabled && !_soundEnabled) return;
    if (_hapticEnabled) HapticFeedback.mediumImpact();
    if (_soundEnabled) _audio.playChestOpen();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_hapticEnabled) HapticFeedback.heavyImpact();
    });
  }

  void chestEvolve() {
    if (!_hapticEnabled && !_soundEnabled) return;
    if (_hapticEnabled) HapticFeedback.heavyImpact();
    if (_soundEnabled) _audio.playChestRare();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_hapticEnabled) HapticFeedback.mediumImpact();
    });
  }

  void chestFail() {
    if (_hapticEnabled) HapticFeedback.lightImpact();
    if (_soundEnabled) _audio.playClank();
  }

  // ── Haptic-only feedback ──

  void lightHaptic() {
    if (_hapticEnabled) HapticFeedback.lightImpact();
  }

  void mediumHaptic() {
    if (_hapticEnabled) HapticFeedback.mediumImpact();
  }
}
