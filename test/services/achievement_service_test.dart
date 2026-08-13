import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/achievement_service.dart';

void main() {
  group('AchievementModel', () {
    test('toJson serializes correctly', () {
      final model = AchievementModel(
        id: 'test',
        title: 'Test',
        description: 'Desc',
        icon: Icons.star,
        xpReward: 10,
        unlocked: true,
        unlockedDate: DateTime(2025, 1, 15),
      );
      final json = model.toJson();
      expect(json['id'], 'test');
      expect(json['unlocked'], true);
      expect(json['unlockedDate'], isNotNull);
    });

    test('toJson handles null unlockedDate', () {
      final model = AchievementModel(
        id: 'test',
        title: 'Test',
        description: 'Desc',
        icon: Icons.star,
        xpReward: 10,
      );
      final json = model.toJson();
      expect(json['unlockedDate'], isNull);
    });
  });

  group('AchievementService', () {
    late AchievementService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      service = AchievementService.instance;
      await service.init(prefs);
    });

    test('initializes with default templates', () {
      expect(service.achievements, isNotEmpty);
      expect(service.totalCount, 12);
      expect(service.unlockedCount, 0);
      expect(service.progress, 0.0);
    });

    test('getById returns achievement for valid id', () {
      final achievement = service.getById('first_lesson');
      expect(achievement, isNotNull);
      expect(achievement!.id, 'first_lesson');
      expect(achievement.title, 'First Shield');
      expect(achievement.unlocked, false);
    });

    test('getById returns null for invalid id', () {
      expect(service.getById('nonexistent'), isNull);
    });

    test('unlock succeeds for locked achievement', () {
      final result = service.unlock('first_lesson');
      expect(result, 10);
      expect(service.unlockedCount, 1);
      expect(service.progress, 1 / 12);
      expect(service.getById('first_lesson')!.unlocked, true);
      expect(service.getById('first_lesson')!.unlockedDate, isNotNull);
    });

    test('unlock returns 0 for already unlocked achievement', () {
      service.unlock('first_lesson');
      final result = service.unlock('first_lesson');
      expect(result, 0);
      expect(service.unlockedCount, 1);
    });

    test('unlock returns 0 for nonexistent achievement', () {
      final result = service.unlock('nonexistent');
      expect(result, 0);
      expect(service.unlockedCount, 0);
    });

    test('progress is 1.0 when all unlocked', () {
      for (final a in service.achievements) {
        service.unlock(a.id);
      }
      expect(service.unlockedCount, service.totalCount);
      expect(service.progress, 1.0);
    });

    test('achievements list is unmodifiable', () {
      expect(
        () => service.achievements.add(
          AchievementModel(
            id: 'hack',
            title: 'Hack',
            description: 'Hack',
            icon: Icons.bug_report,
            xpReward: 0,
          ),
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('persists unlock state across reloads', () async {
      service.unlock('first_lesson');
      service.unlock('streak_3');

      // Reload from SharedPreferences
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      // Manually save to the mock
      await prefs.setString(
        'achievements_data',
        '[{"id":"first_lesson","unlocked":true,"unlockedDate":"2025-01-15T00:00:00.000"},{"id":"streak_3","unlocked":true,"unlockedDate":"2025-01-15T00:00:00.000"}]',
      );

      final service2 = AchievementService.instance;
      await service2.init(prefs);
      expect(service2.unlockedCount, 2);
      expect(service2.getById('first_lesson')!.unlocked, true);
      expect(service2.getById('streak_3')!.unlocked, true);
    });

    test('all 12 template achievements exist', () {
      final expectedIds = [
        'first_lesson',
        'five_lessons',
        'ten_lessons',
        'twenty_five_lessons',
        'fifty_lessons',
        'stage_complete',
        'all_stages',
        'streak_3',
        'streak_7',
        'streak_30',
        'perfect_lesson',
        'sage_talk',
      ];
      for (final id in expectedIds) {
        expect(
          service.getById(id),
          isNotNull,
          reason: 'Missing achievement: $id',
        );
      }
    });
  });
}
