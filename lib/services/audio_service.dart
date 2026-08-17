import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'experience_service.dart';
import 'app_logger.dart';

/// Manages audio playback for UI sound effects.
class AudioService {
  static final AudioService instance = AudioService._();
  AudioService._({ExperienceService? experienceService})
    : _experienceService = experienceService ?? ExperienceService.instance,
      _logger = AppLogger();
  final AppLogger _logger;
  final ExperienceService _experienceService;

  AudioPlayer? _player;
  bool _prewarmed = false;
  DateTime? _lastPlayTime;
  static const _minInterval = Duration(milliseconds: 40);

  // BUG-033: Audio queue to prevent lost sounds on rapid taps
  final List<_QueuedAudio> _audioQueue = [];
  bool _isPlaying = false;

  static const _clankAsset = 'assets/audio/clank.wav';
  static const _successAsset = 'assets/audio/success.wav';
  static const _errorAsset = 'assets/audio/error.wav';
  static const _chestOpenAsset = 'assets/audio/chest_open.wav';
  static const _milestoneAsset = 'assets/audio/milestone.wav';
  static const _uiTapAsset = 'assets/audio/ui_tap.wav';
  static const _levelUpAsset = 'assets/audio/level_up.wav';
  static const _streakMilestoneAsset = 'assets/audio/streak_milestone.wav';
  static const _chestRareAsset = 'assets/audio/chest_rare.wav';
  static const _purchaseSuccessAsset = 'assets/audio/purchase_success.wav';

  Future<void> init() async {
    _player = AudioPlayer();
    await _player?.setVolume(0.5);
  }

  void prewarm() {
    if (_prewarmed || _player == null) return;
    _prewarmed = true;
    _prewarmSounds();
  }

  Future<void> _prewarmSounds() async {
    try {
      final assets = [
        _clankAsset,
        _successAsset,
        _errorAsset,
        _chestOpenAsset,
        _milestoneAsset,
        _uiTapAsset,
        _levelUpAsset,
        _streakMilestoneAsset,
        _chestRareAsset,
        _purchaseSuccessAsset,
      ];
      for (final a in assets) {
        try {
          await _player?.setSource(AssetSource(a));
        } catch (e) {
          _logger.warning('AudioService.prewarm: failed to load $a: $e');
        }
      }
    } catch (e) {
      _logger.error('AudioService.prewarm', e);
    }
  }

  Future<void> dispose() async {
    _audioQueue.clear();
    _isPlaying = false;
    _lastPlayTime = null;
    try {
      await _player?.stop();
    } catch (e) {
      _logger.warning('AudioService.dispose: failed to stop player: $e');
    }
    _player?.dispose();
    _player = null;
    _prewarmed = false;
  }

  void onDetach() => dispose();

  void onAppPaused() {
    _player?.stop();
  }

  bool get _soundOn => _experienceService.soundEnabled;

  Future<void> _play(String asset, {double volume = 0.5}) async {
    if (!_soundOn || _player == null) return;
    // BUG-033: Queue audio instead of discarding on rapid taps
    if (_audioQueue.length >= 5) _audioQueue.removeAt(0);
    _audioQueue.add(_QueuedAudio(asset, volume));
    if (_isPlaying) return;
    await _processQueue();
  }

  Future<void> _processQueue() async {
    if (_audioQueue.isEmpty || _isPlaying) return;
    _isPlaying = true;
    while (_audioQueue.isNotEmpty) {
      final next = _audioQueue.removeAt(0);
      try {
        // Debounce between sounds
        final now = DateTime.now();
        if (_lastPlayTime != null &&
            now.difference(_lastPlayTime!) < _minInterval) {
          await Future.delayed(_minInterval);
        }
        _lastPlayTime = DateTime.now();
        await _player?.stop();
        await _player?.setVolume(next.volume);
        final completer = Completer<void>();
        StreamSubscription<void>? sub;
        try {
          sub = _player?.onPlayerComplete.listen((_) {
            if (!completer.isCompleted) completer.complete();
          });
          await _player?.play(AssetSource(next.asset));
          await completer.future.timeout(
            const Duration(seconds: 5),
            onTimeout: () {},
          );
        } finally {
          await sub?.cancel();
        }
      } catch (e) {
        _logger.error('AudioService._play: ${next.asset}', e);
        try {
          await SystemSound.play(SystemSoundType.click);
        } catch (e) {
          _logger.warning('AudioService: fallback SystemSound also failed: $e');
        }
      }
    }
    _isPlaying = false;
  }

  Future<void> playClank() async => _play(_clankAsset);

  Future<void> playSuccess() async => _play(_successAsset, volume: 0.6);

  Future<void> playError() async => _play(_errorAsset, volume: 0.4);

  Future<void> playChestOpen() async => _play(_chestOpenAsset, volume: 0.7);

  Future<void> playMilestone() async => _play(_milestoneAsset, volume: 0.7);

  Future<void> playUiTap() async => _play(_uiTapAsset, volume: 0.3);

  Future<void> playLevelUp() async => _play(_levelUpAsset, volume: 0.7);

  Future<void> playStreakMilestone() async =>
      _play(_streakMilestoneAsset, volume: 0.7);

  Future<void> playChestRare() async => _play(_chestRareAsset, volume: 0.8);

  Future<void> playPurchaseSuccess() async =>
      _play(_purchaseSuccessAsset, volume: 0.6);
}

class _QueuedAudio {
  final String asset;
  final double volume;
  const _QueuedAudio(this.asset, this.volume);
}
