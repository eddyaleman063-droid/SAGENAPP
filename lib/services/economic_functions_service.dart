import 'dart:async';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  /// Test-only uid override so the authenticated-user branch can be exercised
  /// without a real FirebaseAuth session.
  @visibleForTesting
  static String? Function()? uidOverride;

  String get _uid =>
      uidOverride?.call() ?? FirebaseAuth.instance.currentUser?.uid ?? '';
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
    } on FirebaseFunctionsException catch (e, stack) {
      _logger.error(
        'EconomicFunctions: $name failed: ${e.code} - ${e.message}',
        e,
        stack,
      );
      rethrow;
    } catch (e, stack) {
      _logger.error('EconomicFunctions: $name unexpected error', e, stack);
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
  /// [idempotencyKey] estable permite reintentar offline sin doble acreditación
  /// (transaction_logs por clave): si se omite se genera una nueva por llamada.
  @override
  Future<Map<String, dynamic>?> addXp({
    required String reason,
    String? lessonId,
    String? idempotencyKey,
    String? achievementId,
  }) async {
    final params = <String, dynamic>{
      'reason': reason,
      'idempotencyKey': idempotencyKey ?? _idempotencyKey(reason),
    };
    if (lessonId != null) params['lessonId'] = lessonId;
    if (achievementId != null) params['achievementId'] = achievementId;
    return _call<Map<String, dynamic>>('addXp', params);
  }

  @override
  String createIdempotencyKey([String? prefix]) => _idempotencyKey(prefix);

  /// Increments the daily streak with server-side date validation.
  /// When [freezeUsed] is true and a day was missed, the server keeps the
  /// streak alive instead of resetting it (streak shield consumed).
  /// When [checkIn] is false the call is a READ-ONLY sync (used by reload/login)
  /// that reconciles the local ledgers without mutating the server streak:
  /// merely opening the app never advances the streak, burns a shield or
  /// breaks it. [itemUsed] declares a premium item (titaniumShield /
  /// phoenixFeather) that the SERVER validates and consumes from the
  /// authoritative inventory only when no real shields exist.
  @override
  Future<Map<String, dynamic>?> incrementStreak({
    bool freezeUsed = false,
    bool checkIn = true,
    String? itemUsed,
    String? activityDay,
    int? activityStreak,
  }) async {
    final params = <String, dynamic>{
      'freezeUsed': freezeUsed,
      'checkIn': checkIn,
    };
    if (itemUsed != null) params['itemUsed'] = itemUsed;
    // NUEVO-fix (streak backfill): se envían solo cuando el cliente tiene
    // historial local (primer check-in: null, el server arranca en 1).
    if (activityDay != null) params['activityDay'] = activityDay;
    if (activityStreak != null) params['activityStreak'] = activityStreak;
    return _call<Map<String, dynamic>>('incrementStreak', params);
  }

  /// Atomic lesson completion: XP + streak + level in one transaction.
  @override
  Future<Map<String, dynamic>?> completeLesson({
    required String lessonId,
    required int xpEarned,
    int? correctCount,
    int? totalQuestions,
    bool? perfect,
  }) async {
    return _call<Map<String, dynamic>>('completeLesson', {
      'lessonId': lessonId,
      'xpEarned': xpEarned,
      'correctCount': correctCount ?? 0,
      'totalQuestions': totalQuestions ?? 0,
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

  @override
  Future<Map<String, dynamic>?> claimFreeStreakShield() {
    return _call<Map<String, dynamic>>('claimFreeStreakShield', {});
  }
}
