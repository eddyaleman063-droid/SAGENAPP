import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/repositories/sagen_pass_repository.dart';
import 'package:sagen/services/gamification_cloud_service.dart';
import 'package:sagen/services/chest_event_bus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

class _FakeRepo extends Mock implements SagenPassRepository {}

class _FakeCloud extends Mock implements GamificationCloudService {}

class _FakeChestBus extends Mock implements ChestEventBus {}

void main() {
  group('SagenPassNotifier', () {
    late ProviderContainer container;
    late _FakeRepo repo;
    late _FakeCloud cloud;
    late _FakeChestBus bus;
    late MockLearningNotifier learning;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = _FakeRepo();
      cloud = _FakeCloud();
      bus = _FakeChestBus();
      learning = MockLearningNotifier();

      when(() => repo.currentLevel).thenReturn(1);
      when(() => repo.currentSP).thenReturn(0);
      when(() => repo.claimedLevels).thenReturn(<int>[]);
      when(() => repo.seasonStart).thenReturn(DateTime(2026, 1, 1));
      when(() => repo.seasonDurationDays).thenReturn(90);
      when(() => repo.premium).thenReturn(false);
      when(() => repo.passChestsPending).thenReturn(<int>[]);
      when(() => repo.save(any(), any(), any(), any(), any())).thenReturn(null);
      when(() => repo.saveLevel(any())).thenReturn(null);
      when(() => repo.saveSP(any())).thenReturn(null);
      when(() => repo.saveClaimedLevels(any())).thenReturn(null);
      when(() => repo.savePassChestsPending(any())).thenReturn(null);

      when(() => cloud.claimPassReward(any())).thenAnswer((_) async => null);
      when(
        () => cloud.getSagenPassSeason(),
      ).thenAnswer((_) async => <String, dynamic>{});

      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          sagenPassRepositoryProvider.overrideWithValue(repo),
          gamificationCloudServiceProvider.overrideWithValue(cloud),
          chestEventBusProvider.overrideWithValue(bus),
          learningProvider.overrideWith(() => learning),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('build loads local state and defaults', () {
      final pass = container.read(sagenPassProvider);
      expect(pass.currentLevel, 1);
      expect(pass.currentSP, 0);
      expect(pass.claimedLevels, isEmpty);
      expect(pass.premium, isFalse);
    });

    test('build reconciles server-authoritative season data', () async {
      final fresh = DateTime.now().subtract(const Duration(days: 5));
      when(() => cloud.getSagenPassSeason()).thenAnswer(
        (_) async => <String, dynamic>{
          'seasonStart': fresh.toIso8601String(),
          'level': 7,
          'sp': 120,
          'claimed': <dynamic>[3, 6],
          'premium': true,
          'rotated': false,
        },
      );
      container.pump();
      await Future<void>.delayed(Duration.zero);
      container.read(sagenPassProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final pass = container.read(sagenPassProvider);
      expect(pass.currentLevel, 7);
      expect(pass.currentSP, 120);
      expect(pass.claimedLevels, [3, 6]);
      expect(pass.premium, isTrue);
    });

    test(
      'reconcile discards claimed/level when the server rotated the season',
      () async {
        when(() => cloud.getSagenPassSeason()).thenAnswer(
          (_) async => <String, dynamic>{
            'seasonStart': '2020-01-01T00:00:00.000',
            'level': 40,
            'sp': 800,
            'claimed': <dynamic>[10, 25],
            'premium': true,
            'rotated': true,
          },
        );
        container.pump();
        await Future<void>.delayed(Duration.zero);
        container.read(sagenPassProvider);
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        final pass = container.read(sagenPassProvider);
        expect(pass.currentLevel, 1);
        expect(pass.currentSP, 0);
        expect(pass.claimedLevels, isEmpty);
        expect(pass.seasonStart.year, DateTime.now().year);
      },
    );

    test('claimLevel returns null for already claimed levels', () async {
      when(() => repo.claimedLevels).thenReturn([1, 2]);
      when(() => repo.currentLevel).thenReturn(10);
      when(() => repo.currentSP).thenReturn(50);
      final result = await container
          .read(sagenPassProvider.notifier)
          .claimLevel(1);
      expect(result, isNull);
    });

    test('claimLevel applies server-side XP reward', () async {
      when(() => repo.currentLevel).thenReturn(10);
      when(() => cloud.claimPassReward(5)).thenAnswer(
        (_) async => <String, dynamic>{
          'claimedLevels': <dynamic>[5],
          'seasonStart': '2026-01-01T00:00:00.000',
          'reward': <String, dynamic>{'type': 'xp', 'granted': 100},
        },
      );
      container.pump();
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(sagenPassProvider.notifier);
      final result = await notifier.claimLevel(5);
      expect(result, isNotNull);
      expect(result!.level, 5);
      final pass = container.read(sagenPassProvider);
      expect(pass.claimedLevels, contains(5));
      expect(learning.state.totalXpEarned, 100);
    });

    test(
      'claimLevel validates claimedLevels from malformed server payload',
      () async {
        when(() => repo.currentLevel).thenReturn(10);
        when(() => cloud.claimPassReward(5)).thenAnswer(
          (_) async => <String, dynamic>{
            'claimedLevels': 'corrupt',
            'reward': <String, dynamic>{'type': 'item', 'granted': 1},
          },
        );
        container.pump();
        await Future<void>.delayed(Duration.zero);
        final result = await container
            .read(sagenPassProvider.notifier)
            .claimLevel(5);
        expect(result, isNotNull);
        final pass = container.read(sagenPassProvider);
        expect(pass.claimedLevels, contains(5));
      },
    );

    test('getLevel returns a PassLevel for valid levels', () {
      final level = container.read(sagenPassProvider.notifier).getLevel(10);
      expect(level, isNotNull);
      expect(level!.level, 10);
    });

    test('getLevel returns null for out-of-range levels', () {
      final level = container.read(sagenPassProvider.notifier).getLevel(999);
      expect(level, isNull);
    });
  });
}
