import 'package:shared_preferences/shared_preferences.dart';
import '../models/chest_type.dart';

/// Repository for inventory data persistence.
/// Tracks opened chests and collected boosts.
abstract class InventoryRepository {
  Map<ChestType, int> get chestsOpened;
  int get totalChestsOpened;
  int get xpBoostsCollected;
  int get bonusMultipliersCollected;

  void recordChestOpened(ChestType type);
  void saveAll(InventoryData data);
}

class InventoryData {
  final Map<ChestType, int> chestsOpened;
  final int totalChestsOpened;
  final int xpBoostsCollected;
  final int bonusMultipliersCollected;

  const InventoryData({
    required this.chestsOpened,
    required this.totalChestsOpened,
    required this.xpBoostsCollected,
    required this.bonusMultipliersCollected,
  });
}

class InventoryRepositoryImpl implements InventoryRepository {
  final SharedPreferences _prefs;

  static const _keyChests = 'inv_chests_opened';
  static const _keyTotal = 'inv_total_chests';
  static const _keyBoosts = 'inv_xp_boosts';
  static const _keyMultipliers = 'inv_bonus_multipliers';

  InventoryRepositoryImpl(this._prefs);

  @override
  Map<ChestType, int> get chestsOpened {
    final raw = _prefs.getString(_keyChests) ?? '';
    if (raw.isEmpty) return {};
    final map = <ChestType, int>{};
    for (final entry in raw.split(',')) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final ct = ChestType.values
            .where((t) => t.name == parts[0])
            .firstOrNull;
        if (ct != null) map[ct] = int.tryParse(parts[1]) ?? 0;
      }
    }
    return map;
  }

  @override
  int get totalChestsOpened => _prefs.getInt(_keyTotal) ?? 0;

  @override
  int get xpBoostsCollected => _prefs.getInt(_keyBoosts) ?? 0;

  @override
  int get bonusMultipliersCollected => _prefs.getInt(_keyMultipliers) ?? 0;

  @override
  void recordChestOpened(ChestType type) {
    final current = chestsOpened;
    current[type] = (current[type] ?? 0) + 1;
    _saveChests(current);
    _prefs.setInt(_keyTotal, totalChestsOpened + 1);
  }

  void _saveChests(Map<ChestType, int> map) {
    final encoded = map.entries
        .map((e) => '${e.key.name}:${e.value}')
        .join(',');
    _prefs.setString(_keyChests, encoded);
  }

  @override
  void saveAll(InventoryData data) {
    _saveChests(data.chestsOpened);
    _prefs.setInt(_keyTotal, data.totalChestsOpened);
    _prefs.setInt(_keyBoosts, data.xpBoostsCollected);
    _prefs.setInt(_keyMultipliers, data.bonusMultipliersCollected);
  }
}
