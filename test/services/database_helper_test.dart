import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempDir = Directory.systemTemp.createTempSync('sagen_db_test');
    DatabaseHelper.overrideDatabasesPath = tempDir.path;
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.overrideDatabasesPath = null;
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('DatabaseHelper', () {
    test('database getter opens a versioned schema on first access', () async {
      final db = await DatabaseHelper.instance.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
      expect(await db.getVersion(), 2);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final names = tables.map((r) => r['name']).toSet();
      expect(names, containsAll(['heatmap', 'streak_history', 'kv_store']));
      expect(names, containsAll(['user_preferences', 'sync_queue']));
    });

    test('database getter returns the cached instance', () async {
      final db = await DatabaseHelper.instance.database;
      final again = await DatabaseHelper.instance.database;
      expect(identical(db, again), true);
    });

    test('insert and query roundtrip with filters and ordering', () async {
      final helper = DatabaseHelper.instance;
      await helper.insert('kv_store', {'key': 'theme', 'value': 'dark'});
      await helper.insert('kv_store', {'key': 'lang', 'value': 'es'});
      await helper.insert('kv_store', {'key': 'expo', 'value': 'on'});

      final all = await helper.query('kv_store', orderBy: 'key ASC');
      expect(all.length, 3);
      expect(all.map((r) => r['key']).toList(), ['expo', 'lang', 'theme']);

      final filtered = await helper.query(
        'kv_store',
        where: 'key = ?',
        whereArgs: ['lang'],
      );
      expect(filtered.single['value'], 'es');

      final limited = await helper.query('kv_store', limit: 2);
      expect(limited.length, 2);

      final distinct = await helper.query(
        'kv_store',
        distinct: true,
        columns: ['key'],
      );
      expect(distinct.length, 3);
    });

    test('insert with conflict algorithm replaces existing rows', () async {
      final helper = DatabaseHelper.instance;
      final first = await helper.insert('kv_store', {
        'key': 'theme',
        'value': 'dark',
      });
      expect(first, 1);
      await helper.insert('kv_store', {
        'key': 'theme',
        'value': 'light',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      final rows = await helper.query(
        'kv_store',
        where: 'key = ?',
        whereArgs: ['theme'],
      );
      expect(rows.single['value'], 'light');
    });

    test('update modifies matching rows and returns affected count', () async {
      final helper = DatabaseHelper.instance;
      await helper.insert('kv_store', {'key': 'a', 'value': '1'});
      await helper.insert('kv_store', {'key': 'b', 'value': '2'});
      await helper.insert('kv_store', {'key': 'c', 'value': '3'});

      final updated = await helper.update(
        'kv_store',
        {'value': 'x'},
        where: 'value IN (?, ?)',
        whereArgs: ['1', '2'],
      );
      expect(updated, 2);

      final rows = await helper.query('kv_store', orderBy: 'key ASC');
      expect(rows.map((r) => r['value']).toList(), ['x', 'x', '3']);
    });

    test('delete removes rows and returns the count', () async {
      final helper = DatabaseHelper.instance;
      await helper.insert('kv_store', {'key': 'a', 'value': '1'});
      await helper.insert('kv_store', {'key': 'b', 'value': '2'});

      final deleted = await helper.delete(
        'kv_store',
        where: 'key = ?',
        whereArgs: ['a'],
      );
      expect(deleted, 1);
      final rows = await helper.query('kv_store');
      expect(rows.single['key'], 'b');
    });

    test('rawQuery and execute work with parameters', () async {
      final helper = DatabaseHelper.instance;
      await helper.execute('INSERT INTO kv_store (key, value) VALUES (?, ?)', [
        'raw',
        'row',
      ]);
      final rows = await helper.rawQuery(
        'SELECT * FROM kv_store WHERE key = ?',
        ['raw'],
      );
      expect(rows.single['value'], 'row');
    });

    test('close drops the cached database', () async {
      final helper = DatabaseHelper.instance;
      final db = await helper.database;
      await helper.close();
      expect(db.isOpen, false);

      final reopened = await helper.database;
      expect(reopened.isOpen, true);
      expect(identical(reopened, db), false);
    });
  });
}
