import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';

Challenge _challenge({List<String>? options, int correctIndex = 0}) =>
    Challenge(
      id: 'c1',
      question: 'Q?',
      type: LessonType.multipleChoice,
      options: options ?? ['A', 'B', 'C'],
      correctIndex: correctIndex,
      explanation: 'E',
    );

void main() {
  group('Challenge.effectiveCorrectIndex', () {
    test('returns correctIndex when valid', () {
      expect(_challenge(correctIndex: 2).effectiveCorrectIndex, 2);
    });

    test('fallbacks to 0 when correctIndex negative', () {
      expect(_challenge(correctIndex: -1).effectiveCorrectIndex, 0);
    });

    test('fallbacks to 0 when correctIndex out of range', () {
      expect(_challenge(correctIndex: 99).effectiveCorrectIndex, 0);
    });

    test('does not throw RangeError with empty options', () {
      final c = _challenge(options: [], correctIndex: 0);
      expect(c.isCorrectIndexValid, isFalse);
      expect(c.effectiveCorrectIndex, 0);
    });
  });

  group('Challenge.isCorrectIndexValid', () {
    test('true for valid index', () {
      expect(_challenge(correctIndex: 1).isCorrectIndexValid, isTrue);
    });

    test('false for empty options', () {
      expect(
        _challenge(options: [], correctIndex: 0).isCorrectIndexValid,
        isFalse,
      );
    });

    test('false for negative index', () {
      expect(_challenge(correctIndex: -1).isCorrectIndexValid, isFalse);
    });
  });
}
