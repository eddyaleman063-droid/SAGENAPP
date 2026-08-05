import 'package:json_annotation/json_annotation.dart';

/// Types of lesson activities (true/false, multiple choice, etc).
@JsonEnum()
enum LessonType {
  trueFalse,
  multipleChoice,
  completePhrase,
  detectRisk,
  createPassword,
  whatWouldYouDo,
  miniCase,
}

extension LessonTypeExtension on LessonType {
  String get label {
    switch (this) {
      case LessonType.trueFalse:
        return 'True / False';
      case LessonType.multipleChoice:
        return 'Multiple Choice';
      case LessonType.completePhrase:
        return 'Complete the phrase';
      case LessonType.detectRisk:
        return 'Detect risk';
      case LessonType.createPassword:
        return 'Create password';
      case LessonType.whatWouldYouDo:
        return 'What would you do?';
      case LessonType.miniCase:
        return 'Real case';
    }
  }
}
