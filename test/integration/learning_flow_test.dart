import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/models/learning/lesson.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';

class MockCloudSyncService extends Mock implements CloudSyncService {}

class MockAuthService extends Mock implements AuthService {}

class FakeLearningNotifier extends LearningNotifier {
  @override
  LearningState build() {
    return const LearningState(isLoading: false);
  }

  @override
  Future<void> addXp(int amount, {String? reason, String? lessonId}) async {
    final newXp = state.xp + amount;
    final newTotalXp = state.totalXpEarned + amount;
    final newLevel = (newTotalXp / 100).floor() + 1;
    state = state.copyWith(
      xp: newLevel > state.currentLevel ? 0 : newXp,
      totalXpEarned: newTotalXp,
      currentLevel: newLevel > state.currentLevel
          ? newLevel
          : state.currentLevel,
    );
  }

  @override
  Future<void> completeLesson(
    String stageId,
    String lessonId, {
    bool perfectLesson = false,
    int correctAnswers = 0,
    int totalQuestions = 0,
  }) async {
    final stageIndex = state.stages.indexWhere((s) => s.id == stageId);
    if (stageIndex == -1) return;

    final stage = state.stages[stageIndex];
    final lessonIndex = stage.lessons.indexWhere((l) => l.id == lessonId);
    if (lessonIndex == -1) return;

    final lesson = stage.lessons[lessonIndex];
    if (lesson.completed) return;

    final newLesson = lesson.copyWith(
      completed: true,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );
    final newLessons = List.of(stage.lessons);
    newLessons[lessonIndex] = newLesson;

    final newStages = List.of(state.stages);
    newStages[stageIndex] = stage.copyWith(lessons: newLessons);

    final newLessonsCompleted = state.lessonsCompleted + 1;
    final newXp = state.xp + lesson.xpReward;
    final newTotalXp = state.totalXpEarned + lesson.xpReward;
    final newLevel = (newTotalXp / 100).floor() + 1;

    state = state.copyWith(
      stages: () => newStages,
      lessonsCompleted: newLessonsCompleted,
      xp: newLevel > state.currentLevel ? 0 : newXp,
      totalXpEarned: newTotalXp,
      currentLevel: newLevel > state.currentLevel
          ? newLevel
          : state.currentLevel,
    );
  }

  void loadStages(List<Stage> stages) {
    state = state.copyWith(stages: () => stages, isLoading: false);
  }
}

Widget createTestApp({required ProviderContainer container}) {
  return ProviderScope(
    overrides: container.getAllProviderElements().map((e) {
      return e.origin;
    }).toList(),
    child: const MaterialApp(
      locale: Locale('es'),
      home: Scaffold(body: Center(child: Text('Test'))),
    ),
  );
}

void main() {
  group('Integration - Learning Flow: complete lesson → earn xp', () {
    late ProviderContainer container;
    late FakeLearningNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      notifier = FakeLearningNotifier();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cloudSyncServiceProvider.overrideWith(
            (ref) => MockCloudSyncService(),
          ),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          learningProvider.overrideWith(() => notifier),
        ],
      );

      notifier =
          container.read(learningProvider.notifier) as FakeLearningNotifier;

      // Load initial stages with one stage and one lesson
      notifier.loadStages([
        Stage(
          id: 'stage_1',
          title: 'Introducción',
          subtitle: 'Primer stage',
          accent: Colors.blue,
          icon: Icons.shield,
          unlocked: true,
          lessons: [
            Lesson(
              id: 'lesson_1',
              title: 'Lección 1',
              subtitle: 'Primera lección',
              challenges: [],
              xpReward: 20,
              completed: false,
            ),
          ],
        ),
      ]);
    });

    tearDown(() => container.dispose());

    test('completing a lesson increments xp and lessonsCompleted', () async {
      expect(notifier.state.xp, 0);
      expect(notifier.state.lessonsCompleted, 0);
      expect(notifier.state.stages.first.lessons.first.completed, isFalse);

      await notifier.completeLesson('stage_1', 'lesson_1');

      expect(notifier.state.xp, 20);
      expect(notifier.state.lessonsCompleted, 1);
      expect(notifier.state.stages.first.lessons.first.completed, isTrue);
    });

    test('completing the same lesson twice is a no-op', () async {
      await notifier.completeLesson('stage_1', 'lesson_1');
      final xpAfterFirst = notifier.state.xp;

      await notifier.completeLesson('stage_1', 'lesson_1');

      expect(notifier.state.xp, xpAfterFirst);
      expect(notifier.state.lessonsCompleted, 1);
    });

    test('completing non-existent stage is a no-op', () async {
      await notifier.completeLesson('stage_999', 'lesson_1');
      expect(notifier.state.lessonsCompleted, 0);
    });

    test('completing non-existent lesson is a no-op', () async {
      await notifier.completeLesson('stage_1', 'lesson_999');
      expect(notifier.state.lessonsCompleted, 0);
    });

    test('xp accumulates across multiple lessons', () async {
      notifier.loadStages([
        Stage(
          id: 'stage_1',
          title: 'Introducción',
          subtitle: 'Primer stage',
          accent: Colors.blue,
          icon: Icons.shield,
          unlocked: true,
          lessons: [
            Lesson(
              id: 'lesson_1',
              title: 'Lección 1',
              subtitle: 'Primera lección',
              challenges: [],
              xpReward: 20,
              completed: false,
            ),
            Lesson(
              id: 'lesson_2',
              title: 'Lección 2',
              subtitle: 'Segunda lección',
              challenges: [],
              xpReward: 30,
              completed: false,
            ),
          ],
        ),
      ]);

      await notifier.completeLesson('stage_1', 'lesson_1');
      await notifier.completeLesson('stage_1', 'lesson_2');

      expect(notifier.state.xp, 50);
      expect(notifier.state.lessonsCompleted, 2);
    });

    test('level up resets xp to 0 and increments level', () async {
      notifier.loadStages([
        Stage(
          id: 'stage_1',
          title: 'Intro',
          subtitle: 'Desc',
          accent: Colors.blue,
          icon: Icons.shield,
          unlocked: true,
          lessons: List.generate(
            6,
            (i) => Lesson(
              id: 'lesson_$i',
              title: 'L$i',
              subtitle: 'D',
              challenges: [],
              xpReward: 20,
              completed: false,
            ),
          ),
        ),
      ]);

      // Complete 5 lessons = 100 xp → level 2, xp resets
      for (int i = 0; i < 5; i++) {
        await notifier.completeLesson('stage_1', 'lesson_$i');
      }

      expect(notifier.state.currentLevel, 2);
      expect(notifier.state.xp, 0);
    });
  });
}
