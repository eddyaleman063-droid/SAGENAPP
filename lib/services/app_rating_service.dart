import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages in-app review prompts after milestone sessions.
class AppRatingService {
  AppRatingService();

  static const _keySessionCount = 'app_rating_session_count';
  static const _keyRated = 'app_rating_rated';
  static const _keyDismissed = 'app_rating_dismissed';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> onSessionCompleted() async {
    final prefs = await _getPrefs();
    if (prefs.getBool(_keyRated) == true || prefs.getBool(_keyDismissed) == true) return;

    final count = (prefs.getInt(_keySessionCount) ?? 0) + 1;
    await prefs.setInt(_keySessionCount, count);

    if (count >= 5) {
      _showRatingPrompt();
    }
  }

  Future<void> _showRatingPrompt() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  Future<void> markRated() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyRated, true);
  }

  Future<void> markDismissed() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyDismissed, true);
  }
}
