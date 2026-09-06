import 'package:shared_preferences/shared_preferences.dart';

/// Limpia el estado de juego local por usuario al cerrar sesión.
///
/// El progreso de juego (streak, energía, misiones, review SM-2, items del
/// shop, memory de aprendizaje, gemas, etc.) vive en claves GLOBALES de
/// SharedPreferences y NO se sincroniza a la nube (`_keysToSync` solo cubre
/// perfil). Si no se vacía al cerrar sesión, el siguiente usuario del mismo
/// dispositivo hereda el progreso completo del anterior (fuga cruzada de
/// estado/crédito). Este cleaner borra esas claves, dejando intacto lo que sí
/// debe sobrevivir al sign-out: ajustes de dispositivo (tema, idioma, hápticos,
/// onboarding-wizard, rating, analytics consent) y la caché de configuración
/// remota.
///
/// IMPORTANTE: es una lista explícita por diseño (precisión: nunca borra más de
/// lo necesario). Si se añade una nueva clave de estado de juego por usuario,
/// debe registrarse aquí.
class GameStateCleaner {
  static const List<String> _perUserKeys = [
    // ── Gemas (balance/caché local; el servidor es la fuente de verdad) ──
    'gems_balance',
    'gems_total_earned',
    'gems_total_spent',
    'gems_transactions',
    'gems_pending_earn_queue',
    'last_daily_bonus_day',
    'last_first_lesson_day',
    // ── Streak ──
    'streak_current',
    'streak_longest',
    'streak_last_activity',
    'streak_freezes',
    'streak_frozen',
    'streak_total_checkins',
    'streak_perfect_weeks',
    'streak_history',
    'streak_weekly_stats',
    'streak_heatmap',
    'streak_monthly_data',
    'streak_just_defrosted',
    // ── Sagen Pass ──
    'sagen_pass_v1',
    // ── Items especiales ──
    'special_item_quantities',
    'special_item_active_until',
    // ── Pagos ──
    'payment_pending',
    'payment_history',
    // ── Inventario / cofres ──
    'inv_chests_opened',
    'inv_total_chests',
    'inv_xp_boosts',
    'inv_bonus_multipliers',
    'chest_evolution_history',
    'chest_type_counts',
    // ── Gamificación (XP, cofres, misiones) ──
    'gamification_last_claim_date',
    'gamification_unclaimed_chest',
    'gamification_missions',
    'gamification_counted_missions',
    // ── Dashboard ──
    'dashboard_daily_goal',
    // ── Energía ──
    'energy_current',
    'energy_last_regen',
    // ── Memory de aprendizaje ──
    'learning_memory_weak_topics',
    'learning_memory_completed_challenges',
    'learning_memory_failed',
    'learning_memory_passed',
    'learning_memory_last_session',
    'learning_memory_sessions_week',
    // ── Misiones diarias ──
    'daily_missions_v2',
    'daily_missions_reset',
    'daily_missions_total',
    // ── Protección ──
    'protection_score',
    'protection_queries',
    'protection_analyses',
    'protection_missions',
    'protection_checkins',
    'protection_topics',
    'protection_habits',
    // ── Review (SM-2) ──
    'review_q_fails',
    'review_q_topics',
    'review_t_scores',
    'review_total',
    'review_ease_factor',
    'review_interval',
    'review_repetition',
    'review_next_date',
    // ── Shop ──
    'shop_xp_boost',
    'shop_owned_items',
    // ── Progreso de aprendizaje (XP, nivel, etapas, logros, donaciones) ──
    'learning_xp',
    'learning_level',
    'learning_lessons_completed',
    'learning_total_xp',
    'learning_sage_talks',
    'learning_is_supporter',
    'learning_stages',
    'learning_snapshot',
    'learning_achievements',
    'learning_integrity',
    'learning_needs_rechecksum',
    'learning_total_donated',
    // ── Logros ──
    'achievements_data',
    'analytics_achievements',
  ];

  /// Prefijo de las claves dinámicas de lecciones a medias por stage/lección.
  static const String _lessonProgressPrefix = 'lesson_progress_';

  /// Borra todas las claves de estado de juego por usuario y devuelve cuántas
  /// se eliminaron realmente (contando solo claves que existían antes de
  /// borrar, sin depender de la semántica de retorno de `remove`).
  static Future<int> clearGameState(SharedPreferences prefs) async {
    var count = 0;
    for (final key in _perUserKeys) {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
        count++;
      }
    }
    // Claves dinámicas: lecciones a medias (`lesson_progress_<stage>/<lesson>`).
    final keys = prefs.getKeys().toList();
    for (final key in keys) {
      if (key.startsWith(_lessonProgressPrefix)) {
        final removed = await prefs.remove(key);
        if (removed) count++;
      }
    }
    return count;
  }
}
