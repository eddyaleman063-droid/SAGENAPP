import 'dart:async';

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

/// Event bus for mascot emotion state transitions.
class EmotionEventBus {
  EmotionEventBus._();
  // ignore: avoid_static
  static EmotionEventBus instance = EmotionEventBus._();

  final StreamController<EmotionEventType> _controller =
      StreamController<EmotionEventType>.broadcast();
  bool _disposed = false;

  Stream<EmotionEventType> get events => _controller.stream;

  void fire(EmotionEventType event) {
    if (_disposed) return;
    _controller.add(event);
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
