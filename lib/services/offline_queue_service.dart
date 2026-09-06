import 'dart:async';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'database_helper.dart';
import 'economic_functions_service.dart';
import 'app_logger.dart';

/// Service that queues lesson completions when offline and syncs them
/// when connectivity is restored. Uses SQLite for reliable persistence
/// (SharedPreferences has a 1MB limit and is not designed for structured data).
///
/// H-ARC-01 COORDINATION:
/// This service does NOT write directly to Firestore. All economic mutations
/// go through EconomicFunctionsService → Cloud Functions (server-side).
/// This avoids conflicts with CloudSyncService (profile fields) and
/// BackgroundSyncService (batch writes). No Firestore write lock needed
/// because the server handles atomicity.
class OfflineQueueService {
  static final OfflineQueueService instance = OfflineQueueService._();
  OfflineQueueService._({
    ConnectivityService? connectivity,
    EconomicFunctionsService? economic,
  }) : _connectivity = connectivity ?? ConnectivityService.instance,
       _economic = economic ?? EconomicFunctionsService.instance;

  final ConnectivityService _connectivity;
  final EconomicFunctionsService _economic;
  final AppLogger _logger = AppLogger();

  List<Map<String, dynamic>> _queue = [];
  bool _syncing = false;
  Timer? _retryTimer;
  Timer? _rescheduleTimer;
  bool _initialized = false;

  /// Token de generación: lo incrementa [clear] para invalidar un
  /// `_processQueue` en curso (sign-out mientras se sincroniza). Evita que el
  /// loop siga mutando/removiendo items de una cola ya vaciada/reemplazada.
  int _generation = 0;

  /// Callback fired after a queue item is synced successfully.
  /// The Map contains the server response (gems, xp, level, etc.).
  void Function(Map<String, dynamic> serverResult)? onItemSynced;

  /// Callback fired when a queue item is dropped after a permanent failure
  /// (server-side validation/auth error that would never succeed on retry).
  /// Transient failures (network, timeouts, server outages) are retried
  /// indefinitely and never drop the item, so XP/gems are not lost.
  void Function(Map<String, dynamic> item)? onItemDropped;

  List<Map<String, dynamic>> get queue => List.unmodifiable(_queue);
  int get pendingCount => _queue.length;
  bool get isSyncing => _syncing;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Load pending items from SQLite
    await _loadFromDb();

    _retryTimer?.cancel();
    _connectivity.online.removeListener(_onConnectivityChanged);
    _connectivity.online.addListener(_onConnectivityChanged);
    _onConnectivityChanged();

