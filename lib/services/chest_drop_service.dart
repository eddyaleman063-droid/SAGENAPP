import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../models/chest_reward.dart';
import '../models/chest_type.dart';
import 'app_logger.dart';

/// Client-side chest drop roller that calls Cloud Functions.
class ChestDropService {
  static final ChestDropService instance = ChestDropService._();
  ChestDropService._();

  @visibleForTesting
  ChestDropService.private();

  FirebaseFunctions? _functions;
  final _logger = AppLogger();

  FirebaseFunctions get _getFunctions =>
      _functions ??= FirebaseFunctions.instance;

  static const int _maxRetries = 3;
  static const int _baseDelayMs = 1000;

  Future<ChestReward> roll(ChestType type) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final result = await _getFunctions.httpsCallable('rollChestDrop').call({
          'chestType': type.name,
        });

        final data = result.data;
        if (data is! Map<String, dynamic>) {
          _logger.warning(
            'Chest drop returned non-map data: ${data.runtimeType}',
          );
          return const ChestReward(xp: 0);
        }
        return ChestReward(
          xp: (data['xp'] as num?)?.toInt() ?? 0,
          streakShields: (data['streakShield'] == true) ? 1 : null,
          xpBoost: data['xpBoost'] == true,
        );
      } catch (e) {
        _logger.warning('Chest drop attempt $attempt failed: $e');
        if (attempt < _maxRetries - 1) {
          final delay = _baseDelayMs * pow(2, attempt).toInt();
          await Future.delayed(Duration(milliseconds: delay));
        }
      }
    }
    _logger.error('Chest drop: all $_maxRetries attempts failed for $type');
    return const ChestReward(xp: 0);
  }
}
