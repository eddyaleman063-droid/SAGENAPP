import 'dart:async';

import 'sage_emotion_service.dart';

enum EmotionEventType {
  streakLost,
  achievementUnlocked,
  lessonCompleted,
  perfectLesson,
  streakMilestone,
  levelledUp,
  chatSent,
  chatReceived,
  chatError,
}

/// A bus event. `emotion` is an optional override: when set, the listener
/// should show that exact emotion (e.g. sentiment-driven), otherwise it falls
/// back to the type's default mapping.
class EmotionEvent {
  final EmotionEventType type;
  final SageEmotion? emotion;
  const EmotionEvent(this.type, {this.emotion});
}

/// Event bus for mascot emotion state transitions.
class EmotionEventBus {
  EmotionEventBus._();
  // ignore: avoid_static
  static EmotionEventBus instance = EmotionEventBus._();

  final StreamController<EmotionEvent> _controller =
      StreamController<EmotionEvent>.broadcast();
  bool _disposed = false;

  Stream<EmotionEvent> get events => _controller.stream;

  void fire(EmotionEventType event) {
    if (_disposed) return;
    _controller.add(EmotionEvent(event));
  }

  void fireEmotion(EmotionEventType event, SageEmotion emotion) {
    if (_disposed) return;
    _controller.add(EmotionEvent(event, emotion: emotion));
  }

  void dispose() {
    _disposed = true;
    if (!_controller.isClosed) _controller.close();
  }

  void reset() {
    instance.dispose();
    instance = EmotionEventBus._();
  }
}
