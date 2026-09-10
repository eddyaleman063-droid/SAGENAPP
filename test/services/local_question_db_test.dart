import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
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
      'full lesson keeps its SET but shuffles ORDER per attempt',
      () async {
        final db = LocalQuestionDB.instance;
        await db.getQuestionsForLesson('ac_st1', 'ac_s1_ses2_l1', count: 1);
        final first = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses2_l1',
          count: 15,
        );
        final second = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses2_l1',
          count: 15,
        );
        final third = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses2_l1',
          count: 15,
        );
        expect(first.length, 15);
        // El conjunto de preguntas es estable entre intentos...
        final setA = first.map((q) => q.id).toSet();
        final setB = second.map((q) => q.id).toSet();
        final setC = third.map((q) => q.id).toSet();
        expect(setA, setB);
        expect(setB, setC);
        // ...pero el orden varía (no se memorizan posiciones fijas).
        final orders = [
          first.map((q) => q.id).toList(),
          second.map((q) => q.id).toList(),
          third.map((q) => q.id).toList(),
        ];
        expect(orders.toSet().length, greaterThan(1));
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

  group('LocalQuestionDB.getByIds lazy re-seed', () {
    test(
      'seeds the owning stage on demand for persisted review ids',
      () async {
        final db = LocalQuestionDB.instance;

        // La etapa 1 queda sembrada por el hot path de una lección.
        final seed = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses1_l1',
          count: 5,
        );
        expect(seed, isNotEmpty);

        // Id de una etapa NUNCA sembrada: simula una cola de repaso
        // persistida de una instalación anterior (o tras borrarse el DB),
        // donde la etapa 5 todavía no se había abierto.
        const stage5Id = 'ac_s5_ses1_l1_q001';

        final restored = await db.getByIds([seed.first.id, stage5Id]);
        expect(restored.length, 2);
        expect(
          restored.map((c) => c.id),
          containsAll([seed.first.id, stage5Id]),
        );

        // getById también siembra bajo demanda el stage propietario.
        final single = await db.getById(stage5Id);
        expect(single, isNotNull);
        expect(single!.id, stage5Id);
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'preserves the requested order (SM-2 due priority)',
      () async {
        final db = LocalQuestionDB.instance;
        // Etapa 1 sembrada por el hot path de una lección.
        final seed = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses1_l1',
          count: 15,
        );
        expect(seed.length, 15);

        // La cola de repaso llega ordenada por vencimiento (más antiguo
        // primero); getByIds debe devolverla en ese mismo orden, no en el
        // orden de rowid de SQLite.
        final requested = seed.reversed.map((q) => q.id).toList();
        final restored = await db.getByIds(requested);
        expect(restored.length, requested.length);
        expect(restored.map((c) => c.id).toList(), requested);

        // Un fragmento también preserva su posición relativa.
        final slice = requested.sublist(3, 9);
        final restoredSlice = await db.getByIds(slice);
        expect(restoredSlice.map((c) => c.id).toList(), slice);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'do not throw for ids outside the bank (legacy pools)',
      () async {
        final db = LocalQuestionDB.instance;
        final result = await db.getByIds(const ['pool_legacy_1']);
        expect(result, isEmpty);
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });

  group('LocalQuestionDB.getRandomByType', () {
    test(
      'returns only questions of the requested type',
      () async {
        final db = LocalQuestionDB.instance;
        final result = await db.getRandomByType(
          LessonType.multipleChoice,
          count: 5,
        );
        expect(result, isNotEmpty);
        expect(result.length, lessThanOrEqualTo(5));
        for (final c in result) {
          expect(c.type, LessonType.multipleChoice);
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'works for every enum type that has questions in the bank',
      () async {
        final db = LocalQuestionDB.instance;
        // seeding en frio: getRandomByType siembra la etapa 1 si hace falta
        for (final type in LessonType.values) {
          final result = await db.getRandomByType(type, count: 3);
          if (result.isEmpty) continue;
          expect(result.length, lessThanOrEqualTo(3));
          for (final c in result) {
            expect(c.type, type);
          }
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });

  group('LocalQuestionDB counters', () {
    test(
      'getQuestionCount and getLessonCount reflect the seeded bank',
      () async {
        final db = LocalQuestionDB.instance;
        await db.getQuestionsForLesson('ac_st1', 'ac_s1_ses1_l1', count: 5);
        expect(await db.getQuestionCount(), greaterThan(0));
        expect(await db.getLessonCount(), greaterThan(0));
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });

  group('LocalQuestionDB corrupt-row resilience', () {
    test(
      'falls back to a placeholder option when options are not a list',
      () async {
        final db = LocalQuestionDB.instance;
        final database = await db.database;
        await database.insert('questions', {
          'id': 'x_badjson',
          'question': 'q',
          'type': 'multipleChoice',
          'options': '5',
          'correctIndex': 0,
          'explanation': 'e',
          'lessonId': 'l_x',
        });
        final c = await db.getById('x_badjson');
        expect(c, isNotNull);
        expect(c!.options, ['Option not available']);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'defaults to multipleChoice for an unknown stored type',
      () async {
        final db = LocalQuestionDB.instance;
        final database = await db.database;
        await database.insert('questions', {
          'id': 'x_unknowntype',
          'question': 'q',
          'type': 'weirdType',
          'options': '["a", "b"]',
          'correctIndex': 0,
          'explanation': 'e',
          'lessonId': 'l_x',
        });
        final c = await db.getById('x_unknowntype');
        expect(c, isNotNull);
        expect(c!.type, LessonType.multipleChoice);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });

  group('LocalQuestionDB resilience to database failures', () {
    test(
      'every public read path returns a safe fallback when the DB is corrupt',
      () async {
        File(
          p.join(tempDir.path, 'sagen_questions.db'),
        ).writeAsStringSync('this is not a sqlite database');
        final db = LocalQuestionDB.instance;

        expect(
          await db.getQuestionsForLesson('ac_st1', 'l', count: 5),
          isEmpty,
        );
        expect(await db.getRandomByType(LessonType.multipleChoice), isEmpty);
        expect(await db.getById('ac_s1_ses1_l1_q001'), isNull);
        expect(await db.getByIds(['ac_s1_ses1_l1_q001']), isEmpty);
        expect(await db.getQuestionCount(), 0);
        expect(await db.getLessonCount(), 0);

        // Concurrent access while opening must all fail (no hang, no partial).
        final results = await Future.wait([
          db.database.then((_) => 'ok', onError: (_) => 'err'),
          db.database.then((_) => 'ok', onError: (_) => 'err'),
        ]);
        expect(results, ['err', 'err']);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });

  group('LocalQuestionDB schema migration', () {
    test(
      'migrates a v1 database adding the _meta table',
      () async {
        // Crea un DB v1 sin _meta, como producían las primeras versiones.
        final path = p.join(tempDir.path, 'sagen_questions.db');
        final v1 = await databaseFactory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              await db.execute('CREATE TABLE questions (id TEXT PRIMARY KEY)');
            },
          ),
        );
        await v1.close();

        final db = await LocalQuestionDB.instance.database;
        final rows = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='_meta'",
        );
        expect(rows, isNotEmpty);
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });

  group('LocalQuestionDB lazy re-seed checksum shortcut', () {
    test(
      're-seeding an already seeded stage reuses the stored checksum',
      () async {
        final db = LocalQuestionDB.instance;
        final first = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses1_l1',
          count: 5,
        );
        expect(first, isNotEmpty);

        // close() borra solo el estado en memoria; el archivo persiste.
        await db.close();

        final second = await db.getQuestionsForLesson(
          'ac_st1',
          'ac_s1_ses1_l1',
          count: 5,
        );
        expect(second, isNotEmpty);
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
