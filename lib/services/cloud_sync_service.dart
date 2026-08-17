import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/firestore_field_config.dart';
import '../core/interfaces/i_cloud_sync_service.dart';
import '../utils/retry.dart';
import 'app_logger.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

/// Syncs local user data (progress, streaks, achievements) to Firestore.
///
/// Handles offline queuing, conflict resolution, and automatic retry
/// on network failures. Implements [ICloudSyncService] for testability.
class CloudSyncService implements ICloudSyncService {
  CloudSyncService({
    required AuthService authService,
    FirestoreService? firestoreService,
    AppLogger? logger,
  }) : _authService = authService,
       _firestoreService = firestoreService ?? FirestoreService.instance,
       _logger = logger ?? AppLogger();

  final AuthService _authService;
  final FirestoreService _firestoreService;
  final AppLogger _logger;

  SharedPreferences? _prefs;

  bool _initialized = false;
  @override
  bool get isInitialized => _initialized;

  DateTime? _lastSync;
  @override
  DateTime? get lastSync => _lastSync;
  bool _isSyncing = false;
  @override
  bool get isSyncing => _isSyncing;

  // ── Coordination: prevent concurrent Firestore writes ─────────
  // H-ARC-01: BackgroundSyncService and OfflineQueueService must not
  // write to the same Firestore document while saveAll is in progress.
  // This static flag lets any service check if a Firestore write is
  // currently happening on the users/{uid} document.
  static bool _globalSyncInProgress = false;

  /// Returns true if any sync system is currently writing to Firestore.
  /// Other services MUST check this before performing direct Firestore writes.
  static bool get isGlobalSyncInProgress => _globalSyncInProgress;

  /// Acquires the global sync lock. Returns false if another sync is
  /// already in progress (caller must retry/backoff). Release with
  /// [releaseGlobalSyncLock] in a finally block.
  static bool acquireGlobalSyncLock() {
    if (_globalSyncInProgress) return false;
    _globalSyncInProgress = true;
    return true;
  }

  /// Releases the global sync lock. Must be called in a finally block
  /// after [acquireGlobalSyncLock] succeeds.
  static void releaseGlobalSyncLock() {
    _globalSyncInProgress = false;
  }

  StreamSubscription<DocumentSnapshot>? _snapshotSub;
  String? _listeningUid;

  @override
  Stream<DocumentSnapshot> get userDocStream {
    final uid = _currentUid();
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  static const _lastSyncKey = 'cloud_last_sync';
  static const _pendingWritesKey = 'cloud_pending_writes';
  static const _debounceDuration = Duration(milliseconds: 500);

  // Debounced writes: field -> value
  final Map<String, dynamic> _pendingWrites = {};
  Timer? _debounceTimer;

  void Function(String spKey, dynamic value)? onFieldChanged;

  /// Notifies that a field has changed locally and needs cloud sync.
  /// Profile fields are synced directly to Firestore.
  /// Economic fields are BLOCKED here — use EconomicFunctionsService instead.
  /// Writes are debounced to prevent Firestore write storms.
  @override
  void notifyFieldChanged(String spKey, Object? value) {
    // Accept all primitive types that Firestore supports
    if (value is! int &&
        value is! String &&
        value is! bool &&
        value is! double) {
      return;
    }

    // Economic fields must go through Cloud Functions, not direct Firestore writes
    if (FirestoreFieldConfig.isServerOnlyField(spKey)) {
      _logger.info(
        'CloudSync: server-only field "$spKey" — use EconomicFunctionsService',
      );
      return;
    }

    final firestoreField = FirestoreFieldConfig.spToFirestoreMapping[spKey];
    if (firestoreField == null) return;

    // Mark as dirty for selective sync
    markDirty(spKey);

    _pendingWrites[firestoreField] = value;
    _pendingWrites['_ts_$firestoreField'] = Timestamp.now();
    _persistPendingWrites();
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, _flushPendingWrites);
  }

