import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'app_logger.dart';

enum AnalyticEvent {
  appOpen,
  appClose,
  screenView,
  linkAnalysis,
  tutorQuery,
  voiceQuery,
  streakCheckIn,
  notificationRead,
  notificationClear,
  historySearch,
  historyDelete,
  settingsChange,
  challengeAttempt,
  challengeComplete,
  challengeFail,
  lessonComplete,
  onboardingStep,
  featureUsed,
  tutorialComplete,
  signUp,
  signIn,
  chestOpened,
  achievementUnlocked,
}

enum Achievement {
  firstQuery('First Query', 'Asked Sage something for the first time'),
  streak3('3-Day Streak', 'Kept your streak for 3 days'),
  streak7('7-Day Streak', 'A full week of activity'),
  streak14('14-Day Streak', 'Two unstoppable weeks'),
  streak30('30-Day Streak', 'One month of continuous learning'),
  streak100('100-Day Streak', 'Cybersecurity master'),
  tenQueries('10 Queries', 'Asked Sage 10 things'),
  voiceFirst('First Voice', 'Used the microphone for the first time'),
  linkFirst('First Analysis', 'Analyzed your first link'),
  perfectWeek('Perfect Week', 'Completed 7 days without failing'),
  protectedMonth('Protected Month', 'Kept your streak the whole month'),
  cyberGuardian('Digital Guardian', 'Reached 30+ day streak'),
  shieldBasic('Initial Shield', 'Your first day of protection'),
  shieldGlow('Glowing Shield', 'Reached 7-day streak'),
  shieldCrystal('Crystal Shield', 'Reached 30-day streak'),
  shieldLegendary('Legendary Shield', 'Reached 100-day streak'),
  firstLinkSafe('Safe Link', 'Analyzed your first safe link'),
  firstLinkDanger('Early Alert', 'Detected your first dangerous link'),
  ;

  final String title;
  final String description;
  const Achievement(this.title, this.description);
}

