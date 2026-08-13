import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/repositories/learning_repository.dart';
import 'package:sagen/services/learning_stage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStageService extends LearningStageService {
  _FakeStageService({this.stages = const [], this.error});

  final List<Stage> stages;
  final Object? error;

  @override
  Future<List<Stage>> fetchStages() async {
    if (error != null) throw Exception(error);
    return stages;
  }
}

Stage stage(String id) => Stage(
      id: id,
      title: 'T-$id',
      subtitle: 'S-$id',
      accent: const Color(0xFF123456),
      icon: Icons.shield_rounded,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  LearningRepositoryImpl repo() => LearningRepositoryImpl(prefs);

  group('defaults', () {
    test('empty prefs load to sensible defaults', () async {
      final r = repo();
      await r.load();
      expect(r.xp, 0);
      expect(r.currentLevel, 1);
      expect(r.lessonsCompleted, 0);
      expect(r.totalDonated, 0);
      expect(r.sageTalks, 0);
      expect(r.totalXpEarned, 0);
      expect(r.isSupporter, isFalse);
      expect(r.achievements, isEmpty);
      expect(r.stages, isEmpty);
      expect(r.needsServerReconciliation, isFalse);
    });
  });

  group('saveAll snapshot roundtrip', () {
    test('persists everything through a single JSON blob', () async {
      final r = repo();
      r.saveAll(
        stages: [stage('s1'), stage('s2')],
        totalDonated: 12.5,
        xp: 30,
        level: 3,
        lessonsCompleted: 7,
        achievements: const ['a1', 'a2'],
        totalXp: 300,
        sageTalks: 5,
        isSupporter: true,
      );

      final fresh = repo();
      await fresh.load();
      expect(fresh.xp, 30);
      expect(fresh.currentLevel, 3);
      expect(fresh.lessonsCompleted, 7);
      expect(fresh.totalDonated, 12.5);
      expect(fresh.sageTalks, 5);
      expect(fresh.totalXpEarned, 300);
      expect(fresh.isSupporter, isTrue);
      expect(fresh.achievements, ['a1', 'a2']);
      expect(fresh.stages.map((s) => s.id).toList(), ['s1', 's2']);
    });

    test('does not flag reconciliation after a clean save', () async {
      final r = repo();
      r.saveAll(
        stages: [stage('s1')],
        totalDonated: 0,
        xp: 10,
        level: 1,
        lessonsCompleted: 1,
        achievements: const [],
        totalXp: 10,
        sageTalks: 0,
        isSupporter: false,
      );
      final fresh = repo();
      await fresh.load();
      expect(fresh.needsServerReconciliation, isFalse);
    });
  });

  group('legacy loading', () {
    test('loads from legacy keys when no snapshot exists', () async {
      prefs.setInt('learning_xp', 42);
      prefs.setInt('learning_level', 5);
      prefs.setInt('learning_lessons_completed', 9);
      prefs.setDouble('learning_total_donated', 3.25);
      prefs.setInt('learning_sage_talks', 2);
      prefs.setInt('learning_total_xp', 420);
      prefs.setBool('learning_is_supporter', true);
      prefs.setString('learning_achievements', 'x,y');

      final r = repo();
      await r.load();
      expect(r.xp, 42);
      expect(r.currentLevel, 5);
      expect(r.lessonsCompleted, 9);
      expect(r.totalDonated, 3.25);
      expect(r.sageTalks, 2);
      expect(r.totalXpEarned, 420);
      expect(r.isSupporter, isTrue);
      expect(r.achievements, ['x', 'y']);
    });

    test('falls back to legacy when snapshot is corrupted', () async {
      prefs.setString('learning_snapshot', '{not valid json');
      prefs.setInt('learning_xp', 7);

      final r = repo();
      await r.load();
      expect(r.xp, 7);
    });

    test('clears stages when legacy stages JSON is invalid', () async {
      prefs.setString('learning_stages', 'not-a-list');
      final r = repo();
      await r.load();
      expect(r.stages, isEmpty);
    });

    test('loads legacy stages', () async {
      prefs.setString(
        'learning_stages',
        '[{"id":"s1","title":"T","subtitle":"S","accent":1193046,"icon":"shield"}]',
      );
      final r = repo();
      await r.load();
      expect(r.stages.length, 1);
      expect(r.stages.first.id, 's1');
    });
  });

  group('individual saves', () {
    test('persist each value to prefs', () async {
      final r = repo();
      r.saveXp(11);
      r.saveLevel(4);
      r.saveLessonsCompleted(6);
      r.saveTotalXp(222);
      r.saveSageTalks(3);
      r.saveIsSupporter(true);
      r.saveTotalDonated(9.5);
      r.saveAchievements(['z']);

      expect(prefs.getInt('learning_xp'), 11);
      expect(prefs.getInt('learning_level'), 4);
      expect(prefs.getInt('learning_lessons_completed'), 6);
      expect(prefs.getInt('learning_total_xp'), 222);
      expect(prefs.getInt('learning_sage_talks'), 3);
      expect(prefs.getBool('learning_is_supporter'), isTrue);
      expect(prefs.getDouble('learning_total_donated'), 9.5);
      expect(prefs.getString('learning_achievements'), 'z');
    });

    test('saveStages persists stage JSON', () async {
      final r = repo();
      r.saveStages([stage('s9')]);
      expect(prefs.getString('learning_stages'), contains('s9'));
      final fresh = repo();
      await fresh.load();
      expect(fresh.stages.single.id, 's9');
    });
  });

  group('fetchStages', () {
    test('returns stages from the service', () async {
      final r = LearningRepositoryImpl(prefs, _FakeStageService(stages: [stage('remote')]));
      final result = await r.fetchStages();
      expect(result.single.id, 'remote');
    });

    test('returns an empty list when the service throws', () async {
      final r = LearningRepositoryImpl(prefs, _FakeStageService(error: 'down'));
      final result = await r.fetchStages();
      expect(result, isEmpty);
    });
  });

  group('integrity checks', () {
    test('flags server reconciliation when the checksum is tampered', () async {
      final r = repo();
      r.saveAll(
        stages: [stage('s1')],
        totalDonated: 0,
        xp: 10,
        level: 1,
        lessonsCompleted: 1,
        achievements: const [],
        totalXp: 10,
        sageTalks: 0,
        isSupporter: false,
      );
      prefs.setInt('learning_integrity', 123456);

      final fresh = repo();
      await fresh.load();
      expect(fresh.needsServerReconciliation, isTrue);
    });

    test('markReconciled clears the flag and re-saves the checksum', () async {
      final r = repo();
      r.saveAll(
        stages: [stage('s1')],
        totalDonated: 0,
        xp: 10,
        level: 1,
        lessonsCompleted: 1,
        achievements: const [],
        totalXp: 10,
        sageTalks: 0,
        isSupporter: false,
      );
      r.markReconciled();
      expect(r.needsServerReconciliation, isFalse);

      final fresh = repo();
      await fresh.load();
      expect(fresh.needsServerReconciliation, isFalse);
    });

    test('needsRechecksum flag re-saves a valid checksum', () async {
      final r = repo();
      r.saveAll(
        stages: [stage('s1')],
        totalDonated: 0,
        xp: 10,
        level: 1,
        lessonsCompleted: 1,
        achievements: const [],
        totalXp: 10,
        sageTalks: 0,
        isSupporter: false,
      );
      prefs.setBool('learning_needs_rechecksum', true);

      final fresh = repo();
      await fresh.load();
      expect(fresh.needsServerReconciliation, isFalse);
    });

    test('saveIntegrity writes a checksum', () async {
      final r = repo();
      r.saveAll(
        stages: [stage('s1')],
        totalDonated: 0,
        xp: 10,
        level: 1,
        lessonsCompleted: 1,
        achievements: const [],
        totalXp: 10,
        sageTalks: 0,
        isSupporter: false,
      );
      expect(prefs.getInt('learning_integrity'), isNotNull);
    });
  });
}
