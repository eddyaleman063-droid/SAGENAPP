import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning/lesson.dart';
import '../models/learning/stage.dart';
import 'prefs_provider.dart';

class DashboardState {
  static const _defaultLessonMinutes = 10;

  final String displayName;
  final double totalDonated;
  final int xp;
  final int level;
  final int nextLevelXp;
  final double levelProgress;
  final int currentStreak;
  final int longestStreak;
  final int dailyGoalMinutes;
  final int lessonsCompletedToday;
  final Lesson? nextLesson;
  final String? nextLessonStageTitle;
  final bool isLoading;
  final int activeTab;

  const DashboardState({
    this.displayName = '',
    this.totalDonated = 0.0,
    this.xp = 0,
    this.level = 1,
    this.nextLevelXp = 100,
    this.levelProgress = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.dailyGoalMinutes = 0,
    this.lessonsCompletedToday = 0,
    this.nextLesson,
    this.nextLessonStageTitle,
    this.isLoading = true,
    this.activeTab = 0,
  });

  DashboardState copyWith({
    String? displayName,
    double? totalDonated,
    int? xp,
    int? level,
    int? nextLevelXp,
    double? levelProgress,
    int? currentStreak,
    int? longestStreak,
    int? dailyGoalMinutes,
    int? lessonsCompletedToday,
    Lesson? Function()? nextLesson,
    String? Function()? nextLessonStageTitle,
    bool? isLoading,
    int? activeTab,
  }) {
    return DashboardState(
      displayName: displayName ?? this.displayName,
      totalDonated: totalDonated ?? this.totalDonated,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      levelProgress: levelProgress ?? this.levelProgress,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      lessonsCompletedToday: lessonsCompletedToday ?? this.lessonsCompletedToday,
      nextLesson: nextLesson != null ? nextLesson() : this.nextLesson,
      nextLessonStageTitle: nextLessonStageTitle != null ? nextLessonStageTitle() : this.nextLessonStageTitle,
      isLoading: isLoading ?? this.isLoading,
      activeTab: activeTab ?? this.activeTab,
    );
  }

  double get dailyProgress {
    if (dailyGoalMinutes <= 0) return 0;
    return (lessonsCompletedToday * _defaultLessonMinutes / dailyGoalMinutes).clamp(0, 1);
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  static const _keyDailyGoal = 'dashboard_daily_goal';

  @override
  DashboardState build() {
    final savedGoal = ref.read(prefsProvider).getInt(_keyDailyGoal) ?? 0;
    return DashboardState(dailyGoalMinutes: savedGoal);
  }

  void setActiveTab(int index) {
    if (index == state.activeTab) return;
    state = state.copyWith(activeTab: index);
  }

  void setDailyGoalMinutes(int minutes) {
    state = state.copyWith(dailyGoalMinutes: minutes);
    ref.read(prefsProvider).setInt(_keyDailyGoal, minutes);
  }

  void updateFrom({
    required String displayName,
    required double totalDonated,
    required int xp,
    required int level,
    required int nextLevelXp,
    required double levelProgress,
    required int currentStreak,
    required int longestStreak,
    required int dailyGoalMinutes,
    required int lessonsCompletedToday,
    required List<Stage> stages,
  }) {
    Lesson? nextLesson;
    String? nextLessonStageTitle;
    for (final stage in stages) {
      final next = stage.nextLesson;
      if (next != null && !next.completed) {
        nextLesson = next;
        nextLessonStageTitle = stage.title;
        break;
      }
    }

    state = state.copyWith(
      displayName: displayName,
      totalDonated: totalDonated,
      xp: xp,
      level: level,
      nextLevelXp: nextLevelXp,
      levelProgress: levelProgress,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      dailyGoalMinutes: dailyGoalMinutes,
      lessonsCompletedToday: lessonsCompletedToday,
      nextLesson: () => nextLesson,
      nextLessonStageTitle: () => nextLessonStageTitle,
      isLoading: false,
    );
  }
}
