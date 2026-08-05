import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

/// A single cache entry with TTL-based expiration.
class CacheEntry<T> {
  final T data;
  final DateTime cachedAt;
  final Duration ttl;

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;

  CacheEntry({required this.data, required this.cachedAt, required this.ttl});

  Map<String, dynamic> toJson() => {
    'data': data is String ? data : jsonEncode(data),
    'cachedAt': cachedAt.toIso8601String(),
    'ttlMs': ttl.inMilliseconds,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json, T Function(dynamic) fromData) {
    final ttl = Duration(milliseconds: json['ttlMs'] as int? ?? 300000);
    return CacheEntry(
      data: fromData(json['data']),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      ttl: ttl,
    );
  }
}

class _NoOpCache extends SmartCache {
  _NoOpCache() : super._(null);

  @override
  T? get<T>(String key, T Function(dynamic) fromData) => null;

  @override
  Future<void> set<T>(String key, T data, {Duration ttl = const Duration(minutes: 5)}) async {}

  @override
  Future<void> invalidate(String key) async {}

  @override
  Future<void> invalidateAll() async {}
}

/// In-memory TTL cache for reducing redundant async calls.
class SmartCache {
  static SmartCache? _instance;
  static SmartCache get instance => _instance ?? _NoOpCache();
  static bool get isInitialized => _instance != null;

  final SharedPreferences? _prefs;
  final Map<String, CacheEntry> _memory = {};
  static const _prefix = 'smart_cache_';
  final int maxMemoryEntries;

  // Write batching: debounce SharedPreferences writes
  final Map<String, String> _pendingPrefsWrites = {};
  Timer? _prefsWriteTimer;
  static const _writeBatchDelay = Duration(milliseconds: 200);

  SmartCache._(this._prefs, {this.maxMemoryEntries = 100});

  static Future<void> init(SharedPreferences prefs, {int maxMemoryEntries = 100}) async {
    _instance = SmartCache._(prefs, maxMemoryEntries: maxMemoryEntries);
  }

  T? get<T>(String key, T Function(dynamic) fromData) {
    final mem = _memory[key];
    if (mem != null) {
      try {
        if (!mem.isExpired) return fromData(mem.data);
      } catch (e) {
        AppLogger().warning('SmartCache.get: failed to deserialize cached data: $e');
      }
      _memory.remove(key);
    }
    final raw = _prefs?.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final entry = CacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>, fromData);
      if (entry.isExpired) {
        _prefs?.remove('$_prefix$key');
        return null;
      }
      _memory[key] = entry;
      return entry.data;
    } catch (e) {
      AppLogger().warning('[SmartCache] get error: $e');
      return null;
    }
  }

  static const int _maxPrefsEntries = 200;
  static int _prefsWriteCount = 0;

  Future<void> set<T>(String key, T data, {Duration ttl = const Duration(minutes: 5)}) async {
    final entry = CacheEntry(data: data, cachedAt: DateTime.now(), ttl: ttl);
    _memory[key] = entry;
    if (_memory.length > maxMemoryEntries) {
      final oldest = _memory.entries
          .where((e) => e.key != key)
          .fold<MapEntry<String, CacheEntry>?>(null, (prev, e) =>
              prev == null || e.value.cachedAt.isBefore(prev.value.cachedAt) ? e : prev);
      if (oldest != null) _memory.remove(oldest.key);
    }
    // Batch SharedPreferences writes
    _pendingPrefsWrites['$_prefix$key'] = jsonEncode(entry.toJson());
    _prefsWriteTimer?.cancel();
    _prefsWriteTimer = Timer(_writeBatchDelay, () => _flushPrefsWrites());
    _prefsWriteCount++;
    if (_prefsWriteCount % 50 == 0) {
      await _evictExpiredPrefs();
    }
  }

  Future<void> _flushPrefsWrites() async {
    if (_pendingPrefsWrites.isEmpty) return;
    final prefs = _prefs;
    if (prefs == null) return;
    final writes = Map<String, String>.from(_pendingPrefsWrites);
    _pendingPrefsWrites.clear();
    await Future.wait(
      writes.entries.map((e) => prefs.setString(e.key, e.value)),
    );
  }

  Future<void> _evictExpiredPrefs() async {
    if (_prefs == null) return;
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      final raw = _prefs.getString(k);
      if (raw == null) continue;
      try {
        final entry = CacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>, (d) => d);
        if (entry.isExpired) {
          await _prefs.remove(k);
        }
    } catch (e) {
      AppLogger().warning('[SmartCache] _evictExpiredPrefs error: $e');
      await _prefs.remove(k);
      }
    }
    final remaining = _prefs.getKeys().where((k) => k.startsWith(_prefix)).length;
    if (remaining > _maxPrefsEntries) {
      final allKeys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()
        ..sort((a, b) => (_prefs.getString(a) ?? '').compareTo(_prefs.getString(b) ?? ''));
      final toRemove = allKeys.take(remaining - _maxPrefsEntries);
      for (final k in toRemove) {
        await _prefs.remove(k);
      }
    }
  }

  Future<void> invalidate(String key) async {
    _memory.remove(key);
    _pendingPrefsWrites.remove('$_prefix$key');
    await _prefs?.remove('$_prefix$key');
  }

  Future<void> invalidateAll() async {
    _memory.clear();
    _pendingPrefsWrites.clear();
    _prefsWriteTimer?.cancel();
    if (_prefs == null) return;
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  static String Function(dynamic) get stringData => (d) => d is String ? d : d?.toString() ?? '';
  static int Function(dynamic) get intData => (d) => d is int ? d : int.tryParse(d.toString()) ?? 0;
  static double Function(dynamic) get doubleData => (d) => d is double ? d : double.tryParse(d.toString()) ?? 0.0;
  static List<String> Function(dynamic) get stringListData => (d) => d is List ? (d).map((e) => e.toString()).toList() : [];
}
