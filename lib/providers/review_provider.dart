import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'prefs_provider.dart';
import 'package:sagen/services/app_logger.dart';

class ReviewState {
  final Map<String, int> questionFailures;
  final Map<String, String> questionTopics;
  final Map<String, int> topicScores;
  final int totalReviews;
  final Map<String, double> easeFactor;
  final Map<String, int> interval;
  final Map<String, int> repetition;
  final Map<String, DateTime> nextReviewDate;

  const ReviewState({
    this.questionFailures = const {},
    this.questionTopics = const {},
    this.topicScores = const {},
    this.totalReviews = 0,
    this.easeFactor = const {},
    this.interval = const {},
    this.repetition = const {},
    this.nextReviewDate = const {},
  });

  ReviewState copyWith({
    Map<String, int>? questionFailures,
    Map<String, String>? questionTopics,
    Map<String, int>? topicScores,
    int? totalReviews,
    Map<String, double>? easeFactor,
    Map<String, int>? interval,
    Map<String, int>? repetition,
    Map<String, DateTime>? nextReviewDate,
  }) {
    return ReviewState(
      questionFailures: questionFailures ?? this.questionFailures,
      questionTopics: questionTopics ?? this.questionTopics,
      topicScores: topicScores ?? this.topicScores,
      totalReviews: totalReviews ?? this.totalReviews,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetition: repetition ?? this.repetition,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
}

class ReviewNotifier extends Notifier<ReviewState> {
  late final StorageService _storage;

  static const _keyQuestionFailures = 'review_q_fails';
  static const _keyQuestionTopics = 'review_q_topics';
  static const _keyTopicScores = 'review_t_scores';
  static const _keyTotalReviews = 'review_total';
  static const _keyEaseFactor = 'review_ease_factor';
  static const _keyInterval = 'review_interval';
  static const _keyRepetition = 'review_repetition';
  static const _keyNextReviewDate = 'review_next_date';

  static const weakThreshold = 3;
  static const _maxScore = 10;
  static const _defaultEaseFactor = 2.5;
  static const _minEaseFactor = 1.3;

  @override
  ReviewState build() {
    _storage = StorageService(ref.read(prefsProvider));
    _load();
    return state;
  }

  Map<String, int> get topicScores => Map.unmodifiable(state.topicScores);
  bool get hasWeakTopics =>
      state.topicScores.values.any((s) => s > weakThreshold);
  bool get hasReviewableQuestions =>
      state.questionFailures.isNotEmpty ||
      getQuestionsDueForReview().isNotEmpty;
  List<String> get weakTopics => state.topicScores.entries
      .where((e) => e.value > weakThreshold)
      .map((e) => e.key)
      .toList();
  int get totalReviews => state.totalReviews;
  List<String> get failedQuestionIds {
    final ids = <String>{...state.questionFailures.keys};
    ids.addAll(getQuestionsDueForReview().map((e) => e));
    return ids.toList();
  }

  String? getTopicForQuestion(String questionId) =>
      state.questionTopics[questionId];
  int failureCountFor(String questionId) =>
      state.questionFailures[questionId] ?? 0;
  int scoreFor(String topic) => state.topicScores[topic] ?? 0;

  List<String> getQuestionsDueForReview() {
    final now = DateTime.now();
    final due = <MapEntry<String, DateTime>>[];

    for (final entry in state.nextReviewDate.entries) {
      if (entry.value.isBefore(now)) {
        due.add(entry);
      }
    }

    due.sort((a, b) => a.value.compareTo(b.value));
    return due.take(10).map((e) => e.key).toList();
  }

  void _applySm2Correct(String questionId, int quality) {
    final ef = Map<String, double>.from(state.easeFactor);
    final iv = Map<String, int>.from(state.interval);
    final rep = Map<String, int>.from(state.repetition);
    final next = Map<String, DateTime>.from(state.nextReviewDate);

    final currentEf = ef[questionId] ?? _defaultEaseFactor;
    final currentRep = rep[questionId] ?? 0;
    final currentIv = iv[questionId] ?? 0;

    double newEf;
    int newRep;
    int newIv;

    if (quality >= 3) {
      newRep = currentRep + 1;
      if (currentRep == 0) {
        newIv = 1;
      } else if (currentRep == 1) {
        newIv = 6;
      } else {
        newIv = (currentIv * currentEf).round();
      }
      newEf = currentEf + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    } else {
      newRep = 0;
      newIv = 1;
      newEf = currentEf - 0.2;
    }

    if (newEf < _minEaseFactor) newEf = _minEaseFactor;

    ef[questionId] = newEf;
    rep[questionId] = newRep;
    iv[questionId] = newIv;
    next[questionId] = DateTime.now().add(Duration(days: newIv));

    state = state.copyWith(
      easeFactor: ef,
      interval: iv,
      repetition: rep,
      nextReviewDate: next,
    );
  }

  void _applySm2Incorrect(String questionId) {
    final ef = Map<String, double>.from(state.easeFactor);
    final iv = Map<String, int>.from(state.interval);
    final rep = Map<String, int>.from(state.repetition);
    final next = Map<String, DateTime>.from(state.nextReviewDate);

    final currentEf = ef[questionId] ?? _defaultEaseFactor;

    final newEf = max(_minEaseFactor, currentEf - 0.2);

    ef[questionId] = newEf;
    rep[questionId] = 0;
    iv[questionId] = 1;
    next[questionId] = DateTime.now().add(const Duration(days: 1));

    state = state.copyWith(
      easeFactor: ef,
      interval: iv,
      repetition: rep,
      nextReviewDate: next,
    );
  }

  void recordMistake(String questionId, String topic) {
    final failures = Map<String, int>.from(state.questionFailures);
    final topics = Map<String, String>.from(state.questionTopics);
    final scores = Map<String, int>.from(state.topicScores);

    failures[questionId] = (failures[questionId] ?? 0) + 1;
    topics[questionId] = topic;
    scores[topic] = (scores[topic] ?? 0) + 1;
    if (scores[topic]! > _maxScore) scores[topic] = _maxScore;

    state = state.copyWith(
      questionFailures: failures,
      questionTopics: topics,
      topicScores: scores,
    );
    _applySm2Incorrect(questionId);
    _save();
  }

  void recordCorrect(String questionId) {
    final topic = state.questionTopics[questionId];
    final failures = Map<String, int>.from(state.questionFailures);
    final topics = Map<String, String>.from(state.questionTopics);
    final scores = Map<String, int>.from(state.topicScores);

    if (failures.containsKey(questionId)) {
      final count = failures[questionId]! - 1;
      if (count <= 0) {
        failures.remove(questionId);
        topics.remove(questionId);
      } else {
        failures[questionId] = count;
      }
    }

    if (topic != null && scores.containsKey(topic)) {
      final score = scores[topic]! - 1;
      if (score <= 0) {
        scores.remove(topic);
      } else {
        scores[topic] = score;
      }
    }

    state = state.copyWith(
      questionFailures: failures,
      questionTopics: topics,
      topicScores: scores,
    );
    _applySm2Correct(questionId, 5);
    _save();
  }

  void markReviewCompleted() {
    state = state.copyWith(totalReviews: state.totalReviews + 1);
    _save();
  }

  void reload() {
    _load();
  }

  void _save() {
    final s = state;
    _storage.setJson(
      _keyQuestionFailures,
      s.questionFailures.map((k, v) => MapEntry<String, dynamic>(k, v)),
    );
    _storage.setJson(_keyQuestionTopics, s.questionTopics);
    _storage.setJson(
      _keyTopicScores,
      s.topicScores.map((k, v) => MapEntry<String, dynamic>(k, v)),
    );
    _storage.setInt(_keyTotalReviews, s.totalReviews);
    _storage.setJson(
      _keyEaseFactor,
      s.easeFactor.map((k, v) => MapEntry<String, dynamic>(k, v)),
    );
    _storage.setJson(
      _keyInterval,
      s.interval.map((k, v) => MapEntry<String, dynamic>(k, v)),
    );
    _storage.setJson(
      _keyRepetition,
      s.repetition.map((k, v) => MapEntry<String, dynamic>(k, v)),
    );
    _storage.setJson(
      _keyNextReviewDate,
      s.nextReviewDate.map(
        (k, v) => MapEntry<String, dynamic>(k, v.toIso8601String()),
      ),
    );
  }

  void _load() {
    try {
      final qf = _storage.getJson(_keyQuestionFailures);
      final qfMap = qf != null
          ? qf.map(
              (k, v) => MapEntry(
                k,
                v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0),
              ),
            )
          : <String, int>{};

      final qt = _storage.getJson(_keyQuestionTopics);
      final qtMap = qt?.cast<String, String>() ?? <String, String>{};

      final ts = _storage.getJson(_keyTopicScores);
      final tsMap = ts != null
          ? ts.map(
              (k, v) => MapEntry(
                k,
                v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0),
              ),
            )
          : <String, int>{};

      final total = _storage.getInt(_keyTotalReviews);

      final efRaw = _storage.getJson(_keyEaseFactor);
      final efMap = efRaw != null
          ? efRaw.map(
              (k, v) => MapEntry(
                k,
                v is num
                    ? v.toDouble()
                    : (double.tryParse(v.toString()) ?? _defaultEaseFactor),
              ),
            )
          : <String, double>{};

      final ivRaw = _storage.getJson(_keyInterval);
      final ivMap = ivRaw != null
          ? ivRaw.map(
              (k, v) => MapEntry(
                k,
                v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0),
              ),
            )
          : <String, int>{};

      final repRaw = _storage.getJson(_keyRepetition);
      final repMap = repRaw != null
          ? repRaw.map(
              (k, v) => MapEntry(
                k,
                v is num ? v.toInt() : (int.tryParse(v.toString()) ?? 0),
              ),
            )
          : <String, int>{};

      final nrRaw = _storage.getJson(_keyNextReviewDate);
      final nrMap = <String, DateTime>{};
      if (nrRaw != null) {
        for (final entry in nrRaw.entries) {
          final parsed = DateTime.tryParse(entry.value?.toString() ?? '');
          if (parsed != null) {
            nrMap[entry.key] = parsed;
          }
        }
      }

      state = ReviewState(
        questionFailures: qfMap,
        questionTopics: qtMap,
        topicScores: tsMap,
        totalReviews: total,
        easeFactor: efMap,
        interval: ivMap,
        repetition: repMap,
        nextReviewDate: nrMap,
      );
    } catch (_) {
      AppLogger().warning('ReviewProvider: failed to load review state');
      state = const ReviewState();
    }
  }
}
