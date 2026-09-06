import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

void main() {
  group('FirstLessonState', () {
    test('initial state has correct defaults', () {
      const state = FirstLessonState();
      expect(state.questions, isEmpty);
      expect(state.currentIndex, 0);
      expect(state.correctCount, 0);
      expect(state.wrongCount, 0);
      expect(state.showFeedback, false);
    });

    test('totalQuestions returns length', () {
      const state = FirstLessonState(
        questions: [
          Challenge(
            id: '1',
            question: 'Q1',
            type: LessonType.multipleChoice,
            options: ['A', 'B'],
            correctIndex: 0,
            explanation: 'E',
          ),
          Challenge(
            id: '2',
            question: 'Q2',
            type: LessonType.trueFalse,
            options: ['T', 'F'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
      );
      expect(state.totalQuestions, 2);
    });

    test('isComplete is true when past last question', () {
      const state = FirstLessonState(
        questions: [
          Challenge(
            id: '1',
            question: 'Q',
            type: LessonType.multipleChoice,
            options: ['A', 'B'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
        currentIndex: 1,
      );
      expect(state.isComplete, true);
    });

    test('isPerfect when all correct', () {
      const state = FirstLessonState(
        questions: [
          Challenge(
            id: '1',
            question: 'Q1',
            type: LessonType.multipleChoice,
            options: ['A', 'B'],
            correctIndex: 0,
            explanation: 'E',
          ),
          Challenge(
            id: '2',
            question: 'Q2',
            type: LessonType.trueFalse,
            options: ['T', 'F'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
        correctCount: 2,
      );
      expect(state.isPerfect, true);
    });
  });

  group('FirstLessonNotifier', () {
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
      final state = container.read(firstLessonProvider);
      expect(state.questions, isEmpty);
      expect(state.currentIndex, 0);
    });

    test('reset clears state', () {
      final notifier = container.read(firstLessonProvider.notifier);
      notifier.reset();
      final state = container.read(firstLessonProvider);
      expect(state.questions, isEmpty);
      expect(state.currentIndex, 0);
    });

    test('submitAnswer is no-op when no current challenge', () {
      final notifier = container.read(firstLessonProvider.notifier);
      notifier.submitAnswer(0);
      expect(container.read(firstLessonProvider).showFeedback, false);
    });

    test('wrong answer feeds the review queue with stage topic', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final seeded = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          learningProvider.overrideWith(MockLearningNotifier.new),
          firstLessonProvider.overrideWith(SeededFirstLessonNotifier.new),
        ],
      );
      addTearDown(seeded.dispose);

      final notifier = seeded.read(firstLessonProvider.notifier);
      final q = seeded.read(firstLessonProvider).currentChallenge!;
      final wrongIdx = (q.correctIndex + 1) % q.options.length;

      final reviewNotifier = seeded.read(reviewProvider.notifier);
      final before = reviewNotifier.failureCountFor(q.id);
      notifier.submitAnswer(wrongIdx);

      expect(reviewNotifier.failureCountFor(q.id), before + 1);
      expect(reviewNotifier.getTopicForQuestion(q.id), isNotNull);
      expect(notifier.state.wrongCount, 1);
    });
  });

  group('_selectDiagnosticQuestions', () {
    Challenge c(String id, String question, [List<String>? options]) {
      return Challenge(
        id: id,
        question: question,
        type: LessonType.multipleChoice,
        options: options ?? ['A', 'B', 'C'],
        correctIndex: 0,
        explanation: 'E',
      );
    }

    test('deduplica por id exactos', () {
      final all = [
        c('q1', 'Pregunta A'),
        c('q1', 'Pregunta A'),
        c('q2', 'Pregunta B'),
      ];
      final result = FirstLessonNotifier.selectDiagnosticQuestions(all, 3);
      expect(result.length, 2);
      expect(result.map((e) => e.id).toSet(), {'q1', 'q2'});
    });

    test(
      'deduplica por contenido aunque el id difiera (variante sintética)',
      () {
        // Mismo enunciado y mismas opciones, ids distintos: cuenta como UNA.
        final all = [
          c('ac_..._q1', '¿Qué es el phishing?', ['A', 'B', 'C']),
          c('pool_123', '¿Qué es el phishing?', ['A', 'B', 'C']),
          c('type_mc_9', 'Otra pregunta', ['A', 'B', 'C']),
        ];
        final result = FirstLessonNotifier.selectDiagnosticQuestions(all, 3);
        expect(result.length, 2);
        // Se conserva la primera encontrada.
        expect(result.map((e) => e.id).toSet(), {'ac_..._q1', 'type_mc_9'});
      },
    );

    test(
      'preguntas con DISTINTO contenido pero mismo id se descartan correctamente',
      () {
        final all = [
          c('q1', 'Pregunta A'),
          c('q2', 'Pregunta B'),
          c('q3', 'Pregunta C'),
          c('q4', 'Pregunta D'),
        ];
        // Solo pide 2 -> respeta el límite sin duplicados.
        final result = FirstLessonNotifier.selectDiagnosticQuestions(all, 2);
        expect(result.length, 2);
        expect(result.map((e) => e.id).toSet().length, 2);
      },
    );

    test('respeta el límite de questionCount', () {
      final all = [for (var i = 0; i < 60; i++) c('q$i', 'Pregunta $i')];
      final result = FirstLessonNotifier.selectDiagnosticQuestions(all, 30);
      expect(result.length, 30);
    });
  });
}

/// Variante de test que siembra una pregunta de diagnóstico conocida, para
/// verificar de forma determinista (sin SQLite) que el flujo alimenta el
/// repaso inteligente.
class SeededFirstLessonNotifier extends FirstLessonNotifier {
  @override
  FirstLessonState build() {
    return const FirstLessonState(
      questions: [
        Challenge(
          id: 'ac_s1_ses1_l1_q1',
          lessonId: 'ac_s1_ses1_l1',
          question: '¿Qué es la ingeniería social?',
          type: LessonType.multipleChoice,
          options: ['A', 'B', 'C', 'D'],
          correctIndex: 0,
          explanation: 'Explicación',
        ),
      ],
      startTime: null,
    );
  }
}
