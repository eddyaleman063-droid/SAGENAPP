import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/learning/challenge.dart';
import '../models/learning/lesson_type.dart';
import 'app_logger.dart';

/// SQLite-backed question database for offline quiz content.
class LocalQuestionDB {
  static final LocalQuestionDB instance = LocalQuestionDB._();
  LocalQuestionDB._();

  Database? _db;
  Completer<Database>? _dbCompleter;
  final Set<String> _seededStages = {};
  bool _poolsSeeded = false;
  bool _seedingInProgress = false;
  Completer<void>? _seedingCompleter;
  static const _dbName = 'sagen_questions.db';
  static const _dbVersion = 2;

  /// In-memory cache of question IDs grouped by lessonId for fast random selection.
  final Map<String, List<String>> _idCacheByLesson = {};
  final Map<String, List<String>> _idCacheByType = {};

  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_dbCompleter != null) {
      return _dbCompleter!.future;
    }
    final completer = Completer<Database>();
    _dbCompleter = completer;
    try {
      _db = await _openDB();
      completer.complete(_db);
      return _db!;
    } catch (e) {
      completer.completeError(e);
      _dbCompleter = null;
      rethrow;
    }
  }

  Future<Database> _openDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE questions (
            id TEXT PRIMARY KEY,
            question TEXT NOT NULL,
            type TEXT NOT NULL,
            options TEXT NOT NULL,
            correctIndex INTEGER NOT NULL,
            explanation TEXT NOT NULL,
            lessonId TEXT NOT NULL
          )
        ''');
        await db.execute('CREATE INDEX idx_lessonId ON questions(lessonId)');
        await db.execute('CREATE INDEX idx_type ON questions(type)');
        await db.execute('''
          CREATE TABLE _meta (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS _meta (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  static List<Map<String, dynamic>> _decodeJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! List) return [];
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      AppLogger().warning('[LocalQuestionDB] _decodeJson error: $e');
      return [];
    }
  }

  static String _computeChecksum(String content) {
    final bytes = Uint8List.fromList(utf8.encode(content));
    return md5.convert(bytes).toString();
  }

  Future<String?> _getStoredChecksum(Database db, String key) async {
    final rows = await db.query('_meta', columns: ['value'], where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _storeChecksum(Database db, String key, String checksum) async {
    await db.insert('_meta', {'key': key, 'value': checksum}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static final _questionIdPattern = RegExp(r'^ac_s(\d+)_ses(\d+)_l(\d+)_q(\d+)$');

  static String _extractLessonId(String questionId) {
    final match = _questionIdPattern.firstMatch(questionId);
    if (match == null) return '';
    final stage = int.tryParse(match.group(1) ?? '') ?? 0;
    final session = int.tryParse(match.group(2) ?? '') ?? 0;
    final lesson = int.tryParse(match.group(3) ?? '') ?? 0;
    return 'ac_s${stage}_ses${session}_l$lesson';
  }

  /// Validates a question for structural integrity.
  /// Returns true if the question is valid, false if it should be skipped.
  static bool _validateQuestion(Map<String, dynamic> q) {
    final qId = (q['id'] as String?) ?? '';
    final qType = q['type'] as String?;
    final qQuestion = (q['question'] as String?) ?? '';
    final options = q['options'];
    final correctIndex = q['correctIndex'];

    // Basic required fields
    if (qId.isEmpty || qType == null || qType.isEmpty || qQuestion.trim().isEmpty) {
      return false;
    }

    // Options must be a non-empty list
    if (options is! List || options.isEmpty) {
      return false;
    }

    // All options must be non-empty strings
    final stringOptions = options.whereType<String>().toList();
    if (stringOptions.length != options.length) {
      return false;
    }
    if (stringOptions.any((o) => o.trim().isEmpty)) {
      return false;
    }

    // No duplicate options
    final uniqueOptions = stringOptions.toSet();
    if (uniqueOptions.length != stringOptions.length) {
      return false;
    }

    // correctIndex must be valid
    if (correctIndex is! int || correctIndex < 0 || correctIndex >= options.length) {
      return false;
    }

    // Explanation should not be empty
    final explanation = (q['explanation'] as String?) ?? '';
    if (explanation.trim().isEmpty) {
      return false;
    }

    return true;
  }

  Future<void> _ensureStageSeeded(String stageId) async {
    if (_seededStages.contains(stageId)) return;
    if (_seedingInProgress) {
      await _seedingCompleter?.future;
      if (_seededStages.contains(stageId)) return;
    }
    _seedingInProgress = true;
    _seedingCompleter = Completer<void>();
    try {
      final db = await database;
      final jsonStr = await rootBundle.loadString('assets/content/questions_$stageId.json');
      final currentChecksum = _computeChecksum(jsonStr);
      final storedChecksum = await _getStoredChecksum(db, 'stage_$stageId');

      if (storedChecksum == currentChecksum) {
        _seededStages.add(stageId);
        await _ensurePoolsSeeded(db);
        return;
      }

      AppLogger().info('Seeding stage $stageId into local DB...');
      final decoded = _decodeJson(jsonStr);

      // Clear old data for this stage if checksum changed
      if (storedChecksum != null) {
        await db.delete('questions', where: 'lessonId LIKE ?', whereArgs: ['${stageId}_%']);
        _idCacheByLesson.clear();
        _idCacheByType.clear();
        AppLogger().info('Cleared old data for stage $stageId (checksum changed)');
      }

      var validCount = 0;
      var skippedCount = 0;
      const batchSize = 500;
      for (var i = 0; i < decoded.length; i += batchSize) {
        final chunk = decoded.sublist(i, (i + batchSize).clamp(0, decoded.length));
        final batch = db.batch();
        for (final q in chunk) {
          // Comprehensive validation
          if (!_validateQuestion(q)) {
            skippedCount++;
            continue;
          }
          final qId = q['id'] as String;
          final qType = q['type'] as String;
          final qQuestion = q['question'] as String;
          var lessonId = (q['lessonId'] as String?) ?? '';
          if (lessonId.isEmpty) {
            lessonId = _extractLessonId(qId);
          }
          batch.insert('questions', {
            'id': qId,
            'question': qQuestion,
            'type': qType,
            'options': jsonEncode(q['options']),
            'correctIndex': q['correctIndex'] as int,
            'explanation': (q['explanation'] as String?) ?? '',
            'lessonId': lessonId,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          validCount++;
        }
        await batch.commit(noResult: true);
      }

      _seededStages.add(stageId);
      _idCacheByLesson.clear();
      _idCacheByType.clear();
      await _storeChecksum(db, 'stage_$stageId', currentChecksum);
      if (skippedCount > 0) {
        AppLogger().warning(
            'Seeded $validCount questions for stage $stageId '
            '(skipped $skippedCount with invalid schema)');
      } else {
        AppLogger()
            .info('Seeded $validCount questions for stage $stageId');
      }
      await _ensurePoolsSeeded(db);
    } catch (e) {
      AppLogger().error('Failed to seed stage $stageId', e);
    } finally {
      _seedingInProgress = false;
      _seedingCompleter?.complete();
      _seedingCompleter = null;
    }
  }

  Future<void> _ensurePoolsSeeded(Database db) async {
    if (_poolsSeeded) return;
    try {
      final poolsStr = await rootBundle.loadString('assets/questions.json');
      final pools = jsonDecode(poolsStr) as Map<String, dynamic>;

      final occupiedLessons = <String>{};
      final rows = await db.rawQuery('SELECT DISTINCT lessonId FROM questions');
      for (final row in rows) {
        final lid = row['lessonId'] as String? ?? '';
        if (lid.isNotEmpty) occupiedLessons.add(lid);
      }

      final stagesStr = await rootBundle.loadString('assets/content/stages.json');
      final stagesList = jsonDecode(stagesStr) as List;
      final emptyLessonsByStage = <String, List<String>>{};
      for (final stage in stagesList) {
        final stageId = stage['id'] as String? ?? '';
        final sessions = stage['sessions'] as List? ?? [];
        final empty = <String>[];
        for (final session in sessions) {
          final lessons = session['lessons'] as List? ?? [];
          for (final lesson in lessons) {
            final lessonId = lesson['id'] as String? ?? '';
            if (lessonId.isNotEmpty && !occupiedLessons.contains(lessonId)) {
              empty.add(lessonId);
            }
          }
        }
        emptyLessonsByStage[stageId] = empty;
      }

      int totalEmpty = emptyLessonsByStage.values.fold(0, (s, l) => s + l.length);
      AppLogger().info('Found $totalEmpty empty lessons across all stages');

      int idCounter = 90000;
      int insertedCount = 0;
      const microBatchSize = 50;

      // Stage pools — insert in micro-batches
      final stagePools = pools['stagePools'] as Map<String, dynamic>? ?? {};
      for (final entry in stagePools.entries) {
        final stageKey = entry.key;
        final questions = entry.value as List? ?? [];
        final stageLessons = emptyLessonsByStage[stageKey] ?? [];
        if (stageLessons.isEmpty) continue;

        final batch = db.batch();
        for (int i = 0; i < questions.length; i++) {
          final q = questions[i] as Map<String, dynamic>;
          final targetLesson = stageLessons[i % stageLessons.length];
          batch.insert('questions', {
            'id': 'pool_${q['id'] ?? 'q${idCounter++}'}',
            'question': (q['question'] as String?) ?? '',
            'type': (q['type'] as String?) ?? 'multipleChoice',
            'options': jsonEncode(q['options']),
            'correctIndex': (q['correctIndex'] as int?) ?? 0,
          'explanation': (q['explanation'] as String?) ?? (q['explanationCorrect'] as String?) ?? '',
            'lessonId': targetLesson,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          idCounter++;
          insertedCount++;
          if (insertedCount % microBatchSize == 0) {
            await batch.commit(noResult: true);
            await Future.delayed(Duration.zero); // yield to event loop
          }
        }
        if (insertedCount % microBatchSize != 0) {
          await batch.commit(noResult: true);
        }
      }

      final allEmpty = emptyLessonsByStage.values.expand((l) => l).toList();
      int globalIdx = 0;

      // Topic pools — insert in micro-batches
      final topicPools = pools['topicPools'] as Map<String, dynamic>? ?? {};
      for (final entry in topicPools.entries) {
        final questions = entry.value as List? ?? [];
        final batch = db.batch();
        int batchCount = 0;
        for (final q in questions) {
          if (allEmpty.isEmpty) break;
          final qMap = q as Map<String, dynamic>;
          final targetLesson = allEmpty[globalIdx % allEmpty.length];
          batch.insert('questions', {
            'id': 'topic_${qMap['id'] ?? 'q${idCounter++}'}',
            'question': (qMap['question'] as String?) ?? '',
            'type': (qMap['type'] as String?) ?? 'multipleChoice',
            'options': jsonEncode(qMap['options']),
            'correctIndex': (qMap['correctIndex'] as int?) ?? 0,
            'explanation': (qMap['explanation'] as String?) ?? '',
            'lessonId': targetLesson,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          idCounter++;
          globalIdx++;
          batchCount++;
          if (batchCount % microBatchSize == 0) {
            await batch.commit(noResult: true);
            await Future.delayed(Duration.zero);
          }
        }
        if (batchCount % microBatchSize != 0) {
          await batch.commit(noResult: true);
        }
      }

      // Questions by type — insert in micro-batches
      final byType = pools['questionsByType'] as Map<String, dynamic>? ?? {};
      for (final entry in byType.entries) {
        final questions = entry.value as List? ?? [];
        final batch = db.batch();
        int batchCount = 0;
        for (final q in questions) {
          if (allEmpty.isEmpty) break;
          final qMap = q as Map<String, dynamic>;
          final targetLesson = allEmpty[globalIdx % allEmpty.length];
          batch.insert('questions', {
            'id': 'type_${qMap['id'] ?? 'q${idCounter++}'}',
            'question': (qMap['question'] as String?) ?? '',
            'type': (qMap['type'] as String?) ?? 'multipleChoice',
            'options': jsonEncode(qMap['options']),
            'correctIndex': (qMap['correctIndex'] as int?) ?? 0,
            'explanation': (qMap['explanation'] as String?) ?? '',
            'lessonId': targetLesson,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          idCounter++;
          globalIdx++;
          batchCount++;
          if (batchCount % microBatchSize == 0) {
            await batch.commit(noResult: true);
            await Future.delayed(Duration.zero);
          }
        }
        if (batchCount % microBatchSize != 0) {
          await batch.commit(noResult: true);
        }
      }
      AppLogger().info('Seeded 372 pool questions into $totalEmpty empty lessons');

      await _ensureTypeDiversity(db, pools);
      _poolsSeeded = true;
    } catch (e) {
      _poolsSeeded = false;
      AppLogger().error('Failed to seed pool questions', e);
    }
  }

  Future<void> _ensureTypeDiversity(Database db, Map<String, dynamic> pools) async {
    try {
      const requiredTypes = ['multipleChoice', 'trueFalse', 'miniCase', 'completePhrase', 'detectRisk', 'createPassword', 'whatWouldYouDo'];
      final rows = await db.rawQuery('SELECT DISTINCT lessonId FROM questions');
      final allLessonIds = rows.map((r) => r['lessonId'] as String? ?? '').where((l) => l.isNotEmpty).toList();

      final byType = pools['questionsByType'] as Map<String, dynamic>? ?? {};
      final poolByType = <String, List<Map<String, dynamic>>>{};
      for (final entry in byType.entries) {
        final questions = entry.value as List? ?? [];
        poolByType[entry.key] = questions.cast<Map<String, dynamic>>();
      }

      final batch = db.batch();
      int idCounter = 95000;
      int added = 0;

      final allTypeRows = await db.rawQuery('SELECT DISTINCT lessonId, type FROM questions');
      final existingByLesson = <String, Set<String>>{};
      for (final row in allTypeRows) {
        final lid = row['lessonId'] as String? ?? '';
        final t = row['type'] as String? ?? '';
        if (lid.isNotEmpty && t.isNotEmpty) {
          existingByLesson.putIfAbsent(lid, () => {}).add(t);
        }
      }

      for (final lessonId in allLessonIds) {
        final existingTypes = existingByLesson[lessonId] ?? {};

        for (final requiredType in requiredTypes) {
          if (existingTypes.contains(requiredType)) continue;
          final pool = poolByType[requiredType];
          if (pool == null || pool.isEmpty) continue;
          final q = pool[idCounter % pool.length];
          batch.insert('questions', {
            'id': 'diversity_${lessonId}_$requiredType',
            'question': (q['question'] as String?) ?? '',
            'type': requiredType,
            'options': jsonEncode(q['options']),
            'correctIndex': (q['correctIndex'] as int?) ?? 0,
            'explanation': (q['explanation'] as String?) ?? '',
            'lessonId': lessonId,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          idCounter++;
          added++;
        }
      }

      await batch.commit(noResult: true);
      if (added > 0) {
        AppLogger().info('Added $added diversity questions across ${allLessonIds.length} lessons');
      }
    } catch (e) {
      AppLogger().error('Failed to ensure type diversity', e);
    }
  }

  Future<List<Challenge>> getQuestionsForLesson(
    String stageId,
    String lessonId, {
    int count = 5,
  }) async {
    try {
      await _ensureStageSeeded(stageId);
      final db = await database;

      // Use in-memory ID cache for fast random selection
      if (!_idCacheByLesson.containsKey(lessonId)) {
        await _rebuildIdCache(db, lessonId: lessonId);
      }
      final ids = _idCacheByLesson[lessonId];
      if (ids == null || ids.isEmpty) return [];

      final selectedIds = _pickRandomIds(ids, count, seed: lessonId.hashCode);
      final placeholders = List.generate(selectedIds.length, (_) => '?').join(',');
      final maps = await db.query(
        'questions',
        where: 'id IN ($placeholders)',
        whereArgs: selectedIds,
      );
      return maps.map(_rowToChallenge).toList();
    } catch (e) {
      AppLogger().error('LocalQuestionDB.getQuestionsForLesson failed', e);
      return [];
    }
  }

  Future<List<Challenge>> getRandomByType(LessonType type, {int count = 1}) async {
    try {
      if (_seededStages.isEmpty) {
        await _ensureStageSeeded('ac_st1');
      }
      final db = await database;

      // Use in-memory ID cache for fast random selection
      if (!_idCacheByType.containsKey(type.name)) {
        await _rebuildIdCacheByType(db, type: type.name);
      }
      final ids = _idCacheByType[type.name];
      if (ids == null || ids.isEmpty) return [];

      final selectedIds = _pickRandomIds(ids, count, seed: type.name.hashCode + DateTime.now().microsecondsSinceEpoch);
      final placeholders = List.generate(selectedIds.length, (_) => '?').join(',');
      final maps = await db.query(
        'questions',
        where: 'id IN ($placeholders)',
        whereArgs: selectedIds,
      );
      return maps.map(_rowToChallenge).toList();
    } catch (e) {
      AppLogger().error('LocalQuestionDB.getRandomByType failed', e);
      return [];
    }
  }

  Future<Challenge?> getById(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        'questions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return _rowToChallenge(maps.first);
    } catch (e) {
      AppLogger().error('LocalQuestionDB.getById failed', e);
      return null;
    }
  }

  Future<List<Challenge>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    try {
      final db = await database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final maps = await db.query(
        'questions',
        where: 'id IN ($placeholders)',
        whereArgs: ids,
      );
      return maps.map(_rowToChallenge).toList();
    } catch (e) {
      AppLogger().error('LocalQuestionDB.getByIds failed', e);
      return const [];
    }
  }

  Future<int> getQuestionCount() async {
    try {
      final db = await database;
      return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM questions'),
      ) ?? 0;
    } catch (e) {
      AppLogger().error('LocalQuestionDB.getQuestionCount failed', e);
      return 0;
    }
  }

  Future<int> getLessonCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(DISTINCT lessonId) FROM questions');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      AppLogger().error('LocalQuestionDB.getLessonCount failed', e);
      return 0;
    }
  }

  Challenge _rowToChallenge(Map<String, dynamic> map) {
    final optionsRaw = (map['options'] as String?) ?? '[]';
    List<String> options;
    try {
      options = (jsonDecode(optionsRaw) as List).cast<String>();
    } catch (e) {
      AppLogger().warning('[LocalQuestionDB] _rowToChallenge JSON decode error: $e');
      options = [];
    }
    if (options.isEmpty) {
      options = ['Option not available'];
    }
    final rawType = map['type'] as String?;
    final type = (rawType != null && rawType.isNotEmpty)
        ? LessonType.values.firstWhere(
            (t) => t.name == rawType,
            orElse: () {
              AppLogger().warning(
                  'LocalQuestionDB: unknown type "$rawType", defaulting to multipleChoice');
              return LessonType.multipleChoice;
            },
          )
        : LessonType.multipleChoice;
    var correctIdx = (map['correctIndex'] as int?) ?? 0;
    if (correctIdx < 0 || correctIdx >= options.length) {
      correctIdx = 0;
    }
    return Challenge(
      id: (map['id'] as String?) ?? '',
      question: (map['question'] as String?) ?? '',
      type: type,
      options: options,
      correctIndex: correctIdx,
      explanation: (map['explanation'] as String?) ?? '',
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
      _seededStages.clear();
      _idCacheByLesson.clear();
      _idCacheByType.clear();
    }
  }

  /// Rebuilds the in-memory ID cache for a given lessonId from the database.
  Future<void> _rebuildIdCache(Database db, {String? lessonId}) async {
    if (lessonId != null) {
      final rows = await db.query('questions', columns: ['id'], where: 'lessonId = ?', whereArgs: [lessonId]);
      _idCacheByLesson[lessonId] = rows.map((r) => r['id'] as String).toList();
    }
  }

  /// Rebuilds the in-memory ID cache for a given type from the database.
  Future<void> _rebuildIdCacheByType(Database db, {String? type}) async {
    if (type != null) {
      final rows = await db.query('questions', columns: ['id'], where: 'type = ?', whereArgs: [type]);
      _idCacheByType[type] = rows.map((r) => r['id'] as String).toList();
    }
  }

  /// Picks [count] random IDs from [pool] without shuffling the entire list.
  List<String> _pickRandomIds(List<String> pool, int count, {required int seed}) {
    if (pool.isEmpty) return [];
    if (pool.length <= count) return List.from(pool);
    // Deduplicate pool to avoid infinite loop with duplicate IDs
    final uniquePool = pool.toSet().toList();
    if (uniquePool.length <= count) return List.from(uniquePool);
    final rng = seed >= 0 ? _SecureRandom(seed) : _SecureRandom(DateTime.now().microsecondsSinceEpoch);
    final selected = <String>{};
    while (selected.length < count && selected.length < uniquePool.length) {
      selected.add(uniquePool[rng.nextInt(uniquePool.length)]);
    }
    return selected.toList();
  }
}

/// Simple linear congruential generator for deterministic random selection
/// without importing dart:math (which would conflict with the seed parameter).
class _SecureRandom {
  int _state;
  _SecureRandom(this._state);
  int nextInt(int max) {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }
}
