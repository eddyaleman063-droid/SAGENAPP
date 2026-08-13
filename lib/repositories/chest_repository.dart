import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chest_type.dart';
import 'package:sagen/services/app_logger.dart';

/// Repository for chest and gacha data persistence.
/// Tracks chest evolution history and rewards.
abstract class ChestRepository {
  List<Map<String, dynamic>> get evolutionHistory;
  int get totalChestsOpened;
  Map<ChestType, int> get chestTypeCounts;

  void recordEvolution({
    required ChestType initialType,
    required ChestType finalType,
    required List<Map<String, dynamic>> attempts,
  });

  void incrementChestCount(ChestType type);
  void clearHistory();
}

class ChestRepositoryImpl implements ChestRepository {
  final SharedPreferences _prefs;

  static const _keyEvolution = 'chest_evolution_history';
  static const _keyTypeCounts = 'chest_type_counts';

  ChestRepositoryImpl(this._prefs);

  @override
  List<Map<String, dynamic>> get evolutionHistory {
    final raw = _prefs.getString(_keyEvolution);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      AppLogger().warning(
        'ChestRepository: failed to decode evolution history',
      );
      return [];
    }
  }

  @override
  int get totalChestsOpened {
    final counts = chestTypeCounts;
    return counts.values.fold(0, (sum, c) => sum + c);
  }

  @override
  Map<ChestType, int> get chestTypeCounts {
    final raw = _prefs.getString(_keyTypeCounts);
    if (raw == null || raw.isEmpty) return {};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final result = <ChestType, int>{};
      for (final entry in map.entries) {
        final ct = ChestType.values
            .where((t) => t.name == entry.key)
            .firstOrNull;
        if (ct != null && entry.value is int) {
          result[ct] = entry.value;
        }
      }
      return result;
    } catch (_) {
      AppLogger().warning(
        'ChestRepository: failed to decode chest type counts',
      );
      return {};
    }
  }

  @override
  void recordEvolution({
    required ChestType initialType,
    required ChestType finalType,
    required List<Map<String, dynamic>> attempts,
  }) {
    final history = evolutionHistory;
    history.add({
      'initial': initialType.name,
      'final': finalType.name,
      'attempts': attempts,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // Keep only last 100 evolutions
    if (history.length > 100) {
      history.removeRange(0, history.length - 100);
    }
    _prefs.setString(_keyEvolution, jsonEncode(history));
  }

  @override
  void incrementChestCount(ChestType type) {
    final counts = chestTypeCounts;
    counts[type] = (counts[type] ?? 0) + 1;
    _prefs.setString(
      _keyTypeCounts,
      jsonEncode(counts.map((k, v) => MapEntry(k.name, v))),
    );
  }

  @override
  void clearHistory() {
    _prefs.remove(_keyEvolution);
    _prefs.remove(_keyTypeCounts);
  }
}
