import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class _AppLoggerState {
  bool productionMode = false;
  bool firebaseReady = false;
  final List<_LogEntry> recentErrors = [];
}

/// Centralized logging service with recent error tracking.
///
/// In release mode, `error()` forwards to Crashlytics automatically when
/// Firebase is initialized.  All catch blocks should pass the exception
/// and stack trace to `error()` so that production issues are diagnosable.
class AppLogger {
  static final _AppLoggerState _state = _AppLoggerState();
  static const int _maxRecentErrors = 50;

  AppLogger();

  void setProductionMode(bool enabled) {
    _state.productionMode = enabled;
  }

  void markFirebaseReady() {
    _state.firebaseReady = true;
  }

  List<Map<String, dynamic>> get recentErrors => _state.recentErrors
      .map((e) => {'time': e.time.toIso8601String(), 'message': e.message})
      .toList();

  void debug(String message) {
    if (!_state.productionMode) debugPrint('[SAGEN] $message');
  }

  void info(String message) {
    if (!_state.productionMode) debugPrint('[SAGEN] [INFO] $message');
  }

  void warning(String message, [Object? exception, StackTrace? stack]) {
    if (!_state.productionMode) {
      debugPrint('[SAGEN] [WARN] $message');
      if (exception != null) debugPrint('  Exception: $exception');
      if (stack != null) debugPrint('  Stack: $stack');
    }
  }

  void error(String message, [Object? exception, StackTrace? stack]) {
    _state.recentErrors.add(_LogEntry(message, DateTime.now()));
    if (_state.recentErrors.length > _maxRecentErrors) {
      _state.recentErrors.removeAt(0);
    }

    if (!_state.productionMode) {
      debugPrint('[SAGEN] [ERROR] $message');
      if (exception != null) debugPrint('  Exception: $exception');
      if (stack != null) debugPrint('  Stack: $stack');
    }

    if (_state.productionMode && _state.firebaseReady && exception != null) {
      _reportToCrashlytics(message, exception, stack);
    }
  }

  void log(
    LogLevel level,
    String message, [
    Object? exception,
    StackTrace? stack,
  ]) {
    switch (level) {
      case LogLevel.debug:
        debug(message);
      case LogLevel.info:
        info(message);
      case LogLevel.warning:
        warning(message, exception, stack);
      case LogLevel.error:
        error(message, exception, stack);
    }
  }

  void _reportToCrashlytics(
    String message,
    Object exception,
    StackTrace? stack,
  ) {
    try {
      if (Firebase.apps.isEmpty) return;
      FirebaseCrashlytics.instance.recordError(
        exception,
        stack ?? StackTrace.current,
        reason: message,
        fatal: false,
      );
    } catch (_) {
      // Never let Crashlytics reporting crash the app
    }
  }
}

class _LogEntry {
  final String message;
  final DateTime time;
  _LogEntry(this.message, this.time);
}
