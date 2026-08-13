import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../core/interfaces/i_auth_service.dart';
export 'auth_models.dart';
import 'auth_models.dart';
import 'firebase_auth_client.dart';
import 'auth_session_manager.dart';
import 'app_logger.dart';

/// Manages user authentication via Firebase Auth.
///
/// Wraps [FirebaseAuth] with session management, automatic token refresh,
/// and error handling. Implements [IAuthService] for testability.
class AuthService implements IAuthService {
  AuthService({
    AppLogger? logger,
    AuthClient? client,
    AuthSessionManager? sessionManager,
  }) : _logger = logger ?? AppLogger(),
       _client = client ?? FirebaseAuthClient(),
       _sessionManager = sessionManager ?? AuthSessionManager();

  final AuthClient _client;
  final AuthSessionManager _sessionManager;
  final AppLogger _logger;

  AppUser? _currentUser;
  StreamSubscription<firebase.User?>? _authSub;
  final StreamController<AppUser?> _authController =
      StreamController<AppUser?>.broadcast();
  bool _disposed = false;

  @override
  AppUser? get currentUser => _currentUser;
  @override
  bool get isLoggedIn => _currentUser != null;
  String get displayName => _currentUser?.displayName ?? 'Estudiante';
  String get email => _currentUser?.email ?? '';
  String? get photoUrl => _currentUser?.photoUrl;

  @override
  Stream<AppUser?> get authStateChanges => _authController.stream;

  @override
  Future<void> init() async {
    _authSub?.cancel();
    _client.init();

    if (!_client.isAvailable) return;

    _authSub = _client.authStateChanges.listen(
      (firebaseUser) async {
        try {
          if (firebaseUser != null) {
            await firebaseUser.reload();
            _currentUser = _client.appUserFromFirebase(firebaseUser);
            final user = _currentUser;
            if (user == null) return;
            await _sessionManager.saveSession(user);
          } else {
            _currentUser = null;
          }
          if (!_authController.isClosed) {
            _authController.add(_currentUser);
          }
        } catch (e) {
          _logger.error('AuthService: authState handler error', e);
        }
      },
      onError: (Object error) {
        _logger.error('AuthService: authStateChanges error', error);
      },
      cancelOnError: false,
    );

    try {
      final fbUser = _client.firebaseUser;
      if (fbUser != null) {
        await fbUser.reload();
        _currentUser = _client.appUserFromFirebase(fbUser);
        final user = _currentUser;
        if (user == null) return;
        await _sessionManager.saveSession(user);
      } else {
        final restored = await _sessionManager.restoreSession();
        if (restored != null) {
          final valid = await _validateRestoredSession();
          _currentUser = valid ? restored : null;
          if (!valid) await _sessionManager.clearSession();
        }
      }
    } catch (e) {
      _logger.warning('AuthService: init failed to get Firebase user: $e');
      final restored = await _sessionManager.restoreSession();
      if (restored != null) {
        final valid = await _validateRestoredSession();
        _currentUser = valid ? restored : null;
        if (!valid) await _sessionManager.clearSession();
      }
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final user = await _client.signInWithGoogle();
      _currentUser = user;
      await _sessionManager.saveSession(user);
      return user;
    } catch (e) {
      _logger.error('AuthService: signInWithGoogle failed', e);
      rethrow;
    }
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    try {
      final user = await _client.signInWithFacebook();
      _currentUser = user;
      await _sessionManager.saveSession(user);
      return user;
    } catch (e) {
      _logger.error('AuthService: signInWithFacebook failed', e);
      rethrow;
    }
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _client.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _currentUser = user;
      await _sessionManager.saveSession(user);
      return user;
    } catch (e) {
      _logger.error('AuthService: signUpWithEmail failed', e);
      rethrow;
    }
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _client.signInWithEmail(
        email: email,
        password: password,
      );
      _currentUser = user;
      await _sessionManager.saveSession(user);
      return user;
    } catch (e) {
      _logger.error('AuthService: signInWithEmail failed', e);
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _client.sendEmailVerification();
    } catch (e) {
      _logger.error('AuthService: sendEmailVerification failed', e);
      rethrow;
    }
  }

  @override
  Future<bool> reloadUser() async {
    try {
      final verified = await _client.reloadUser();
      final fbUser = _client.firebaseUser;
      if (fbUser != null) {
        _currentUser = _client.appUserFromFirebase(fbUser);
        final user = _currentUser;
        if (user == null) return verified;
        await _sessionManager.saveSession(user);
      }
      return verified;
    } catch (e) {
      _logger.error('AuthService: reloadUser failed', e);
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.sendPasswordResetEmail(email);
    } catch (e) {
      _logger.error('AuthService: sendPasswordResetEmail failed', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.signOutFirebase();
      await _sessionManager.clearSession();
      _currentUser = null;
    } catch (e) {
      _logger.error('AuthService: signOut failed', e);
      rethrow;
    }
  }

  Future<bool> _validateRestoredSession() async {
    if (!_client.isAvailable) return false;
    try {
      final fbUser = _client.firebaseUser;
      if (fbUser == null) return false;
      await fbUser.reload();
      return true;
    } catch (_) {
      _logger.warning('AuthService: _validateRestoredSession failed');
      return false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _client.deleteFirebaseUser();
      await signOut();
    } catch (e) {
      _logger.error('AuthService: deleteAccount failed', e);
      rethrow;
    }
  }

  Future<void> clearAllLocalData() async {
    await _sessionManager.clearSession();
  }

  @override
  Future<firebase.User?> reauthenticate(String email, String password) async {
    try {
      return await _client.reauthenticate(email, password);
    } catch (e) {
      _logger.error('AuthService: reauthenticate failed', e);
      rethrow;
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      return await _client.getIdToken();
    } catch (e) {
      _logger.error('AuthService: getIdToken failed', e);
      return null;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _authSub?.cancel();
    _authController.close();
  }
}
