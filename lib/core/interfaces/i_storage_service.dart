/// Abstract interface for local storage operations.
/// Enables dependency injection and testability.
abstract class IStorageService {
  String getString(String key, [String defaultValue = '']);
  Future<bool> setString(String key, String value);
  int getInt(String key, [int defaultValue = 0]);
  Future<bool> setInt(String key, int value);
  bool getBool(String key, [bool defaultValue = false]);
  Future<bool> setBool(String key, bool value);
  List<Map<String, dynamic>> getJsonList(String key);
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> list);
  Map<String, dynamic>? getJson(String key);
  Future<bool> setJson(String key, Map<String, dynamic> value);
  List<String> getStringList(String key);
  Future<bool> setStringList(String key, List<String> value);
  Future<bool> remove(String key);
}
