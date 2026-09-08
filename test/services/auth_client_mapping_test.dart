import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/services/firebase_auth_client.dart';

import '../helpers/mock_firebase_auth.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('es'));

  group('AuthException.localizedMessage', () {
    final cases = {
      'firebase_unavailable': l.authFirebaseUnavailable,
      'canceled': l.authCanceled,
      'null_user': l.authNullUser,
      'unknown': l.authUnknown,
      'null_token': l.authNullToken,
      'not_found': l.authNotFound,
      'wrong_password': l.authWrongPassword,
      'invalid_credential': l.authInvalidCredential,
      'email_in_use': l.authEmailInUse,
      'weak_password': l.authWeakPassword,
      'invalid_email': l.authInvalidEmail,
      'too_many_requests': l.authTooManyRequests,
      'network_error': l.authNetworkError,
      'not_authenticated': l.authNotAuthenticated,
      'not_verified': l.authNotVerified,
      'verify_error': l.authVerifyError,
      'recovery_error': l.authRecoveryError,
      'resend_error': l.authResendEmailError,
      'rate_limited': l.authRateLimited,
      'reauth_error': l.authReauthError,
      'reauth_required_for_delete': l.authReauthRequiredForDelete,
      'delete_account_failed': l.authDeleteAccountFailed,
    };

    test('mapea cada codigo conocido a su string localizado', () {
      cases.forEach((code, expected) {
        expect(AuthException(code).localizedMessage(l), expected, reason: code);
      });
    });

    test('codigo desconocido cae en authDefault', () {
      expect(
        const AuthException('codigo_raro').localizedMessage(l),
        l.authDefault,
      );
    });

    test('toString incluye el codigo', () {
      expect(
        const AuthException('canceled').toString(),
        'AuthException(canceled)',
      );
    });
  });

  group('FirebaseAuthClient.appUserFromFirebase', () {
    final client = FirebaseAuthClient();

    test('mapea campos basicos con emailVerified', () {
      final user = FakeUser(
        uid: 'uid-1',
        email: 'ana@test.com',
        displayName: 'Ana',
        emailVerified: true,
      );
      final appUser = client.appUserFromFirebase(user);
      expect(appUser.uid, 'uid-1');
      expect(appUser.displayName, 'Ana');
      expect(appUser.email, 'ana@test.com');
      expect(appUser.isEmailVerified, isTrue);
    });

    test('displayName fallback al prefijo del email', () {
      final user = FakeUser(uid: 'uid-2', email: 'juan@test.com');
      final appUser = client.appUserFromFirebase(user);
      expect(appUser.displayName, 'juan');
    });

    test('displayName fallback a Estudiante sin email', () {
      final user = FakeUser(uid: 'uid-3');
      final appUser = client.appUserFromFirebase(user);
      expect(appUser.displayName, 'Estudiante');
      expect(appUser.email, '');
    });
  });
}
