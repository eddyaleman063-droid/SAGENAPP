import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import '../config/firestore_field_config.dart';
import '../core/interfaces/i_firestore_service.dart';
import 'app_logger.dart';

final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', caseSensitive: false);
final RegExp _scriptRegex = RegExp(r'javascript:', caseSensitive: false);
final RegExp _controlChars = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]');
final RegExp _multiline = RegExp(r'[\r\n]+');
final RegExp _eventHandlerRegex = RegExp(r'\bon\w+\s*=', caseSensitive: false);
final RegExp _dataUriRegex = RegExp(r'data:', caseSensitive: false);
final RegExp _base64Regex = RegExp(r'base64,', caseSensitive: false);

String _sanitizeWorker(String value) {
  var decoded = value
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#x27;', "'")
      .replaceAll('&#x2F;', '/')
      .replaceAll('&#x25;', '%')
      .replaceAll('&nbsp;', ' ');

  var clean = decoded
      .replaceAll(_controlChars, '')
      .replaceAll(_multiline, ' ')
      .replaceAll(_eventHandlerRegex, '')
      .replaceAll(_dataUriRegex, '')
      .replaceAll(_base64Regex, '');

  int prevLen;
  do {
    prevLen = clean.length;
    clean = clean.replaceAll(_scriptRegex, '').replaceAll(_htmlTagRegex, '');
  } while (clean.length != prevLen);

  clean = clean
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .trim();

  if (clean.length > 100) {
    clean = clean.substring(0, 100);
  }

  return clean;
}

