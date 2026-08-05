import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/experience_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ExperienceService.instance.init();
  });
  group('ExperienceService', () {
    test('initializes with defaults', () {
      expect(ExperienceService.instance.soundEnabled, isTrue);
      expect(ExperienceService.instance.hapticEnabled, isTrue);
      expect(ExperienceService.instance.reduceAnimations, isFalse);
    });
    test('normal returns non-zero duration when animations enabled', () {
      final duration = ExperienceService.instance.normal;
      expect(duration.inMilliseconds, greaterThan(0));
    });
    test('normal returns zero when reduced animations enabled', () async {
      SharedPreferences.setMockInitialValues({'reduce_animations': true});
      await ExperienceService.instance.init();
      final duration = ExperienceService.instance.normal;
      expect(duration, Duration.zero);
    });
    test('provides all animation duration getters', () {
      expect(ExperienceService.instance.fast, isNotNull);
      expect(ExperienceService.instance.normal, isNotNull);
      expect(ExperienceService.instance.medium, isNotNull);
      expect(ExperienceService.instance.slow, isNotNull);
      expect(ExperienceService.instance.celebration, isNotNull);
    });
    test('celebration is non-zero even with reduced animations', () async {
      SharedPreferences.setMockInitialValues({'reduce_animations': true});
      await ExperienceService.instance.init();
      expect(
        ExperienceService.instance.celebration.inMilliseconds,
        greaterThan(0),
      );
    });
    test('sound preference defaults to enabled', () {
      expect(ExperienceService.instance.soundEnabled, isTrue);
    });
    test('setting sound preference persists', () async {
      await ExperienceService.instance.setSoundEnabled(false);
      expect(ExperienceService.instance.soundEnabled, isFalse);
    });
    test('setting haptic preference persists', () async {
      await ExperienceService.instance.setHapticEnabled(false);
      expect(ExperienceService.instance.hapticEnabled, isFalse);
    });
  });
}
