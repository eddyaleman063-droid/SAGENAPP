import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/app_logger.dart';

/// Repository for gamification data persistence.
/// Tracks daily chest and missions.
abstract class GamificationRepository {
  bool get hasUnclaimedDailyChest;
  bool get canClaimDailyChest;
  int claimDailyChest();
  void setUnclaimedChest(bool value);
  void checkMidnightReset();
  int get secondsUntilMidnight;
  Map<String, int> getMissions();
  void saveMissions(Map<String, int> missions);
  void incrementMission(String missionId, {int amount = 1});
  bool isMissionComplete(String missionId, {int target = 1});
  Set<String> getCountedMissions();
  void saveCountedMissions(Set<String> missions);
}

class GamificationRepositoryImpl implements GamificationRepository {
  final SharedPreferences _prefs;

  /// Base reward for claiming the daily chest. Server may override.
  static const int baseDailyChestReward = 2;

  GamificationRepositoryImpl(this._prefs);

  static const _keyLastClaim = 'gamification_last_claim_date';
  static const _keyUnclaimedChest = 'gamification_unclaimed_chest';
  static const _keyMissions = 'gamification_missions';
  static const _keyCountedMissions = 'gamification_counted_missions';

  Map<String, int>? _missionsCache;

  String _today() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  bool get hasUnclaimedDailyChest {
    final stored = _prefs.getBool(_keyUnclaimedChest) ?? false;
    if (!stored) return false;
    final lastClaimDate = _prefs.getString(_keyLastClaim) ?? '';
    return lastClaimDate == _today();
  }

  @override
  bool get canClaimDailyChest {
    final lastClaimDate = _prefs.getString(_keyLastClaim) ?? '';
    if (lastClaimDate.isNotEmpty && lastClaimDate.compareTo(_today()) > 0) {
      return false;
    }
    if (lastClaimDate != _today()) return true;
    return _prefs.getBool(_keyUnclaimedChest) ?? false;
  }

  @override
  int claimDailyChest() {
    final storedDate = _prefs.getString(_keyLastClaim) ?? '';
    if (storedDate.isNotEmpty && storedDate.compareTo(_today()) > 0) {
      _prefs.setBool(_keyUnclaimedChest, false);
      throw PlatformException(
        code: 'CLOCK_MANIPULATION',
        message: 'Clock manipulation detected. Cannot claim chest.',
      );
    }

    if (storedDate != _today()) {
      _prefs.setBool(_keyUnclaimedChest, true);
      _prefs.setString(_keyLastClaim, _today());
    }

    if (!(_prefs.getBool(_keyUnclaimedChest) ?? false)) {
      throw StateError('No chest available to claim today');
    }

    const reward = baseDailyChestReward;
    _prefs.setBool(_keyUnclaimedChest, false);
    return reward;
  }

  @override
  void setUnclaimedChest(bool value) {
    _prefs.setBool(_keyUnclaimedChest, value);
  }

  @override
  void checkMidnightReset() {
    final lastClaimDate = _prefs.getString(_keyLastClaim) ?? '';
    if (lastClaimDate.isNotEmpty && lastClaimDate != _today()) {
      final wasUnclaimed = _prefs.getBool(_keyUnclaimedChest) ?? false;
      if (wasUnclaimed) {
        _prefs.setBool(_keyUnclaimedChest, false);
      }
    }
  }

  @override
  int get secondsUntilMidnight {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now).inSeconds;
  }

  @override
  Map<String, int> getMissions() {
    if (_missionsCache != null) return Map<String, int>.from(_missionsCache!);
    final raw = _prefs.getString(_keyMissions);
    if (raw == null) return {};
    try {
      final parsed = jsonDecode(raw);
      if (parsed is Map) {
        _missionsCache = Map<String, int>.from(parsed.map((k, v) => MapEntry(k.toString(), (v as num).toInt())));
        return Map<String, int>.from(_missionsCache!);
      }
      return {};
    } catch (_) {
      AppLogger().warning('GamificationRepository: failed to decode missions JSON');
      return _migrateCsvMissions(raw);
    }
  }

  Map<String, int> _migrateCsvMissions(String raw) {
    try {
      final map = <String, int>{};
      for (final pair in raw.split(',')) {
        if (pair.isEmpty) continue;
        final colonIdx = pair.lastIndexOf(':');
        if (colonIdx < 0) continue;
        final key = pair.substring(0, colonIdx);
        final value = int.tryParse(pair.substring(colonIdx + 1)) ?? 0;
        map[key] = value;
      }
      if (map.isNotEmpty) {
        saveMissions(map);
      }
      return map;
    } catch (_) {
      AppLogger().warning('GamificationRepository: failed to parse CSV missions');
      return {};
    }
  }

  @override
  void saveMissions(Map<String, int> missions) {
    _missionsCache = Map<String, int>.from(missions);
    _prefs.setString(_keyMissions, jsonEncode(missions));
  }

  @override
  void incrementMission(String missionId, {int amount = 1}) {
    final missions = getMissions();
    missions[missionId] = (missions[missionId] ?? 0) + amount;
    _missionsCache = missions;
    _prefs.setString(_keyMissions, jsonEncode(missions));
  }

  @override
  bool isMissionComplete(String missionId, {int target = 1}) {
    final missions = getMissions();
    return (missions[missionId] ?? 0) >= target;
  }

  @override
  Set<String> getCountedMissions() {
    final raw = _prefs.getString(_keyCountedMissions);
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  @override
  void saveCountedMissions(Set<String> missions) {
    _prefs.setString(_keyCountedMissions, missions.join(','));
  }
}
