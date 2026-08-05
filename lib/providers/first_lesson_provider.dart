import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning/challenge.dart';
import '../models/learning/quiz_score.dart';
import '../services/question_bank.dart';

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
  double get accuracy => (correctCount + wrongCount) > 0 ? correctCount / (correctCount + wrongCount) : 0;
  int get earnedXp => QuizScoreCalculator(
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        timeSpentSeconds: 0,
      ).xp;
  Duration? get elapsedTime => startTime != null ? DateTime.now().difference(startTime ?? DateTime.now()) : null;
  Challenge? get currentChallenge => currentIndex < questions.length ? questions[currentIndex] : null;

  int get recommendedStage {
    if (path == DiagnosticPath.beginner) return 1;
    return accuracy >= 0.5 ? 2 : 1;
  }
}

class FirstLessonNotifier extends AutoDisposeNotifier<FirstLessonState> {
  final _random = Random();

  @override
  FirstLessonState build() => const FirstLessonState();

  Future<void> startLesson({DiagnosticPath path = DiagnosticPath.beginner}) async {
    final questionCount = path == DiagnosticPath.beginner ? 30 : 60;

    List<Challenge> allQuestions = [];

    if (path == DiagnosticPath.beginner) {
      allQuestions = [
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st1', 'default', count: 20),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st1', 'ac_s1_ses1_l1', count: 10),
      ];
    } else {
      allQuestions = [
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st1', 'default', count: 15),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st1', 'ac_s1_ses1_l1', count: 10),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st2', 'ac_s2_ses1_l1', count: 10),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st3', 'ac_s3_ses1_l1', count: 10),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st4', 'ac_s4_ses1_l1', count: 5),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st5', 'ac_s5_ses1_l1', count: 5),
        ...await QuestionBank.instance.getQuestionsForLesson('ac_st6', 'ac_s6_ses1_l1', count: 5),
      ];
    }

    final shuffled = List<Challenge>.from(allQuestions)..shuffle(_random);
    final selected = shuffled.take(questionCount).toList();

    state = FirstLessonState(
      questions: selected,
      startTime: DateTime.now(),
      path: path,
    );
  }

  void submitAnswer(int selectedIndex) {
    final question = state.currentChallenge;
    if (question == null || state.showFeedback) return;

    final correct = selectedIndex == question.correctIndex;
    state = state.copyWith(
      correctCount: correct ? state.correctCount + 1 : state.correctCount,
      wrongCount: correct ? state.wrongCount : state.wrongCount + 1,
      showFeedback: true,
      selectedAnswer: selectedIndex,
      answeredCorrectly: correct,
    );
  }

  void nextQuestion() {
    if (state.currentIndex + 1 >= state.totalQuestions) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        showFeedback: false,
      );
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      showFeedback: false,
    );
  }

  void reset() {
    state = const FirstLessonState();
  }
}

final firstLessonProvider = NotifierProvider.autoDispose<FirstLessonNotifier, FirstLessonState>(
  FirstLessonNotifier.new,
);

final diagnosticPathProvider = StateProvider.autoDispose<DiagnosticPath>((ref) => DiagnosticPath.beginner);
