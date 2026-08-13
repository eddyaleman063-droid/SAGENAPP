import 'package:cloud_functions/cloud_functions.dart';
import '../core/result.dart';
import 'app_logger.dart';

/// Server-authoritative gamification claims.
/// Replaces client-side SharedPreferences-based daily claims.
/// All responses are validated to prevent crashes from malformed server data.
class GamificationCloudService {
  GamificationCloudService._();
  static final GamificationCloudService instance = GamificationCloudService._();

  final _functions = FirebaseFunctions.instance;
  final _logger = AppLogger();

  /// Validates that a response is a non-null Map.
  static Map<String, dynamic>? _validateResponse(dynamic data) {
    if (data == null) return null;
    if (data is! Map<String, dynamic>) return null;
    return data;
  }

  /// Safely extracts a bool from a map, returning defaultValue if missing or wrong type.
  static bool _safeBool(Map<String, dynamic> data, String key, [bool defaultValue = false]) {
    final val = data[key];
    if (val is bool) return val;
    return defaultValue;
  }

  /// Safely extracts an int from a map, returning defaultValue if missing or wrong type.
  static int _safeInt(Map<String, dynamic> data, String key, [int defaultValue = 0]) {
    final val = data[key];
    if (val is int) return val;
    if (val is num) return val.toInt();
    return defaultValue;
  }

  /// Safely extracts a String from a map, returning defaultValue if missing or wrong type.
  static String _safeString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final val = data[key];
    if (val is String) return val;
    return defaultValue;
  }

  // ─── Result-typed methods ────────────────────────────────────

  /// Claims the daily chest with explicit error handling.
  Future<AppResult<Map<String, dynamic>>> claimDailyChestResult() async {
    try {
      final result = await _functions.httpsCallable('claimDailyChest').call();
      final data = _validateResponse(result.data);
      if (data == null) return AppResult.ok({'alreadyClaimed': true});
      if (_safeBool(data, 'alreadyClaimed')) return AppResult.ok({'alreadyClaimed': true});
      return AppResult.ok({
        'xp': _safeInt(data, 'xp', 10),
        'chestType': _safeString(data, 'chestType', 'bronze'),
        'alreadyClaimed': false,
      });
    } on FirebaseFunctionsException catch (e) {
      _logger.error('GamificationCloudService.claimDailyChest failed: ${e.code}', e);
      return AppResult.error(NetworkError(message: e.code, originalError: e));
    } catch (e) {
      _logger.error('GamificationCloudService.claimDailyChest failed', e);
      return AppResult.error(NetworkError(message: 'unknown', originalError: e));
    }
  }

  /// Claims an ad reward with explicit error handling.
  Future<AppResult<Map<String, dynamic>>> claimAdRewardResult() async {
    try {
      final result = await _functions.httpsCallable('claimAdReward').call();
      final data = _validateResponse(result.data);
      if (data == null) return AppResult.ok({'limitReached': true});
      if (_safeBool(data, 'limitReached')) return AppResult.ok({'limitReached': true});
      return AppResult.ok({
        'xp': _safeInt(data, 'xp', 50),
        'limitReached': false,
      });
    } on FirebaseFunctionsException catch (e) {
      _logger.error('GamificationCloudService.claimAdReward failed: ${e.code}', e);
      return AppResult.error(NetworkError(message: e.code, originalError: e));
    } catch (e) {
      _logger.error('GamificationCloudService.claimAdReward failed', e);
      return AppResult.error(NetworkError(message: 'unknown', originalError: e));
    }
  }

  /// Earns Sagen Pass SP with explicit error handling.
  /// The server decides the SP amount by `reason`; clients never send an amount.
  Future<AppResult<Map<String, dynamic>>> earnSPResult({String? reason}) async {
    try {
      final result = await _functions.httpsCallable('earnSagenPassSP').call({
        'reason': reason ?? 'lesson',
      });
      final data = _validateResponse(result.data);
      if (data == null) return AppResult.error(const SyncError('null response'));
      return AppResult.ok({
        'sp': _safeInt(data, 'sp'),
        'level': _safeInt(data, 'level', 1),
      });
    } on FirebaseFunctionsException catch (e) {
      _logger.error('GamificationCloudService.earnSP failed: ${e.code}', e);
      return AppResult.error(NetworkError(message: e.code, originalError: e));
    } catch (e) {
      _logger.error('GamificationCloudService.earnSP failed', e);
      return AppResult.error(NetworkError(message: 'unknown', originalError: e));
    }
  }

  /// Claims a Sagen Pass level reward with explicit error handling.
  Future<AppResult<Map<String, dynamic>>> claimPassRewardResult(int level) async {
    try {
      final result = await _functions.httpsCallable('claimSagenPassReward').call({
        'level': level,
      });
      final data = _validateResponse(result.data);
      if (data == null) return AppResult.ok({'alreadyClaimed': true});
      if (_safeBool(data, 'alreadyClaimed')) return AppResult.ok({'alreadyClaimed': true});
      return AppResult.ok({
        'reward': _safeString(data, 'reward', 'xp'),
        'amount': _safeInt(data, 'amount'),
        'alreadyClaimed': false,
        'claimedLevels': data['claimedLevels'],
        'seasonStart': data['seasonStart'],
      });
    } on FirebaseFunctionsException catch (e) {
      _logger.error('GamificationCloudService.claimPassReward failed: ${e.code}', e);
      return AppResult.error(NetworkError(message: e.code, originalError: e));
    } catch (e) {
      _logger.error('GamificationCloudService.claimPassReward failed', e);
      return AppResult.error(NetworkError(message: 'unknown', originalError: e));
    }
  }

  /// Fetches Sagen Pass season data with explicit error handling.
  Future<AppResult<Map<String, dynamic>>> getSagenPassSeasonResult() async {
    try {
      final result = await _functions.httpsCallable('getSagenPassSeason').call();
      final data = _validateResponse(result.data);
      if (data == null) return AppResult.error(const SyncError('null response'));
      return AppResult.ok({
        'seasonStart': data['seasonStart'],
        'level': _safeInt(data, 'level', 1),
        'sp': _safeInt(data, 'sp'),
        'claimed': data['claimed'],
      });
    } on FirebaseFunctionsException catch (e) {
      _logger.error('GamificationCloudService.getSagenPassSeason failed: ${e.code}', e);
      return AppResult.error(NetworkError(message: e.code, originalError: e));
    } catch (e) {
      _logger.error('GamificationCloudService.getSagenPassSeason failed', e);
      return AppResult.error(NetworkError(message: 'unknown', originalError: e));
    }
  }

  // ─── Legacy methods (backward compatible) ────────────────────

  Future<Map<String, dynamic>?> claimDailyChest() async {
    final result = await claimDailyChestResult();
    return result.value;
  }

  Future<Map<String, dynamic>?> claimAdReward() async {
    final result = await claimAdRewardResult();
    return result.value;
  }

  Future<Map<String, dynamic>?> earnSP({String? reason}) async {
    final result = await earnSPResult(reason: reason);
    return result.value;
  }

  Future<Map<String, dynamic>?> claimPassReward(int level) async {
    final result = await claimPassRewardResult(level);
    return result.value;
  }

  Future<Map<String, dynamic>?> getSagenPassSeason() async {
    final result = await getSagenPassSeasonResult();
    return result.value;
  }
}
