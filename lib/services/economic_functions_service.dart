import 'dart:async';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/interfaces/i_economic_functions_service.dart';
import 'app_logger.dart';

/// Service that handles all economic operations via Firebase Cloud Functions.
/// Economic fields (XP, streak, level, donations) must NEVER be written directly
/// to Firestore from the client. All mutations go through these server-side
/// functions which validate and execute atomically.
class EconomicFunctionsService implements IEconomicFunctionsService {
  final AppLogger _logger;

  static final EconomicFunctionsService instance = EconomicFunctionsService._();
  EconomicFunctionsService._() : _logger = AppLogger();

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';
  final _random = Random.secure();

  String _idempotencyKey([String? prefix]) {
    final suffix = List.generate(
      16,
      (_) => _random.nextInt(36).toRadixString(36),
    ).join();
    return '${_uid}_${prefix ?? ''}_$suffix';
  }

  /// Calls a Firebase Cloud Function with error handling.
  Future<T?> _call<T>(
    String name,
    Map<String, dynamic> params, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_uid.isEmpty) {
      _logger.warning('EconomicFunctions: no authenticated user for $name');
      return null;
    }

    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable(params).timeout(timeout);
      _logger.info('EconomicFunctions: $name succeeded');
      return result.data as T?;
    } on FirebaseFunctionsException catch (e) {
      _logger.error(
        'EconomicFunctions: $name failed: ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      _logger.error('EconomicFunctions: $name unexpected error: $e');
      rethrow;
    }
  }

  /// Processes a donation via Cloud Functions.
  /// Server validates the amount and method, updates atomically.
  @override
  Future<Map<String, dynamic>?> processDonation({
    required double amount,
    required String method,
    required String idempotencyKey,
  }) async {
    return _call<Map<String, dynamic>>('processDonation', {
      'amount': amount,
      'method': method,
      'idempotencyKey': idempotencyKey,
    });
  }

  /// Adds XP server-authoritative (reason-based predefined rewards).
  /// Client cannot specify amount — server uses REASON_REWARDS map.
  @override
  Future<Map<String, dynamic>?> addXp({
    required String reason,
    String? lessonId,
  }) async {
    final params = <String, dynamic>{
      'reason': reason,
      'idempotencyKey': _idempotencyKey(reason),
    };
    if (lessonId != null) params['lessonId'] = lessonId;
    return _call<Map<String, dynamic>>('addXp', params);
  }

  /// Increments the daily streak with server-side date validation.
  /// When [freezeUsed] is true and a day was missed, the server keeps the
  /// streak alive instead of resetting it (streak shield consumed).
  @override
  Future<Map<String, dynamic>?> incrementStreak({
    bool freezeUsed = false,
  }) async {
    return _call<Map<String, dynamic>>('incrementStreak', {
      'freezeUsed': freezeUsed,
    });
  }

  /// Atomic lesson completion: XP + streak + level in one transaction.
  @override
  Future<Map<String, dynamic>?> completeLesson({
    required String lessonId,
    required int xpEarned,
    int? correctCount,
    bool? perfect,
  }) async {
    return _call<Map<String, dynamic>>('completeLesson', {
      'lessonId': lessonId,
      'xpEarned': xpEarned,
      'correctCount': correctCount ?? 0,
      'perfect': perfect ?? false,
      'idempotencyKey': 'lesson_$lessonId',
    });
  }

  /// Records a donation via Cloud Functions.
  @override
  Future<Map<String, dynamic>?> recordDonation({
    required double amount,
    required String method,
  }) async {
    return _call<Map<String, dynamic>>('recordDonation', {
      'amount': amount,
      'method': method,
      'idempotencyKey': _idempotencyKey('donation'),
    });
  }
}
