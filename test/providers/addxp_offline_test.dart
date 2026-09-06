import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/economic_functions_service.dart';
import 'package:sagen/services/offline_queue_service.dart';

/// Notifier real (solo se aligera build()) para probar addXp + reconcile.
class RealLearningNotifier extends LearningNotifier {
  @override
  LearningState build() => const LearningState(
    isLoading: false,
    xp: 0,
    totalXpEarned: 0,
    currentLevel: 1,
  );
}

class MockEconomicFunctions extends Mock implements EconomicFunctionsService {}

class MockOfflineQueue extends Mock implements OfflineQueueService {}

void main() {
  late SharedPreferences prefs;
  late MockEconomicFunctions mockEconomic;
  late MockOfflineQueue mockQueue;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockEconomic = MockEconomicFunctions();
    mockQueue = MockOfflineQueue();

    when(
      () => mockEconomic.createIdempotencyKey(any()),
    ).thenReturn('xp_review_stable_key');
    when(
      () => mockQueue.queueAddXp(
        reason: any(named: 'reason'),
        lessonId: any(named: 'lessonId'),
        achievementId: any(named: 'achievementId'),
        idempotencyKey: any(named: 'idempotencyKey'),
      ),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        learningProvider.overrideWith(RealLearningNotifier.new),
        economicFunctionsServiceProvider.overrideWithValue(mockEconomic),
        offlineQueueServiceProvider.overrideWithValue(mockQueue),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('addXp offline-safe', () {
    test('revierte el optimismo y reencola con la clave estable', () async {
      when(
        () => mockEconomic.addXp(
          reason: any(named: 'reason'),
          lessonId: any(named: 'lessonId'),
          idempotencyKey: any(named: 'idempotencyKey'),
        ),
      ).thenThrow(Exception('sin red'));

      final notifier = container.read(learningProvider.notifier);
      await notifier.addXp(15, reason: 'review');

      // Sin red: el estado vuelve atrás y la recompensa NO se pierde.
      expect(notifier.state.xp, 0);
      expect(notifier.state.totalXpEarned, 0);
      verify(
        () => mockQueue.queueAddXp(
          reason: 'review',
          lessonId: null,
          achievementId: null,
          idempotencyKey: 'xp_review_stable_key',
        ),
      ).called(1);
      verify(
        () => mockEconomic.addXp(
          reason: 'review',
          lessonId: any(named: 'lessonId'),
          idempotencyKey: 'xp_review_stable_key',
        ),
      ).called(1);
    });

    test(
      'aplica los totales del servidor cuando la llamada tiene exito',
      () async {
        when(
          () => mockEconomic.addXp(
            reason: any(named: 'reason'),
            lessonId: any(named: 'lessonId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenAnswer(
          (_) async => <String, dynamic>{
            'success': true,
            'duplicate': false,
            'totalXp': 130,
            'level': 2,
          },
        );

        final notifier = container.read(learningProvider.notifier);
        await notifier.addXp(15, reason: 'review');

        expect(notifier.state.totalXpEarned, 130);
        expect(notifier.state.currentLevel, 2);
        expect(notifier.state.xp, 30);
        verifyNever(
          () => mockQueue.queueAddXp(
            reason: any(named: 'reason'),
            lessonId: any(named: 'lessonId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        );
      },
    );

    test(
      'sin red, reencola el logro conservando su achievementId (FIX)',
      () async {
        // FIX-achievementId: el id del logro debe sobrevivir el encolado.
        // Antes se perdía y el servidor caía al fallback plano de 10 XP.
        when(
          () => mockEconomic.addXp(
            reason: any(named: 'reason'),
            lessonId: any(named: 'lessonId'),
            achievementId: any(named: 'achievementId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenThrow(Exception('sin red'));

        final notifier = container.read(learningProvider.notifier);
        await notifier.addXp(
          25,
          reason: 'achievement',
          achievementId: 'five_lessons',
        );

        expect(notifier.state.totalXpEarned, 0);
        verify(
          () => mockQueue.queueAddXp(
            reason: 'achievement',
            lessonId: null,
            achievementId: 'five_lessons',
            idempotencyKey: 'xp_review_stable_key',
          ),
        ).called(1);
      },
    );

    test(
      'el rollback resta el delta al estado ACTUAL, no a un snapshot stale',
      () async {
        // Durante el await del server call, otro método (applyServerXp, p.ej. el
        // cofre diario) acredita +5. El rollback previo restauraba el snapshot
        // capturado ANTES del addXp y perdería esos +5. Ahora solo restamos el
        // monto fallido al total actual, preservando el cambio concurrente.
        final completer = Completer<Map<String, dynamic>?>();
        when(
          () => mockEconomic.addXp(
            reason: any(named: 'reason'),
            lessonId: any(named: 'lessonId'),
            idempotencyKey: any(named: 'idempotencyKey'),
          ),
        ).thenAnswer((_) => completer.future);

        final notifier = container.read(learningProvider.notifier);
        final pending = notifier.addXp(15, reason: 'review');

        notifier.applyServerXp(5);
        completer.completeError(Exception('sin red'));
        await pending;

        expect(notifier.state.totalXpEarned, 5);
        expect(notifier.state.currentLevel, 1);
        expect(notifier.state.xp, 5);
        verify(
          () => mockQueue.queueAddXp(
            reason: 'review',
            lessonId: null,
            achievementId: null,
            idempotencyKey: 'xp_review_stable_key',
          ),
        ).called(1);
      },
    );
  });

  group('_reconcileWithServer shapes', () {
    test('add_xp raíz: aplica totales y nivel', () {
      final notifier = container.read(learningProvider.notifier);
      notifier.reconcileForTest({
        '_op': 'add_xp',
        'success': true,
        'duplicate': false,
        'totalXp': 500,
        'level': 6,
      });
      expect(notifier.state.totalXpEarned, 500);
      expect(notifier.state.currentLevel, 6);
      expect(notifier.state.xp, 0);
    });

    test('add_xp duplicado: también aplica totales (respuesta perdida)', () {
      final notifier = container.read(learningProvider.notifier);
      notifier.reconcileForTest({
        '_op': 'add_xp',
        'success': true,
        'duplicate': true,
        'totalXp': 240,
        'level': 3,
      });
      expect(notifier.state.totalXpEarned, 240);
      expect(notifier.state.currentLevel, 3);
    });

    test('completeLesson anidado: aplica totales y lessonsCompleted', () {
      final notifier = container.read(learningProvider.notifier);
      notifier.reconcileForTest({
        'xp': {'totalXp': 130},
        'level': {'current': 2},
      });
      expect(notifier.state.totalXpEarned, 130);
      expect(notifier.state.currentLevel, 2);
      expect(notifier.state.xp, 30);
    });

    test('completeLesson duplicado (sin _op): no toca el estado', () {
      final notifier = container.read(learningProvider.notifier);
      notifier.reconcileForTest({
        'success': true,
        'duplicate': true,
        'xp': {'totalXp': 999},
        'level': {'current': 10},
      });
      expect(notifier.state.totalXpEarned, 0);
      expect(notifier.state.currentLevel, 1);
    });
  });
}
