import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/interfaces/i_economic_functions_service.dart';
import 'package:sagen/services/connectivity_service.dart';
import 'package:sagen/services/database_helper.dart';
import 'package:sagen/services/offline_queue_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeEconomicFunctions implements IEconomicFunctionsService {
  Object? error;
  Map<String, dynamic>? result;

  final calls = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>?> completeLesson({
    required String lessonId,
    required int xpEarned,
    int? correctCount,
    int? totalQuestions,
    bool? perfect,
  }) async {
    calls.add({
      'method': 'completeLesson',
      'lessonId': lessonId,
      'xpEarned': xpEarned,
    });
    final err = error;
    if (err != null) throw err;
    return result ?? <String, dynamic>{'xp': xpEarned};
  }

  @override
  Future<Map<String, dynamic>?> addXp({
    required String reason,
    String? lessonId,
    String? idempotencyKey,
    String? achievementId,
  }) async {
    calls.add({
      'method': 'addXp',
      'reason': reason,
      'idempotencyKey': idempotencyKey ?? '',
    });
    final err = error;
    if (err != null) throw err;
    return result ?? <String, dynamic>{'xp': 10};
  }

  @override
  Future<Map<String, dynamic>?> processDonation({
    required double amount,
    required String method,
    required String idempotencyKey,
  }) async {
    return result;
  }

  @override
  Future<Map<String, dynamic>?> incrementStreak({
    bool freezeUsed = false,
    bool checkIn = true,
    String? itemUsed,
    String? activityDay,
    int? activityStreak,
  }) async {
    return result;
  }

  @override
  Future<Map<String, dynamic>?> recordDonation({
    required double amount,
    required String method,
  }) async {
    return result;
  }

  @override
  Future<Map<String, dynamic>?> claimFreeStreakShield() async {
    return result;
  }

  @override
  String createIdempotencyKey([String? prefix]) => 'fake-key';
}

