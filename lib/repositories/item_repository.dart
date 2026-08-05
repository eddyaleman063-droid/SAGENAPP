import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/special_item.dart';
import 'package:sagen/services/app_logger.dart';

abstract class ItemRepository {
  int getQuantity(SpecialItemType type);
  DateTime? getActiveUntil(SpecialItemType type);
  void setQuantity(SpecialItemType type, int quantity);
  void setActiveUntil(SpecialItemType type, DateTime? activeUntil);
  Map<SpecialItemType, int> getAllQuantities();
  void save();
}

class ItemRepositoryImpl implements ItemRepository {
  final SharedPreferences _prefs;
  static const _keyQuantities = 'special_item_quantities';
  static const _keyActiveUntil = 'special_item_active_until';

  Map<SpecialItemType, int> _quantities = {};
  Map<SpecialItemType, DateTime?> _activeUntil = {};

  ItemRepositoryImpl(this._prefs) {
    _load();
  }

  void _load() {
    final rawQ = _prefs.getString(_keyQuantities);
    if (rawQ != null && rawQ.isNotEmpty) {
      try {
        final map = jsonDecode(rawQ) as Map<String, dynamic>;
        _quantities = {};
        for (final entry in map.entries) {
          final match = SpecialItemType.values.where((t) => t.name == entry.key);
          if (match.isNotEmpty) {
            _quantities[match.first] = (entry.value as num?)?.toInt() ?? 0;
          }
        }
      } catch (_) {
        AppLogger().warning('ItemRepository: failed to decode item quantities');
        _quantities = {};
      }
    }

    final rawA = _prefs.getString(_keyActiveUntil);
    if (rawA != null && rawA.isNotEmpty) {
      try {
        final map = jsonDecode(rawA) as Map<String, dynamic>;
        _activeUntil = {};
        for (final entry in map.entries) {
          final match = SpecialItemType.values.where((t) => t.name == entry.key);
          if (match.isNotEmpty) {
            _activeUntil[match.first] =
                entry.value != null ? DateTime.tryParse(entry.value as String) : null;
          }
        }
      } catch (_) {
        AppLogger().warning('ItemRepository: failed to decode active until dates');
        _activeUntil = {};
      }
    }
  }

  @override
  int getQuantity(SpecialItemType type) => _quantities[type] ?? 0;

  @override
  DateTime? getActiveUntil(SpecialItemType type) => _activeUntil[type];

  @override
  void setQuantity(SpecialItemType type, int quantity) {
    final maxLimit = type.maxLimit;
    _quantities[type] = quantity.clamp(0, maxLimit);
  }

  @override
  void setActiveUntil(SpecialItemType type, DateTime? activeUntil) {
    _activeUntil[type] = activeUntil;
  }

  @override
  Map<SpecialItemType, int> getAllQuantities() => Map.unmodifiable(_quantities);

  @override
  void save() {
    _prefs.setString(_keyQuantities, jsonEncode({
      for (final entry in _quantities.entries) entry.key.name: entry.value,
    }));
    _prefs.setString(_keyActiveUntil, jsonEncode({
      for (final entry in _activeUntil.entries)
        entry.key.name: entry.value?.toIso8601String(),
    }));
  }
}
