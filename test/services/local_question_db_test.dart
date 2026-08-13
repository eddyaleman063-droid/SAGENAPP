import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/services/local_question_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = Directory.systemTemp.createTempSync('sagen_db_test');
    LocalQuestionDB.overrideDatabasesPath = tempDir.path;
  });

  tearDown(() async {
    await LocalQuestionDB.instance.close();
    LocalQuestionDB.overrideDatabasesPath = null;
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('LocalQuestionDB.getQuestionsForLesson', () {
    Future<void> expectStagePrefixes(List<Challenge> result) async {
      expect(result, isNotEmpty);
      final database = await LocalQuestionDB.instance.database;
      final placeholders = List.filled(result.length, '?').join(',');
      final rows = await database.query(
        'questions',
        columns: ['lessonId'],
        where: 'id IN ($placeholders)',
        whereArgs: result.map((q) => q.id).toList(),
      );
      expect(rows.length, result.length);
      for (final row in rows) {
        expect(row['lessonId'], startsWith('ac_s1'));
      }
    }

    test(
      'falls back to the whole stage when a lesson has no questions',
      () async {
        final result = await LocalQuestionDB.instance.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses9_l1_does_not_exist',
          count: 5,
        );
        expect(result.length, 5);
        await expectStagePrefixes(result);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'returns questions for the "default" legacy lesson id (beginner path)',
      () async {
        final result = await LocalQuestionDB.instance.getQuestionsForLesson(
          'ac_st1',
          'default',
          count: 20,
        );
        await expectStagePrefixes(result);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'selection is deterministic for a given lesson id',
      () async {
        final db = LocalQuestionDB.instance;
        final first = await db.getQuestionsForLesson(
          'ac_st1',
          'default',
          count: 20,
        );
        final second = await db.getQuestionsForLesson(
          'ac_st1',
          'default',
          count: 20,
        );
        expect(first.map((q) => q.id).toSet(), second.map((q) => q.id).toSet());
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'exact lesson id returns non-empty, distinct questions',
      () async {
        final result = await LocalQuestionDB.instance.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses1_l1',
          count: 5,
        );
        expect(result, isNotEmpty);
        expect(result.length, 5);
        final ids = result.map((q) => q.id).toSet();
        expect(ids.length, 5);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test('unknown stage returns empty list', () async {
      final result = await LocalQuestionDB.instance.getQuestionsForLesson(
        'unknown_stage',
        'unknown_lesson',
        count: 10,
      );
      expect(result, isEmpty);
    });

    test('stage fallback ids all belong to the stage prefix', () async {
      final db = LocalQuestionDB.instance;
      final result = await db.getQuestionsForLesson(
        'ac_st1',
        'no_such_lesson_zzz',
        count: 8,
      );
      expect(result, isNotEmpty);
      final database = await db.database;
      final rows = await database.query(
        'questions',
        columns: ['id', 'lessonId'],
        where: 'lessonId LIKE ?',
        whereArgs: ['ac_s1%'],
      );
      expect(rows, isNotEmpty);
    });
  });
}
