// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChallengeImpl _$$ChallengeImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeImpl(
      id: json['id'] as String,
      question: json['question'] as String,
      type: $enumDecode(_$LessonTypeEnumMap, json['type']),
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String,
      lessonId: json['lessonId'] as String? ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$ChallengeImplToJson(_$ChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'type': _$LessonTypeEnumMap[instance.type]!,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
      'lessonId': instance.lessonId,
      'difficulty': instance.difficulty,
    };

const _$LessonTypeEnumMap = {
  LessonType.trueFalse: 'trueFalse',
  LessonType.multipleChoice: 'multipleChoice',
  LessonType.completePhrase: 'completePhrase',
  LessonType.detectRisk: 'detectRisk',
  LessonType.createPassword: 'createPassword',
  LessonType.whatWouldYouDo: 'whatWouldYouDo',
  LessonType.miniCase: 'miniCase',
};
