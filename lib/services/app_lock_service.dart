import 'package:flutter/widgets.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'app_logger.dart';

/// Manages biometric app lock via local_auth.
class AppLockService {
  AppLockService._() : _logger = AppLogger();
  final AppLogger _logger;
  static final AppLockService instance = AppLockService._();

  final LocalAuthentication _auth = LocalAuthentication();
  static const _prefsKey = 'app_lock_enabled';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  Future<bool> get isAvailable async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      _logger.warning('AppLock: biometric check failed: $e');
      return false;
    }
  }

  Future<bool> get isEnabled async {
    final prefs = await _getPrefs();
    return prefs.getBool(_prefsKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_prefsKey, value);
  }

  Future<bool> authenticate({String? localizedReason}) async {
    if (!await isAvailable) return false;

    try {
      _isLocked = true;
      final reason = localizedReason ?? await _biometricReason();
      final result = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
      _isLocked = !result;
      return result;
    } on Exception catch (e) {
      _logger.warning('AppLock: auth failed: $e');
      _isLocked = false;
      return false;
    } catch (e) {
      _logger.warning('AppLock: auth failed: $e');
      _isLocked = false;
      return false;
    }
  }

  Future<bool> handleAppStart({String? localizedReason}) async {
    if (!await isEnabled) return true;
    return authenticate(localizedReason: localizedReason);
  }

  // NUEVO-fix: el prompt biométrico se localiza con la preferencia de idioma
  // persistida (mismo patrón que _resolveErrorLocale en main.dart). Antes se
  // mostraba 'Unlock SAGEN to continue' en inglés sin importar el idioma.
  Future<String> _biometricReason() async {
    const supported = ['es', 'en', 'fr', 'pt'];
    final prefs = await _getPrefs();
    final saved = prefs.getString('app_language');
    if (saved != null && supported.contains(saved)) {
      return lookupAppLocalizations(Locale(saved)).biometricReason;
    }
    final system =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final locale = supported.contains(system) ? system : 'es';
    return lookupAppLocalizations(Locale(locale)).biometricReason;
  }
}
