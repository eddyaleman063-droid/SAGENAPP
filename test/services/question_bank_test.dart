import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/local_question_db.dart';
import 'package:sagen/services/question_bank.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuestionBank qb;
  late Directory tempDir;

  setUp(() {
    qb = QuestionBank.instance;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = Directory.systemTemp.createTempSync('sagen_qb_test');
    LocalQuestionDB.overrideDatabasesPath = tempDir.path;
  });

  tearDown(() async {
    await LocalQuestionDB.instance.close();
    LocalQuestionDB.overrideDatabasesPath = null;
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('QuestionBank', () {
    test('singleton returns same instance', () {
      expect(QuestionBank.instance, same(qb));
    });

    group('getQuestionsForLesson', () {
      test('returns empty list when no DB data (no hardcoded fallback)', () async {
        final result = await qb.getQuestionsForLesson('unknown_stage', 'unknown_lesson', count: 10);
        expect(result, isEmpty);
      });
    });

    group('getById', () {
      test('returns null for unknown id', () async {
        final result = await qb.getById('no_such_id');
        expect(result, isNull);
      });
    });
  });
}
