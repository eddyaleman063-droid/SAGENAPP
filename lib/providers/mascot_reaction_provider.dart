import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sage_emotion_service.dart';

class MascotReactionState {
  final SageEmotion? overrideEmotion;

  const MascotReactionState({this.overrideEmotion});

  bool get isActive => overrideEmotion != null;
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

  void triggerReaction(
    SageEmotion emotion, {
    Duration duration = const Duration(seconds: 5),
  }) {
    _clearTimer?.cancel();
    state = MascotReactionState(overrideEmotion: emotion);
    _clearTimer = Timer(duration, () {
      if (!_disposed) state = const MascotReactionState();
    });
  }
}

final mascotReactionProvider =
    NotifierProvider.autoDispose<MascotReactionNotifier, MascotReactionState>(
      MascotReactionNotifier.new,
    );
