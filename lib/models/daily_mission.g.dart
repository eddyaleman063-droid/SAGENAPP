// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyMissionImpl _$$DailyMissionImplFromJson(Map<String, dynamic> json) =>
    _$DailyMissionImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$MissionTypeEnumMap, json['type']),
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 30,
      target: (json['target'] as num?)?.toInt() ?? 1,
      difficulty:
          $enumDecodeNullable(_$MissionDifficultyEnumMap, json['difficulty']) ??
          MissionDifficulty.easy,
      rarity:
          $enumDecodeNullable(_$MissionRarityEnumMap, json['rarity']) ??
          MissionRarity.common,
      xpBonus: (json['xpBonus'] as num?)?.toInt() ?? 0,
      streakBonus: (json['streakBonus'] as num?)?.toInt() ?? 0,
      category:
          $enumDecodeNullable(_$MissionCategoryEnumMap, json['category']) ??
          MissionCategory.learning,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$$DailyMissionImplToJson(_$DailyMissionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$MissionTypeEnumMap[instance.type]!,
      'xpReward': instance.xpReward,
      'target': instance.target,
      'difficulty': _$MissionDifficultyEnumMap[instance.difficulty]!,
      'rarity': _$MissionRarityEnumMap[instance.rarity]!,
      'xpBonus': instance.xpBonus,
      'streakBonus': instance.streakBonus,
      'category': _$MissionCategoryEnumMap[instance.category]!,
      'progress': instance.progress,
      'completed': instance.completed,
    };

const _$MissionTypeEnumMap = {
  MissionType.completeLesson: 'completeLesson',
  MissionType.talkToSage: 'talkToSage',
  MissionType.analyzeLink: 'analyzeLink',
  MissionType.perfectLesson: 'perfectLesson',
  MissionType.maintainStreak: 'maintainStreak',
  MissionType.quickChallenge: 'quickChallenge',
  MissionType.detectPhishing: 'detectPhishing',
};

const _$MissionDifficultyEnumMap = {
  MissionDifficulty.easy: 'easy',
  MissionDifficulty.medium: 'medium',
  MissionDifficulty.hard: 'hard',
};

const _$MissionRarityEnumMap = {
  MissionRarity.common: 'common',
  MissionRarity.rare: 'rare',
  MissionRarity.epic: 'epic',
};

const _$MissionCategoryEnumMap = {
  MissionCategory.learning: 'learning',
  MissionCategory.protection: 'protection',
  MissionCategory.consistency: 'consistency',
  MissionCategory.awareness: 'awareness',
  MissionCategory.privacy: 'privacy',
  MissionCategory.safeHabits: 'safeHabits',
};
