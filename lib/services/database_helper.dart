import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/interfaces/i_database_helper.dart';
import 'app_logger.dart';

/// SQLite database helper with versioned migrations.
class DatabaseHelper implements IDatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  Database? _db;
  Completer<Database>? _pending;
  static const _dbName = 'sagen_data.db';
  static const _dbVersion = 2;

  @override
  Future<Database> get database async {
    if (_db != null) return _db!;
    if (_pending != null) {
      return _pending!.future;
    }
    _pending = Completer<Database>();
    try {
      final db = await _openDB();
      _db = db;
      _pending!.complete(db);
      return db;
    } catch (e) {
      _pending!.completeError(e);
      _pending = null;
      rethrow;
    }
  }

  Future<Database> _openDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA journal_mode=WAL');
        await db.execute('PRAGMA busy_timeout=2000');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE heatmap (
        date TEXT PRIMARY KEY,
        count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE streak_history (
        date TEXT PRIMARY KEY
      )
    ''');

    // kv_store: transient cache data (session tokens, feature flags, temp state).
    // Cleared on logout. Not synced to cloud.
    await db.execute('''
      CREATE TABLE kv_store (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // user_preferences: synced user settings (profile data, learning prefs).
    // Persists across sessions. Synced to Firestore via CloudSyncService.
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    AppLogger().info('Database created at version $version');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger().info('Database upgrade from $oldVersion to $newVersion');
    final migrations = _getMigrations(oldVersion, newVersion);
    for (final migration in migrations) {
      AppLogger().info('Running migration: ${migration.description}');
      await migration.execute(db);
    }
  }

  List<_Migration> _getMigrations(int from, int to) {
    final migrations = <_Migration>[];
    if (from < 2 && to >= 2) {
      migrations.add(_MigrationV2());
    }
    return migrations;
  }

  @override
  Future<void> close() async {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      try { await pending.future.timeout(const Duration(seconds: 5)); } catch (e) { AppLogger().error('Database pending future failed', e); }
    }
    final db = _db;
    _db = null;
    _pending = null;
    if (db != null) {
      try { await db.close(); } catch (e) { AppLogger().error('Database close failed', e); }
    }
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    final db = database;
    return (await db).insert(table, values, nullColumnHack: nullColumnHack, conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<dynamic>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    final db = database;
    return (await db).query(table, distinct: distinct, columns: columns, where: where, whereArgs: whereArgs, groupBy: groupBy, having: having, orderBy: orderBy, limit: limit, offset: offset);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<dynamic>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    final db = database;
    return (await db).update(table, values, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  }

  @override
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = database;
    return (await db).delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = database;
    return (await db).rawQuery(sql, arguments);
  }

  @override
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = database;
    await (await db).execute(sql, arguments);
  }
}

abstract class _Migration {
  String get description;
  Future<void> execute(Database db);
}

class _MigrationV2 extends _Migration {
  @override
  String get description => 'Add user_preferences and sync_queue tables';

  @override
  Future<void> execute(Database db) async {
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
