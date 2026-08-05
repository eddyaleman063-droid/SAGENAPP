import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which changelog entries the user has seen.
class WhatsNewService {
  WhatsNewService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyLastVersion = 'whats_new_last_version';

  /// Checks if the app version has changed since last launch.
  /// Returns true if a "what's new" dialog should be shown.
  Future<bool> shouldShow() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    final lastVersion = _prefs.getString(_keyLastVersion);

    if (lastVersion != currentVersion) {
      await _prefs.setString(_keyLastVersion, currentVersion);
      return lastVersion != null;
    }
    return false;
  }
}
