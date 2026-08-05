import 'package:shared_preferences/shared_preferences.dart';

/// Controls visibility of streak UI elements.
class StreakVisibilityService {
  static const _key = 'has_completed_daily_streak';
  final SharedPreferences _prefs;

  StreakVisibilityService(this._prefs);

  bool shouldShow() {
    final stored = _prefs.getString(_key);
    if (stored == null) return true;
    return stored != _todayKey();
  }

  Future<void> markShown() => _prefs.setString(_key, _todayKey());

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