  void _flushPendingWrites() {
    if (_pendingWrites.isEmpty) return;
    final uid = _currentUid();
    if (uid == null) {
      _pendingWrites.clear();
      _clearPersistedPendingWrites();
      return;
    }

    // Atomically swap out pending writes to avoid losing concurrent additions
    final data = Map<String, dynamic>.from(_pendingWrites);
    _pendingWrites.clear();
    _clearPersistedPendingWrites();

    // Validate fields before writing
    final validUpdates = <String, dynamic>{};
    for (final entry in data.entries) {
      if (FirestoreFieldConfig.isProfileField(entry.key) ||
          entry.key.startsWith('_ts_')) {
        validUpdates[entry.key] = entry.value;
      } else {
        _logger.warning('CloudSync: skipping non-profile field: ${entry.key}');
      }
    }

    if (validUpdates.isEmpty) return;

    _firestoreService.updateFields(uid, validUpdates).catchError((e) {
      _logger.warning('CloudSync: _flushPendingWrites failed: $e');
      // Re-queue only fields that haven't been superseded by a newer write
      for (final entry in validUpdates.entries) {
        if (!_pendingWrites.containsKey(entry.key)) {
          _pendingWrites[entry.key] = entry.value;
        }
      }
      _persistPendingWrites();
    });
  }

  String? _currentUid() {
    try {
      return _authService.currentUser?.uid;
    } catch (_) {
      _logger.warning('CloudSync: _currentUid failed');
      return null;
    }
  }

  @override
  void startListening(String uid, SharedPreferences prefs) {
    if (_listeningUid == uid) return;
    _snapshotSub?.cancel();
    _listeningUid = uid;
    _snapshotSub = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen(
          (snapshot) => _onSnapshot(snapshot, prefs),
          onError: (e) => _logger.error('CloudSync: snapshot error: $e'),
        );
    _logger.info('CloudSync: listening to user $uid');
  }

  @override
  void stopListening() {
    _snapshotSub?.cancel();
    _snapshotSub = null;
    _listeningUid = null;
  }

  void dispose() {
    stopListening();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingWrites.clear();
    _clearPersistedPendingWrites();
  }

  void _onSnapshot(DocumentSnapshot snapshot, SharedPreferences prefs) {
    if (!snapshot.exists) return;
    try {
      final data = snapshot.data();
      if (data == null || data is! Map<String, dynamic>) return;
      _applyDocumentData(data, prefs);
    } catch (e) {
      _logger.error('CloudSync: _onSnapshot error: $e');
    }
  }

  Future<void> _applyDocumentData(
    Map<String, dynamic> data,
    SharedPreferences prefs, {
    bool isInitialLoad = false,
  }) async {
    final pendingWrites = <String, dynamic>{};

    for (final entry in data.entries) {
      if (entry.key.startsWith('_') && !entry.key.startsWith('_ts_')) {
        continue;
      }
      final spKey =
          FirestoreFieldConfig.firestoreToSpMapping[entry.key] ?? entry.key;
      try {
        final val = entry.value;

        if (!isInitialLoad) {
          final localVal = prefs.get(spKey);
          if (localVal != null && !_isCloudNewer(entry.key, data, prefs)) {
            continue;
          }
        }

        pendingWrites[spKey] = val;
      } catch (e) {
        _logger.warning('CloudSync: field ${entry.key} prepare failed: $e');
      }
    }

    final futures = <Future<bool>>[];
    for (final entry in pendingWrites.entries) {
      try {
        final val = entry.value;
        if (val is String) {
          futures.add(prefs.setString(entry.key, val));
        } else if (val is int) {
          futures.add(prefs.setInt(entry.key, val));
        } else if (val is bool) {
          futures.add(prefs.setBool(entry.key, val));
        } else if (val is double) {
          futures.add(prefs.setDouble(entry.key, val));
        } else if (val is DateTime) {
          futures.add(prefs.setString(entry.key, val.toIso8601String()));
        } else if (val is Timestamp) {
          futures.add(
            prefs.setString(entry.key, val.toDate().toIso8601String()),
          );
        } else if (val is List) {
          futures.add(prefs.setString(entry.key, jsonEncode(val)));
        } else if (val is Map) {
          futures.add(prefs.setString(entry.key, jsonEncode(val)));
        }
      } catch (e) {
        _logger.warning('CloudSync: field ${entry.key} write failed: $e');
      }
    }
    await Future.wait(futures);

    if (isInitialLoad) {
      await prefs.setBool('learning_needs_rechecksum', true);
    }
  }

