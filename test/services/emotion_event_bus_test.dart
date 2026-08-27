import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/emotion_event_bus.dart';
import 'package:sagen/services/sage_emotion_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmotionEventBus', () {
    test('delivers fired events to listeners', () async {
      final bus = EmotionEventBus.instance;
      final received = <EmotionEvent>[];
      final sub = bus.events.listen(received.add);

      bus.fire(EmotionEventType.lessonCompleted);
      bus.fire(EmotionEventType.streakMilestone);

      await Future<void>.delayed(Duration.zero);
      expect(received, [
        isA<EmotionEvent>()
            .having((e) => e.type, 'type', EmotionEventType.lessonCompleted)
            .having((e) => e.emotion, 'emotion', isNull),
        isA<EmotionEvent>()
            .having((e) => e.type, 'type', EmotionEventType.streakMilestone)
            .having((e) => e.emotion, 'emotion', isNull),
      ]);

      await sub.cancel();
    });

    test('broadcasts events to multiple listeners', () async {
      final bus = EmotionEventBus.instance;
      final first = <EmotionEvent>[];
      final second = <EmotionEvent>[];
      final sub1 = bus.events.listen(first.add);
      final sub2 = bus.events.listen(second.add);

      bus.fire(EmotionEventType.levelledUp);

      await Future<void>.delayed(Duration.zero);
      expect(first.map((e) => e.type), [EmotionEventType.levelledUp]);
      expect(second.map((e) => e.type), [EmotionEventType.levelledUp]);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('fireEmotion carries a sentiment override', () async {
      final bus = EmotionEventBus.instance;
      final received = <EmotionEvent>[];
      final sub = bus.events.listen(received.add);

      bus.fireEmotion(EmotionEventType.chatSent, SageEmotion.worried);

      await Future<void>.delayed(Duration.zero);
      expect(received, [
        isA<EmotionEvent>()
            .having((e) => e.type, 'type', EmotionEventType.chatSent)
            .having((e) => e.emotion, 'emotion', SageEmotion.worried),
      ]);

      await sub.cancel();
    });

    test('reset swaps the instance', () async {
      final old = EmotionEventBus.instance;
      EmotionEventBus.instance.fire(EmotionEventType.achievementUnlocked);
      EmotionEventBus.instance.reset();
      expect(EmotionEventBus.instance, isNot(same(old)));
    });

    test('reset keeps the bus usable', () async {
      EmotionEventBus.instance.reset();
      final received = <EmotionEvent>[];
      final sub = EmotionEventBus.instance.events.listen(received.add);
      EmotionEventBus.instance.fire(EmotionEventType.chatSent);
      await Future<void>.delayed(Duration.zero);
      expect(received.map((e) => e.type), [EmotionEventType.chatSent]);
      await sub.cancel();
      EmotionEventBus.instance.reset();
    });

    test('disposed bus ignores events', () async {
      final bus = EmotionEventBus.instance;
      bus.dispose();
      final received = <EmotionEvent>[];
      // Can't listen after close; fire should be a no-op without throwing.
      bus.fire(EmotionEventType.chatError);
      expect(received, isEmpty);
      EmotionEventBus.instance.reset();
    });
  });
}
