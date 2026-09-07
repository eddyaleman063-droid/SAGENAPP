import 'package:shared_preferences/shared_preferences.dart';

/// Controls visibility of streak UI elements.
class StreakVisibilityService {
  static const _key = 'has_completed_daily_streak';
  final SharedPreferences _prefs;
  final DateTime Function() _now;

  // NUEVO-fix (ronda 23): el lock del "streak ya completado hoy" debe usar la
  // MISMA frontera de día que el dominio de racha (UTC), no la medianoche
  // local: antes, el aviso se re-ejecutaba entre las 19:00 y 23:59 en Perú
  // (cuando UTC ya era el día siguiente) aunque la racha no hubiera cambiado.
  StreakVisibilityService(this._prefs, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  bool shouldShow() {
    final stored = _prefs.getString(_key);
    if (stored == null) return true;
    return stored != _todayKey();
  }

  Future<void> markShown() => _prefs.setString(_key, _todayKey());

  String _todayKey() {
    final now = _now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
