import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/achievement_service.dart';
import 'providers.dart';

class AchievementState {
  final bool isInitialized;
  final List<AchievementModel> achievements;
  final int unlockedCount;
  final int totalCount;
  final double progress;

  const AchievementState({
    this.isInitialized = false,
    this.achievements = const [],
    this.unlockedCount = 0,
    this.totalCount = 0,
    this.progress = 0.0,
  });

  AchievementState copyWith({
    bool? isInitialized,
    List<AchievementModel>? achievements,
    int? unlockedCount,
    int? totalCount,
    double? progress,
  }) {
    return AchievementState(
      isInitialized: isInitialized ?? this.isInitialized,
      achievements: achievements ?? this.achievements,
      unlockedCount: unlockedCount ?? this.unlockedCount,
      totalCount: totalCount ?? this.totalCount,
      progress: progress ?? this.progress,
    );
  }
}

class AchievementNotifier extends Notifier<AchievementState> {
  bool _disposed = false;

  @override
  AchievementState build() {
    ref.onDispose(() => _disposed = true);
    final prefs = ref.read(prefsProvider);
    _init(prefs);
    return const AchievementState();
  }

  Future<void> _init(SharedPreferences prefs) async {
    final service = ref.read(achievementServiceProvider);
    await service.init(prefs);
    if (_disposed) return;
    state = AchievementState(
      isInitialized: true,
      achievements: service.achievements,
      unlockedCount: service.unlockedCount,
      totalCount: service.totalCount,
      progress: service.progress,
    );
  }

  bool unlockAchievement(String id) {
    final service = ref.read(achievementServiceProvider);
    final xpReward = service.unlock(id);
    if (xpReward > 0) {
      state = state.copyWith(
        achievements: service.achievements,
        unlockedCount: service.unlockedCount,
        totalCount: service.totalCount,
        progress: service.progress,
      );
      // Deliver XP reward through the learning provider
      ref
          .read(learningProvider.notifier)
          .addXp(xpReward, reason: 'achievement');
      // Award gems from achievement
      ref.read(gemProvider.notifier).awardAchievementGems(xpReward);
    }
    return xpReward > 0;
  }
}
