/// Calculates XP, accuracy, and timing metrics for a quiz.
class QuizScoreCalculator {
  final int correctCount;
  final int totalQuestions;
  final int timeSpentSeconds;
  final int timeBudgetSeconds;

  static const int xpPerCorrect = 15;
  static const int perfectBonusXp = 30;
  static const double perfectMultiplier = 1.5;

  const QuizScoreCalculator({
    required this.correctCount,
    required this.totalQuestions,
    required this.timeSpentSeconds,
    this.timeBudgetSeconds = 0,
  });

  bool get isPerfect => correctCount == totalQuestions && totalQuestions > 0;

  /// Unified XP formula: base XP + perfect bonus + optional time bonus.
  int get xp {
    final base = correctCount * xpPerCorrect;
    final bonus = isPerfect ? perfectBonusXp : 0;
    final remaining = (timeBudgetSeconds - timeSpentSeconds).clamp(0, timeBudgetSeconds);
    final timeBonus = timeBudgetSeconds > 0
        ? ((remaining / timeBudgetSeconds) * 20).round()
        : 0;
    return base + bonus + timeBonus;
  }

  double get accuracyPercent {
    if (totalQuestions <= 0) return 0;
    return (correctCount / totalQuestions) * 100;
  }

  double get avgTimePerQuestion {
    if (totalQuestions <= 0 || timeSpentSeconds <= 0) return 0;
    return timeSpentSeconds / totalQuestions;
  }
}
