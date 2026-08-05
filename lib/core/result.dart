/// Sealed result type for explicit error handling.
///
/// ```dart
/// final result = await getUser();
/// switch (result) {
///   case AppOk(:final value):
///     setState(() => _user = value);
///   case AppError(:final error):
///     _showError(error);
/// }
/// ```
sealed class AppResult<T> {
  const AppResult();

  factory AppResult.ok(T value) = AppOk<T>;
  factory AppResult.error(Object error) = AppError<T>;

  bool get isOk => this is AppOk<T>;
  bool get isError => this is AppError<T>;

  T? get value => switch (this) {
        AppOk(:final value) => value,
        AppError() => null,
      };

  Object? get error => switch (this) {
        AppOk() => null,
        AppError(:final error) => error,
      };

  T orElse(T fallback) => switch (this) {
        AppOk(:final value) => value,
        AppError() => fallback,
      };

  T orElseGet(T Function(Object error) fn) => switch (this) {
        AppOk(:final value) => value,
        AppError(:final error) => fn(error),
      };

  AppResult<R> map<R>(R Function(T value) fn) => switch (this) {
        AppOk(:final value) => AppResult.ok(fn(value)),
        AppError(:final error) => AppResult.error(error),
      };

  Future<AppResult<R>> flatMap<R>(
    Future<AppResult<R>> Function(T value) fn,
  ) async =>
      switch (this) {
        AppOk(:final value) => await fn(value),
        AppError(:final error) => AppResult.error(error),
      };

  T unwrap() => switch (this) {
        AppOk(:final value) => value,
        AppError(:final error) => throw error,
      };
}

final class AppOk<T> extends AppResult<T> {
  const AppOk(this.value);
  @override
  final T value;

  @override
  String toString() => 'AppResult.ok($value)';
}

final class AppError<T> extends AppResult<T> {
  const AppError(this.error);
  @override
  final Object error;

  @override
  String toString() => 'AppResult.error($error)';
}

/// Extension for `Future<AppResult<T>>` convenience.
extension FutureAppResult<T> on Future<AppResult<T>> {
  Future<AppResult<R>> map<R>(R Function(T value) fn) async {
    final result = await this;
    return result.map(fn);
  }

  Future<AppResult<R>> flatMap<R>(
    Future<AppResult<R>> Function(T value) fn,
  ) async {
    final result = await this;
    return result.flatMap(fn);
  }
}

/// Wraps an async operation that throws into a Result.
Future<AppResult<T>> resultOf<T>(Future<T> Function() fn) async {
  try {
    return AppResult.ok(await fn());
  } catch (e) {
    return AppResult.error(e);
  }
}

/// Wraps a sync operation that throws into a Result.
AppResult<T> resultOfSync<T>(T Function() fn) {
  try {
    return AppResult.ok(fn());
  } catch (e) {
    return AppResult.error(e);
  }
}

// ─── Domain Error Types ───────────────────────────────────

sealed class ServiceError {
  const ServiceError();
}

class NetworkError extends ServiceError {
  const NetworkError({this.message, this.originalError});
  final String? message;
  final Object? originalError;
}

class AuthError extends ServiceError {
  const AuthError(this.code, {this.message});
  final String code;
  final String? message;
}

class SyncError extends ServiceError {
  const SyncError(this.message, {this.originalError});
  final String message;
  final Object? originalError;
}

class DatabaseError extends ServiceError {
  const DatabaseError(this.message, {this.originalError});
  final String message;
  final Object? originalError;
}

class PaymentError extends ServiceError {
  const PaymentError(this.message, {this.originalError});
  final String message;
  final Object? originalError;
}

class GeminiError extends ServiceError {
  const GeminiError(this.type, {this.message, this.originalError});
  final GeminiErrorType type;
  final String? message;
  final Object? originalError;
}

enum GeminiErrorType {
  unauthorized,
  quotaExceeded,
  contentBlocked,
  networkTimeout,
  unknown,
}
