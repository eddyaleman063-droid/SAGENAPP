/// Completed quiz result with scores and timing.
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int xpEarned;
  final int gemsEarned;
  final bool perfect;
  final Duration timeTaken;
  final String stageId;
  final String lessonId;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.xpEarned,
    this.gemsEarned = 0,
    required this.perfect,
    required this.timeTaken,
    required this.stageId,
    required this.lessonId,
  });

  double get score => totalQuestions > 0 ? correctAnswers / totalQuestions : 0;
}
