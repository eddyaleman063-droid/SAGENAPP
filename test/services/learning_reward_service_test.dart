import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_reward.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/services/learning_reward_service.dart';

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
}
