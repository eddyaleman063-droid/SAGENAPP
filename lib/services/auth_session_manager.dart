import 'auth_models.dart';
import 'app_logger.dart';
import 'secure_storage_service.dart';

/// Persists and restores auth sessions via secure storage.
class AuthSessionManager {
  final SecureStorageService _secureStorage;
  final AppLogger _logger = AppLogger();

  AuthSessionManager({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService.instance;

  static const _keyUid = 'auth_fb_uid';
  static const _keyName = 'auth_fb_name';
  static const _keyEmail = 'auth_fb_email';
  static const _keyPhoto = 'auth_fb_photo';

  Future<void> saveSession(AppUser user) async {
    try {
      await _secureStorage.write(_keyUid, user.uid);
      await _secureStorage.write(_keyName, user.displayName);
      // Always write email/photoUrl to prevent stale data from previous user
      await _secureStorage.write(_keyEmail, user.email);
      await _secureStorage.write(_keyPhoto, user.photoUrl ?? '');
    } catch (e) {
      _logger.warning('AuthSessionManager: saveSession failed: $e');
    }
  }

  Future<AppUser?> restoreSession() async {
    try {
      final uid = await _secureStorage.read(_keyUid);
      if (uid != null && uid.isNotEmpty) {
        return AppUser(
          uid: uid,
          displayName: await _secureStorage.read(_keyName) ?? 'Estudiante',
          email: await _secureStorage.read(_keyEmail) ?? '',
          photoUrl: await _secureStorage.read(_keyPhoto),
        );
      }
    } catch (e) {
      _logger.warning('AuthSessionManager: restoreSession failed: $e');
    }
    return null;
  }

  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(_keyUid);
      await _secureStorage.delete(_keyName);
      await _secureStorage.delete(_keyEmail);
      await _secureStorage.delete(_keyPhoto);
    } catch (e) {
      _logger.warning('AuthSessionManager: clearSession failed: $e');
    }
  }
}
