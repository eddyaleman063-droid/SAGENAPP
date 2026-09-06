import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/local_question_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Aceptación de precisión milimétrica del curriculum a nivel runtime.
/// El grid autoritativo del proyecto es:
///   etapas 1..8 con 27/22/30/24/29/20/25/28 sesiones,
///   5 ó 6 lecciones por sesión -> 135/132/150/144/145/120/125/168 lecciones,
///   15 preguntas fijas por lección -> 2.025/1.980/2.250/2.160/2.175/1.800/
///   1.875/2.520 preguntas (total 16.785).
/// Se valida que el DB real (LocalQuestionDB) expone exactamente esa malla.
///
/// Los conteos "autoritativos" filtran por id de banco
/// (`ac_s*_ses*_l*_q*`); las preguntas sintéticas (pool_/topic_/type_/
/// diversity_) son relleno opcional y no cuentan.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = Directory.systemTemp.createTempSync('sagen_grid_test');
    LocalQuestionDB.overrideDatabasesPath = tempDir.path;
  });

  tearDown(() async {
    await LocalQuestionDB.instance.close();
    LocalQuestionDB.overrideDatabasesPath = null;
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  const gridSessions = [27, 22, 30, 24, 29, 20, 25, 28];
  const gridLessons = [135, 132, 150, 144, 145, 120, 125, 168];
  const gridQuestions = [2025, 1980, 2250, 2160, 2175, 1800, 1875, 2520];

  test(
    'runtime DB exposes exactly the authoritative curriculum grid',
    () async {
      final db = LocalQuestionDB.instance;

      // 1) Fuerza la siembra de las 8 etapas por el hot path de una lección.
      for (var i = 1; i <= 8; i++) {
        final probe = await db.getQuestionsForLesson(
          'ac_st$i',
          'ac_s${i}_ses1_l1',
          count: 1,
        );
        expect(probe, isNotEmpty, reason: 'stage ac_st$i must be reachable');
      }

      final sqlite = await db.database;

      // 2) Total de preguntas autoritativas == 16.785.
      final totalRows = await sqlite.rawQuery(
        "SELECT COUNT(*) AS c FROM questions"
        " WHERE id GLOB 'ac_s*_ses*_l*_q*'",
      );
      expect(
        totalRows.first['c'] as int,
        gridQuestions.reduce((a, b) => a + b),
        reason: 'total bank questions must match the grid (16.785)',
      );

      // 3) Una lección tras otra: 1.119 lecciones únicas con exactamente
      //    15 preguntas de banco, sin duplicados dentro de cada lección.
      final lessonRows = await sqlite.rawQuery(
        "SELECT lessonId, COUNT(*) AS c FROM questions"
        " WHERE id GLOB 'ac_s*_ses*_l*_q*'"
        " GROUP BY lessonId",
      );
      expect(lessonRows.length, 1119, reason: 'exactly 1.119 lessons');

      final countsByLesson = {
        for (final r in lessonRows) r['lessonId'] as String: r['c'] as int,
      };
      for (final entry in countsByLesson.entries) {
        expect(
          entry.value,
          15,
          reason: 'lesson ${entry.key} must have exactly 15 questions',
        );
      }

      // 4) Desglose por etapa == grid de preguntas.
      final stageRows = await sqlite.rawQuery(
        "SELECT substr(lessonId, 1, 5) AS prefix, COUNT(*) AS c"
        " FROM questions"
        " WHERE id GLOB 'ac_s*_ses*_l*_q*'"
        " GROUP BY prefix ORDER BY prefix",
      );
      expect(stageRows.length, 8);
      for (var i = 0; i < 8; i++) {
        expect(
          stageRows[i]['prefix'],
          'ac_s${i + 1}',
          reason: 'stage prefix order',
        );
        expect(
          stageRows[i]['c'],
          gridQuestions[i],
          reason: 'stage ac_st${i + 1} question count',
        );
      }

      // 5) Legacy de lecciones == grid de lecciones por etapa.
      final byStageLessons = await sqlite.rawQuery(
        "SELECT substr(lessonId, 1, 5) AS prefix, COUNT(DISTINCT lessonId) AS c"
        " FROM questions"
        " WHERE id GLOB 'ac_s*_ses*_l*_q*'"
        " GROUP BY prefix ORDER BY prefix",
      );
      for (var i = 0; i < 8; i++) {
        expect(
          byStageLessons[i]['c'],
          gridLessons[i],
          reason: 'stage ac_st${i + 1} lesson count',
        );
      }

      // 6) Sesiones por etapa (lecciones / lecciones-por-sesión).
      final byStageSessions = await sqlite.rawQuery(
        "SELECT substr(lessonId, 1, 5) AS prefix,"
        "       COUNT(DISTINCT substr(lessonId, instr(lessonId, '_ses') + 4,"
        "                      instr(substr(lessonId, instr(lessonId, '_ses') + 4), '_l') - 1)) AS c"
        " FROM questions"
        " WHERE id GLOB 'ac_s*_ses*_l*_q*'"
        " GROUP BY prefix ORDER BY prefix",
      );
      for (var i = 0; i < 8; i++) {
        expect(
          byStageSessions[i]['c'],
          gridSessions[i],
          reason: 'stage ac_st${i + 1} session count',
        );
      }

      // 7) Cada lección SIERVE exactamente sus 15 preguntas de banco, todas
      //    distintas, y de forma determinista entre llamadas.
      for (var i = 1; i <= 8; i++) {
        final lessonId = 'ac_s${i}_ses1_l1';
        final once = await db.getQuestionsForLesson(
          'ac_st$i',
          lessonId,
          count: 15,
        );
        expect(once.length, 15, reason: '$lessonId serves 15');
        final bankIds = once.map((q) => q.id).toList();
        expect(bankIds.toSet().length, 15, reason: '$lessonId all distinct');
        final twice = await db.getQuestionsForLesson(
          'ac_st$i',
          lessonId,
          count: 15,
        );
        expect(
          twice.map((q) => q.id).toSet(),
          bankIds.toSet(),
          reason: '$lessonId deterministic',
        );
      }

      // 8) getByIds devuelve una pregunta por cada etapa distinta.
      final samples = <String>[];
      for (var i = 1; i <= 8; i++) {
        final served = await db.getQuestionsForLesson(
          'ac_st$i',
          'ac_s${i}_ses1_l1',
          count: 1,
        );
        samples.add(served.first.id);
      }
      final resolved = await db.getByIds(samples);
      expect(resolved.length, 8, reason: 'review can resolve one id per stage');
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
