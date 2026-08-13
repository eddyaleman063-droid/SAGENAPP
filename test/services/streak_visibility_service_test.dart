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

    test('stored value matches today format', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = StreakVisibilityService(prefs);
      await service.markShown();
      final now = DateTime.now();
      final expected =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      expect(prefs.getString('has_completed_daily_streak'), expected);
    });
  });
}
