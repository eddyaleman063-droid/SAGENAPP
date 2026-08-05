// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StageImpl _$$StageImplFromJson(Map<String, dynamic> json) => _$StageImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  subtitle: json['subtitle'] as String,
  accent: const _ColorConverter().fromJson((json['accent'] as num).toInt()),
  icon: const _IconConverter().fromJson(json['icon'] as String),
  lessons:
      (json['lessons'] as List<dynamic>?)
          ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  unlocked: json['unlocked'] as bool? ?? false,
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$StageImplToJson(_$StageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'accent': const _ColorConverter().toJson(instance.accent),
      'icon': const _IconConverter().toJson(instance.icon),
      'lessons': instance.lessons,
      'unlocked': instance.unlocked,
      'sessions': instance.sessions,
    };
