import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning/challenge.dart';
import '../services/app_logger.dart';
import '../services/question_bank.dart';
import 'providers.dart';

enum SessionPhase { intro, playing, feedback, gameOver, completed }

class SessionState {
  final Challenge? currentChallenge;
  final List<Challenge> challenges;
  final int currentIndex;
  final int lives;
  final int correctCount;
  final int wrongCount;
  final int totalQuestions;
  final int feedbackSelected;
  final bool feedbackCorrect;
  final SessionPhase phase;

  const SessionState({
    this.currentChallenge,
    this.challenges = const [],
    this.currentIndex = 0,
    this.lives = 3,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.totalQuestions = 0,
    this.feedbackSelected = -1,
    this.feedbackCorrect = false,
    this.phase = SessionPhase.intro,
  });

  SessionState copyWith({
    Challenge? Function()? currentChallenge,
    List<Challenge> Function()? challenges,
    int? currentIndex,
    int? lives,
    int? correctCount,
    int? wrongCount,
    int? totalQuestions,
    int? feedbackSelected,
    bool? feedbackCorrect,
    SessionPhase? phase,
  }) {
    return SessionState(
      currentChallenge: currentChallenge != null
          ? currentChallenge()
          : this.currentChallenge,
      challenges: challenges != null ? challenges() : this.challenges,
      currentIndex: currentIndex ?? this.currentIndex,
      lives: lives ?? this.lives,
      correctCount: correctCount ?? this.correctCount,
      wrongCount: wrongCount ?? this.wrongCount,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      feedbackSelected: feedbackSelected ?? this.feedbackSelected,
      feedbackCorrect: feedbackCorrect ?? this.feedbackCorrect,
      phase: phase ?? this.phase,
    );
  }

  double get progress =>
      totalQuestions > 0 ? completedSegments / totalQuestions : 0;
  int get segmentCount => totalQuestions;
  int get completedSegments => totalQuestions <= 0
      ? 0
      : (currentIndex + (phase == SessionPhase.feedback ? 1 : 0)).clamp(
          0,
          totalQuestions,
        );
  double get accuracy => correctCount + wrongCount > 0
      ? correctCount / (correctCount + wrongCount)
      : 0;
  bool get isPerfect => wrongCount == 0 && correctCount == totalQuestions;
  int get earnedXp {
    const xpPerCorrect = 15;
    const perfectBonusXp = 30;
    final base = correctCount * xpPerCorrect;
    final bonus = isPerfect ? perfectBonusXp : 0;
    return base + bonus;
  }
}

