/// Abstract interface for secure storage operations.
/// Enables dependency injection and testability.
abstract class ISecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<bool> containsKey(String key);
  Future<void> deleteAll();
}
