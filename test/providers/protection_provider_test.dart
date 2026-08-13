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
  });
}
