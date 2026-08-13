import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/services/chest_event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ChestRewardData reward({
    ChestType type = ChestType.bronze,
    int xp = 10,
    List<SpecialItemType> specialItems = const [],
    List<SpecialItemType> cosmetics = const [],
  }) =>
      ChestRewardData(
        type: type,
        xp: xp,
        source: 'test',
        specialItems: specialItems,
        cosmeticUnlocks: cosmetics,
      );

  group('ChestRewardData', () {
    test('defaults apply', () {
      const data = ChestRewardData(type: ChestType.gold, source: 'lesson');
      expect(data.xp, 0);
      expect(data.streakShields, isNull);
      expect(data.title, isNull);
      expect(data.message, isNull);
      expect(data.xpBoost, isFalse);
      expect(data.specialItems, isEmpty);
      expect(data.cosmeticUnlocks, isEmpty);
      expect(data.hasSpecialRewards, isFalse);
    });

    test('hasSpecialRewards with special items', () {
      expect(reward(specialItems: [SpecialItemType.focusElixir]).hasSpecialRewards, isTrue);
      expect(reward(cosmetics: [SpecialItemType.avatarFrameNeon]).hasSpecialRewards, isTrue);
    });

    test('exposes all fields', () {
      const data = ChestRewardData(
        type: ChestType.legendary,
        xp: 500,
        streakShields: 2,
        title: '¡Increíble!',
        message: 'Recompensa épica',
        source: 'chest',
        xpBoost: true,
        specialItems: [SpecialItemType.phoenixFeather],
        cosmeticUnlocks: [SpecialItemType.titleCyberSage],
      );
      expect(data.type, ChestType.legendary);
      expect(data.xp, 500);
      expect(data.streakShields, 2);
      expect(data.title, '¡Increíble!');
      expect(data.message, 'Recompensa épica');
      expect(data.source, 'chest');
      expect(data.xpBoost, isTrue);
      expect(data.specialItems, [SpecialItemType.phoenixFeather]);
      expect(data.cosmeticUnlocks, [SpecialItemType.titleCyberSage]);
    });
  });

  group('ChestEventBus', () {
    tearDown(() => ChestEventBus.instance.reset());

    test('fire delivers to listeners and queues', () async {
      final bus = ChestEventBus.instance;
      final received = <ChestRewardData>[];
      final sub = bus.events.listen(received.add);

      bus.fire(reward(type: ChestType.silver, xp: 25));

      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(1));
      expect(received.first.type, ChestType.silver);
      expect(bus.pending?.xp, 25);
      expect(bus.pending?.type, ChestType.silver);

      await sub.cancel();
    });

    test('consume removes the head of the queue', () async {
      final bus = ChestEventBus.instance;
      bus.fire(reward(xp: 1));
      bus.fire(reward(xp: 2));
      expect(bus.pending?.xp, 1);

      bus.consume();
      expect(bus.pending?.xp, 2);

      bus.consume();
      expect(bus.pending, isNull);
    });

    test('queue is capped at ten entries', () async {
      final bus = ChestEventBus.instance;
      for (var i = 0; i < 12; i++) {
        bus.fire(reward(xp: i));
      }
      // Two extra entries were evicted from the front.
      expect(bus.pending?.xp, 2);
    });

    test('disposed bus ignores fire', () {
      final bus = ChestEventBus.instance;
      bus.fire(reward(xp: 1));
      bus.dispose();
      bus.fire(reward(xp: 2));
      expect(bus.pending?.xp, 1);
    });

    test('reset clears queue and keeps bus usable', () async {
      final bus = ChestEventBus.instance;
      bus.fire(reward(xp: 1));
      bus.reset();
      expect(bus.pending, isNull);

      final received = <ChestRewardData>[];
      final sub = bus.events.listen(received.add);
      bus.fire(reward(xp: 3));
      await Future<void>.delayed(Duration.zero);
      expect(received, hasLength(1));
      await sub.cancel();
    });
  });
}