void main() {
  group('OfflineQueueService', () {
    test('singleton returns same instance', () {
      final a = OfflineQueueService.instance;
      final b = OfflineQueueService.instance;
      expect(identical(a, b), isTrue);
    });

    test('initial state has empty queue', () {
      final service = OfflineQueueService.instance;
      expect(service.queue, isEmpty);
    });

    test('pendingCount is 0 initially', () {
      final service = OfflineQueueService.instance;
      expect(service.pendingCount, 0);
    });

    test('isSyncing is false initially', () {
      final service = OfflineQueueService.instance;
      expect(service.isSyncing, isFalse);
    });

    test('queue returns unmodifiable list', () {
      final service = OfflineQueueService.instance;
      expect(() => service.queue.add({'test': true}), throwsUnsupportedError);
    });

    test('clear does not throw', () async {
      final service = OfflineQueueService.instance;
      await service.clear();
      expect(service.queue, isEmpty);
    });

    test('dispose does not throw', () {
      final service = OfflineQueueService.instance;
      service.dispose();
    });

    test('queueAddXp enqueues a persistent add_xp item', () async {
      final service = OfflineQueueService.instance;
      await service.clear();
      await service.queueAddXp(
        reason: 'review',
        lessonId: null,
        idempotencyKey: 'xp_review_fixed',
      );
      expect(service.pendingCount, 1);
      final item = service.queue.first;
      expect(item['op'], 'add_xp');
      expect(item['reason'], 'review');
      expect(item['lessonId'], isNull);
      expect(item['idempotencyKey'], 'xp_review_fixed');
      await service.clear();
    });

    test('queueAddXp persists the idempotency key for safe retries', () async {
      final service = OfflineQueueService.instance;
      await service.clear();
      // La misma clave debe sobrevivir al viaje ida y vuelta SQLite -> memoria,
      // porque el reintento offline la reutiliza para no duplicar.
      await service.queueAddXp(
        reason: 'achievement',
        idempotencyKey: 'stable-key-42',
      );
      expect(service.queue.single['idempotencyKey'], 'stable-key-42');
      await service.clear();
    });

    test(
      'queueAddXp persists achievementId so addXp awards the real achievement XP',
      () async {
        // FIX-achievementId: sin este id el servidor cae al fallback de 10 XP
        // para reason='achievement'. El id debe viajar en el payload SQLite.
        final service = OfflineQueueService.instance;
        await service.clear();
        await service.queueAddXp(
          reason: 'achievement',
          achievementId: 'five_lessons',
          idempotencyKey: 'stable-key-42',
        );
        final item = service.queue.single;
        expect(item['achievementId'], 'five_lessons');
        expect(item['op'], 'add_xp');
        expect(item['reason'], 'achievement');
        await service.clear();
      },
    );

    test(
      'isPermanentError treats internal and aborted as TRANSIENT (item kept for retry)',
      () {
        // El servidor envuelve fallos transitorios (contención de Firestore,
        // timeouts, caídas puntuales) en 'internal'; 'aborted' es contención
        // gRPC. Ambos pueden triunfar al reintentar. Si se clasificaran como
        // permanentes, el item se descartaría y el usuario perdería su XP/gemas.
        expect(
          OfflineQueueService.isPermanentError(
            FirebaseFunctionsException(code: 'internal', message: 'boom'),
          ),
          isFalse,
        );
        expect(
          OfflineQueueService.isPermanentError(
            FirebaseFunctionsException(code: 'aborted', message: 'contention'),
          ),
          isFalse,
        );
      },
    );

    test(
      'isPermanentError treats failed-precondition as TRANSIENT (M2-fix)',
      () {
        // M2-fix: 'failed-precondition' en las callables económicas significa
        // "correo sin verificar todavia" (requireVerifiedUser). Se resuelve
        // cuando el usuario verifica, así que los items encolados deben
        // permanecer y acreditarse luego — no descartarse ni perder XP/gemas.
        expect(
          OfflineQueueService.isPermanentError(
            FirebaseFunctionsException(
              code: 'failed-precondition',
              message: 'Verify your email first.',
            ),
          ),
          isFalse,
        );
        expect(
          OfflineQueueService.isPermanentError(
            FirebaseFunctionsException(
              code: 'failed-precondition',
              message: 'today_mismatch',
            ),
          ),
          isFalse,
        );
      },
    );

    test('isPermanentError keeps genuine rejections as permanent', () {
      // Fallos de validación/permiso son reales y nunca triunfarían al
      // reintentar, así que el item debe descartarse.
      for (final code in [
        'invalid-argument',
        'permission-denied',
        'not-found',
        'unauthenticated',
        'already-exists',
      ]) {
        expect(
          OfflineQueueService.isPermanentError(
            FirebaseFunctionsException(code: code, message: 'nope'),
          ),
          isTrue,
          reason: '$code should be permanent',
        );
      }
    });
  });

  group('OfflineQueueService persistence and sync', () {
    late Directory tempDir;
    late FakeEconomicFunctions economic;
    late OfflineQueueService service;
    String? testUid;

    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      tempDir = Directory.systemTemp.createTempSync('sagen_oq_test');
      DatabaseHelper.overrideDatabasesPath = tempDir.path;
      ConnectivityService.instance.online.value = false;
      economic = FakeEconomicFunctions();
      testUid = null;
      service = OfflineQueueService.forTesting(
        economic: economic,
        currentUid: () => testUid,
      );
      await service.init();
    });

    tearDown(() async {
      service.dispose();
      await OfflineQueueService.instance.clear();
      await DatabaseHelper.instance.close();
      DatabaseHelper.overrideDatabasesPath = null;
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    Future<int> dbRowCount() async {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('sync_queue');
      return rows.length;
    }

    Future<void> waitUntil(bool Function() condition) async {
      for (var i = 0; i < 100 && !condition(); i++) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(condition(), isTrue);
    }

    test('queueLessonCompletion persists to SQLite and enqueues', () async {
      await service.queueLessonCompletion(
        lessonId: 'l1',
        stageId: 's1',
        gemsEarned: 5,
        xpEarned: 20,
        correctAnswers: 3,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );

      expect(service.pendingCount, 1);
      final item = service.queue.single;
      expect(item['lessonId'], 'l1');
      expect(item['stageId'], 's1');
      expect(item['correctAnswers'], 3);
      expect(item['totalQuestions'], 5);
      expect(item['_dbId'], isA<int>());
      expect(await dbRowCount(), 1);
    });

    test('queueAddXp persists an add_xp item to SQLite', () async {
      await service.queueAddXp(
        reason: 'mission',
        achievementId: 'hard_worker',
        idempotencyKey: 'k1',
      );

      expect(service.pendingCount, 1);
      final item = service.queue.single;
      expect(item['op'], 'add_xp');
      expect(item['achievementId'], 'hard_worker');
      expect(await dbRowCount(), 1);
    });

    test('pending items restore from SQLite on a fresh instance', () async {
      await service.queueLessonCompletion(
        lessonId: 'l9',
        stageId: 's1',
        gemsEarned: 0,
        xpEarned: 15,
        correctAnswers: 3,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );

      service.dispose();
      final fresh = OfflineQueueService.forTesting(economic: economic);
      await fresh.init();

      expect(fresh.pendingCount, 1);
      expect(fresh.queue.single['lessonId'], 'l9');
      expect(fresh.queue.single['retries'], 0);

      fresh.dispose();
      await fresh.clear();
    });

    test('flush syncs items with a signed-in user and removes them', () async {
      testUid = 'uid-123';
      economic.result = {'xp': 20, 'gems': 5};
      var syncedCount = 0;
      Map<String, dynamic>? lastResult;
      service.onItemSynced = (result) {
        syncedCount++;
        lastResult = result;
      };

      await service.queueLessonCompletion(
        lessonId: 'l_sync',
        stageId: 's1',
        gemsEarned: 5,
        xpEarned: 20,
        correctAnswers: 5,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );

      ConnectivityService.instance.online.value = true;
      await service.flush();

      await waitUntil(() => service.pendingCount == 0);

      expect(economic.calls.last['lessonId'], 'l_sync');
      expect(syncedCount, 1);
      expect(lastResult?['lessonId'], 'l_sync');
      expect(await dbRowCount(), 0);
    });

    test('add_xp items sync through the addXp path', () async {
      testUid = 'uid-123';
      economic.result = {'xp': 10};

      await service.queueAddXp(reason: 'review', idempotencyKey: 'k2');

      ConnectivityService.instance.online.value = true;
      await service.flush();
      await waitUntil(() => service.pendingCount == 0);

      expect(economic.calls.single['method'], 'addXp');
      expect(economic.calls.single['idempotencyKey'], 'k2');
      expect(await dbRowCount(), 0);
    });

    test('flush without a session keeps the item and bumps retries', () async {
      await service.queueLessonCompletion(
        lessonId: 'l_noauth',
        stageId: 's1',
        gemsEarned: 5,
        xpEarned: 20,
        correctAnswers: 3,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );

      ConnectivityService.instance.online.value = true;
      await service.flush();

      expect(service.pendingCount, 1);
      expect(service.queue.single['retries'], 1);
      expect(await dbRowCount(), 1);

      final db = await DatabaseHelper.instance.database;
      final rows = await db.query('sync_queue');
      expect(rows.single['retry_count'], 1);
    });

    test('flush with a permanent error drops the item', () async {
      testUid = 'uid-123';
      economic.error = FirebaseFunctionsException(
        code: 'invalid-argument',
        message: 'bad request',
      );
      var dropped = 0;
      service.onItemDropped = (_) => dropped++;

      await service.queueLessonCompletion(
        lessonId: 'l_perm',
        stageId: 's1',
        gemsEarned: 5,
        xpEarned: 20,
        correctAnswers: 3,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );

      ConnectivityService.instance.online.value = true;
      await service.flush();
      await waitUntil(() => service.pendingCount == 0);

      expect(dropped, 1);
      expect(await dbRowCount(), 0);
    });

    test(
      'flush with a transient error keeps the item and bumps retries',
      () async {
        testUid = 'uid-123';
        economic.error = FirebaseFunctionsException(
          code: 'internal',
          message: 'server hiccup',
        );

        await service.queueLessonCompletion(
          lessonId: 'l_trans',
          stageId: 's1',
          gemsEarned: 5,
          xpEarned: 20,
          correctAnswers: 3,
          totalQuestions: 5,
          completedAt: DateTime.now(),
        );

        ConnectivityService.instance.online.value = true;
        await service.flush();

        expect(service.pendingCount, 1);
        expect(service.queue.single['retries'], 1);
        expect(await dbRowCount(), 1);
      },
    );

    test('clear wipes memory and SQLite rows', () async {
      await service.queueLessonCompletion(
        lessonId: 'l_a',
        stageId: 's1',
        gemsEarned: 0,
        xpEarned: 10,
        correctAnswers: 3,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );
      await service.queueLessonCompletion(
        lessonId: 'l_b',
        stageId: 's1',
        gemsEarned: 0,
        xpEarned: 10,
        correctAnswers: 3,
        totalQuestions: 5,
        completedAt: DateTime.now(),
      );

      await service.clear();

      expect(service.pendingCount, 0);
      expect(await dbRowCount(), 0);
    });
  });
}
