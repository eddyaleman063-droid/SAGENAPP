import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/models/chest_reward.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/services/audio_service.dart';
import 'package:sagen/services/chest_drop_service.dart';
import 'package:sagen/services/chest_event_bus.dart';
import 'package:sagen/services/chest_reward_roller.dart';
import 'package:sagen/services/learning_reward_service.dart';

class _FakeDropService extends ChestDropService {
  _FakeDropService([this._rewards = const []]) : super.private();
  final List<ChestReward> _rewards;
  final List<ChestType> rolled = [];
  int calls = 0;

  @override
  Future<ChestReward> roll(
    ChestType type, {
    String? contextId,
    String source = 'lesson',
    bool luckBoostActive = false,
  }) async {
    calls++;
    rolled.add(type);
    return _rewards.isEmpty
        ? ChestReward(xp: 25, gems: 3, chestType: type)
        : _rewards[(calls - 1) % _rewards.length];
  }
}

class _FakeBus extends Mock implements ChestEventBus {}

class _FakeAudio extends Mock implements AudioService {}

void main() {
  group('LearningRewardService.chestTypeFor', () {
    test('returns bronze for non-milestone lessons', () {
      expect(LearningRewardService.chestTypeFor(1), ChestType.bronze);
      expect(LearningRewardService.chestTypeFor(2), ChestType.bronze);
      expect(LearningRewardService.chestTypeFor(4), ChestType.bronze);
      expect(LearningRewardService.chestTypeFor(7), ChestType.bronze);
    });

    test('returns silver for every 3rd lesson (not divisible by 5)', () {
      expect(LearningRewardService.chestTypeFor(3), ChestType.silver);
      expect(LearningRewardService.chestTypeFor(6), ChestType.silver);
      expect(LearningRewardService.chestTypeFor(9), ChestType.silver);
      expect(LearningRewardService.chestTypeFor(12), ChestType.silver);
    });

    test('returns gold for every 5th lesson (not divisible by 15)', () {
      expect(LearningRewardService.chestTypeFor(5), ChestType.gold);
      expect(LearningRewardService.chestTypeFor(10), ChestType.gold);
      expect(LearningRewardService.chestTypeFor(20), ChestType.gold);
      expect(LearningRewardService.chestTypeFor(25), ChestType.gold);
    });

    test('returns legendary for every 15th lesson', () {
      expect(LearningRewardService.chestTypeFor(15), ChestType.legendary);
      expect(LearningRewardService.chestTypeFor(30), ChestType.legendary);
      expect(LearningRewardService.chestTypeFor(45), ChestType.legendary);
    });

    test('15th lesson is legendary (not gold, even though 15 % 5 == 0)', () {
      expect(LearningRewardService.chestTypeFor(15), ChestType.legendary);
    });

    test('30th lesson is legendary (not gold)', () {
      expect(LearningRewardService.chestTypeFor(30), ChestType.legendary);
    });
  });

  group('ChestSystem.shouldUnlockChest', () {
    test('returns false for 0 lessons', () {
      expect(ChestSystem.shouldUnlockChest(0), false);
    });

    test('returns false for negative lessons', () {
      expect(ChestSystem.shouldUnlockChest(-1), false);
    });

    test('returns true for lessons divisible by 3', () {
      expect(ChestSystem.shouldUnlockChest(3), true);
      expect(ChestSystem.shouldUnlockChest(6), true);
      expect(ChestSystem.shouldUnlockChest(9), true);
      expect(ChestSystem.shouldUnlockChest(12), true);
    });

    test('returns true for lessons divisible by 5', () {
      expect(ChestSystem.shouldUnlockChest(5), true);
      expect(ChestSystem.shouldUnlockChest(10), true);
      expect(ChestSystem.shouldUnlockChest(15), true);
      expect(ChestSystem.shouldUnlockChest(20), true);
    });

    test('returns true for lessons divisible by both 3 and 5', () {
      expect(ChestSystem.shouldUnlockChest(15), true);
      expect(ChestSystem.shouldUnlockChest(30), true);
    });

    test('returns false for lessons not divisible by 3 or 5', () {
      expect(ChestSystem.shouldUnlockChest(1), false);
      expect(ChestSystem.shouldUnlockChest(2), false);
      expect(ChestSystem.shouldUnlockChest(4), false);
      expect(ChestSystem.shouldUnlockChest(7), false);
      expect(ChestSystem.shouldUnlockChest(11), false);
    });
  });

  group('ChestSystem.isPremiumChest', () {
    test('returns false for 0 lessons', () {
      expect(ChestSystem.isPremiumChest(0), false);
    });

    test('returns true for lessons divisible by 5', () {
      expect(ChestSystem.isPremiumChest(5), true);
      expect(ChestSystem.isPremiumChest(10), true);
      expect(ChestSystem.isPremiumChest(15), true);
      expect(ChestSystem.isPremiumChest(20), true);
    });

    test('returns false for lessons not divisible by 5', () {
      expect(ChestSystem.isPremiumChest(1), false);
      expect(ChestSystem.isPremiumChest(3), false);
      expect(ChestSystem.isPremiumChest(7), false);
      expect(ChestSystem.isPremiumChest(11), false);
    });

    test('returns true for 30 (divisible by 5)', () {
      expect(ChestSystem.isPremiumChest(30), true);
    });
  });

  group('ChestReward default values', () {
    test('default chest reward has zero xp', () {
      const reward = ChestReward();
      expect(reward.xp, 0);
      expect(reward.streakShields, isNull);
      expect(reward.xpBoost, false);
      expect(reward.isPremium, false);
    });

    test('chest reward with values', () {
      const reward = ChestReward(xp: 25, streakShields: 1);
      expect(reward.xp, 25);
      expect(reward.streakShields, 1);
    });
  });

  group('LearningRewardService.rollChest', () {
    late _FakeDropService drop;
    late _FakeBus bus;
    late _FakeAudio audio;
    late LearningRewardService service;

    setUp(() {
      drop = _FakeDropService();
      bus = _FakeBus();
      audio = _FakeAudio();
      service = LearningRewardService(
        roller: ChestRewardRoller(dropService: drop),
        eventBus: bus,
        audio: audio,
      );
    });

    test('constructor accepts injectable dependencies', () {
      expect(service, isA<LearningRewardService>());
    });

    test('returns null when the chest should not unlock', () async {
      final reward = await service.rollChest(
        lessonsCompleted: 1,
        totalDonated: 0,
        xp: 50,
      );
      expect(reward, isNull);
      expect(drop.calls, 0);
    });

    test('rolls for 3/5/10/15/30 milestones', () async {
      for (final n in [3, 5, 10, 15, 30]) {
        final reward = await service.rollChest(
          lessonsCompleted: n,
          totalDonated: 0,
          xp: 100,
        );
        expect(reward, isNotNull, reason: 'lesson $n must roll');
      }
    });

    test('maps the roller result into ChestRewardData', () async {
      final reward = await service.rollChest(
        lessonsCompleted: 6,
        totalDonated: 0,
        xp: 100,
      );
      expect(reward, isNotNull);
      expect(reward!.type, ChestType.silver);
      expect(reward.xp, 25);
      expect(reward.gems, 3);
      expect(reward.source, 'lesson');
    });

    test('forwards luck boost and context to the drop service', () async {
      await service.rollChest(
        lessonsCompleted: 3,
        totalDonated: 0,
        xp: 60,
        luckBoostActive: true,
        contextId: 'ctx_1',
      );
      expect(drop.calls, 1);
    });

    test('passes through server special items, boosts and cosmetics', () async {
      drop = _FakeDropService([
        const ChestReward(
          xp: 10,
          gems: 0,
          streakShields: 1,
          xpBoost: true,
          chestType: ChestType.gold,
          specialItems: [SpecialItemType.focusElixir],
          cosmeticUnlocks: [SpecialItemType.themeDarkFire],
        ),
      ]);
      service = LearningRewardService(
        roller: ChestRewardRoller(dropService: drop),
        eventBus: bus,
        audio: audio,
      );
      final reward = await service.rollChest(
        lessonsCompleted: 5,
        totalDonated: 10,
        xp: 70,
        luckBoostActive: true,
      );
      expect(reward, isNotNull);
      expect(reward!.streakShields, 1);
      expect(reward.xpBoost, isTrue);
      expect(reward.specialItems, contains(SpecialItemType.focusElixir));
      expect(reward.cosmeticUnlocks, contains(SpecialItemType.themeDarkFire));
    });

    test('keeps an empty rewards list honest (no fabricated xp)', () async {
      drop = _FakeDropService([
        const ChestReward(xp: 0, gems: 0, chestType: ChestType.legendary),
      ]);
      service = LearningRewardService(
        roller: ChestRewardRoller(dropService: drop),
        eventBus: bus,
        audio: audio,
      );
      final reward = await service.rollChest(
        lessonsCompleted: 15,
        totalDonated: 0,
        xp: 9,
      );
      expect(reward, isNotNull);
      expect(reward!.xp, 0);
      expect(reward.gems, 0);
    });
  });

  group('LearningRewardService.emitRewardEffects', () {
    test('fires the event bus and plays the chest sound', () async {
      final bus = _FakeBus();
      final audio = _FakeAudio();
      when(() => audio.playChestOpen()).thenAnswer((_) async {});
      final service = LearningRewardService(
        roller: ChestRewardRoller(dropService: _FakeDropService()),
        eventBus: bus,
        audio: audio,
      );
      const data = ChestRewardData(
        type: ChestType.bronze,
        xp: 20,
        gems: 2,
        source: 'lesson',
      );
      service.emitRewardEffects(data);
      verify(() => bus.fire(data)).called(1);
      verify(() => audio.playChestOpen()).called(1);
    });
  });
}
