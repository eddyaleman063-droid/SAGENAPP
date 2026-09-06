import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/game_state_cleaner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameStateCleaner', () {
    // Muestra representativa de claves de estado de juego por usuario.
    const perUserSample = <String, Object>{
      'gems_balance': 1200,
      'gems_total_earned': 4200,
      'streak_current': 7,
      'streak_history': '2026-09-01,2026-09-02',
      'streak_heatmap': 'a:1',
      'energy_current': 45,
      'energy_last_regen': '2026-09-03T00:00:00',
      'daily_missions_v2': '[]',
      'review_q_fails': '{}',
      'review_ease_factor': '{}',
      'shop_owned_items': '["hat"]',
      'learning_memory_weak_topics': '[]',
      'protection_score': 5,
      'learning_xp': 500,
      'learning_level': 6,
      'learning_total_xp': 3000,
      'learning_stages': '[]',
      'learning_snapshot': '{}',
      'learning_integrity': 12345,
      'learning_total_donated': 10.5,
      'dashboard_daily_goal': 5,
      'sagen_pass_v1': '{}',
      'special_item_quantities': '{}',
      'payment_history': '[]',
      'inv_chests_opened': 3,
      'gamification_missions': '[]',
      'chest_evolution_history': '[]',
      'last_daily_bonus_day': '2026-09-03',
      'achievements_data': '{}',
    };

    // Claves de dispositivo que DEBEN sobrevivir al sign-out.
    const deviceKeys = <String, Object>{
      'theme_mode': 'dark',
      'preferred_language': 'es',
      'haptics_enabled': true,
      'onboarding_wizard_done': true,
      'app_rating_rated': true,
      'whats_new_last_version': '1.2.0',
    };

    setUp(() async {
      // Resetea el singleton memoizado para que cada test parta de un store
      // limpio (setMockInitialValues solo afecta a instancias nuevas; sin
      // resetStatic el cache del singleton arrastra claves de tests previos).
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();
    });

    test('clears all per-user game state keys', () async {
      SharedPreferences.setMockInitialValues({...perUserSample, ...deviceKeys});
      final prefs = await SharedPreferences.getInstance();

      await GameStateCleaner.clearGameState(prefs);

      for (final key in perUserSample.keys) {
        expect(prefs.get(key), isNull, reason: '$key should be cleared');
      }
    });

    test('clears dynamic lesson_progress_* keys', () async {
      SharedPreferences.setMockInitialValues({
        'lesson_progress_ac_st1/ses1': '[...]',
        'lesson_progress_ac_st2/ses2': '[...]',
        'theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();

      await GameStateCleaner.clearGameState(prefs);

      expect(prefs.getString('lesson_progress_ac_st1/ses1'), isNull);
      expect(prefs.getString('lesson_progress_ac_st2/ses2'), isNull);
      // Device key untouched.
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('does NOT clear device-level settings', () async {
      SharedPreferences.setMockInitialValues({...perUserSample, ...deviceKeys});
      final prefs = await SharedPreferences.getInstance();

      await GameStateCleaner.clearGameState(prefs);

      for (final key in deviceKeys.keys) {
        expect(prefs.get(key), isNotNull, reason: '$key should persist');
      }
    });

    test('returns the number of removed keys', () async {
      SharedPreferences.setMockInitialValues({...perUserSample, ...deviceKeys});
      final prefs = await SharedPreferences.getInstance();

      final removed = await GameStateCleaner.clearGameState(prefs);

      expect(removed, perUserSample.length);
    });

    test('is a no-op when there is nothing to clear', () async {
      final prefs = await SharedPreferences.getInstance();
      final removed = await GameStateCleaner.clearGameState(prefs);
      expect(removed, 0);
    });
  });
}
