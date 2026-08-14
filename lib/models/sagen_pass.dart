import '../l10n/app_localizations.dart';

enum PassRewardType { title, avatarFrame, cosmetic, chest, donation, xp, item }

/// A single reward level in the SAGEN Pass season pass.
class PassLevel {
  final int level;
  final int spRequired;
  final PassRewardType rewardType;
  final String rewardName;
  final String rewardKey;
  final int rewardValue;

  const PassLevel({
    required this.level,
    required this.spRequired,
    required this.rewardType,
    required this.rewardName,
    required this.rewardKey,
    this.rewardValue = 0,
  });

  String localizedRewardName(AppLocalizations l) {
    switch (rewardKey) {
      case 'rewardCopperFrame':
        return l.rewardCopperFrame;
      case 'rewardEpicChest':
        return l.rewardEpicChest;
      case 'rewardIceFlame':
        return l.rewardIceFlame;
      case 'rewardGoldenChest':
        return l.rewardGoldenChest;
      case 'reward100Xp':
        return l.reward100Xp;
      case 'rewardTitaniumShield':
        return l.rewardTitaniumShield;
      case 'reward200Exp':
        return l.reward200Exp;
      default:
        return rewardName;
    }
  }
}

/// Manages the SAGEN Pass season pass state and rewards.
class SagenPass {
  final int currentLevel;
  final int currentSP;
  final List<int> claimedLevels;
  final DateTime seasonStart;
  final int seasonDurationDays;
  final bool premium;

  SagenPass({
    this.currentLevel = 1,
    this.currentSP = 0,
    List<int>? claimedLevels,
    DateTime? seasonStart,
    this.seasonDurationDays = 90,
    this.premium = false,
  }) : claimedLevels = List<int>.unmodifiable(claimedLevels ?? const []),
       seasonStart = seasonStart ?? DateTime.now();

  SagenPass copyWith({
    int? currentLevel,
    int? currentSP,
    List<int>? claimedLevels,
    DateTime? seasonStart,
    bool clearSeasonStart = false,
    int? seasonDurationDays,
    bool? premium,
  }) {
    return SagenPass(
      currentLevel: currentLevel ?? this.currentLevel,
      currentSP: currentSP ?? this.currentSP,
      claimedLevels: List<int>.unmodifiable(
        claimedLevels ?? this.claimedLevels,
      ),
      seasonStart: clearSeasonStart ? null : (seasonStart ?? this.seasonStart),
      seasonDurationDays: seasonDurationDays ?? this.seasonDurationDays,
      premium: premium ?? this.premium,
    );
  }

  static const int maxLevel = 50;
  static const int spPerLesson = 10;
  static const int spPerPerfectLesson = 15;
  static const int spPerMission = 5;

  static int spForLevel(int level) => 50 + (level - 1) * 10;

  int get spForNextLevel {
    if (currentLevel >= maxLevel) return 0;
    return spForLevel(currentLevel);
  }

  double get progressFraction =>
      spForNextLevel > 0 ? (currentSP / spForNextLevel).clamp(0.0, 1.0) : 1.0;

  bool get isMaxLevel => currentLevel >= maxLevel;

  bool isLevelClaimed(int level) => claimedLevels.contains(level);

  static final List<PassLevel> allLevels = List.generate(maxLevel, (i) {
    final level = i + 1;
    final sp = 50 + i * 10;
    if (level == 10) {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.avatarFrame,
        rewardName: 'Copper Frame',
        rewardKey: 'rewardCopperFrame',
      );
    } else if (level == 25) {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.chest,
        rewardName: 'Epic Chest',
        rewardKey: 'rewardEpicChest',
        rewardValue: 1,
      );
    } else if (level == 50) {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.cosmetic,
        rewardName: 'Ice Flame + Guardian',
        rewardKey: 'rewardIceFlame',
      );
    } else if (level % 10 == 0) {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.chest,
        rewardName: 'Golden Chest',
        rewardKey: 'rewardGoldenChest',
        rewardValue: 1,
      );
    } else if (level % 5 == 0) {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.xp,
        rewardName: '100 EXP',
        rewardKey: 'reward100Xp',
        rewardValue: 100,
      );
    } else if (level % 3 == 0) {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.item,
        rewardName: 'Titanium Shield',
        rewardKey: 'rewardTitaniumShield',
        rewardValue: 1,
      );
    } else {
      return PassLevel(
        level: level,
        spRequired: sp,
        rewardType: PassRewardType.xp,
        rewardName: '200 EXP',
        rewardKey: 'reward200Exp',
        rewardValue: 200,
      );
    }
  });
}