class SessionNotifier extends AutoDisposeNotifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  Challenge? get currentChallenge => state.currentChallenge;
  List<Challenge> get challenges => List.unmodifiable(state.challenges);
  int get currentIndex => state.currentIndex;
  int get lives => state.lives;
  int get correctCount => state.correctCount;
  int get wrongCount => state.wrongCount;
  int get totalQuestions => state.totalQuestions;
  int get feedbackSelected => state.feedbackSelected;
  bool get feedbackCorrect => state.feedbackCorrect;
  SessionPhase get phase => state.phase;
  double get progress => state.progress;
  int get segmentCount => state.segmentCount;
  int get completedSegments => state.completedSegments;
  double get accuracy => state.accuracy;
  bool get isPerfect => state.isPerfect;
  int get earnedXp => state.earnedXp;

  String _lastStageId = '';
  String _lastLessonId = '';

  String get _progressKey => 'lesson_progress_$_lastStageId/$_lastLessonId';

  /// Si hay una lección a medias guardada (mismo stage/lección, menos de 30
  /// minutos y con alguna pregunta sin responder) que la pantalla puede ofrecer
  /// reanudar. Lee de prefs sin cambiar el estado activo.
  Future<bool> hasResumableProgress(String stageId, String lessonId) async {
    try {
      final prefs = ref.read(prefsProvider);
      final data = prefs.getStringList('lesson_progress_$stageId/$lessonId');
      if (data == null || data.length < 6) return false;
      final savedStageId = data[0];
      final savedTime = DateTime.tryParse(data[4]);
      final savedFirstUnansweredId = data[5].trim();
      if (savedStageId != stageId || savedFirstUnansweredId.isEmpty) {
        return false;
      }
      if (savedTime != null &&
          DateTime.now().difference(savedTime).inMinutes > 30) {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> startSession(
    String stageId,
    String lessonId, {
    int count = 15,
    bool resume = false,
  }) async {
    _lastStageId = stageId;
    _lastLessonId = lessonId;
    var challenges = await QuestionBank.instance.getQuestionsForLesson(
      stageId,
      lessonId,
      count: count,
    );
    if (challenges.isEmpty) {
      challenges = await QuestionBank.instance.getQuestionsForLesson(
        stageId,
        lessonId,
        count: 3,
      );
    }

    // Reanudación: el orden de preguntas puede variar por intento, así que el
    // cursor guardado se localiza POR ID de la primera pregunta sin responder y
    // se continúa AHÍ MISMO (nunca se salta ni se repite una pregunta).
    //
    // El marcador (correct/wrong) se restaura desde lo GUARDADO (contadores
    // reales de la sesión previa), NO desde la posición del cursor en el nuevo
    // orden, porque el orden varía por intento y esa posición no equivale al
    // nº de preguntas respondidas.
    if (resume) {
      final resumeInfo = await _loadProgress(stageId, challenges);
      if (resumeInfo != null &&
          resumeInfo.savedAnswered > 0 &&
          resumeInfo.resumeAt < challenges.length) {
        state = state.copyWith(
          challenges: () => challenges,
          totalQuestions: challenges.length,
          currentIndex: resumeInfo.resumeAt,
          lives: 3,
          correctCount: resumeInfo.correctCount,
          wrongCount: resumeInfo.wrongCount,
          feedbackSelected: -1,
          feedbackCorrect: false,
          phase: SessionPhase.playing,
          currentChallenge: () => challenges[resumeInfo.resumeAt],
        );
        return;
      }
    }

    final totalQuestions = challenges.length;
    state = state.copyWith(
      challenges: () => challenges,
      totalQuestions: totalQuestions,
      currentIndex: 0,
      lives: 3,
      correctCount: 0,
      wrongCount: 0,
      feedbackSelected: -1,
      feedbackCorrect: false,
      phase: SessionPhase.playing,
      currentChallenge: () => challenges.isNotEmpty ? challenges[0] : null,
    );
  }

  /// Devuelve el índice (en [challenges]) de la PRIMERA pregunta sin responder
  /// y los contadores reales de la sesión previa (respondidas/exactas/falladas),
  /// si hay una lección reanudable válida; si no, null. Valida stage, ventana
  /// temporal y que el set de ids coincida (ordenable por intento).
  ///
  /// [savedAnswered] es el nº de preguntas respondidas en la sesión previa
  /// (contador, no índice de un orden concreto). [wrongCount] se deriva de esos
  /// contadores, nunca de la posición del cursor, pues el orden varía por intento.
  Future<({int resumeAt, int correctCount, int wrongCount, int savedAnswered})?>
  _loadProgress(String stageId, List<Challenge> challenges) async {
    try {
      final prefs = ref.read(prefsProvider);
      final data = prefs.getStringList(_progressKey);
      if (data == null || data.length < 6) return null;
      final savedStageId = data[0];
      final savedAnswered = int.tryParse(data[1]) ?? 0;
      final savedCorrect = int.tryParse(data[2]) ?? 0;
      final savedIds = data[3].split(',');
      final savedTime = DateTime.tryParse(data[4]);
      final savedFirstUnansweredId = data[5].trim();

      if (savedStageId != stageId) return null;
      if (savedTime != null &&
          DateTime.now().difference(savedTime).inMinutes > 30) {
        await _clearProgress();
        return null;
      }
      final currentIds = challenges.map((c) => c.id).toList();
      final savedSet = savedIds.toSet();
      if (savedIds.length != currentIds.length ||
          savedSet.length != currentIds.length ||
          !savedSet.containsAll(currentIds)) {
        await _clearProgress();
        return null;
      }
      if (savedFirstUnansweredId.isEmpty) {
        await _clearProgress();
        return null;
      }
      final resumeAt = currentIds.indexOf(savedFirstUnansweredId);
      if (resumeAt < 0) {
        await _clearProgress();
        return null;
      }
      var wrongCount = savedAnswered - savedCorrect;
      if (wrongCount < 0) wrongCount = 0;
      return (
        resumeAt: resumeAt,
        correctCount: savedCorrect,
        wrongCount: wrongCount,
        savedAnswered: savedAnswered,
      );
    } catch (e, stack) {
      AppLogger().error('SessionNotifier._loadProgress failed', e, stack);
      return null;
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = ref.read(prefsProvider);
      final ids = state.challenges.map((c) => c.id).toList();
      final firstUnansweredIndex =
          state.currentIndex + (state.phase == SessionPhase.feedback ? 1 : 0);
      final firstUnansweredId = firstUnansweredIndex < ids.length
          ? ids[firstUnansweredIndex]
          : '';
      await prefs.setStringList(_progressKey, [
        _lastStageId,
        firstUnansweredIndex.toString(),
        state.correctCount.toString(),
        ids.join(','),
        DateTime.now().toIso8601String(),
        firstUnansweredId,
      ]);
    } catch (e, stack) {
      AppLogger().warning('SessionNotifier._saveProgress failed', e, stack);
    }
  }

  Future<void> _clearProgress() async {
    try {
      final prefs = ref.read(prefsProvider);
      await prefs.remove(_progressKey);
    } catch (e, stack) {
      AppLogger().warning('SessionNotifier._clearProgress failed', e, stack);
    }
  }

  /// Elimina TODAS las lecciones a medias guardadas (cualquier stage/lección).
  /// Se usa al cerrar sesión para que un usuario no vea el progreso de repaso
  /// de otro usuario en el mismo dispositivo.
  Future<void> clearAllProgress() async {
    try {
      final prefs = ref.read(prefsProvider);
      final keys = prefs.getKeys().where(
        (k) => k.startsWith('lesson_progress_'),
      );
      for (final key in keys.toList()) {
        await prefs.remove(key);
      }
      _lastStageId = '';
      _lastLessonId = '';
      state = const SessionState();
    } catch (e, stack) {
      AppLogger().warning('SessionNotifier.clearAllProgress failed', e, stack);
    }
  }

  void submitAnswer(int selectedIndex, {String? topicForReview}) {
    if (state.phase != SessionPhase.playing || state.currentChallenge == null) {
      return;
    }
    final challenge = state.currentChallenge;
    if (challenge == null) return;
    final validCorrectIndex = challenge.effectiveCorrectIndex;
    final feedbackCorrect = selectedIndex == validCorrectIndex;
    final newLives = feedbackCorrect
        ? state.lives
        : (state.lives > 0 ? state.lives - 1 : 0);
    state = state.copyWith(
      feedbackSelected: selectedIndex,
      feedbackCorrect: feedbackCorrect,
      correctCount: feedbackCorrect
          ? state.correctCount + 1
          : state.correctCount,
      wrongCount: feedbackCorrect ? state.wrongCount : state.wrongCount + 1,
      lives: newLives,
      phase: SessionPhase.feedback,
    );
    _recordReviewFeedback(challenge, feedbackCorrect, topicForReview);
    _saveProgress();
  }

  /// Alimenta el sistema de repaso (SM-2) desde el flujo de sesión de
  /// lección: cada acierto programa la siguiente repetición y cada fallo
  /// registra el tema débil. Espejo del comportamiento de `QuizSession`
  /// (H-04) para que el Repaso inteligente funcione también en el flujo
  /// principal de lecciones.
  void _recordReviewFeedback(
    Challenge challenge,
    bool correct,
    String? topicForReview,
  ) {
    try {
      if (correct) {
        ref.read(reviewProvider.notifier).recordCorrect(challenge.id);
      } else {
        final topic = (topicForReview == null || topicForReview.isEmpty)
            ? 'lesson'
            : topicForReview;
        ref.read(reviewProvider.notifier).recordMistake(challenge.id, topic);
      }
    } catch (e, stack) {
      AppLogger().error(
        'SessionNotifier: failed to record review feedback',
        e,
        stack,
      );
    }
  }

  void onFeedbackDismissed() {
    if (state.lives <= 0) {
      state = state.copyWith(phase: SessionPhase.gameOver);
    }
  }

  void nextQuestion() {
    // Hardening: solo se avanza desde la fase feedback (tras responder) o se
    // resuelve el fin de sesión desde gameOver. Un doble toque en el mismo
    // frame no puede saltar dos preguntas (la 2ª llamada ve phase==playing y
    // es no-op), igual que hace QuizSession con su bandera _transitioning.
    if (state.phase != SessionPhase.feedback &&
        state.phase != SessionPhase.gameOver) {
      return;
    }
    if (state.lives <= 0) {
      state = state.copyWith(phase: SessionPhase.gameOver);
      _clearProgress();
      return;
    }
    if (state.currentIndex + 1 >= state.totalQuestions) {
      state = state.copyWith(phase: SessionPhase.completed);
      _clearProgress();
      return;
    }
    final nextIndex = state.currentIndex + 1;
    state = state.copyWith(
      currentIndex: nextIndex,
      currentChallenge: () => state.challenges[nextIndex],
      feedbackSelected: -1,
      feedbackCorrect: false,
      phase: SessionPhase.playing,
    );
    _saveProgress();
  }

  void resetSession() {
    _lastStageId = '';
    _lastLessonId = '';
    _clearProgress();
    state = const SessionState();
  }

  /// Descarta la lección a medias guardada (sin tocar el estado activo), para
  /// que al elegir "Empezar de nuevo" no resucite al re-entrar.
  Future<void> discardResume(String stageId, String lessonId) async {
    try {
      final prefs = ref.read(prefsProvider);
      await prefs.remove('lesson_progress_$stageId/$lessonId');
    } catch (e, stack) {
      AppLogger().warning('SessionNotifier.discardResume failed', e, stack);
    }
  }

  void retry() {
    startSession(_lastStageId, _lastLessonId, count: state.totalQuestions);
  }
}
