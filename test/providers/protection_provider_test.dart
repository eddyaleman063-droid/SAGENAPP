import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProtectionState', () {
    test('initial state has correct defaults', () {
      const state = ProtectionState();
      expect(state.score, 0);
      expect(state.totalQueries, 0);
      expect(state.totalAnalyses, 0);
      expect(state.totalCheckIns, 0);
      expect(state.learnedTopics, isEmpty);
      expect(state.habits, isEmpty);
    });

    test('copyWith updates only specified fields', () {
      const state = ProtectionState();
      final updated = state.copyWith(score: 50, totalCheckIns: 5);
      expect(updated.score, 50);
      expect(updated.totalCheckIns, 5);
      expect(updated.totalQueries, 0);
    });
  });

  group('ProtectionNotifier', () {
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
      final state = container.read(protectionProvider);
      expect(state.score, 0);
    });

    test('initial score and level', () {
      final notifier = container.read(protectionProvider.notifier);
      expect(notifier.score, 0);
      expect(notifier.level, 1);
    });

    test('registerCheckIn increments score and check-in count', () {
      final notifier = container.read(protectionProvider.notifier);
      notifier.registerCheckIn();
      final state = container.read(protectionProvider);
      expect(state.score, 10);
      expect(state.totalCheckIns, 1);
    });

    test('registerCheckIn updates habits map', () {
      final notifier = container.read(protectionProvider.notifier);
      notifier.registerCheckIn();
      final state = container.read(protectionProvider);
      expect(state.habits['checkins'], 1);
    });

    test('registerCheckIn provides insight on level up', () {
      final notifier = container.read(protectionProvider.notifier);
      for (int i = 0; i < 20; i++) {
        notifier.registerCheckIn();
      }
      final state = container.read(protectionProvider);
      expect(state.score, 200);
      expect(state.lastInsight, isNotEmpty);
    });

    test('multiple check-ins stack correctly', () {
      final notifier = container.read(protectionProvider.notifier);
      for (int i = 0; i < 3; i++) {
        notifier.registerCheckIn();
      }
      final state = container.read(protectionProvider);
      expect(state.totalCheckIns, 3);
      expect(state.score, 30);
      expect(state.habits['checkins'], 3);
    });

    test('persists score across container rebuild', () async {
      SharedPreferences.setMockInitialValues({
        'protection_score': 50,
        'protection_checkins': 5,
        'protection_habits': 'checkins:5',
      });
      final prefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      final state = newContainer.read(protectionProvider);
      expect(state.score, 50);
      expect(state.totalCheckIns, 5);
      expect(state.habits['checkins'], 5);
      newContainer.dispose();
    });

    test('getters expose level, name, progress and counters', () {
      final notifier = container.read(protectionProvider.notifier);
      expect(notifier.score, 0);
      expect(notifier.level, 1);
      expect(notifier.levelName, isNotEmpty);
      expect(notifier.progress, 0.0);
      expect(notifier.totalQueries, 0);
      expect(notifier.totalAnalyses, 0);
      expect(notifier.totalMissionsCompleted, 0);
      expect(notifier.totalCheckIns, 0);
      expect(notifier.learnedTopics, isEmpty);
      expect(notifier.habits, isEmpty);
      expect(notifier.lastInsight, isEmpty);
    });

    test('registerQuery adds score, habit and topic with level-up insight', () {
      final notifier = container.read(protectionProvider.notifier);
      notifier.registerQuery('phishing');
      notifier.registerQuery('phishing');
      notifier.registerQuery('passwords');
      final state = container.read(protectionProvider);
      expect(state.totalQueries, 3);
      expect(state.score, 45);
      expect(state.habits['queries'], 3);
      expect(state.learnedTopics, containsAll(['phishing', 'passwords']));
    });

    test('registerQuery without topic only counts the query', () {
      final notifier = container.read(protectionProvider.notifier);
      notifier.registerQuery(null);
      expect(container.read(protectionProvider).totalQueries, 1);
      expect(container.read(protectionProvider).score, 5);
      expect(container.read(protectionProvider).learnedTopics, isEmpty);
    });

    test('registerAnalysis adds score and analytics habit', () {
      final notifier = container.read(protectionProvider.notifier);
      for (int i = 0; i < 3; i++) {
        notifier.registerAnalysis();
      }
      final state = container.read(protectionProvider);
      expect(state.totalAnalyses, 3);
      expect(state.score, 24);
      expect(state.habits['analyses'], 3);
    });

    test('registerMissionCompleted adds score and missions habit', () {
      final notifier = container.read(protectionProvider.notifier);
      for (int i = 0; i < 2; i++) {
        notifier.registerMissionCompleted();
      }
      final state = container.read(protectionProvider);
      expect(state.totalMissionsCompleted, 2);
      expect(state.score, 60);
      expect(state.habits['missions'], 2);
    });

    test('generateInsight returns default encouragement when inactive', () {
      final notifier = container.read(protectionProvider.notifier);
      final insight = notifier.generateInsight();
      expect(insight, isNotEmpty);
      expect(container.read(protectionProvider).lastInsight, insight);
    });

    test('generateInsight returns progression insights for active users', () {
      final notifier = container.read(protectionProvider.notifier);
      for (int i = 0; i < 25; i++) {
        notifier.registerQuery('topics_$i');
      }
      for (int i = 0; i < 12; i++) {
        notifier.registerAnalysis();
      }
      for (int i = 0; i < 6; i++) {
        notifier.registerMissionCompleted();
      }
      for (int i = 0; i < 31; i++) {
        notifier.registerCheckIn();
      }
      final insight = notifier.generateInsight();
      expect(insight, isNotEmpty);
      expect(notifier.score, greaterThanOrEqualTo(500));
    });

    test('reload restores state from storage', () {
      final notifier = container.read(protectionProvider.notifier);
      notifier.registerQuery('phishing');
      notifier.registerAnalysis();
      final before = container.read(protectionProvider);
      expect(before.totalQueries, 1);
      expect(before.totalAnalyses, 1);
      // Force a reload from the same prefs (values already persisted).
      notifier.reload();
      final after = container.read(protectionProvider);
      expect(after.totalQueries, 1);
      expect(after.totalAnalyses, 1);
      expect(after.score, before.score);
    });

    test('reload picks up externally written preference values', () async {
      final notifier = container.read(protectionProvider.notifier);
      expect(notifier.score, 0);
      // Escribimos a mano en las prefs y recargamos para simular un cambio
      // externo entre sesiones.
      await container.read(prefsProvider).setInt('protection_score', 1200);
      notifier.reload();
      expect(container.read(protectionProvider).score, 1200);
    });
  });
}
