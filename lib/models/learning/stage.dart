import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson.dart';
import 'session.dart';
import 'package:sagen/services/app_logger.dart';
import '../../core/theme/theme_constants.dart';

part 'stage.freezed.dart';
part 'stage.g.dart';

class _ColorConverter implements JsonConverter<Color, Object> {
  const _ColorConverter();
  @override
  Color fromJson(Object json) {
    if (json is int) return Color(json);
    if (json is String) {
      var h = json.replaceFirst('#', '');
      if (h.length == 6) h = 'FF$h';
      try {
        return Color(int.parse(h, radix: 16));
      } catch (_) {
        AppLogger().warning('StageColorConverter: failed to parse color from hex');
        return PremiumColors.wizardOrange;
      }
    }
    return PremiumColors.wizardOrange;
  }
  @override
  Object toJson(Color object) => object.toARGB32();
}

class _IconConverter implements JsonConverter<IconData, Object> {
  const _IconConverter();

  static const _iconMap = <String, IconData>{
    'shield': Icons.shield_rounded,
    'school': Icons.school_rounded,
    'lock': Icons.lock_rounded,
    'star': Icons.star_rounded,
    'emoji_events': Icons.emoji_events_rounded,
    'psychology': Icons.psychology_rounded,
    'build': Icons.build_rounded,
    'security': Icons.security_rounded,
    'vpn_key': Icons.vpn_key_rounded,
    'visibility': Icons.visibility_rounded,
  };

  static final Map<int, IconData> _codePointMap = {
    for (final entry in _iconMap.entries) entry.value.codePoint: entry.value,
  };

  @override
  IconData fromJson(Object json) {
    if (json is String) return _iconMap[json] ?? Icons.shield_rounded;
    if (json is int) return _codePointMap[json] ?? Icons.shield_rounded;
    return Icons.shield_rounded;
  }
  @override
  Object toJson(IconData object) {
    for (final entry in _iconMap.entries) {
      if (entry.value == object) return entry.key;
    }
    return 'shield';
  }
}

@freezed
class Stage with _$Stage {
  const Stage._();

  /// Represents a learning stage containing sessions and lessons.
  ///
  /// Hierarchy: Stage → Sessions → Lessons → Challenges
  ///
  /// [lessons] is a flat list of ALL lessons across all sessions,
  /// denormalized for efficient progress computation (progress,
  /// completedCount, isComplete, nextLesson).
  ///
  /// [sessions] provides the grouped structure for UI display.
  /// Each Session contains its own [Session.lessons] subset.
  ///
  /// Invariant: `lessons` == `sessions.expand((s) => s.lessons).toList()`
  factory Stage({
    required String id,
    required String title,
    required String subtitle,
    @_ColorConverter() required Color accent,
    @_IconConverter() required IconData icon,
    @Default([]) List<Lesson> lessons,
    @Default(false) bool unlocked,
    @Default([]) List<Session> sessions,
  }) = _Stage;

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);

  double get progress {
    if (lessons.isEmpty) return 0;
    final done = lessons.where((l) => l.completed).length;
    return done / lessons.length;
  }

  int get completedCount => lessons.where((l) => l.completed).length;

  bool get isComplete => lessons.every((l) => l.completed);

  Lesson? get nextLesson => lessons.where((l) => !l.completed).firstOrNull;

  /// Asserts the invariant that [lessons] is consistent with [sessions].
  /// In debug mode, throws if the flat list doesn't match the grouped structure.
  void assertConsistency() {
    assert(() {
      final sessionLessons = sessions.expand((s) => s.lessons).toList();
      if (lessons.length != sessionLessons.length) {
        throw StateError(
            'Stage $id: lessons (${lessons.length}) != '
            'sessions.expand().lessons (${sessionLessons.length})');
      }
      for (int i = 0; i < lessons.length; i++) {
        if (lessons[i].id != sessionLessons[i].id) {
          throw StateError(
              'Stage $id: lessons[$i].id (${lessons[i].id}) != '
              'sessions.expand()[$i].id (${sessionLessons[i].id})');
        }
      }
      return true;
    }());
  }
}
