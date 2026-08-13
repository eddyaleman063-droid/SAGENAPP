import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'app_logger.dart';
import 'auth_models.dart';

/// Abstract interface for Firebase Authentication operations.
abstract class AuthClient {
  bool get isAvailable;
  firebase.User? get firebaseUser;
  Stream<firebase.User?> get authStateChanges;

  void init();
  AppUser appUserFromFirebase(firebase.User user);

  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithFacebook();

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendEmailVerification();
  Future<bool> reloadUser();
  Future<void> sendPasswordResetEmail(String email);

  Future<firebase.User?> reauthenticate(String email, String password);
  Future<String?> getIdToken();

  Future<void> signOutFirebase();
  Future<void> deleteFirebaseUser();
}

/// Firebase Auth implementation with Google and email sign-in.
class FirebaseAuthClient implements AuthClient {
  final AppLogger _logger;
  firebase.FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  FirebaseAuthClient({AppLogger? logger}) : _logger = logger ?? AppLogger();

  @override
  bool get isAvailable => _auth != null;
  bool get isGoogleAvailable => _auth != null && _googleSignIn != null;
  @override
  firebase.User? get firebaseUser => _auth?.currentUser;

  @override
  Stream<firebase.User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  @override
  void init() {
    try {
      _auth = firebase.FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
    } catch (e) {
      _logger.error('FirebaseAuthClient: FirebaseAuth unavailable', e);
    }
  }

  @override
  AppUser appUserFromFirebase(firebase.User user) {
    return AppUser(
      uid: user.uid,
      displayName:
          user.displayName ?? user.email?.split('@').first ?? 'Estudiante',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    if (!isGoogleAvailable) {
      throw const AuthException('firebase_unavailable');
    }
    final gs = _googleSignIn;
    final auth = _auth;
    if (gs == null || auth == null) {
      throw const AuthException('firebase_unavailable');
    }
    try {
      final googleUser = await gs.signIn();
      if (googleUser == null) {
        throw const AuthException('canceled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final result = await auth.signInWithCredential(credential);
      final fbUser = result.user;
      if (fbUser == null) {
        throw const AuthException('null_user');
      }
      return appUserFromFirebase(fbUser);
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      _logger.warning('FirebaseAuthClient: signInWithGoogle failed: $e');
      throw const AuthException('unknown');
    }
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    if (!isAvailable) {
      throw const AuthException('firebase_unavailable');
    }
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (result.status == LoginStatus.cancelled) {
        throw const AuthException('canceled');
      }
      if (result.status != LoginStatus.success) {
        throw const AuthException('unknown');
      }
      final accessToken = result.accessToken;
      if (accessToken == null) {
        throw const AuthException('null_token');
      }
      final auth = _auth;
      if (auth == null) throw const AuthException('firebase_unavailable');
      final credential = firebase.FacebookAuthProvider.credential(
        accessToken.tokenString,
      );
      final fbResult = await auth.signInWithCredential(credential);
      final fbUser = fbResult.user;
      if (fbUser == null) {
        throw const AuthException('null_user');
      }
      return appUserFromFirebase(fbUser);
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      _logger.warning('FirebaseAuthClient: signInWithFacebook failed: $e');
      throw const AuthException('unknown');
    }
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!isAvailable) {
      throw const AuthException('firebase_unavailable');
    }
    try {
      final auth = _auth;
      if (auth == null) throw const AuthException('firebase_unavailable');
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(displayName.trim());
      final fbUser = result.user;
      if (fbUser == null) {
        throw const AuthException('null_user');
      }
      await fbUser.sendEmailVerification();
      return appUserFromFirebase(fbUser);
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      _logger.warning('FirebaseAuthClient: signUpWithEmail failed: $e');
      throw const AuthException('unknown');
    }
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isAvailable) {
      throw const AuthException('firebase_unavailable');
    }
    try {
      final auth = _auth;
      if (auth == null) throw const AuthException('firebase_unavailable');
      final result = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = result.user;
      if (fbUser == null) {
        throw const AuthException('null_user');
      }
      await fbUser.reload();
      return appUserFromFirebase(fbUser);
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      _logger.warning('FirebaseAuthClient: signInWithEmail failed: $e');
      throw const AuthException('unknown');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final auth = _auth;
    if (auth == null) return;
    final user = auth.currentUser;
    if (user == null) {
      throw const AuthException('not_authenticated');
    }
    try {
      await user.sendEmailVerification();
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<bool> reloadUser() async {
    final auth = _auth;
    if (auth == null) return false;
    try {
      final user = auth.currentUser;
      if (user == null) return false;
      await user.reload();
      final reloaded = auth.currentUser;
      if (reloaded != null) {
        return reloaded.emailVerified;
      }
      return false;
    } catch (e) {
      _logger.warning('FirebaseAuthClient: reloadUser failed: $e');
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth == null) throw const AuthException('firebase_unavailable');
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<firebase.User?> reauthenticate(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;
    final user = auth.currentUser;
    if (user == null) return null;
    try {
      final credential = firebase.EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final result = await user.reauthenticateWithCredential(credential);
      return result.user;
    } on firebase.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  @override
  Future<String?> getIdToken() async {
    final auth = _auth;
    if (auth == null) return null;
    final user = auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (e) {
      _logger.warning('[FirebaseAuthClient] getIdToken error: $e');
      return null;
    }
  }

  @override
  Future<void> signOutFirebase() async {
    final gs = _googleSignIn;
    try {
      if (gs != null) {
        await gs.signOut();
      }
    } catch (e) {
      _logger.warning('FirebaseAuthClient: Google signOut failed: $e');
    }
    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      _logger.warning('FirebaseAuthClient: Facebook logOut failed: $e');
    }
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
  }

  @override
  Future<void> deleteFirebaseUser() async {
    try {
      final auth = _auth;
      if (auth != null) {
        final user = auth.currentUser;
        if (user != null) {
          await user.delete();
        }
      }
    } catch (e) {
      _logger.error('FirebaseAuthClient: user deletion failed: $e');
      rethrow;
    }
    final gs = _googleSignIn;
    try {
      if (gs != null) {
        await gs.disconnect();
      }
    } catch (e) {
      _logger.warning('FirebaseAuthClient: Google disconnect failed: $e');
    }
  }

  AuthException _mapFirebaseException(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException('not_found');
      case 'wrong-password':
        return const AuthException('wrong_password');
      case 'invalid-credential':
        return const AuthException('invalid_credential');
      case 'email-already-in-use':
        return const AuthException('email_in_use');
      case 'weak-password':
        return const AuthException('weak_password');
      case 'invalid-email':
        return const AuthException('invalid_email');
      case 'too-many-requests':
        return const AuthException('too_many_requests');
      case 'network-request-failed':
        return const AuthException('network_error');
      default:
        return AuthException(e.code);
    }
  }
}
