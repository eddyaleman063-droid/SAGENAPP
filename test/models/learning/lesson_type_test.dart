import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/lesson_type.dart';

void main() {
  test('every lesson type has a label', () {
    expect(LessonType.trueFalse.label, 'True / False');
    expect(LessonType.multipleChoice.label, 'Multiple Choice');
    expect(LessonType.completePhrase.label, 'Complete the phrase');
    expect(LessonType.detectRisk.label, 'Detect risk');
    expect(LessonType.createPassword.label, 'Create password');
    expect(LessonType.whatWouldYouDo.label, 'What would you do?');
    expect(LessonType.miniCase.label, 'Real case');
  });

  test('labels are unique across types', () {
    final labels = LessonType.values.map((t) => t.label).toList();
    expect(labels.toSet().length, labels.length);
  });

  test('has seven lesson types', () {
    expect(LessonType.values.length, 7);
  });
}
