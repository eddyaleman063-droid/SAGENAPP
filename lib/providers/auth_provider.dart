import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/auth/email_verification_manager.dart';
import '../services/auth/auth_sync_manager.dart';
import '../services/app_logger.dart';
import '../services/game_state_cleaner.dart';
import 'providers.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
  error,
  demo,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? uid;
  final bool pendingVerification;
  final bool onboardingCompleted;
  final bool profileLoaded;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.errorMessage,
    this.displayName = '',
    this.email = '',
    this.photoUrl,
    this.uid,
    this.pendingVerification = false,
    this.onboardingCompleted = false,
    this.profileLoaded = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? Function()? errorMessage,
    String? displayName,
    String? email,
    String? Function()? photoUrl,
    String? Function()? uid,
    bool? pendingVerification,
    bool? onboardingCompleted,
    bool? profileLoaded,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
      uid: uid != null ? uid() : this.uid,
      pendingVerification: pendingVerification ?? this.pendingVerification,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      profileLoaded: profileLoaded ?? this.profileLoaded,
    );
  }

  bool get isAuthenticated =>
      status == AuthStatus.authenticated || status == AuthStatus.demo;
  bool get isLoading => status == AuthStatus.loading;
  bool get isUninitialized => status == AuthStatus.uninitialized;
  bool get showVerificationScreen => pendingVerification;
  bool get isDemoMode => status == AuthStatus.demo;
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;
  late final AuthSyncManager _syncManager;
  late final EmailVerificationManager _verificationManager;
  SharedPreferences? _prefs;
  StreamSubscription<AppUser?>? _authSub;
  DateTime? _lastAuthAttempt;
  DateTime? _lastAuthError;
  static const _authCooldown = Duration(seconds: 3);
  static const _authErrorWindow = Duration(minutes: 1);
  int _consecutiveAuthErrors = 0;
  static const _maxConsecutiveErrors = 5;
  int _onboardingLoadEpoch = 0;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    final cloudSync = ref.watch(cloudSyncServiceProvider);
    _syncManager = AuthSyncManager(cloudSync);
    _verificationManager = EmailVerificationManager(_authService);
    final prefs = ref.read(prefsProvider);
    _prefs = prefs;
    _applyUser(_authService.currentUser);
    _cancelAuthSubscription();
    _authSub = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (e, st) {
        AppLogger().error('AuthStream error', e, st);
        state = state.copyWith(errorMessage: () => 'Error in auth stream');
      },
    );
    ref.onDispose(() {
      // NUEVO-fix (ronda 10): cancel devuelve Future; fire-and-forget explícito.
      unawaited(_authSub?.cancel());
      _verificationManager.dispose();
    });
    return state;
  }

  void _cancelAuthSubscription() {
    // NUEVO-fix (ronda 10): cancel devuelve Future; fire-and-forget explícito.
    unawaited(_authSub?.cancel());
    _authSub = null;
  }

  bool _checkRateLimit() {
    final now = DateTime.now();
    if (_lastAuthAttempt != null &&
        now.difference(_lastAuthAttempt ?? DateTime.now()) < _authCooldown) {
      return false;
    }
    if (_consecutiveAuthErrors >= _maxConsecutiveErrors) {
      final lastError = _lastAuthError;
      if (lastError != null && now.difference(lastError) >= _authErrorWindow) {
        // Ventana temporal: tras 1 minuto sin errores, se permite reintentar.
        _consecutiveAuthErrors = 0;
      } else {
        return false;
      }
    }
    _lastAuthAttempt = now;
    return true;
  }

  void _recordAuthError() {
    _consecutiveAuthErrors++;
    _lastAuthError = DateTime.now();
  }

  void _resetAuthErrors() {
    _consecutiveAuthErrors = 0;
  }

  void _onAuthStateChanged(AppUser? user) {
    final wasAuthenticated = state.status == AuthStatus.authenticated;
    _applyUser(user);
    if (state.status == AuthStatus.authenticated &&
        !wasAuthenticated &&
        user != null) {
      final prefs = _prefs;
      if (prefs != null) {
        // NUEVO-fix (ronda 10): syncAfterLogin maneja sus propios errores;
        // fire-and-forget explícito dentro del handler sync del stream.
        unawaited(_syncManager.syncAfterLogin(user.uid, prefs));
        _syncManager.startListening(user.uid, prefs);
      }
      // Reconcile the local gem cache with the authoritative server balance
      // right after login so the UI shows the real balance (NUEVO-03).
      // NUEVO-fix (ronda 9, P5): el Future es fire-and-forget → unawaited()
      // explícito (maneja sus propios errores internamente).
      unawaited(ref.read(gemProvider.notifier).syncBalanceFromServer());
    } else if (state.status == AuthStatus.unauthenticated && wasAuthenticated) {
      _syncManager.stopListening();
    }
  }

  void _applyUser(AppUser? user) {
    if (user != null) {
      final needsVerification = !user.isEmailVerified;
      state = state.copyWith(
        displayName: user.displayName,
        email: user.email,
        photoUrl: () => user.photoUrl,
        uid: () => user.uid,
        pendingVerification: needsVerification,
        status: user.isEmailVerified
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        errorMessage: () => null,
      );
      _syncManager.cancelInflightLoads();
      // NUEVO-fix (ronda 10): _loadOnboardingStatus maneja sus propios errores;
      // fire-and-forget explícito.
      unawaited(_loadOnboardingStatus(user.uid));
      if (needsVerification) {
        _verificationManager.startAutoCheck(_onEmailVerified);
      } else {
        _verificationManager.stopAutoCheck();
      }
    } else {
      _verificationManager.stopAutoCheck();
      _syncManager.cancelInflightLoads();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void _onEmailVerified(bool verified) {
    if (verified && state.status != AuthStatus.authenticated) {
      state = state.copyWith(
        pendingVerification: false,
        status: AuthStatus.authenticated,
        errorMessage: () => null,
      );
    }
  }

  Future<void> _loadOnboardingStatus(String uid) async {
    final epoch = ++_onboardingLoadEpoch;
    final completed = await _syncManager.loadOnboardingStatus(uid);
    if (epoch != _onboardingLoadEpoch) {
      return; // Stale — superseded by newer login
    }
    if (completed != null && state.uid == uid) {
      state = state.copyWith(
        onboardingCompleted: completed,
        profileLoaded: true,
      );
    } else if (state.uid == uid) {
      state = state.copyWith(profileLoaded: true);
    }
  }

  Future<void> refreshCurrentUser() async {
    _applyUser(_authService.currentUser);
  }

  Future<void> signInWithGoogle() async {
    if (!_checkRateLimit()) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'rate_limited',
      );
      return;
    }
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: () => null,
    );
    try {
      final user = await _authService.signInWithGoogle();
      _resetAuthErrors();
      state = state.copyWith(
        displayName: user.displayName,
        email: user.email,
        photoUrl: () => user.photoUrl,
        uid: () => user.uid,
        pendingVerification: !user.isEmailVerified,
        status: user.isEmailVerified
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        errorMessage: () => null,
      );
    } on AuthException catch (e) {
      _recordAuthError();
      if (e.code == 'canceled') {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => e.code,
        );
      }
    } catch (e) {
      AppLogger().warning('Auth: signInWithGoogle failed: $e');
      _recordAuthError();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'unknown',
      );
    }
  }

  Future<void> signInWithFacebook() async {
    if (!_checkRateLimit()) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'rate_limited',
      );
      return;
    }
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: () => null,
    );
    try {
      final user = await _authService.signInWithFacebook();
      _resetAuthErrors();
      state = state.copyWith(
        displayName: user.displayName,
        email: user.email,
        photoUrl: () => user.photoUrl,
        uid: () => user.uid,
        pendingVerification: !user.isEmailVerified,
        status: user.isEmailVerified
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        errorMessage: () => null,
      );
    } on AuthException catch (e) {
      _recordAuthError();
      if (e.code == 'canceled') {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => e.code,
        );
      }
    } catch (e) {
      AppLogger().warning('Auth: signInWithFacebook failed: $e');
      _recordAuthError();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'unknown',
      );
    }
  }

  Future<void> signUpWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    if (!_checkRateLimit()) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'rate_limited',
      );
      return;
    }
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: () => null,
    );
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _resetAuthErrors();
      state = state.copyWith(
        displayName: user.displayName,
        email: user.email,
        uid: () => user.uid,
        pendingVerification: true,
        status: AuthStatus.unauthenticated,
        errorMessage: () => null,
      );
    } on AuthException catch (e) {
      _recordAuthError();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => e.code,
      );
    } catch (e) {
      AppLogger().warning('Auth: signUpWithEmail failed: $e');
      _recordAuthError();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'unknown',
      );
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!_checkRateLimit()) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'rate_limited',
      );
      return;
    }
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: () => null,
    );
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _resetAuthErrors();
      state = state.copyWith(
        displayName: user.displayName,
        email: user.email,
        photoUrl: () => user.photoUrl,
        uid: () => user.uid,
        pendingVerification: !user.isEmailVerified,
        status: user.isEmailVerified
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        errorMessage: () => null,
      );
    } on AuthException catch (e) {
      _recordAuthError();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => e.code,
      );
    } catch (e) {
      AppLogger().warning('Auth: signInWithEmail failed: $e');
      _recordAuthError();
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'unknown',
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    state = state.copyWith(errorMessage: () => null);
    try {
      await _authService.sendEmailVerification();
    } on AuthException catch (e) {
      state = state.copyWith(errorMessage: () => e.code);
      rethrow;
    } catch (e) {
      AppLogger().warning('Auth: resendVerificationEmail failed: $e');
      state = state.copyWith(errorMessage: () => 'resend_error');
      rethrow;
    }
  }

  Future<void> checkEmailVerified() async {
    try {
      final verified = await _authService.reloadUser();
      if (verified) {
        // El token aun lleva claims antiguos (email_verified=false). Forzamos
        // la reemision del ID token para que las callables con
        // requireVerifiedUser no rechacen al usuario recien verificado.
        await _authService.getIdToken(forceRefresh: true);
        state = state.copyWith(
          pendingVerification: false,
          status: AuthStatus.authenticated,
          errorMessage: () => null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: () => 'not_verified',
        );
      }
    } catch (e) {
      AppLogger().warning('Auth: checkEmailVerified failed: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: () => 'verify_error',
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: () => null,
    );
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => e.code,
      );
    } catch (e) {
      AppLogger().warning('Auth: sendPasswordResetEmail failed: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'unknown',
      );
    }
  }

  Future<void> reauthenticate(String email, String password) async {
    try {
      final result = await _authService.reauthenticate(email, password);
      if (result == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => 'reauth_error',
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => e.code,
      );
    } catch (e) {
      AppLogger().warning('Auth: reauthenticate failed: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: () => 'reauth_error',
      );
    }
  }

  Future<void> signOut() async {
    try {
      final uid = state.uid;
      final prefs = _prefs;
      if (uid != null && prefs != null) {
        await _syncManager.saveBeforeSignOut(uid, prefs);
      }
      _syncManager.stopListening();
    } catch (e, stack) {
      AppLogger().error('Cloud sync during sign-out failed', e, stack);
    }
    // El sign-out real de Firebase NO debe pasarse por alto: si falla, el
    // usuario sigue autenticado a nivel de Firebase. Reseteamos el estado solo
    // si el sign-out tuvo exito; de lo contrario devolveríamos "deslogueado"
    // mientras FirebaseAuth aún tiene sesión activa (desync que confunde la
    // próxima sesión / re-atenticación en el siguiente arranque).
    try {
      await _authService.signOut();
    } catch (e, stack) {
      AppLogger().error('Auth: Firebase sign-out failed', e, stack);
      return;
    }
    // Al cerrar sesión, se limpian los datos locales de lección a medias para
    // que el siguiente usuario en este dispositivo no vea progreso ajeno.
    try {
      await ref.read(sessionProvider.notifier).clearAllProgress();
    } catch (e, stack) {
      AppLogger().warning(
        'signOut: failed to clear session progress',
        e,
        stack,
      );
    }
    // Se vacía la cola offline pendiente: al re-sincronizar, _syncItem usa el
    // uid del usuario actual de FirebaseAuth. Si quedara trabajo de la sesión
    // anterior en la cola, se acreditaría al siguiente usuario que inicie
    // sesión en este dispositivo (crédito cruzado de XP/gemas).
    try {
      await ref.read(offlineQueueServiceProvider).clear();
    } catch (e, stack) {
      AppLogger().warning('signOut: failed to clear offline queue', e, stack);
    }
    // La cola de acreditaciones de gemas pendientes es una clave global de
    // prefs: si no se vacía al cerrar sesión, el siguiente usuario del
    // dispositivo reenviaría los earns offline del anterior a su cuenta
    // (crédito cruzado de gemas), igual que la cola offline de items.
    try {
      await ref.read(gemProvider.notifier).clearPendingEarns();
    } catch (e, stack) {
      AppLogger().warning(
        'signOut: failed to clear pending gem earns',
        e,
        stack,
      );
    }
    // Limpieza completa del estado de juego por usuario (streak, energía,
    // misiones, review SM-2, items del shop, memory de aprendizaje, progreso de
    // aprendizaje, gemas, etc.): todas viven en claves globales de prefs y no
    // se sincronizan a la nube. Sin esto, el siguiente usuario del dispositivo
    // heredaría el progreso del anterior (fuga cruzada de estado/crédito).
    try {
      final prefs = _prefs;
      if (prefs != null) {
        await GameStateCleaner.clearGameState(prefs);
      }
    } catch (e, stack) {
      AppLogger().warning(
        'signOut: failed to clear per-user game state',
        e,
        stack,
      );
    }
    // La cola diaria de Sage es estática a nivel de clase; se resetea al
    // cerrar sesión para que el siguiente usuario no herede el conteo/límite
    // de mensajes del anterior en el mismo dispositivo.
    SageAiNotifier.resetRateLimits();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> deleteAccount({required String email, String? password}) async {
    // For OAuth users (Google/Facebook), try direct deletion since session is recent
    final isOAuth = password == null || password.isEmpty;
    if (!isOAuth) {
      try {
        final reauthResult = await _authService.reauthenticate(email, password);
        if (reauthResult == null) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: () => 'reauth_required_for_delete',
          );
          return;
        }
      } on AuthException catch (e) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => e.code,
        );
        return;
      } catch (e) {
        AppLogger().warning('Auth: deleteAccount reauth failed: $e');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => 'reauth_error',
        );
        return;
      }
    }

    _syncManager.stopListening();
    final uid = state.uid;
    final prefs = _prefs;
    if (uid != null && prefs != null) {
      await _syncManager.deleteCloudData(uid, prefs);
    }
    try {
      await _authService.deleteAccount();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e, stack) {
      AppLogger().error('deleteAccount failed', e, stack);
      // If direct deletion fails for OAuth user, show reauth message
      if (isOAuth) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: () => 'reauth_required_for_delete',
        );
      } else {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'delete_account_failed',
        );
      }
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: () => null);
  }

  /// Enters offline demo mode with a local-only user.
  /// No Firebase connection required — safe for live presentation without network.
  void enterDemoMode({String? displayName}) {
    state = AuthState(
      status: AuthStatus.demo,
      displayName: displayName ?? 'Demo Student',
      email: 'demo@sagen.local',
      uid: 'demo_user_001',
      onboardingCompleted: true,
      profileLoaded: true,
    );
  }

  Future<void> markOnboardingCompleted() async {
    final uid = state.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'onboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': uid,
      }, SetOptions(merge: true));
      state = state.copyWith(onboardingCompleted: true);
    } catch (e, stack) {
      AppLogger().error('auth: markOnboardingCompleted failed', e, stack);
    }
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      return await _authService.getIdToken(forceRefresh: forceRefresh);
    } catch (e, stack) {
      AppLogger().error('Auth: getIdToken failed', e, stack);
      return null;
    }
  }
}
