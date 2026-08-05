class MockAnalyticsService {
  final List<String> trackedEvents = [];
  final List<String> trackedFeatures = [];
  String? lastFlexCardSource;

  Future<void> init() async {}

  void track(String event, {Map<String, dynamic>? properties}) {
    trackedEvents.add(event);
  }

  void trackFlexCardShared(String source) {
    trackedFeatures.add('flex_card_shared');
    lastFlexCardSource = source;
  }

  void trackScreen(String screenName) {
    trackedEvents.add('screen_view_$screenName');
  }

  void trackFeatureUsed(String feature) {
    trackedFeatures.add(feature);
  }

  void reset() {
    trackedEvents.clear();
    trackedFeatures.clear();
    lastFlexCardSource = null;
  }
}
