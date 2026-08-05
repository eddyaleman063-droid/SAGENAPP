import 'package:shared_preferences/shared_preferences.dart';

/// Repository for streak data persistence.
/// Abstracts SharedPreferences access for testability.
abstract class StreakRepository {
  int get currentStreak;
  int get longestStreak;
  String get lastActivityDate;
  int get streakFreezes;
  bool get streakFrozen;

  void saveCurrentStreak(int value);
  void saveLongestStreak(int value);
  void saveLastActivityDate(String value);
  void saveStreakFreezes(int value);
  void saveStreakFrozen(bool value);
  void saveAll({
    required int currentStreak,
    required int longestStreak,
    required String lastActivityDate,
    required int streakFreezes,
  });
}

class StreakRepositoryImpl implements StreakRepository {
  final SharedPreferences _prefs;

  static const _keyCurrent = 'streak_current';
  static const _keyLongest = 'streak_longest';
  static const _keyLast = 'streak_last_activity';
  static const _keyFreezes = 'streak_freezes';
  static const _keyFrozen = 'streak_frozen';

  StreakRepositoryImpl(this._prefs);

  @override
  int get currentStreak => _prefs.getInt(_keyCurrent) ?? 0;

  @override
  int get longestStreak => _prefs.getInt(_keyLongest) ?? 0;

  @override
  String get lastActivityDate => _prefs.getString(_keyLast) ?? '';

  @override
  int get streakFreezes => _prefs.getInt(_keyFreezes) ?? 0;

  @override
  bool get streakFrozen => _prefs.getBool(_keyFrozen) ?? false;

  @override
  void saveCurrentStreak(int value) {
    _prefs.setInt(_keyCurrent, value);
  }

  @override
  void saveLongestStreak(int value) {
    _prefs.setInt(_keyLongest, value);
  }

  @override
  void saveLastActivityDate(String value) {
    _prefs.setString(_keyLast, value);
  }

  @override
  void saveStreakFreezes(int value) {
    _prefs.setInt(_keyFreezes, value);
  }

  @override
  void saveStreakFrozen(bool value) {
    _prefs.setBool(_keyFrozen, value);
  }

  @override
  void saveAll({
    required int currentStreak,
    required int longestStreak,
    required String lastActivityDate,
    required int streakFreezes,
  }) {
    _prefs.setInt(_keyCurrent, currentStreak);
    _prefs.setInt(_keyLongest, longestStreak);
    _prefs.setString(_keyLast, lastActivityDate);
    _prefs.setInt(_keyFreezes, streakFreezes);
  }
}
