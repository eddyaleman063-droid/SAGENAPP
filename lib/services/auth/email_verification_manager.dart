import 'dart:async';
import '../app_logger.dart';
import '../auth_service.dart';

/// Manages email verification polling and auto-check logic.
/// Extracted from AuthNotifier to reduce class responsibilities.
class EmailVerificationManager {
  final AuthService _authService;
  final AppLogger _logger;
  Timer? _verificationTimer;
  int _verificationAttempts = 0;
  bool _verificationRunning = false;
  static const _maxVerificationAttempts = 5;

  EmailVerificationManager(this._authService) : _logger = AppLogger();

  void startAutoCheck(void Function(bool verified) onVerified) {
    _verificationAttempts = 0;
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_verificationRunning) return;
      if (_verificationAttempts >= _maxVerificationAttempts) {
        stopAutoCheck();
        return;
      }
      _verificationRunning = true;
      try {
        _verificationAttempts++;
        final verified = await _authService.reloadUser();
        if (verified) {
          onVerified(true);
          stopAutoCheck();
        }
      } catch (e) {
        _logger.warning('Email verification check failed: $e');
      } finally {
        _verificationRunning = false;
      }
    });
  }

  void stopAutoCheck() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
    _verificationRunning = false;
  }

  void dispose() {
    stopAutoCheck();
  }
}
