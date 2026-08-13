import 'package:shared_preferences/shared_preferences.dart';

/// Determines which promotional content to display to the user.
class SmartPromoService {
  static const _keyLastPromoShown = 'smart_promo_last_shown';
  static const _keyLessonsSincePromo = 'smart_promo_lessons_since';
  static const _keyDismissedUntil = 'smart_promo_dismissed_until';
  static const _keyDismissCount = 'smart_promo_dismiss_count';

  static const int lessonsBetweenPromos = 3;
  static const int dismissCooldownDays = 3;

  static SmartPromoService? _instance;
  static SmartPromoService get instance => _instance ??= SmartPromoService._();
  SmartPromoService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> incrementLessonCount() async {
    final current = _prefs?.getInt(_keyLessonsSincePromo) ?? 0;
    await _prefs?.setInt(_keyLessonsSincePromo, current + 1);
  }

  bool shouldShowPromo() {
    final p = _prefs;
    if (p == null) return false;

    final dismissedUntil = p.getString(_keyDismissedUntil);
    if (dismissedUntil != null) {
      final dismissedDate = DateTime.tryParse(dismissedUntil);
      if (dismissedDate != null && DateTime.now().isBefore(dismissedDate)) {
        return false;
      }
    }

    final lessonsSince = p.getInt(_keyLessonsSincePromo) ?? 0;
    return lessonsSince >= lessonsBetweenPromos;
  }

  Future<void> recordPromoShown() async {
    await _prefs?.setString(
      _keyLastPromoShown,
      DateTime.now().toIso8601String(),
    );
    await _prefs?.setInt(_keyLessonsSincePromo, 0);
  }

  Future<void> dismissForCooldown() async {
    final dismissCount = _prefs?.getInt(_keyDismissCount) ?? 0;
    final cooldown = dismissCooldownDays + (dismissCount * 2);
    final until = DateTime.now().add(Duration(days: cooldown));
    await _prefs?.setString(_keyDismissedUntil, until.toIso8601String());
    await _prefs?.setInt(_keyDismissCount, dismissCount + 1);
  }

  Future<void> dismissForever() async {
    await _prefs?.setString(_keyDismissedUntil, '2099-12-31T23:59:59');
  }

  int get lessonsUntilNextPromo {
    final lessonsSince = _prefs?.getInt(_keyLessonsSincePromo) ?? 0;
    return (lessonsBetweenPromos - lessonsSince).clamp(0, lessonsBetweenPromos);
  }
}
