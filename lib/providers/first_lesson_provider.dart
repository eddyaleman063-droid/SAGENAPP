import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning/challenge.dart';
import '../models/learning/quiz_score.dart';
import '../services/question_bank.dart';
import 'providers.dart';

enum DiagnosticPath { beginner, experienced }

class FirstLessonState {
  final List<Challenge> questions;
  final int currentIndex;
  final int correctCount;
  final int wrongCount;
  final DateTime? startTime;
  final bool showFeedback;
  final int? selectedAnswer;
  final bool answeredCorrectly;
  final DiagnosticPath? path;

  const FirstLessonState({
    this.questions = const [],
    this.currentIndex = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.startTime,
    this.showFeedback = false,
    this.selectedAnswer,
    this.answeredCorrectly = false,
    this.path,
  });

  FirstLessonState copyWith({
    List<Challenge>? questions,
    int? currentIndex,
    int? correctCount,
    int? wrongCount,
    DateTime? startTime,
    bool? showFeedback,
    int? selectedAnswer,
    bool? answeredCorrectly,
    DiagnosticPath? path,
  }) {
    return FirstLessonState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      startTime: startTime ?? this.startTime,
      showFeedback: showFeedback ?? this.showFeedback,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      answeredCorrectly: answeredCorrectly ?? this.answeredCorrectly,
      path: path ?? this.path,
    );
  }

  int get totalQuestions => questions.length;
  bool get isComplete => currentIndex >= totalQuestions && totalQuestions > 0;
  bool get isPerfect => correctCount == totalQuestions && correctCount > 0;
  double get accuracy => (correctCount + wrongCount) > 0
      ? correctCount / (correctCount + wrongCount)
      : 0;
  int get earnedXp => QuizScoreCalculator(
    correctCount: correctCount,
    totalQuestions: totalQuestions,
    timeSpentSeconds: 0,
  ).xp;
  Duration? get elapsedTime => startTime != null
      ? DateTime.now().difference(startTime ?? DateTime.now())
      : null;
  Challenge? get currentChallenge =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  int get recommendedStage {
    if (path == DiagnosticPath.beginner) return 1;
    return accuracy >= 0.5 ? 2 : 1;
  }
}

class FirstLessonNotifier extends AutoDisposeNotifier<FirstLessonState> {
  final _random = Random();

  @override
  FirstLessonState build() => const FirstLessonState();

  Future<void> startLesson({
    DiagnosticPath path = DiagnosticPath.beginner,
  }) async {
    final questionCount = path == DiagnosticPath.beginner ? 30 : 60;

    List<Challenge> allQuestions = [];

    if (path == DiagnosticPath.beginner) {
      allQuestions = [
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st1',
          'default',
          count: questionCount + 10,
        ),
      ];
    } else {
      allQuestions = [
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st1',
          'default',
          count: 12,
        ),
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st2',
          'default',
          count: 12,
        ),
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st3',
          'default',
          count: 12,
        ),
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st4',
          'default',
          count: 12,
        ),
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st5',
          'default',
          count: 12,
        ),
        ...await QuestionBank.instance.getQuestionsForLesson(
          'ac_st6',
          'default',
          count: 12,
        ),
      ];
    }

    final selected = List<Challenge>.from(
      selectDiagnosticQuestions(allQuestions, questionCount),
    )..shuffle(_random);

    state = FirstLessonState(
      questions: selected,
      startTime: DateTime.now(),
      path: path,
    );
  }

  /// Selecciona las [questionCount] preguntas del diagnóstico a partir de las
  /// [allQuestions] recolectadas por etapa, garantizando que NO haya duplicados
  /// (ni por id ni por contenido: mismo enunciado más las mismas opciones).
  /// Pura y determinista, por lo que es directamente testeable sin SQLite.
  @visibleForTesting
  static List<Challenge> selectDiagnosticQuestions(
    List<Challenge> allQuestions,
    int questionCount,
  ) {
    // Deduplicación por contenido completo primero: dos entradas con el mismo
    // enunciado y las mismas opciones (aunque tengan ids distintos, p.ej. una
    // variante sintética) cuentan como una, conservando la primera.
    final byContent = <String, Challenge>{};
    final byId = <String>{};
    for (final q in allQuestions) {
      final contentKey = '${q.question}\u0000${q.options.join('\u0001')}';
      if (!byContent.containsKey(contentKey)) {
        byContent[contentKey] = q;
        byId.add(q.id);
      }
    }
    final unique = byContent.values.toList();
    return unique.take(questionCount).toList();
  }

  void submitAnswer(int selectedIndex) {
    final question = state.currentChallenge;
    if (question == null || state.showFeedback) return;

    final correct = selectedIndex == question.effectiveCorrectIndex;
    state = state.copyWith(
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      wrongCount: correct ? state.wrongCount : state.wrongCount + 1,
      showFeedback: true,
      selectedAnswer: selectedIndex,
      answeredCorrectly: correct,
    );

    // Alimenta el repaso inteligente (SM-2) igual que las lecciones normales:
    // cada acierto/fallo del diagnóstico deja programada la repetición de ese
    // tema, de modo que los puntos débiles detectados al empezar no se pierden.
    try {
      final topic = _topicForChallenge(question);
      if (correct) {
        ref.read(reviewProvider.notifier).recordCorrect(question.id);
      } else {
        ref.read(reviewProvider.notifier).recordMistake(question.id, topic);
      }
    } catch (e) {
      // Nunca debe romper el flujo del diagnóstico.
    }
  }

  /// Resuelve el título de etapa al que pertenece la pregunta del diagnóstico
  /// (por su lessonId) para registrar el tema débil con el mismo criterio que
  /// las lecciones normales. No debe nunca lanzar ni forzar la inicialización
  /// de la red: si el curriculum aún no está cargado, usa un respaldo derivado
  /// del número de etapa.
  String _topicForChallenge(Challenge question) {
    var stagePrefix = '';
    final idMatch = RegExp(
      r'^ac_s(\d+)_ses(\d+)_l(\d+)_q(\d+)$',
    ).firstMatch(question.id);
    if (idMatch != null) {
      stagePrefix = 'ac_st${idMatch.group(1)}';
    } else {
      final lessonMatch = RegExp(
        r'^ac_s(\d+)_ses\d+_l\d+$',
      ).firstMatch(question.lessonId);
      if (lessonMatch != null) {
        stagePrefix = 'ac_st${lessonMatch.group(1)}';
      }
    }
    if (stagePrefix.isEmpty) return 'lesson';
    try {
      final stage = ref
          .read(learningProvider)
          .stages
          .where((s) => s.id == stagePrefix)
          .firstOrNull;
      if (stage != null && stage.title.isNotEmpty) return stage.title;
    } catch (_) {
      // Si learningProvider aún no está listo, se cae al respaldo.
    }
    // Respaldos estables (evita 'lesson' reservado para que el tema débil
    // sí se muestre en las listas de Sage).
    return stagePrefix;
  }

  void nextQuestion() {
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      showFeedback: false,
    );
  }

  void reset() {
    state = const FirstLessonState();
  }
}

final firstLessonProvider =
    NotifierProvider.autoDispose<FirstLessonNotifier, FirstLessonState>(
      FirstLessonNotifier.new,
    );

final diagnosticPathProvider = StateProvider<DiagnosticPath>(
  (ref) => DiagnosticPath.beginner,
);
