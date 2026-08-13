import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

enum SyncOperationType {
  completeLesson,
  addXp,
  streakUpdate,
  missionComplete,
  profileUpdate,
}

class SyncOperation {
  final String id;
  final SyncOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'retryCount': retryCount,
  };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
    id: json['id'] as String,
    type: SyncOperationType.values.firstWhere((t) => t.name == json['type']),
    data: Map<String, dynamic>.from(json['data'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String),
    retryCount: json['retryCount'] as int? ?? 0,
  );
}

/// Generic sync queue backed by SharedPreferences.
///
/// H-ARC-01 COORDINATION:
/// This service is initialized but currently has NO active callers in
/// production code (no calls to enqueue() or processQueue() outside tests).
/// It exists as infrastructure for future use. When a caller is added,
/// it MUST route writes through CloudSyncService (profile fields) or
/// EconomicFunctionsService (economic fields) — never direct Firestore.
/// The external [processor] callback in processQueue() must respect
/// CloudSyncService.isGlobalSyncInProgress before writing to Firestore.
class SyncQueueService {
  static final SyncQueueService instance = SyncQueueService._();
  SyncQueueService._() : _logger = AppLogger();
  final AppLogger _logger;

  final List<SyncOperation> _queue = [];
  static const _maxRetries = 5;
  static const _queueKey = 'sync_queue';

  bool _processing = false;
  bool get isProcessing => _processing;
  int get pendingCount => _queue.length;
  SharedPreferences? _prefs;

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    final stored = prefs.getString(_queueKey);
    if (stored != null && stored.isNotEmpty) {
      try {
        final list = jsonDecode(stored) as List;
        _queue.addAll(
          list.map((e) => SyncOperation.fromJson(e as Map<String, dynamic>)),
        );
        _logger.debug('SyncQueue: loaded ${_queue.length} pending operations');
      } catch (e) {
        _logger.error('SyncQueue: failed to load queue', e);
      }
    }
  }

  Future<void> _save(SharedPreferences prefs) async {
    final json = jsonEncode(_queue.map((op) => op.toJson()).toList());
    await prefs.setString(_queueKey, json);
  }

  void enqueue(SyncOperationType type, Map<String, dynamic> data) {
    if (_processing) {
      _queue.add(
        SyncOperation(
          id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}_${_queue.length}',
          type: type,
          data: data,
        ),
      );
      _logger.debug(
        'SyncQueue: enqueued ${type.name} (${_queue.length} pending) [deferred]',
      );
      return;
    }
    final op = SyncOperation(
      id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}_${_queue.length}',
      type: type,
      data: data,
    );
    _queue.add(op);
    _logger.debug(
      'SyncQueue: enqueued ${type.name} (${_queue.length} pending)',
    );
    final prefs = _prefs;
    if (prefs != null) _save(prefs);
  }

  void remove(String id) {
    _queue.removeWhere((op) => op.id == id);
    final prefs = _prefs;
    if (prefs != null) _save(prefs);
  }

  Future<bool> processQueue({
    required Future<bool> Function(SyncOperation operation) processor,
  }) async {
    if (_processing || _queue.isEmpty) return false;
    _processing = true;

    final prefs = _prefs ?? await SharedPreferences.getInstance();

    try {
      while (_queue.isNotEmpty) {
        final op = _queue.first;

        if (op.retryCount >= _maxRetries) {
          _queue.removeAt(0);
          await _save(prefs);
          _logger.warning(
            'SyncQueue: dropping operation ${op.id} after $_maxRetries retries',
          );
          continue;
        }

        try {
          final success = await processor(op);
          if (success) {
            _queue.removeAt(0);
            await _save(prefs);
            _logger.debug('SyncQueue: completed ${op.id}');
          } else {
            op.retryCount++;
            _queue.removeAt(0);
            _queue.add(op);
            await _save(prefs);
            _logger.warning(
              'SyncQueue: failed ${op.id}, retry ${op.retryCount}/$_maxRetries',
            );
            break;
          }
        } catch (e) {
          op.retryCount++;
          _queue.removeAt(0);
          _queue.add(op);
          await _save(prefs);
          _logger.error('SyncQueue: error processing ${op.id}', e);
          break;
        }
      }
    } finally {
      _processing = false;
    }
    return _queue.isEmpty;
  }

  void clear() {
    _queue.clear();
    SharedPreferences.getInstance().then((prefs) => _save(prefs));
  }
}
