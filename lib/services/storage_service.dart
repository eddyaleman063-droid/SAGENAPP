import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/interfaces/i_storage_service.dart';
import 'app_logger.dart';

/// SharedPreferences wrapper for simple key-value persistence.
class StorageService implements IStorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  @override
  String getString(String key, [String defaultValue = '']) =>
      _prefs.getString(key) ?? defaultValue;

  @override
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  int getInt(String key, [int defaultValue = 0]) =>
      _prefs.getInt(key) ?? defaultValue;

  @override
  Future<bool> setInt(String key, int value) =>
      _prefs.setInt(key, value);

  @override
  bool getBool(String key, [bool defaultValue = false]) =>
      _prefs.getBool(key) ?? defaultValue;

  @override
  Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  @override
  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is List) return list.cast<Map<String, dynamic>>();
      return [];
    } catch (e) {
      AppLogger().warning('[StorageService] getJsonList error: $e');
      return [];
    }
  }

  @override
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> list) =>
      _prefs.setString(key, jsonEncode(list));

  @override
  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return null;
    } catch (e) {
      AppLogger().warning('[StorageService] getJson error: $e');
      return null;
    }
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) =>
      _prefs.setString(key, jsonEncode(value));

  @override
  List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? [];

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<bool> remove(String key) => _prefs.remove(key);
}
