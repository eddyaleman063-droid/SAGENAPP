import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = AnalyticsService.instance;
      await service.init();
      await service.setConsent(true);
    });

    tearDown(() {
      service.clearAll();
    });

    test('init sets isInitialized', () {
      expect(service.isInitialized, true);
    });

    test('track adds event to log', () {
      service.track(AnalyticEvent.appOpen);
      expect(service.eventCount(AnalyticEvent.appOpen), 1);
    });

    test('track increments aggregated counters', () {
      service.track(AnalyticEvent.screenView, properties: {'screen': 'home'});
      service.track(AnalyticEvent.screenView, properties: {'screen': 'home'});
      expect(service.eventCount(AnalyticEvent.screenView), 2);
    });

    test('trackScreen logs screen_view event', () {
      service.trackScreen('dashboard');
      expect(service.eventCount(AnalyticEvent.screenView), 1);
    });

    test('trackChallengeAttempt logs challenge events', () {
      service.trackChallengeAttempt('ch1', true);
      expect(service.eventCount(AnalyticEvent.challengeComplete), 1);
      expect(service.eventCount(AnalyticEvent.challengeAttempt), 1);
    });

    test('trackChallengeAttempt logs fail on incorrect', () {
      service.trackChallengeAttempt('ch1', false);
      expect(service.eventCount(AnalyticEvent.challengeFail), 1);
    });

    test('trackLessonComplete logs lesson_complete event', () {
      service.trackLessonComplete('lesson1');
      expect(service.eventCount(AnalyticEvent.lessonComplete), 1);
    });

    test('challengePassRate returns correct percentage', () {
      service.trackChallengeAttempt('ch1', true);
      service.trackChallengeAttempt('ch1', false);
      service.trackChallengeAttempt('ch1', true);
      expect(service.challengePassRate('ch1'), closeTo(2.0 / 3.0, 0.01));
    });

    test('unlockAchievement adds achievement', () {
      expect(service.isAchievementUnlocked(Achievement.firstQuery), false);
      service.unlockAchievement(Achievement.firstQuery);
      expect(service.isAchievementUnlocked(Achievement.firstQuery), true);
    });

    test('unlockAchievement does not duplicate', () {
      service.unlockAchievement(Achievement.firstQuery);
      service.unlockAchievement(Achievement.firstQuery);
      expect(service.unlocked.length, 1);
    });

    test('remove achievement clears it', () {
      service.unlockAchievement(Achievement.firstQuery);
      service.remove(Achievement.firstQuery);
      expect(service.isAchievementUnlocked(Achievement.firstQuery), false);
    });

    test('allAchievements returns all enum values', () {
      expect(service.allAchievements.length, Achievement.values.length);
    });

    test('clearAll resets everything', () {
      service.track(AnalyticEvent.appOpen);
      service.unlockAchievement(Achievement.firstQuery);
      service.clearAll();
      expect(service.eventCount(AnalyticEvent.appOpen), 0);
      expect(service.unlocked.length, 0);
    });

    test('track increments event count', () {
      service.track(AnalyticEvent.appOpen);
      expect(service.eventCount(AnalyticEvent.appOpen), 1);
    });
  });
}
