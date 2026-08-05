import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../services/auth_models.dart';

/// Abstract interface for authentication services.
/// Enables dependency injection and testability.
abstract class IAuthService {
  Future<void> init();
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
  Future<void> signOut();
  Future<void> deleteAccount();
  Future<firebase.User?> reauthenticate(String email, String password);
  Future<String?> getIdToken();
  AppUser? get currentUser;
  bool get isLoggedIn;
  Stream<AppUser?> get authStateChanges;
  void dispose();
}
