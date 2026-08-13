import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cloud_sync_service.dart';
import '../app_logger.dart';

/// Manages cloud sync and onboarding status after login.
/// Extracted from AuthNotifier to reduce class responsibilities.
class AuthSyncManager {
  final CloudSyncService _cloudSync;
  int _onboardingLoadId = 0;
  int _sessionEpoch = 0;

  AuthSyncManager(this._cloudSync);

  /// Sync local data with server after login. Retries up to 3 times.
  /// Aborts if the session changes (logout/login) while retrying.
  Future<void> syncAfterLogin(String uid, SharedPreferences prefs) async {
    final epoch = ++_sessionEpoch;
    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        await _cloudSync.loadAll(uid, prefs);
        if (epoch != _sessionEpoch) {
          return; // Session changed — discard stale result
        }
        return;
      } catch (e) {
        if (epoch != _sessionEpoch) return; // Session changed — stop retrying
        AppLogger().warning(
          'AuthSyncManager: sync attempt ${attempt + 1} failed: $e',
        );
        if (attempt < maxAttempts - 1) {
          await Future<void>.delayed(Duration(seconds: 1 << attempt));
          if (epoch != _sessionEpoch) return; // Logged out during backoff
        }
      }
    }
    AppLogger().warning(
      'AuthSyncManager: all retries failed, using local data',
    );
  }

  /// Start cloud sync listening for real-time updates.
  void startListening(String uid, SharedPreferences prefs) {
    _cloudSync.startListening(uid, prefs);
  }

  /// Stop cloud sync listening.
  void stopListening() {
    _cloudSync.stopListening();
  }

  /// Save all local data to cloud before sign-out.
  Future<void> saveBeforeSignOut(String uid, SharedPreferences prefs) async {
    cancelInflightLoads();
    try {
      await _cloudSync.saveAll(uid, prefs);
      await _cloudSync.clearLocal(prefs);
    } catch (e) {
      AppLogger().error('AuthSyncManager: cleanup during sign-out failed', e);
    }
  }

  /// Delete all cloud data for account deletion.
  Future<void> deleteCloudData(String uid, SharedPreferences prefs) async {
    cancelInflightLoads();
    try {
      await _cloudSync.deleteCloudData(uid);
      await _cloudSync.clearLocal(prefs);
    } catch (e) {
      AppLogger().error('AuthSyncManager: cleanup during delete failed', e);
    }
  }

  /// Load onboarding status from Firestore. Uses monotonic ID to cancel stale loads.
  Future<bool?> loadOnboardingStatus(String uid) async {
    final loadId = ++_onboardingLoadId;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));
      if (loadId != _onboardingLoadId) return null;
      if (doc.exists) {
        final data = doc.data();
        return data?['onboardingCompleted'] == true;
      }
      return false;
    } catch (e) {
      AppLogger().warning('AuthSyncManager: loadOnboardingStatus failed: $e');
      return null;
    }
  }

  /// Cancel any in-flight onboarding load (called on user change).
  void cancelInflightLoads() {
    _onboardingLoadId++;
  }
}
