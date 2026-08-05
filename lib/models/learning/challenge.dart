import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson_type.dart';
import '../../core/theme/theme_constants.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
class Challenge with _$Challenge {
  const Challenge._();

  const factory Challenge({
    required String id,
    required String question,
    required LessonType type,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    @Default('') String lessonId,
    @Default(1) int difficulty,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);

  Color get color {
    switch (type) {
      case LessonType.trueFalse:
        return PremiumColors.challengeTrueFalse;
      case LessonType.multipleChoice:
        return PremiumColors.challengeMultipleChoice;
      case LessonType.completePhrase:
        return PremiumColors.challengeCompletePhrase;
      case LessonType.detectRisk:
        return PremiumColors.challengeDetectRisk;
      case LessonType.createPassword:
        return PremiumColors.challengeCreatePassword;
      case LessonType.whatWouldYouDo:
        return PremiumColors.challengeWhatWouldYouDo;
      case LessonType.miniCase:
        return PremiumColors.challengeMiniCase;
    }
  }

  bool get isCorrectIndexValid => correctIndex >= 0 && correctIndex < options.length;
}
