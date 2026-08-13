import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/theme_constants.dart';
import '../models/learning/stage.dart';
import '../models/learning/lesson.dart';
import '../models/learning/session.dart';
import '../services/app_logger.dart';

List<Stage> _cachedStages = [];

List<Stage> get defaultStages => _cachedStages.isNotEmpty ? _cachedStages : [];

Future<List<Stage>> loadStagesFromAssets() async {
  if (_cachedStages.isNotEmpty) return _cachedStages;
  try {
    final jsonStr = await rootBundle.loadString('assets/content/stages.json');
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) return [];
    _cachedStages = decoded.whereType<Map<String, dynamic>>().map((s) {
      final accentHex = s['accent'] as String? ?? '#FF6F00';
      final accentColor = _parseColor(accentHex);

      final sessionsRaw = s['sessions'];
      final sessions = <Session>[];
      final allLessons = <Lesson>[];

      if (sessionsRaw is List) {
        for (final ses in sessionsRaw) {
          if (ses is! Map<String, dynamic>) continue;
          final lessonsRaw = ses['lessons'];
          final lessons = <Lesson>[];
          if (lessonsRaw is List) {
            for (final l in lessonsRaw) {
              if (l is! Map<String, dynamic>) continue;
              final lesson = Lesson(
                id: (l['id'] as String?) ?? '',
                title: (l['title'] as String?) ?? '',
                subtitle: (l['subtitle'] as String?) ?? '',
                challenges: [],
                xpReward: (l['xpReward'] as num?)?.toInt() ?? 15,
                estimatedMinutes: (l['estimatedMinutes'] as num?)?.toInt() ?? 3,
                completed: l['completed'] == true,
              );
              lessons.add(lesson);
              allLessons.add(lesson);
            }
          }
          sessions.add(
            Session(
              id: (ses['id'] as String?) ?? '',
              title: (ses['title'] as String?) ?? '',
              subtitle: (ses['subtitle'] as String?) ?? '',
              lessons: lessons,
            ),
          );
        }
      }

      return Stage(
        id: (s['id'] as String?) ?? '',
        title: (s['title'] as String?) ?? '',
        subtitle: (s['subtitle'] as String?) ?? '',
        accent: accentColor,
        icon: Icons.shield_rounded,
        lessons: allLessons,
        sessions: sessions,
      );
    }).toList();
    AppLogger().info(
      'Loaded ${_cachedStages.length} stages from assets '
      '(${_cachedStages.fold(0, (s, st) => s + st.lessons.length)} lessons, '
      '${_cachedStages.fold(0, (s, st) => s + st.sessions.length)} sessions)',
    );
    return _cachedStages;
  } catch (e) {
    AppLogger().error('Failed to load stages from assets', e);
    return [];
  }
}

Color _parseColor(String hex) {
  try {
    var h = hex.replaceFirst('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  } catch (_) {
    AppLogger().warning('Failed to parse color hex: $hex');
    return PremiumColors.gradientActive[0];
  }
}
