import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workmanager/workmanager.dart';
import 'app_logger.dart';
import 'cloud_sync_service.dart';

const _taskName = 'sagen-background-sync';

/// H-ARC-01 COORDINATION:
/// This service performs background Firestore writes via WorkManager.
/// It MUST check CloudSyncService.isGlobalSyncInProgress and acquire
/// CloudSyncService.acquireGlobalSyncLock() before writing to prevent
/// concurrent writes to the users/{uid} document. Both this service
/// and CloudSyncService write to the same Firestore document — the
/// global lock ensures only one writes at a time.
///
/// NOTE: Currently reads `sync_dirty_keys` from SharedPreferences, but
/// nothing in the codebase writes that key. This service effectively
/// exits immediately on every cycle. If direct Firestore writes for
/// profile fields are needed in the background, the caller should
/// write to `sync_dirty_keys` AND the corresponding `sync_<field>`
/// keys in SharedPreferences.

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      return await _performSync();
    }
    return false;
  });
}

Future<bool> _performSync() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final dirtyKeys = prefs.getStringList('sync_dirty_keys') ?? [];
    if (dirtyKeys.isEmpty) return true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    // H-ARC-01: Check if CloudSyncService is currently writing to Firestore.
    // If so, skip this cycle to prevent concurrent writes to the same
    // users/{uid} document. The next periodic cycle will pick up the work.
    if (CloudSyncService.isGlobalSyncInProgress) {
      AppLogger().info('BackgroundSync: skipped — CloudSyncService is syncing');
      return true;
    }
    if (!CloudSyncService.acquireGlobalSyncLock()) {
      AppLogger().info('BackgroundSync: skipped — global sync lock held');
      return true;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      for (final key in dirtyKeys) {
        final value = prefs.get('sync_$key');
        if (value != null) {
          batch.set(userDoc, {key: value}, SetOptions(merge: true));
        }
      }

      await batch.commit();
      await prefs.remove('sync_dirty_keys');
      for (final key in dirtyKeys) {
        await prefs.remove('sync_$key');
      }

      AppLogger().info('BackgroundSync: synced ${dirtyKeys.length} fields');
      return true;
    } finally {
      CloudSyncService.releaseGlobalSyncLock();
    }
  } catch (e) {
    AppLogger().error('BackgroundSync: failed', e);
    return false;
  }
}

class BackgroundSyncService {
  static final instance = BackgroundSyncService._();
  BackgroundSyncService._();

  final _workmanager = Workmanager();

  Future<void> init() async {
    await _workmanager.initialize(_callbackDispatcher);
  }

  Future<void> registerPeriodicSync() async {
    try {
      await _workmanager.cancelAll();
      await _workmanager.registerPeriodicTask(
        'sagen-periodic-sync',
        _taskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
    } catch (e) {
      AppLogger().error('BackgroundSync: registerPeriodicSync failed', e);
    }
  }

  Future<void> cancelAll() async {
    try {
      await _workmanager.cancelAll();
    } catch (e) {
      AppLogger().error('BackgroundSync: cancelAll failed', e);
    }
  }
}
