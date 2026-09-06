import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/offline_queue_service.dart';

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
}
