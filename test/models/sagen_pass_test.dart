import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/sagen_pass.dart';

void main() {
  group('SagenPass.spForNextLevel', () {
    test('returns 50 at level 1', () {
      expect(SagenPass(currentLevel: 1).spForNextLevel, 50);
    });

    test('returns 60 at level 2', () {
      expect(SagenPass(currentLevel: 2).spForNextLevel, 60);
    });

    test('returns 0 at maxLevel', () {
      expect(SagenPass(currentLevel: 50).spForNextLevel, 0);
    });
  });

  group('SagenPass.progressFraction', () {
    test('returns 0 when sp is 0', () {
      expect(SagenPass(currentLevel: 1, currentSP: 0).progressFraction, 0.0);
    });

    test('returns 0.5 at half progress', () {
      expect(
        SagenPass(currentLevel: 1, currentSP: 25).progressFraction,
        closeTo(0.5, 0.01),
      );
    });

    test('clamps at 1.0 when sp exceeds requirement', () {
      expect(
        SagenPass(currentLevel: 1, currentSP: 100).progressFraction,
        1.0,
      );
    });

    test('returns 1.0 at maxLevel', () {
      expect(SagenPass(currentLevel: 50, currentSP: 0).progressFraction, 1.0);
    });
  });

  group('SagenPass.isMaxLevel', () {
    test('returns false below maxLevel', () {
      expect(SagenPass(currentLevel: 49).isMaxLevel, isFalse);
    });

    test('returns true at maxLevel', () {
      expect(SagenPass(currentLevel: 50).isMaxLevel, isTrue);
    });
  });

  group('SagenPass.isLevelClaimed', () {
    test('returns false for unclaimed level', () {
      expect(SagenPass(claimedLevels: [1, 2]).isLevelClaimed(3), isFalse);
    });

    test('returns true for claimed level', () {
      expect(SagenPass(claimedLevels: [1, 2, 3]).isLevelClaimed(2), isTrue);
    });
  });

  group('SagenPass.allLevels', () {
    test('has exactly 50 entries', () {
      expect(SagenPass.allLevels.length, 50);
    });

    test('level 10 has avatarFrame reward', () {
      expect(SagenPass.allLevels[9].rewardType, PassRewardType.avatarFrame);
    });

    test('level 25 has chest reward', () {
      expect(SagenPass.allLevels[24].rewardType, PassRewardType.chest);
    });

    test('level 50 has cosmetic reward', () {
      expect(SagenPass.allLevels[49].rewardType, PassRewardType.cosmetic);
    });

    test('level 5 has xp reward', () {
      expect(SagenPass.allLevels[4].rewardType, PassRewardType.xp);
    });

    test('level 3 has item reward', () {
      expect(SagenPass.allLevels[2].rewardType, PassRewardType.item);
    });
  });

  group('SagenPass.copyWith', () {
    test('preserves all fields when none changed', () {
      final pass = SagenPass(currentLevel: 5, currentSP: 30);
      final copy = pass.copyWith();
      expect(copy.currentLevel, 5);
      expect(copy.currentSP, 30);
    });

    test('updates specific fields', () {
      final pass = SagenPass(currentLevel: 5, currentSP: 30);
      final copy = pass.copyWith(currentLevel: 10);
      expect(copy.currentLevel, 10);
      expect(copy.currentSP, 30);
    });
  });
}