/// Tracks user analytics events and manages achievement progression.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  static AnalyticsService get instance => _instance;
  AnalyticsService._();

  static const _keyEvents = 'analytics_events';
  static const _keyAggregated = 'analytics_aggregated';
  static const _keyAchievements = 'analytics_achievements';
  static const _keyConsent = 'analytics_consent_given';
  static const _maxStoredEvents = 500;
  static const _maxAggregatedKeys = 500;
  static const _batchSize = 20;
  static const _flushInterval = Duration(seconds: 15);

  final AppLogger _logger = AppLogger();
  bool _initialized = false;
  SharedPreferences? _prefs;
  FirebaseAnalytics? _firebase;
  final List<Map<String, dynamic>> _eventLog = [];
  final Set<Achievement> _unlocked = {};
  Map<String, int> _aggregated = {};
  Timer? _flushTimer;
  bool _dirty = false;
  int _pendingCount = 0;
  bool _consentGiven = false;

  bool get isInitialized => _initialized;
  bool get consentGiven => _consentGiven;
  Set<Achievement> get unlocked => Set.unmodifiable(_unlocked);
  List<Achievement> get allAchievements => Achievement.values.toList();
  Map<String, int> get aggregated => Map.unmodifiable(_aggregated);

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _consentGiven = _prefs?.getBool(_keyConsent) ?? false;
      _load();
    } catch (e) {
      _logger.warning('AnalyticsService: SharedPreferences init failed: $e');
    }
    try {
      _firebase = FirebaseAnalytics.instance;
    } catch (e) {
      _logger.warning('AnalyticsService: FirebaseAnalytics unavailable: $e');
    }
    _initialized = true;
  }

  /// Sets GDPR analytics consent. When false, no events are tracked or sent.
  Future<void> setConsent(bool given) async {
    _consentGiven = given;
    try {
      await _prefs?.setBool(_keyConsent, given);
    } catch (e) {
      _logger.warning('AnalyticsService.setConsent: failed to save consent preference: $e');
    }
    if (!given) {
      await _firebase?.setAnalyticsCollectionEnabled(false);
      _logger.info('AnalyticsService: analytics disabled by user consent');
    } else {
      await _firebase?.setAnalyticsCollectionEnabled(true);
      _logger.info('AnalyticsService: analytics enabled by user consent');
    }
  }

  void _load() {
    try {
      final eventsJson = _prefs?.getString(_keyEvents);
      if (eventsJson != null) {
        final list = jsonDecode(eventsJson) as List;
        _eventLog.addAll(list.cast<Map<String, dynamic>>());
        if (_eventLog.length > _maxStoredEvents) {
          _eventLog.removeRange(0, _eventLog.length - _maxStoredEvents);
        }
      }
      final aggJson = _prefs?.getString(_keyAggregated);
      if (aggJson != null) {
        final map = jsonDecode(aggJson) as Map<String, dynamic>;
        _aggregated = map.map((k, v) => MapEntry(k, v as int));
      }
      final achJson = _prefs?.getString(_keyAchievements);
      if (achJson != null) {
        final list = jsonDecode(achJson) as List;
        for (final item in list) {
          final a = Achievement.values.firstWhere(
            (a) => a.name == item,
            orElse: () => Achievement.firstQuery,
          );
          _unlocked.add(a);
        }
      }
    } catch (e) {
      _logger.warning('AnalyticsService: _load failed: $e');
    }
  }

  void _save() {
    _dirty = true;
    _pendingCount++;
    if (_pendingCount >= _batchSize) {
      _flushSave();
      return;
    }
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushInterval, _flushSave);
  }

  Future<void> _flushSave() async {
    if (!_dirty) return;
    _dirty = false;
    _pendingCount = 0;
    _flushTimer?.cancel();
    _flushTimer = null;
    try {
      final eventsJson = jsonEncode(
        _eventLog.length > _maxStoredEvents
          ? _eventLog.sublist(_eventLog.length - _maxStoredEvents)
          : _eventLog,
      );
      final aggregatedJson = jsonEncode(_aggregated);
      final achievementsJson = jsonEncode(_unlocked.map((a) => a.name).toList());
      await Future.wait([
        _prefs?.setString(_keyEvents, eventsJson) ?? Future.value(),
        _prefs?.setString(_keyAggregated, aggregatedJson) ?? Future.value(),
        _prefs?.setString(_keyAchievements, achievementsJson) ?? Future.value(),
      ]);
    } catch (e) {
      _logger.warning('AnalyticsService: _flushSave failed: $e');
    }
  }

  void track(AnalyticEvent event, {Map<String, dynamic>? properties}) {
    if (!_initialized || !_consentGiven) return;
    final entry = <String, dynamic>{
      'event': event.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (properties != null) entry['properties'] = properties;
    _eventLog.add(entry);

    if (_eventLog.length > _maxStoredEvents * 2) {
      _eventLog.removeRange(0, _eventLog.length - _maxStoredEvents);
    }

    final key = 'count_${event.name}';
    _aggregated[key] = (_aggregated[key] ?? 0) + 1;

    if (properties != null) {
      for (final p in properties.entries) {
        final propKey = '${event.name}_${p.key}_${p.value}';
        _aggregated[propKey] = (_aggregated[propKey] ?? 0) + 1;
      }
    }

    // Evict oldest property-based keys if map grows too large
    if (_aggregated.length > _maxAggregatedKeys) {
      final keysToRemove = _aggregated.keys
          .where((k) => k.startsWith('${event.name}_') && !k.startsWith('count_'))
          .toList()
        ..sort();
      final removeCount = _aggregated.length - _maxAggregatedKeys;
      for (int i = 0; i < removeCount && i < keysToRemove.length; i++) {
        _aggregated.remove(keysToRemove[i]);
      }
    }

    _save();
    _logToFirebase(event, properties);
  }

  void _logToFirebase(AnalyticEvent event, Map<String, dynamic>? properties) {
    if (!_consentGiven) return;
    try {
      final fb = _firebase;
      if (fb == null) return;
      final name = _firebaseEventName(event);
      if (properties case final p?) {
        fb.logEvent(name: name, parameters: p.cast<String, Object>());
      } else {
        fb.logEvent(name: name);
      }
    } catch (e) {
      _logger.warning('AnalyticsService: Firebase logEvent failed: $e');
    }
  }

  String _firebaseEventName(AnalyticEvent event) {
    switch (event) {
      case AnalyticEvent.screenView:
        return 'screen_view';
      case AnalyticEvent.lessonComplete:
        return 'lesson_completed';
      case AnalyticEvent.challengeComplete:
        return 'challenge_completed';
      case AnalyticEvent.challengeFail:
        return 'challenge_failed';
      case AnalyticEvent.streakCheckIn:
        return 'streak_checkin';
      case AnalyticEvent.tutorialComplete:
        return 'tutorial_complete';
      case AnalyticEvent.signUp:
        return 'sign_up';
      case AnalyticEvent.signIn:
        return 'login';
      case AnalyticEvent.chestOpened:
        return 'chest_opened';
      case AnalyticEvent.appOpen:
        return 'app_open';
      case AnalyticEvent.appClose:
        return 'app_close';
      default:
        return event.name;
    }
  }

  void trackScreen(String screenName) {
    track(AnalyticEvent.screenView, properties: {'screen': screenName});
  }

  void trackChallengeAttempt(String challengeId, bool correct) {
    track(
      correct ? AnalyticEvent.challengeComplete : AnalyticEvent.challengeFail,
      properties: {'challenge': challengeId},
    );
    track(AnalyticEvent.challengeAttempt, properties: {'challenge': challengeId});
  }

  void trackLessonComplete(String lessonId) {
    track(AnalyticEvent.lessonComplete, properties: {'lesson': lessonId});
  }

  void trackOnboardingStep(int step) {
    track(AnalyticEvent.onboardingStep, properties: {'step': step.toString()});
  }

  void trackOnboardingComplete() {
    track(AnalyticEvent.onboardingStep, properties: {'step': 'complete'});
  }

  void trackFeatureUsed(String feature) {
    track(AnalyticEvent.featureUsed, properties: {'feature': feature});
  }


  void trackFlexCardShared(String source) {
    track(AnalyticEvent.featureUsed, properties: {
      'feature': 'flex_card_shared',
      'source': source,
    });
  }

  int eventCount(AnalyticEvent event) =>
      _aggregated['count_${event.name}'] ?? 0;

  int challengeAttempts(String challengeId) =>
      _aggregated['${AnalyticEvent.challengeAttempt.name}_challenge_$challengeId'] ?? 0;

  int challengeFails(String challengeId) =>
      _aggregated['${AnalyticEvent.challengeFail.name}_challenge_$challengeId'] ?? 0;

  double challengePassRate(String challengeId) {
    final total = challengeAttempts(challengeId);
    if (total == 0) return 0;
    final fails = challengeFails(challengeId);
    return (total - fails) / total;
  }

  bool isAchievementUnlocked(Achievement a) => _unlocked.contains(a);

  void unlockAchievement(Achievement achievement) {
    if (_unlocked.contains(achievement)) return;
    _unlocked.add(achievement);
    track(AnalyticEvent.achievementUnlocked, properties: {
      'achievement': achievement.name,
      'title': achievement.title,
    });
  }

  void remove(Achievement achievement) {
    _unlocked.remove(achievement);
    _flushSave();
  }

  void clearAll() {
    _unlocked.clear();
    _eventLog.clear();
    _aggregated.clear();
    _pendingCount = 0;
    _flushTimer?.cancel();
    _flushTimer = null;
    _flushSave();
  }

  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }
}
