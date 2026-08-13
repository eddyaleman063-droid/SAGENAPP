import 'package:sqflite/sqflite.dart';

/// Abstract interface for database operations.
/// Enables dependency injection and testability.
abstract class IDatabaseHelper {
  Future<Database> get database;
  Future<void> close();
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  });
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  });
  Future<int> delete(String table, {String? where, List<dynamic>? whereArgs});
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]);
  Future<void> execute(String sql, [List<dynamic>? arguments]);
}
