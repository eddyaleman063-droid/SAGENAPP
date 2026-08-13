import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/quiz_result.dart';

QuizResult result({
  int total = 10,
  int correct = 8,
  int xp = 40,
  bool perfect = false,
  Duration time = const Duration(minutes: 3),
}) {
  return QuizResult(
    totalQuestions: total,
    correctAnswers: correct,
    xpEarned: xp,
    perfect: perfect,
    timeTaken: time,
    stageId: 'stage-1',
    lessonId: 'lesson-1',
  );
}

void main() {
  test('score is correctAnswers divided by total', () {
    expect(result().score, 0.8);
  });

  test('perfect quiz has score 1.0', () {
    expect(result(correct: 10, perfect: true).score, 1.0);
  });

  test('zero questions yields a zero score', () {
    expect(result(total: 0).score, 0);
  });

  test('carries metadata fields', () {
    final r = result();
    expect(r.stageId, 'stage-1');
    expect(r.lessonId, 'lesson-1');
    expect(r.xpEarned, 40);
    expect(r.timeTaken, const Duration(minutes: 3));
    expect(r.perfect, isFalse);
  });

  test('score is a double between zero and one', () {
    for (int total = 1; total <= 10; total++) {
      for (int correct = 0; correct <= total; correct++) {
        final score = result(total: total, correct: correct).score;
        expect(score, inInclusiveRange(0.0, 1.0));
      }
    }
  });
}
