import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sage_emotion_service.dart';

class MascotReactionState {
  final SageEmotion? overrideEmotion;
  final SageEmotion? overlayEmotion;
  final double overlayStrength;

  const MascotReactionState({
    this.overrideEmotion,
    this.overlayEmotion,
    this.overlayStrength = 0.3,
  });

  bool get isActive => overrideEmotion != null || overlayEmotion != null;
}

class MascotReactionNotifier extends AutoDisposeNotifier<MascotReactionState> {
  Timer? _clearTimer;
  bool _disposed = false;

  @override
  MascotReactionState build() {
    ref.onDispose(() {
      _disposed = true;
      _clearTimer?.cancel();
    });
    return const MascotReactionState();
  }

  void triggerReaction(SageEmotion emotion, {Duration duration = const Duration(seconds: 5)}) {
    _clearTimer?.cancel();
    state = MascotReactionState(overrideEmotion: emotion);
    _clearTimer = Timer(duration, () {
      if (!_disposed) state = const MascotReactionState();
    });
  }

  void triggerOverlay(SageEmotion emotion, {Duration duration = const Duration(seconds: 8), double strength = 0.3}) {
    _clearTimer?.cancel();
    state = MascotReactionState(overlayEmotion: emotion, overlayStrength: strength);
    _clearTimer = Timer(duration, () {
      if (!_disposed) state = const MascotReactionState();
    });
  }
}

final mascotReactionProvider = NotifierProvider.autoDispose<MascotReactionNotifier, MascotReactionState>(
  MascotReactionNotifier.new,
);
