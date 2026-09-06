import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReviewState', () {
    test('initial state has correct defaults', () {
      const state = ReviewState();
      expect(state.questionFailures, isEmpty);
      expect(state.questionTopics, isEmpty);
      expect(state.topicScores, isEmpty);
      expect(state.totalReviews, 0);
    });

    test('copyWith updates only specified fields', () {
      const state = ReviewState();
      final updated = state.copyWith(totalReviews: 3);
      expect(updated.totalReviews, 3);
      expect(updated.questionFailures, isEmpty);
    });
  });

  group('ReviewNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('build returns default state', () {
      final state = container.read(reviewProvider);
      expect(state.totalReviews, 0);
      expect(state.questionFailures, isEmpty);
    });

    test('initial getters return empty state', () {
      final notifier = container.read(reviewProvider.notifier);
      expect(notifier.hasWeakTopics, false);
      expect(notifier.hasReviewableQuestions, false);
      expect(notifier.weakTopics, isEmpty);
      expect(notifier.failedQuestionIds, isEmpty);
      expect(notifier.totalReviews, 0);
    });

    test('recordMistake adds question failure and topic score', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      expect(notifier.failureCountFor('q1'), 1);
      expect(notifier.scoreFor('phishing'), 1);
      expect(notifier.getTopicForQuestion('q1'), 'phishing');
    });

    test('recordMistake increments multiple failures for same question', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q1', 'phishing');
      expect(notifier.failureCountFor('q1'), 2);
      expect(notifier.scoreFor('phishing'), 2);
    });

    test('recordMistake caps topic score at max', () {
      final notifier = container.read(reviewProvider.notifier);
      for (int i = 0; i < 15; i++) {
        notifier.recordMistake('q$i', 'passwords');
      }
      expect(notifier.scoreFor('passwords'), 10);
    });

    test('hasReviewableQuestions returns true after mistakes', () {
      final notifier = container.read(reviewProvider.notifier);
      expect(notifier.hasReviewableQuestions, false);
      notifier.recordMistake('q1', 'phishing');
      expect(notifier.hasReviewableQuestions, true);
    });

    test('recordCorrect decrements failure count', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.failureCountFor('q1'), 1);
    });

    test('recordCorrect removes question when count reaches 0', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.failureCountFor('q1'), 0);
      expect(notifier.hasReviewableQuestions, false);
    });

    test('recordCorrect decrements topic score', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q2', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.scoreFor('phishing'), 1);
    });

    test('recordCorrect removes topic when score reaches 0', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.scoreFor('phishing'), 0);
    });

    test('recordCorrect never-failed question does not schedule a review', () {
      final notifier = container.read(reviewProvider.notifier);

      notifier.recordCorrect('q1');

      final review = container.read(reviewProvider);
      expect(review.interval, isEmpty);
      expect(review.repetition, isEmpty);
      expect(review.easeFactor, isEmpty);
      expect(review.nextReviewDate, isEmpty);
      expect(notifier.hasReviewableQuestions, false);
      expect(notifier.reviewQueueIds, isEmpty);
    });

    test('recordCorrect after a mistake schedules interval 1 for tomorrow', () {
      final notifier = container.read(reviewProvider.notifier);

      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');

      final review = container.read(reviewProvider);
      expect(review.interval['q1'], 1);
      expect(review.repetition['q1'], 1);
      expect(review.easeFactor['q1'], closeTo(2.4, 0.001));
      expect(review.nextReviewDate['q1'], isNotNull);
      // Programada para manana: aun no vence, no sale en la cola hoy.
      expect(notifier.reviewQueueIds, isEmpty);
    });

    test('repeated correct answers advance the SM-2 interval', () {
      final notifier = container.read(reviewProvider.notifier);

      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      notifier.recordCorrect('q1');

      final review = container.read(reviewProvider);
      expect(review.repetition['q1'], 2);
      // Secuencia clasica SM-2: rep 1 -> intervalo 1; rep 2 -> intervalo 6.
      expect(review.interval['q1'], 6);
      expect(review.easeFactor['q1'], closeTo(2.5, 0.001));
    });

    test('resolved mistakes leave the failures map but keep the schedule', () {
      final notifier = container.read(reviewProvider.notifier);

      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      notifier.recordCorrect('q1');

      final review = container.read(reviewProvider);
      // Sin fallos pendientes y sin topic, pero el planificador persiste.
      expect(review.questionFailures, isEmpty);
      expect(review.questionTopics, isEmpty);
      expect(review.topicScores, isEmpty);
      expect(review.interval['q1'], isNotNull);
      expect(review.repetition['q1'], 2);
    });

    test(
      'la fecha de repaso se programa al INICIO del día objetivo (medianoche)',
      () {
        final notifier = container.read(reviewProvider.notifier);
        notifier.recordMistake('q1', 'phishing');
        notifier.recordCorrect('q1');

        final review = container.read(reviewProvider);
        final next = review.nextReviewDate['q1'];
        expect(next, isNotNull);
        final nextDt = next as DateTime;
        final now = DateTime.now();
        final expectedMidnight = DateTime(
          now.year,
          now.month,
          now.day + review.interval['q1']!,
        );
        // Vence al amanecer del día objetivo, no dentro de 24h exactas.
        expect(
          nextDt,
          DateTime(
            expectedMidnight.year,
            expectedMidnight.month,
            expectedMidnight.day,
          ),
        );
        expect(nextDt.hour, 0);
        expect(nextDt.minute, 0);
        expect(nextDt.second, 0);
      },
    );

    test('markReviewCompleted increments total reviews', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.markReviewCompleted();
      expect(notifier.totalReviews, 1);
    });

    test('markReviewCompleted increments cumulative', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.markReviewCompleted();
      notifier.markReviewCompleted();
      notifier.markReviewCompleted();
      expect(notifier.totalReviews, 3);
    });

    test('pruneMissingIds prunes only requested-but-unresolved ids', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q2', 'passwords');

      // El banco resolvio q1 y q2 (se pidieron y existieron): no se poda nada.
      notifier.pruneMissingIds(['q1', 'q2'], ['q1', 'q2']);
      final review1 = container.read(reviewProvider);
      expect(review1.questionFailures['q1'], 1);
      expect(review1.questionFailures['q2'], 1);

      // Se pidieron q1 y qX; qX no existe en el banco -> solo qX se poda.
      notifier.pruneMissingIds(['q1', 'qX'], ['q1']);
      final review2 = container.read(reviewProvider);
      expect(review2.questionFailures['q1'], 1);
      expect(review2.questionFailures.containsKey('qX'), isFalse);
    });

    test(
      'pruneMissingIds nunca toca IDs debidos pero no servidos en el lote',
      () {
        final notifier = container.read(reviewProvider.notifier);
        notifier.recordMistake('q1', 'phishing');
        notifier.recordMistake('q2', 'passwords');

        // Simula el tope de 10: este lote solo pidio q1, pero q2 sigue viviendo
        // en los mapas SM-2. q2 NO debe podarse (no se pidio en este lote).
        notifier.pruneMissingIds(['q1'], ['q1']);
        final review = container.read(reviewProvider);
        expect(review.questionFailures['q1'], 1);
        expect(review.questionFailures['q2'], 1);
      },
    );

    test('weakTopics identifies topics above threshold', () {
      final notifier = container.read(reviewProvider.notifier);
      for (int i = 0; i < 5; i++) {
        notifier.recordMistake('q$i', 'phishing');
      }
      expect(notifier.hasWeakTopics, true);
      expect(notifier.weakTopics, contains('phishing'));
    });

    test('reserved topics never surface as weak topics', () {
      final notifier = container.read(reviewProvider.notifier);

      // Fallar preguntas en un repaso (tema 'review') o sin tema disponible
      // ('lesson') no debe pintar chips/fraseos al LLM con esos metadatos.
      for (int i = 0; i < 5; i++) {
        notifier.recordMistake('review_q$i', 'review');
      }
      for (int i = 0; i < 5; i++) {
        notifier.recordMistake('lesson_q$i', 'lesson');
      }
      expect(notifier.weakTopics, isNot(contains('review')));
      expect(notifier.weakTopics, isNot(contains('lesson')));

      // Un tema real sigue apareciendo aunque conviva con los reservados.
      for (int i = 0; i < 5; i++) {
        notifier.recordMistake('phish_q$i', 'phishing');
      }
      expect(notifier.weakTopics, contains('phishing'));
      expect(notifier.weakTopics, isNot(contains('review')));
      expect(notifier.weakTopics, isNot(contains('lesson')));
    });

    test('reload preserves persisted state', () async {
      SharedPreferences.setMockInitialValues({
        'review_q_fails': '{"q1":2,"q2":1}',
        'review_q_topics': '{"q1":"phishing","q2":"passwords"}',
        'review_t_scores': '{"phishing":2,"passwords":1}',
        'review_total': 5,
      });
      final prefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      final notifier = newContainer.read(reviewProvider.notifier);
      expect(notifier.failureCountFor('q1'), 2);
      expect(notifier.failureCountFor('q2'), 1);
      expect(notifier.scoreFor('phishing'), 2);
      expect(notifier.scoreFor('passwords'), 1);
      expect(notifier.totalReviews, 5);
      newContainer.dispose();
    });

    test(
      'reload tras sign-out limpia el estado en memoria (evita fuga entre usuarios)',
      () async {
        final notifier = container.read(reviewProvider.notifier);
        for (int i = 0; i < 5; i++) {
          notifier.recordMistake('q$i', 'phishing');
        }
        expect(notifier.hasWeakTopics, true);
        expect(notifier.failedQuestionIds, isNotEmpty);

        // Simula GameStateCleaner al sign-out: se vacian las claves por usuario.
        SharedPreferences.resetStatic();
        SharedPreferences.setMockInitialValues({});
        final freshPrefs = await SharedPreferences.getInstance();
        container = ProviderContainer(
          overrides: [prefsProvider.overrideWithValue(freshPrefs)],
        );

        // SyncCoordinator llama reload() al re-login (fix H-ARC-01): debe
        // reconstruir el estado desde las prefs limpias, sin heredar la cola de
        // repaso del usuario anterior en memoria.
        final freshNotifier = container.read(reviewProvider.notifier);
        freshNotifier.reload();
        expect(freshNotifier.failedQuestionIds, isEmpty);
        expect(freshNotifier.hasWeakTopics, false);
        expect(container.read(reviewProvider).totalReviews, 0);
      },
    );
  });
}
