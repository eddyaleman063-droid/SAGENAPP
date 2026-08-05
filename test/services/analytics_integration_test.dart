import 'package:flutter_test/flutter_test.dart';

class MockAnalyticsService {
  final List<String> trackedEvents = [];
  final List<String> trackedFeatures = [];
  int _flushCount = 0;

  void track(String event, {Map<String, dynamic>? properties}) {
    trackedEvents.add(event);
  }

  void trackScreen(String screenName) {
    trackedEvents.add('screen_$screenName');
  }

  void trackFeatureUsed(String feature) {
    trackedFeatures.add(feature);
  }

  void flush() {
    _flushCount++;
  }

  int get flushCount => _flushCount;

  void reset() {
    trackedEvents.clear();
    trackedFeatures.clear();
    _flushCount = 0;
  }
}

void main() {
  group('Analytics Integration', () {
    late MockAnalyticsService analytics;

    setUp(() {
      analytics = MockAnalyticsService();
    });

    test('tracks user journey from login to dashboard', () {
      analytics.trackScreen('login');
      analytics.track('login_success');
      analytics.trackScreen('dashboard');
      analytics.trackFeatureUsed('lessons_tab');

      expect(analytics.trackedEvents, [
        'screen_login',
        'login_success',
        'screen_dashboard',
      ]);
      expect(analytics.trackedFeatures, ['lessons_tab']);
    });

    test('tracks lesson completion flow', () {
      analytics.trackScreen('lesson_session');
      analytics.track('lesson_start');
      analytics.track('lesson_answer_correct');
      analytics.track('lesson_complete');
      analytics.trackFeatureUsed('lesson_5');

      expect(analytics.trackedEvents.length, equals(4));
      expect(analytics.trackedFeatures, contains('lesson_5'));
    });

    test('tracks store purchase flow', () {
      analytics.trackScreen('store');
      analytics.trackFeatureUsed('chest_dorado');
      analytics.track('purchase_initiated');
      analytics.track('purchase_completed');

      expect(analytics.trackedEvents.length, equals(3));
      expect(analytics.trackedFeatures, contains('chest_dorado'));
    });

    test('flush persists events', () {
      analytics.track('test_event');
      analytics.flush();
      expect(analytics.flushCount, equals(1));
    });

    test('reset clears all data', () {
      analytics.track('event1');
      analytics.trackFeatureUsed('feature1');
      analytics.flush();
      analytics.reset();

      expect(analytics.trackedEvents, isEmpty);
      expect(analytics.trackedFeatures, isEmpty);
      expect(analytics.flushCount, equals(0));
    });
  });
}