  bool _isCloudNewer(
    String fieldKey,
    Map<String, dynamic> cloudData,
    SharedPreferences prefs,
  ) {
    final tsKey = '_ts_$fieldKey';
    final cloudTs = cloudData[tsKey];

    final localTsStr = prefs.getString(tsKey);

    if (cloudTs == null && localTsStr == null) return true;
    if (cloudTs == null && localTsStr != null) return false;

    final cloudTime = cloudTs is Timestamp
        ? cloudTs.toDate()
        : DateTime.tryParse(cloudTs.toString());
    final localTime = localTsStr != null ? DateTime.tryParse(localTsStr) : null;

    if (cloudTime == null && localTime == null) return true;
    if (cloudTime == null && localTime != null) return false;
    if (cloudTime != null && localTime == null) return true;
    if (cloudTime == null || localTime == null) return true;
    return cloudTime.isAfter(localTime);
  }

  @override
  @pragma('vm:entry-point')
  Future<void> init(SharedPreferences prefs) async {
    if (_initialized) return;
    _initialized = true;
    _prefs = prefs;

    final lastSyncStr = prefs.getString(_lastSyncKey);
    if (lastSyncStr != null) {
      _lastSync = DateTime.tryParse(lastSyncStr);
    }

    await _loadPendingWrites(prefs);

    _logger.info('CloudSync: initialized');
  }

  // Keys synced directly by client. ONLY profile fields allowed by Firestore rules.
  // Economic keys (gems, xp, streak, shop) are managed exclusively by Cloud Functions.
  // Uses FirestoreFieldConfig.syncKeys as single source of truth.
  static List<String> get _keysToSync => FirestoreFieldConfig.syncKeys;

  // Dirty tracking: only sync keys that have actually changed
  final Set<String> _dirtyKeys = {};

  /// Marks a key as needing sync.
  void markDirty(String key) {
    if (FirestoreFieldConfig.spToFirestoreMapping.containsKey(key)) {
      _dirtyKeys.add(key);
    }
  }

  @override
  Future<bool> saveAll(String uid, SharedPreferences prefs) async {
    if (!_initialized) return false;

    if (_dirtyKeys.isEmpty) return true;

    // H-ARC-01: Acquire global sync lock to prevent concurrent Firestore
    // writes from BackgroundSyncService or other services.
    if (!acquireGlobalSyncLock()) {
      _logger.warning('CloudSync: saveAll skipped — another sync in progress');
      return false;
    }
    try {
      return await retry<bool>(
        () async {
          _isSyncing = true;
          try {
            final data = <String, dynamic>{};
            final keysToSync = _dirtyKeys.isEmpty
                ? _keysToSync
                : _dirtyKeys.toList();
            for (final key in keysToSync) {
              final val = _getPrefValue(prefs, key);
              if (val != null) {
                data[key] = val;
              }
            }

            if (data.isEmpty) {
              _dirtyKeys.clear();
              return true;
            }

            await _firestore
                .collection('users')
                .doc(uid)
                .set(data, SetOptions(merge: true))
                .timeout(const Duration(seconds: 10));
            await prefs.setString(
              _lastSyncKey,
              DateTime.now().toIso8601String(),
            );
            _lastSync = DateTime.now();
            _dirtyKeys.clear();
            _logger.info('CloudSync: saved ${data.length} keys for $uid');
            return true;
          } finally {
            _isSyncing = false;
          }
        },
        config: const RetryConfig(
          maxRetries: 3,
          baseDelay: Duration(seconds: 1),
          policy: RetryPolicy.exponentialBackoff,
        ),
      );
    } catch (e) {
      _logger.error('CloudSync: saveAll failed after retries: $e');
      return false;
    } finally {
      // H-ARC-01: Release the global sync lock so other services can write.
      releaseGlobalSyncLock();
    }
  }

