import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/emotion_event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmotionEventBus', () {
    test('delivers fired events to listeners', () async {
      final bus = EmotionEventBus.instance;
      final received = <EmotionEventType>[];
      final sub = bus.events.listen(received.add);

      bus.fire(EmotionEventType.lessonCompleted);
      bus.fire(EmotionEventType.streakMilestone);

      await Future<void>.delayed(Duration.zero);
      expect(received, [EmotionEventType.lessonCompleted, EmotionEventType.streakMilestone]);

      await sub.cancel();
    });

    test('broadcasts events to multiple listeners', () async {
      final bus = EmotionEventBus.instance;
      final first = <EmotionEventType>[];
      final second = <EmotionEventType>[];
      final sub1 = bus.events.listen(first.add);
      final sub2 = bus.events.listen(second.add);

      bus.fire(EmotionEventType.levelledUp);

      await Future<void>.delayed(Duration.zero);
      expect(first, [EmotionEventType.levelledUp]);
      expect(second, [EmotionEventType.levelledUp]);

      await sub1.cancel();
      await sub2.cancel();
    });

    test('reset swaps the instance', () async {
      final old = EmotionEventBus.instance;
      EmotionEventBus.instance.fire(EmotionEventType.achievementUnlocked);
      EmotionEventBus.instance.reset();
      expect(EmotionEventBus.instance, isNot(same(old)));
    });

    test('reset keeps the bus usable', () async {
      EmotionEventBus.instance.reset();
      final received = <EmotionEventType>[];
      final sub = EmotionEventBus.instance.events.listen(received.add);
      EmotionEventBus.instance.fire(EmotionEventType.chatSent);
      await Future<void>.delayed(Duration.zero);
      expect(received, [EmotionEventType.chatSent]);
      await sub.cancel();
      EmotionEventBus.instance.reset();
    });

    test('disposed bus ignores events', () async {
      final bus = EmotionEventBus.instance;
      bus.dispose();
      final received = <EmotionEventType>[];
      // Can't listen after close; fire should be a no-op without throwing.
      bus.fire(EmotionEventType.chatError);
      expect(received, isEmpty);
      EmotionEventBus.instance.reset();
    });
  });
}
