// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chest_reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChestRewardImpl _$$ChestRewardImplFromJson(Map<String, dynamic> json) =>
    _$ChestRewardImpl(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      gems: (json['gems'] as num?)?.toInt() ?? 0,
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
      chestType: $enumDecodeNullable(_$ChestTypeEnumMap, json['chestType']),
    );

Map<String, dynamic> _$$ChestRewardImplToJson(_$ChestRewardImpl instance) =>
    <String, dynamic>{
      'xp': instance.xp,
      'gems': instance.gems,
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
      'chestType': _$ChestTypeEnumMap[instance.chestType],
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
  SpecialItemType.avatarFrameSkull: 'avatarFrameSkull',
  SpecialItemType.avatarFrameGalaxy: 'avatarFrameGalaxy',
  SpecialItemType.titleCyberSage: 'titleCyberSage',
  SpecialItemType.titleNightGuardian: 'titleNightGuardian',
  SpecialItemType.titleDigitalPhoenix: 'titleDigitalPhoenix',
  SpecialItemType.titleShadowHacker: 'titleShadowHacker',
  SpecialItemType.titleStormBreaker: 'titleStormBreaker',
  SpecialItemType.themeDarkFire: 'themeDarkFire',
  SpecialItemType.themeCyberNeon: 'themeCyberNeon',
  SpecialItemType.effectDigitalRain: 'effectDigitalRain',
  SpecialItemType.effectFireTrail: 'effectFireTrail',
};

const _$ChestTypeEnumMap = {
  ChestType.bronze: 'bronze',
  ChestType.silver: 'silver',
  ChestType.gold: 'gold',
  ChestType.legendary: 'legendary',
};