    _retryTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_queue.isNotEmpty && !_syncing) {
        _processQueue();
      }
    });

    _logger.info(
      'OfflineQueue: initialized with ${_queue.length} pending items',
    );
  }

  void _onConnectivityChanged() {
    if (_connectivity.online.value && _queue.isNotEmpty && !_syncing) {
      _processQueue();
    }
  }

  /// Loads pending items from SQLite sync_queue table.
  Future<void> _loadFromDb() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('sync_queue', orderBy: 'created_at ASC');
      _queue = rows.map((row) {
        final payload =
            jsonDecode(row['payload'] as String) as Map<String, dynamic>;
        payload['_dbId'] = row['id'];
        payload['retries'] = row['retry_count'] ?? 0;
        return payload;
      }).toList();
    } catch (e) {
      _logger.error('OfflineQueue: failed to load from SQLite', e);
      _queue = [];
    }
  }

  Future<void> queueLessonCompletion({
    required String lessonId,
    required String stageId,
    required int gemsEarned,
    required int xpEarned,
    required int correctAnswers,
    required int totalQuestions,
    required DateTime completedAt,
    String? feedback,
  }) async {
    final item = {
      'id':
          '${lessonId}_${completedAt.millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}_${_queue.length}',
      'lessonId': lessonId,
      'stageId': stageId,
      'gemsEarned': gemsEarned,
      'xpEarned': xpEarned,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toUtc().toIso8601String(),
      'feedback': feedback,
      'retries': 0,
      'queuedAt': DateTime.now().toUtc().toIso8601String(),
    };

    // Persist to SQLite
    try {
      final db = await DatabaseHelper.instance.database;
      final dbId = await db.insert('sync_queue', {
        'operation': 'lesson_completion',
        'payload': jsonEncode(item),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'retry_count': 0,
      });
      item['_dbId'] = dbId;
    } catch (e) {
      _logger.error(
        'OfflineQueue: failed to persist to SQLite — lesson will not be queued',
        e,
      );
      return;
    }

    _queue.add(item);
    _logger.info(
      'OfflineQueue: queued lesson $lessonId (${_queue.length} pending)',
    );

    // Procesa de inmediato si hay conexión para acreditar rápido; la cola
    // protege contra reintentos/duplicados (idempotencia por lessonId).
    if (_connectivity.online.value) {
      unawaited(flush());
    }
  }

  /// Encola una acreditación de XP offline (repaso, logros, misiones,
  /// mini-juegos). Reusa la MISMA [idempotencyKey] del intento online para que
  /// el reintento nunca duplique (transaction_logs por clave en el servidor).
  /// Al sincronizarse, onItemSynced notifica al reconciler con el shape addXp.
  /// FIX-achievementId: se persiste [achievementId] para que el servidor
  /// acredite la recompensa REAL del logro (tabla de logros) y no el fallback
  /// plano de 10 XP que aplica addXp cuando reason='achievement' llega sin id.
  Future<void> queueAddXp({
    required String reason,
    String? lessonId,
    String? achievementId,
    required String idempotencyKey,
  }) async {
    final item = {
      'id':
          'xp_${reason}_${DateTime.now().microsecondsSinceEpoch}_${_queue.length}',
      'op': 'add_xp',
      'reason': reason,
      'lessonId': lessonId,
      'achievementId': achievementId,
      'idempotencyKey': idempotencyKey,
      'retries': 0,
      'queuedAt': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final db = await DatabaseHelper.instance.database;
      final dbId = await db.insert('sync_queue', {
        'operation': 'add_xp',
        'payload': jsonEncode(item),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'retry_count': 0,
      });
      item['_dbId'] = dbId;
    } catch (e) {
      _logger.error(
        'OfflineQueue: failed to persist add_xp to SQLite — XP won\'t be queued',
        e,
      );
      return;
    }

    _queue.add(item);
    _logger.info(
      'OfflineQueue: queued add_xp($reason) (${_queue.length} pending)',
    );

    if (_connectivity.online.value) {
      unawaited(flush());
    }
  }

  /// Procesa la cola inmediatamente si hay conexión.
  Future<void> flush() async {
    if (_connectivity.online.value && _queue.isNotEmpty && !_syncing) {
      await _processQueue();
    }
  }

  Future<void> _persistRetryCount(int dbId, int retries) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'sync_queue',
        {'retry_count': retries},
        where: 'id = ?',
        whereArgs: [dbId],
      );
    } catch (e) {
      _logger.error('OfflineQueue: failed to persist retry count', e);
    }
  }

  /// Whether [error] is permanent (server-side validation/auth failure) so the
  /// item would never succeed on retry, or transient (network/timeout/server
  /// outage) where keeping the item in the queue is safe because completeLesson
  /// is idempotent per lessonId (transaction_logs guard against double credit).
  /// Transient errors are retried indefinitely so XP/gems are never lost.
  /// Exposed for tests. Returns true only for errors that are a genuine
  /// server-side rejection that would never succeed on retry (validation,
  /// permission, not-found...). Transient conditions (`internal` server errors,
  /// `aborted` Firestore contention) are NOT permanent: they can succeed on a
  /// retry, so the item must stay queued to avoid losing XP/gems.
  ///
  /// M2-fix: `failed-precondition` es REINTENTABLE en SAGENAPP, no permanente.
  /// En las callables económicas ese código significa "correo sin verificar"
  /// (requireVerifiedUser) o un guard de día/hito no alineado todavia: ambas
  /// condiciones se resuelven con el tiempo (el usuario verifica su correo).
  /// Marcar esto como permanente descartaba la cola de XP/recompensas de
  /// lecciones completadas antes de verificar, perdiendo la acreditacion.
  @visibleForTesting
  static bool isPermanentError(Object error) {
    if (error is FirebaseFunctionsException) {
      const permanent = {
        'invalid-argument',
        'permission-denied',
        'not-found',
        'unauthenticated',
        'out-of-range',
        'already-exists',
      };
      return permanent.contains(error.code);
    }
    return error is ArgumentError;
  }

  Future<void> _processQueue() async {
    if (_syncing || _queue.isEmpty) return;
    _syncing = true;

    final gen = _generation;
    final toRemove = <int>[];

    for (int i = 0; i < _queue.length; i++) {
      final item = _queue[i];
      final retries = (item['retries'] as int?) ?? 0;

      try {
        final result = await _syncItem(item);
        // Si clear() se ejecutó durante el await (sign-out), aborta la
        // iteración: la cola ya no es propiedad de este ciclo y remover
        // items aquí podría descartar datos de otra sesión.
        if (gen != _generation) return;
        if (result != null) {
          toRemove.add(i);
          _logger.info('OfflineQueue: synced ${item['lessonId']}');
          onItemSynced?.call(result);
        } else {
          // El servidor no devolvio resultado: tipicamente no hay sesion
          // autenticada (EconomicFunctionsService._call devuelve null cuando
          // currentUser es null). El item NO se acredito, asi que se mantiene
          // en cola para reintentar cuando haya sesion; eliminarlo aqui
          // perderia XP/gemas sin acreditarlos.
          _queue[i]['retries'] = retries + 1;
          final dbId = item['_dbId'];
          if (dbId is int) {
            await _persistRetryCount(dbId, retries + 1);
          }
          _logger.warning(
            'OfflineQueue: no server result for ${item['lessonId']} '
            '(attempt ${retries + 1}), keeping item for retry',
          );
        }
      } catch (e) {
        // clear() pudo ejecutarse mientras el server call estaba en vuelo.
        if (gen != _generation) return;
        if (isPermanentError(e)) {
          toRemove.add(i);
          _logger.warning(
            'OfflineQueue: permanent failure for ${item['lessonId']}, '
            'removing (${e.toString()})',
          );
          onItemDropped?.call(item);
          continue;
        }
        // Transient failure: keep the item and retry on the next cycle.
        // completeLesson is idempotent, so re-sending cannot double-credit.
        item['retries'] = retries + 1;
        final dbId = item['_dbId'];
        if (dbId is int) {
          await _persistRetryCount(dbId, retries + 1);
        }
        _logger.warning(
          'OfflineQueue: transient failure for ${item['lessonId']} '
          '(attempt ${retries + 1}), keeping item for retry',
        );
      }
    }

    // Remove synced/max-retried items from SQLite and memory
    if (gen == _generation && toRemove.isNotEmpty) {
      final db = await DatabaseHelper.instance.database;
      final dbIds = <dynamic>[];
      for (int i = toRemove.length - 1; i >= 0; i--) {
        final item = _queue[toRemove[i]];
        final dbId = item['_dbId'];
        if (dbId != null) dbIds.add(dbId);
        _queue.removeAt(toRemove[i]);
      }
      if (dbIds.isNotEmpty) {
        try {
          final placeholders = List.filled(dbIds.length, '?').join(',');
          await db.delete(
            'sync_queue',
            where: 'id IN ($placeholders)',
            whereArgs: dbIds,
          );
        } catch (e) {
          _logger.warning('OfflineQueue: batch delete failed');
        }
      }
    }

    _syncing = false;

    if (_queue.isNotEmpty && _connectivity.online.value) {
      _rescheduleTimer?.cancel();
      _rescheduleTimer = Timer(const Duration(seconds: 30), _processQueue);
    }
  }

  Future<Map<String, dynamic>?> _syncItem(Map<String, dynamic> item) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');

    final economicService = _economic;

    final op = item['op'] as String?;

    if (op == 'add_xp') {
      final result = await economicService.addXp(
        reason: item['reason'] as String? ?? 'unknown',
        lessonId: item['lessonId'] as String?,
        achievementId: item['achievementId'] as String?,
        idempotencyKey: item['idempotencyKey'] as String?,
      );
      if (result != null) result['_op'] = 'add_xp';
      return result;
    }

    // Sync lesson completion through Cloud Function (atomic: gems + XP + streak)
    final correctCount = item['correctAnswers'] as int? ?? 0;
    final totalQuestions = item['totalQuestions'] as int? ?? 0;
    final result = await economicService.completeLesson(
      lessonId: item['lessonId'] as String? ?? '',
      xpEarned: item['xpEarned'] as int? ?? 0,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      perfect: correctCount > 0 && correctCount == totalQuestions,
    );

    // NOTE: Metadata write to lesson_completions subcollection is intentionally omitted.
    // Firestore rules block client writes to subcollections (server-only).
    // The economic mutation above already records the completion server-side.
    // If metadata logging is needed, create a Cloud Function for it.

    if (result != null && item['lessonId'] != null) {
      result['lessonId'] = item['lessonId'];
    }

    return result;
  }

  Future<void> clear() async {
    // Invalida cualquier _processQueue en curso para que no siga removiendo
    // items de una cola que vamos a vaciar (evita crédito cruzado entre
    // cuentas al hacer sign-out mientras hay una sincronización activa).
    _rescheduleTimer?.cancel();
    _generation++;
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('sync_queue');
    } catch (e) {
      _logger.error('OfflineQueue: failed to clear SQLite', e);
    }
    _queue.clear();
    _syncing = false;
  }

  void dispose() {
    _retryTimer?.cancel();
    _rescheduleTimer?.cancel();
    _connectivity.online.removeListener(_onConnectivityChanged);
    _initialized = false;
  }
}
