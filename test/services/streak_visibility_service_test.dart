import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/streak_visibility_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StreakVisibilityService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('shows when nothing is stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = StreakVisibilityService(prefs);
      expect(service.shouldShow(), isTrue);
    });

    test('shows when stored date is not today', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = StreakVisibilityService(prefs);
      await prefs.setString('has_completed_daily_streak', '2000-01-01');
      expect(service.shouldShow(), isTrue);
    });

    test('hides after markShown', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = StreakVisibilityService(prefs);
      await service.markShown();
      expect(service.shouldShow(), isFalse);
    });

    test('stored value matches UTC today format', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = StreakVisibilityService(prefs);
      await service.markShown();
      final now = DateTime.now().toUtc();
      final expected =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(prefs.getString('has_completed_daily_streak'), expected);
    });

    test('todayKey uses the UTC calendar day (NUEVO-fix ronda 23)', () async {
      final prefs = await SharedPreferences.getInstance();
      // 2026-09-07 23:00 UTC: en zonas con offset positivo el calendario
      // local ya sería 2026-09-08; la clave debe seguir al día UTC de la racha.
      final service = StreakVisibilityService(
        prefs,
        clock: () => DateTime.utc(2026, 9, 7, 23, 0),
      );
      await service.markShown();
      expect(prefs.getString('has_completed_daily_streak'), '2026-09-07');
      expect(service.shouldShow(), isFalse);
    });
  });
}