  @override
  Future<bool> loadAll(String uid, SharedPreferences prefs) async {
    if (!_initialized) return false;

    try {
      return await retry<bool>(
        () async {
          _isSyncing = true;
          try {
            final doc = await _firestore
                .collection('users')
                .doc(uid)
                .get()
                .timeout(const Duration(seconds: 10));
            if (!doc.exists) {
              _logger.info('CloudSync: no cloud data for $uid');
              return false;
            }

            final data = doc.data();
            if (data == null) return false;
            await _applyDocumentData(data, prefs, isInitialLoad: true);
            _logger.info('CloudSync: loaded ${data.length} keys for $uid');
            return true;
          } finally {
            _isSyncing = false;
          }
        },
        config: const RetryConfig(
          maxRetries: 3,
          baseDelay: Duration(seconds: 1),
          policy: RetryPolicy.exponentialBackoff,
        ),
      );
    } catch (e) {
      _logger.error('CloudSync: loadAll failed after retries: $e');
      return false;
    }
  }

  @override
  Future<void> clearLocal(SharedPreferences prefs) async {
    int count = 0;
    for (final key in _keysToSync) {
      final removed = await prefs.remove(key);
      if (removed) count++;
    }
    _logger.info('CloudSync: cleared $count local keys');
  }

  @override
  Future<bool> deleteCloudData(String uid) async {
    if (!_initialized) return false;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .delete()
          .timeout(const Duration(seconds: 10));
      _logger.info('CloudSync: deleted cloud data for $uid');
      return true;
    } catch (e) {
      _logger.error('CloudSync: deleteCloudData failed: $e');
      return false;
    }
  }

  // ── Private helpers ──

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  void _persistPendingWrites() {
    try {
      final serializable = <String, dynamic>{};
      for (final entry in _pendingWrites.entries) {
        final val = entry.value;
        if (val is Timestamp) {
          serializable[entry.key] = val.toDate().toIso8601String();
        } else if (val is int ||
            val is String ||
            val is bool ||
            val is double ||
            val is List ||
            val is Map) {
          serializable[entry.key] = val;
        }
      }
      final prefs = _prefs;
      if (prefs != null) {
        prefs.setString(_pendingWritesKey, jsonEncode(serializable));
      }
    } catch (e) {
      _logger.warning('CloudSync: _persistPendingWrites failed: $e');
    }
  }

  Future<void> _loadPendingWrites(SharedPreferences prefs) async {
    try {
      final raw = prefs.getString(_pendingWritesKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        if (entry.key.startsWith('_ts_') && entry.value is String) {
          final dt = DateTime.tryParse(entry.value as String);
          if (dt != null) _pendingWrites[entry.key] = Timestamp.fromDate(dt);
        } else {
          _pendingWrites[entry.key] = entry.value;
        }
      }
      if (_pendingWrites.isNotEmpty) {
        _logger.info(
          'CloudSync: loaded ${_pendingWrites.length} pending writes from local storage',
        );
      }
    } catch (e) {
      _logger.warning('CloudSync: _loadPendingWrites failed: $e');
    }
  }

  void _clearPersistedPendingWrites() {
    _prefs?.remove(_pendingWritesKey);
  }

  dynamic _getPrefValue(SharedPreferences prefs, String key) {
    final val = prefs.get(key);
    if (val == null) return null;
    if (val is String || val is int || val is bool || val is double) return val;
    if (val is List) return val;
    return null;
  }
}
