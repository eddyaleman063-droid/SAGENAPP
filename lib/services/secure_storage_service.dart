import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/interfaces/i_secure_storage_service.dart';
import 'app_logger.dart';

/// Encrypted key-value storage via flutter_secure_storage.
class SecureStorageService implements ISecureStorageService {
  static final SecureStorageService instance = SecureStorageService._();
  SecureStorageService._() : _logger = AppLogger();
  final AppLogger _logger;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyPrefix = 'ss_';

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: '$_keyPrefix$key', value: value);
    } catch (e, stack) {
      _logger.error('SecureStorage: write failed for $key', e, stack);
      rethrow;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: '$_keyPrefix$key');
    } catch (e, stack) {
      _logger.error('SecureStorage: read failed for $key', e, stack);
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: '$_keyPrefix$key');
    } catch (e, stack) {
      _logger.error('SecureStorage: delete failed for $key', e, stack);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      final allData = await _storage.readAll();
      // Snapshot de claves: borrar sobre un iterable vivo del plugin mientras
      // muta produce "Concurrent modification during iteration".
      final appKeys = allData.keys
          .where((k) => k.startsWith(_keyPrefix))
          .toList();
      for (final key in appKeys) {
        await _storage.delete(key: key);
      }
    } catch (e, stack) {
      _logger.error('SecureStorage: deleteAll failed', e, stack);
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: '$_keyPrefix$key');
    } catch (e, stack) {
      _logger.error('SecureStorage: containsKey failed for $key', e, stack);
      return false;
    }
  }
}
