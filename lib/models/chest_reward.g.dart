// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chest_reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChestRewardImpl _$$ChestRewardImplFromJson(Map<String, dynamic> json) =>
    _$ChestRewardImpl(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streakShields: (json['streakShields'] as num?)?.toInt(),
      title: json['title'] as String?,
      message: json['message'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
      xpBoost: json['xpBoost'] as bool? ?? false,
      specialItems:
          (json['specialItems'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$SpecialItemTypeEnumMap, e))
              .toList() ??
          const [],
      cosmeticUnlocks:
          (json['cosmeticUnlocks'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$SpecialItemTypeEnumMap, e))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ChestRewardImplToJson(_$ChestRewardImpl instance) =>
    <String, dynamic>{
      'xp': instance.xp,
      'streakShields': instance.streakShields,
      'title': instance.title,
      'message': instance.message,
      'isPremium': instance.isPremium,
      'xpBoost': instance.xpBoost,
      'specialItems': instance.specialItems
          .map((e) => _$SpecialItemTypeEnumMap[e]!)
          .toList(),
      'cosmeticUnlocks': instance.cosmeticUnlocks
          .map((e) => _$SpecialItemTypeEnumMap[e]!)
          .toList(),
    };

const _$SpecialItemTypeEnumMap = {
  SpecialItemType.focusElixir: 'focusElixir',
  SpecialItemType.phoenixFeather: 'phoenixFeather',
  SpecialItemType.sageMonocle: 'sageMonocle',
  SpecialItemType.titaniumShield: 'titaniumShield',
  SpecialItemType.luckBoost: 'luckBoost',
  SpecialItemType.timeWarp: 'timeWarp',
  SpecialItemType.avatarFrameNeon: 'avatarFrameNeon',
  SpecialItemType.avatarFrameDragon: 'avatarFrameDragon',
  SpecialItemType.avatarFrameCrystal: 'avatarFrameCrystal',
  SpecialItemType.titleCyberSage: 'titleCyberSage',
  SpecialItemType.titleNightGuardian: 'titleNightGuardian',
  SpecialItemType.titleDigitalPhoenix: 'titleDigitalPhoenix',
  SpecialItemType.themeDarkFire: 'themeDarkFire',
  SpecialItemType.themeCyberNeon: 'themeCyberNeon',
};
