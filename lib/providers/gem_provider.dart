import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/gem_repository.dart';
import 'providers.dart';

class GemState {
  final int balance;
  final int totalEarned;
  final int totalSpent;

  const GemState({this.balance = 0, this.totalEarned = 0, this.totalSpent = 0});

  GemState copyWith({int? balance, int? totalEarned, int? totalSpent}) {
    return GemState(
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

class GemNotifier extends Notifier<GemState> {
  late final GemRepository _repo;

  @override
  GemState build() {
    _repo = ref.read(gemRepositoryProvider);
    return _load();
  }

  GemState _load() {
    return GemState(
      balance: _repo.balance,
      totalEarned: _repo.totalEarned,
      totalSpent: _repo.totalSpent,
    );
  }

  void addGems(int amount, {String? reason}) {
    if (amount <= 0) return;
    _repo.addGems(amount);
    _repo.save();
    state = _load();
  }

  bool spendGems(int amount, {String? reason}) {
    final success = _repo.spendGems(amount);
    if (success) {
      _repo.save();
      state = _load();
    }
    return success;
  }

  /// Award gems from a lesson based on correct answers.
  /// Base: 5 gems per correct answer + 100% bonus on perfect.
  void awardLessonGems(int correctAnswers, bool isPerfect) {
    final base = correctAnswers * 5;
    final perfectBonus = isPerfect ? base : 0;
    final total = base + perfectBonus;
    if (total > 0) addGems(total, reason: 'lesson');
  }

  /// Award gems from opening a chest.
  /// Scales with chest XP: chestXp / 3, clamped 2-75.
  /// Returns the number of gems awarded.
  int awardChestGems(int chestXp) {
    final gems = (chestXp / 3).round().clamp(2, 75);
    addGems(gems, reason: 'chest');
    return gems;
  }

  /// Award gems from daily login bonus.
  /// Escalates with streak: day 1-2=5, day 3-6=8, day 7-13=12, day 14-29=18, day 30+=30
  void awardDailyBonus(int dayStreak) {
    final prefs = ref.read(prefsProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    const lastKey = 'last_daily_bonus_day';
    if (prefs.getString(lastKey) == today) return;
    prefs.setString(lastKey, today);
    int gems;
    if (dayStreak >= 30) {
      gems = 30;
    } else if (dayStreak >= 14) {
      gems = 18;
    } else if (dayStreak >= 7) {
      gems = 12;
    } else if (dayStreak >= 3) {
      gems = 8;
    } else {
      gems = 5;
    }
    addGems(gems, reason: 'daily_bonus');
  }

  /// Award gems from achievement unlock.
  /// Scales with achievement XP: xpReward / 4, clamped 2-30.
  void awardAchievementGems(int xpReward) {
    final gems = (xpReward / 4).round().clamp(2, 30);
    addGems(gems, reason: 'achievement');
  }

  /// Award gems for completing a perfect lesson (all correct).
  /// Bonus 20 gems on top of normal lesson gems.
  void awardPerfectLessonBonus() {
    addGems(20, reason: 'perfect_lesson');
  }

  /// Award gems for first lesson of the day.
  /// 10 bonus gems once per day.
  void awardFirstLessonOfDay() {
    final prefs = ref.read(prefsProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    const lastKey = 'last_first_lesson_day';
    if (prefs.getString(lastKey) == today) return;
    prefs.setString(lastKey, today);
    addGems(10, reason: 'first_lesson_of_day');
  }

  /// Whether the first-lesson-of-day bonus can still be awarded today.
  bool get canAwardFirstLessonOfDay {
    final prefs = ref.read(prefsProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return prefs.getString('last_first_lesson_day') != today;
  }

  /// Award gems for reaching a streak milestone.
  /// Scales: 7d=15, 14d=30, 30d=60, 60d=100, 100d=150, 180d=250, 365d=500
  void awardStreakMilestone(int streakDays) {
    int gems;
    if (streakDays >= 365) {
      gems = 500;
    } else if (streakDays >= 180) {
      gems = 250;
    } else if (streakDays >= 100) {
      gems = 150;
    } else if (streakDays >= 60) {
      gems = 100;
    } else if (streakDays >= 30) {
      gems = 60;
    } else if (streakDays >= 14) {
      gems = 30;
    } else if (streakDays >= 7) {
      gems = 15;
    } else {
      return;
    }
    addGems(gems, reason: 'streak_milestone');
  }

  /// Award gems for completing a daily mission.
  /// Fixed 12 gems per mission.
  void awardMissionGems() {
    addGems(12, reason: 'mission');
  }

  /// Award gems for reviewing a lesson (spaced repetition).
  /// 6 gems per review.
  void awardReviewGems() {
    addGems(6, reason: 'review');
  }
}
