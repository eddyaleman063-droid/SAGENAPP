import 'package:sagen/l10n/app_localizations.dart';

/// Represents an authenticated user profile.
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isEmailVerified;

  const AppUser({
    this.uid = '',
    this.displayName = 'Estudiante',
    this.email = '',
    this.photoUrl,
    this.isEmailVerified = false,
  });
}

/// Exception for authentication-related errors with localized messages.
class AuthException implements Exception {
  final String code;
  const AuthException(this.code);

  String localizedMessage(AppLocalizations l) {
    switch (code) {
      case 'firebase_unavailable':
        return l.authFirebaseUnavailable;
      case 'canceled':
        return l.authCanceled;
      case 'null_user':
        return l.authNullUser;
      case 'unknown':
        return l.authUnknown;
      case 'null_token':
        return l.authNullToken;
      case 'not_found':
        return l.authNotFound;
      case 'wrong_password':
        return l.authWrongPassword;
      case 'invalid_credential':
        return l.authInvalidCredential;
      case 'email_in_use':
        return l.authEmailInUse;
      case 'weak_password':
        return l.authWeakPassword;
      case 'invalid_email':
        return l.authInvalidEmail;
      case 'too_many_requests':
        return l.authTooManyRequests;
      case 'network_error':
        return l.authNetworkError;
      case 'not_authenticated':
        return l.authNotAuthenticated;
      case 'not_verified':
        return l.authNotVerified;
      case 'verify_error':
        return l.authVerifyError;
      case 'recovery_error':
        return l.authRecoveryError;
      case 'resend_error':
        return l.authResendEmailError;
      case 'rate_limited':
        return l.authRateLimited;
      case 'reauth_error':
        return l.authReauthError;
      case 'reauth_required_for_delete':
        return l.authReauthRequiredForDelete;
      case 'delete_account_failed':
        return l.authDeleteAccountFailed;
      default:
        return l.authDefault;
    }
  }

  @override
  String toString() => 'AuthException($code)';
}
