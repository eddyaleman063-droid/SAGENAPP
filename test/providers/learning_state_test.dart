import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/learning_provider.dart';

Stage _stage(String id, {required int total, required int completed}) {
  return Stage(
    id: id,
    title: 'T$id',
    subtitle: 'S$id',
    accent: Colors.blue,
    icon: Icons.school_rounded,
    lessons: List.generate(
      total,
      (i) => Lesson(
        id: '${id}_l${i + 1}',
        title: 'L${i + 1}',
        subtitle: 'S${i + 1}',
        challenges: const [],
        completed: i < completed,
        correctAnswers: i < completed ? 3 : 0,
        totalQuestions: i < completed ? 3 : 0,
      ),
    ),
  );
}

void main() {
  group('LearningState', () {
    test('overallProgress es 0 con stages vacios', () {
      const state = LearningState();
      expect(state.overallProgress, 0);
    });

    test('overallProgress es 0 sin lessons', () {
      const state = LearningState();
      expect(state.copyWith().overallProgress, 0);
    });

    test('overallProgress calcula la fraccion de lecciones completadas', () {
      final stages = [
        _stage('s1', total: 4, completed: 1),
        _stage('s2', total: 4, completed: 4),
      ];
      final state = LearningState(stages: stages);
      expect(state.overallProgress, 5 / 8);
    });

    test('levelProgress refleja el progreso dentro del nivel', () {
      const state = LearningState(
        totalXpEarned: 150,
        currentLevel: 2,
        xp: 50,
      );
      expect(state.nextLevelXp, 100);
      expect(state.levelProgress, 0.5);
    });

    test('levelProgress clampa a 1.0 cuando supera el nivel', () {
      const maxed = LearningState(totalXpEarned: 0, currentLevel: 1, xp: 0);
      expect(maxed.levelProgress, 0.0);
      const overshoot = LearningState(
        totalXpEarned: 250,
        currentLevel: 2,
        xp: 150,
      );
      expect(overshoot.levelProgress, 1.0);
    });

    test('copyWith mantiene campos y resetea errorMessage con sentinel', () {
      const state = LearningState(
        xp: 10,
        isLoading: true,
        errorMessage: 'err',
        achievements: ['a'],
      );
      final cleared = state.copyWith(
        errorMessage: () => null,
        achievements: () => ['a', 'b'],
      );
      expect(cleared.errorMessage, isNull);
      expect(cleared.achievements, ['a', 'b']);
      expect(cleared.xp, 10);
    });
  });
}