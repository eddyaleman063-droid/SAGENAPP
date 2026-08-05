import 'package:freezed_annotation/freezed_annotation.dart';
import 'challenge.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@unfreezed
class Lesson with _$Lesson {
  Lesson._();

  factory Lesson({
    required String id,
    required String title,
    required String subtitle,
    required List<Challenge> challenges,
    @Default(15) int xpReward,
    @Default(3) int estimatedMinutes,
    @Default(false) bool completed,
    @Default(0) int correctAnswers,
    @Default(0) int totalQuestions,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
