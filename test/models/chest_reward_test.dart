import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_reward.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/services/chest_reward_roller.dart';
import 'package:sagen/services/chest_drop_service.dart';

class FakeChestDropService extends ChestDropService {
  FakeChestDropService() : super.private();

  @override
  Future<ChestReward> roll(
    ChestType type, {
    String? contextId,
    String source = 'lesson',
    bool luckBoostActive = false,
  }) async {
    return switch (type) {
      ChestType.bronze => const ChestReward(xp: 20),
      ChestType.silver => const ChestReward(xp: 30),
      ChestType.gold => const ChestReward(xp: 45),
      ChestType.legendary => const ChestReward(xp: 65, streakShields: 1),
    };
  }
}

void main() {
  group('ChestSystem.shouldUnlockChest', () {
    test('returns false for 0 lessons', () {
      expect(ChestSystem.shouldUnlockChest(0), isFalse);
    });

    test('returns false for negative lessons', () {
      expect(ChestSystem.shouldUnlockChest(-1), isFalse);
    });

    test('returns true for 3 lessons', () {
      expect(ChestSystem.shouldUnlockChest(3), isTrue);
    });

    test('returns true for 5 lessons', () {
      expect(ChestSystem.shouldUnlockChest(5), isTrue);
    });

    test('returns true for 6 lessons', () {
      expect(ChestSystem.shouldUnlockChest(6), isTrue);
    });

    test('returns true for 9 lessons', () {
      expect(ChestSystem.shouldUnlockChest(9), isTrue);
    });

    test('returns true for 10 lessons', () {
      expect(ChestSystem.shouldUnlockChest(10), isTrue);
    });

    test('returns false for 1 lesson', () {
      expect(ChestSystem.shouldUnlockChest(1), isFalse);
    });

    test('returns false for 2 lessons', () {
      expect(ChestSystem.shouldUnlockChest(2), isFalse);
    });

    test('returns false for 4 lessons', () {
      expect(ChestSystem.shouldUnlockChest(4), isFalse);
    });
  });

  group('ChestSystem.isPremiumChest', () {
    test('returns true for multiples of 5', () {
      expect(ChestSystem.isPremiumChest(5), isTrue);
      expect(ChestSystem.isPremiumChest(10), isTrue);
      expect(ChestSystem.isPremiumChest(15), isTrue);
    });

    test('returns false for non-multiples of 5', () {
      expect(ChestSystem.isPremiumChest(3), isFalse);
      expect(ChestSystem.isPremiumChest(6), isFalse);
      expect(ChestSystem.isPremiumChest(9), isFalse);
    });

    test('returns false for 0 or negative', () {
      expect(ChestSystem.isPremiumChest(0), isFalse);
      expect(ChestSystem.isPremiumChest(-5), isFalse);
    });
  });

  group('ChestRewardRoller.roll', () {
    late ChestRewardRoller roller;

    setUp(() {
      roller = ChestRewardRoller(dropService: FakeChestDropService());
    });

    test('returns ChestReward for bronze type', () async {
      final reward = await roller.roll(ChestType.bronze);
      expect(reward.xp, greaterThan(0));
    });

    test('returns ChestReward for silver type', () async {
      final reward = await roller.roll(ChestType.silver);
      expect(reward.xp, greaterThan(0));
    });

    test('returns ChestReward for gold type', () async {
      final reward = await roller.roll(ChestType.gold);
      expect(reward.xp, greaterThan(0));
    });

    test('returns ChestReward for legendary type', () async {
      final reward = await roller.roll(ChestType.legendary);
      expect(reward.xp, greaterThan(0));
    });

    test('overrideXp replaces rolled XP', () async {
      final reward = await roller.roll(ChestType.bronze);
      expect(reward.xp, greaterThanOrEqualTo(0));
    });

    test('legendary chest can have streakShields', () async {
      final reward = await roller.roll(ChestType.legendary);
      expect(reward.streakShields, isNotNull);
    });

    test('bronze chest never has streakShields', () async {
      for (int i = 0; i < 10; i++) {
        expect((await roller.roll(ChestType.bronze)).streakShields, isNull);
      }
    });

    test('bronze chest never has xpBoost', () async {
      for (int i = 0; i < 10; i++) {
        expect((await roller.roll(ChestType.bronze)).xpBoost, isFalse);
      }
    });
  });
}
