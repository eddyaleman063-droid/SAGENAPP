import 'package:freezed_annotation/freezed_annotation.dart';
import 'special_item.dart';

part 'chest_reward.freezed.dart';
part 'chest_reward.g.dart';

@freezed
class ChestReward with _$ChestReward {
  const factory ChestReward({
    @Default(0) int xp,
    int? streakShields,
    String? title,
    String? message,
    @Default(false) bool isPremium,
    @Default(false) bool xpBoost,
    @Default([]) List<SpecialItemType> specialItems,
    @Default([]) List<SpecialItemType> cosmeticUnlocks,
  }) = _ChestReward;

  factory ChestReward.fromJson(Map<String, dynamic> json) => _$ChestRewardFromJson(json);
}

/// Determines when chests unlock and whether they are premium.
///
/// Chests unlock every 3rd or 5th lesson completed.
/// Premium chests (better rewards) unlock every 5th lesson.
class ChestSystem {
  static bool shouldUnlockChest(int lessonsCompleted) {
    if (lessonsCompleted <= 0) return false;
    return lessonsCompleted % 3 == 0 || lessonsCompleted % 5 == 0;
  }

  static bool isPremiumChest(int lessonsCompleted) {
    return lessonsCompleted > 0 && lessonsCompleted % 5 == 0;
  }
}
