// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LessonImpl _$$LessonImplFromJson(Map<String, dynamic> json) => _$LessonImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  challenges: (json['challenges'] as List<dynamic>)
      .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
      .toList(),
  xpReward: (json['xpReward'] as num?)?.toInt() ?? 15,
  estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 3,
  completed: json['completed'] as bool? ?? false,
  correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
  totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$LessonImplToJson(_$LessonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'challenges': instance.challenges,
      'xpReward': instance.xpReward,
      'estimatedMinutes': instance.estimatedMinutes,
      'completed': instance.completed,
      'correctAnswers': instance.correctAnswers,
      'totalQuestions': instance.totalQuestions,
    };