/// Firestore CRUD operations for user profiles and game data.
class FirestoreService implements IFirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();
  final AppLogger _logger = AppLogger();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  static const _collection = 'users';
  static const _maxConcurrentListeners = 5;

  final Map<String, StreamSubscription<DocumentSnapshot>> _activeListeners = {};
  int _listenerCount = 0;

  // Delegated to FirestoreFieldConfig for single source of truth.
  static Set<String> get allowedUpdateFields =>
      FirestoreFieldConfig.profileFields;

  static final RegExp _urlRegex = RegExp(
    r'(https?|ftp)://[^\s/$.?#].[^\s]*',
    caseSensitive: false,
  );

  static Future<String> sanitize(String value) async {
    if (value.isEmpty) return value;
    if (value.length > 100) value = value.substring(0, 100);
    return compute(_sanitizeWorker, value);
  }

  static String sanitizeUrl(String url) {
    final trimmed = url.trim();
    if (!_urlRegex.hasMatch(trimmed)) return '';
    if (trimmed.toLowerCase().contains('javascript:')) return '';
    return trimmed;
  }

  static int clampAge(int age) => age.clamp(13, 120);

  @override
  Future<void> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required int age,
  }) async {
    try {
      final sanitizedFirst = await sanitize(firstName);
      final safeFirst = sanitizedFirst.length > 50
          ? sanitizedFirst.substring(0, 50)
          : sanitizedFirst;
      final sanitizedLast = await sanitize(lastName);
      final safeLast = sanitizedLast.length > 50
          ? sanitizedLast.substring(0, 50)
          : sanitizedLast;
      final safeEmail = email.trim().toLowerCase();
      final safeAge = age.clamp(13, 120);

      if (safeFirst.isEmpty || safeLast.isEmpty || !safeEmail.contains('@')) {
        throw ArgumentError('Invalid profile data');
      }

      await _db
          .collection(_collection)
          .doc(uid)
          .set({
            'firstName': safeFirst,
            'lastName': safeLast,
            'email': safeEmail,
            'age': safeAge,
            'lastLoginDate': FieldValue.serverTimestamp(),
            'onboardingCompleted': true,
            'photoUrl': '',
            'dailyGoalMinutes': 30,
            'dailyLessonsGoal': 3,
            'preferredLanguage': 'es',
            'referralSource': '',
            'routeType': '',
            'motivation': '',
            'updatedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
    } catch (e, stack) {
      _logger.error('FirestoreService: createUserProfile failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'createUserProfile failed',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateField(String uid, String field, Object? value) async {
    if (!FirestoreFieldConfig.isProfileField(field)) {
      _logger.warning(
        'FirestoreService: blocked update to disallowed field "$field"',
      );
      return;
    }
    if (!FirestoreFieldConfig.validateFieldType(field, value)) {
      _logger.warning(
        'FirestoreService: type mismatch for field "$field" — '
        'expected ${FirestoreFieldConfig.profileFieldTypes[field]}, got ${value.runtimeType}',
      );
      return;
    }
    // Validate string length if applicable
    if (value is String &&
        !FirestoreFieldConfig.validateStringLength(field, value)) {
      _logger.warning(
        'FirestoreService: string too long for field "$field" — '
        'max ${FirestoreFieldConfig.stringFieldMaxLengths[field]}, got ${value.length}',
      );
      return;
    }
    // Validate int range if applicable
    if (value is int && !FirestoreFieldConfig.validateIntRange(field, value)) {
      final range = FirestoreFieldConfig.intFieldRanges[field];
      _logger.warning(
        'FirestoreService: int out of range for field "$field" — '
        'expected ${range?.$1}-${range?.$2}, got $value',
      );
      return;
    }
    try {
      await _db
          .collection(_collection)
          .doc(uid)
          .update({field: value})
          .timeout(const Duration(seconds: 10));
    } catch (e, stack) {
      _logger.error('FirestoreService: updateField($field) failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'updateField($field) failed',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateFields(String uid, Map<String, dynamic> data) async {
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.key.startsWith('_ts_')) {
        sanitized[entry.key] = entry.value;
        continue;
      }
      if (!FirestoreFieldConfig.isProfileField(entry.key)) continue;

      if (!FirestoreFieldConfig.validateFieldType(entry.key, entry.value)) {
        _logger.warning(
          'FirestoreService: type mismatch for field "${entry.key}" — '
          'expected ${FirestoreFieldConfig.profileFieldTypes[entry.key]}, got ${entry.value.runtimeType}',
        );
        continue;
      }

      if (entry.value is String) {
        sanitized[entry.key] = await sanitize(entry.value as String);
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    if (sanitized.isEmpty) return;
    try {
      await _db
          .collection(_collection)
          .doc(uid)
          .update(sanitized)
          .timeout(const Duration(seconds: 10));
    } catch (e, stack) {
      _logger.error('FirestoreService: updateFields failed: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'updateFields failed',
      );
      rethrow;
    }
  }

  @override
  Stream<DocumentSnapshot> streamUserDoc(String uid) {
    if (_listenerCount >= _maxConcurrentListeners) {
      _logger.warning(
        'FirestoreService: listener limit reached ($_listenerCount/$_maxConcurrentListeners)',
      );
      return const Stream.empty();
    }

    final subKey = 'stream_${uid}_${DateTime.now().millisecondsSinceEpoch}';
    StreamSubscription<DocumentSnapshot>? subscription;

    late final StreamController<DocumentSnapshot> controller;
    controller = StreamController<DocumentSnapshot>.broadcast(
      onListen: () {
        _listenerCount++;
        subscription = _db
            .collection(_collection)
            .doc(uid)
            .snapshots()
            .listen(
              (snap) => controller.add(snap),
              onError: (e) {
                _logger.error('FirestoreService: streamUserDoc error: $e');
                _activeListeners.remove(subKey);
                _listenerCount = (_listenerCount - 1).clamp(
                  0,
                  _maxConcurrentListeners,
                );
                controller.close();
              },
            );
        _activeListeners[subKey] = subscription!;
      },
      onCancel: () {
        subscription?.cancel();
        final removed = _activeListeners.remove(subKey);
        if (removed != null) {
          _listenerCount = (_listenerCount - 1).clamp(
            0,
            _maxConcurrentListeners,
          );
        }
        controller.close();
      },
    );

    return controller.stream;
  }

  void removeListener(String listenerId) {
    final removed = _activeListeners.remove(listenerId);
    if (removed != null) {
      removed.cancel();
      _listenerCount = (_listenerCount - 1).clamp(0, _maxConcurrentListeners);
    }
  }

  void dispose() {
    for (final sub in _activeListeners.values) {
      sub.cancel();
    }
    _activeListeners.clear();
    _listenerCount = 0;
  }
}
