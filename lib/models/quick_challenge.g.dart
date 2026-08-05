// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$QuickChallengeImpl _$$QuickChallengeImplFromJson(Map<String, dynamic> json) =>
    _$QuickChallengeImpl(
      id: json['id'] as String,
      type: $enumDecode(_$QuickChallengeTypeEnumMap, json['type']),
      question: json['question'] as String,
      scenario: json['scenario'] as String,
      options: (json['options'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      correctIndex: (json['correctIndex'] as num).toInt(),
      explanation: json['explanation'] as String,
      consequenceCorrect: json['consequenceCorrect'] as String? ?? '',
      consequenceWrong: json['consequenceWrong'] as String? ?? '',
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 15,
    );

Map<String, dynamic> _$$QuickChallengeImplToJson(
  _$QuickChallengeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$QuickChallengeTypeEnumMap[instance.type]!,
  'question': instance.question,
  'scenario': instance.scenario,
  'options': instance.options,
  'correctIndex': instance.correctIndex,
  'explanation': instance.explanation,
  'consequenceCorrect': instance.consequenceCorrect,
  'consequenceWrong': instance.consequenceWrong,
  'xpReward': instance.xpReward,
};

const _$QuickChallengeTypeEnumMap = {
  QuickChallengeType.trueFalse: 'trueFalse',
  QuickChallengeType.detectRisk: 'detectRisk',
  QuickChallengeType.safePassword: 'safePassword',
  QuickChallengeType.whatWouldYouDo: 'whatWouldYouDo',
  QuickChallengeType.detectPhishing: 'detectPhishing',
};
