import 'package:cloud_functions/cloud_functions.dart';
import '../models/special_item.dart';
import 'app_logger.dart';

/// Server-authoritative inventory access (NUEVO-08).
///
/// Items/cosmetics are granted and persisted SERVER-SIDE (rollChestDrop,
/// spendGems). The client only reads the authoritative state and consumes
/// consumables through useInventoryItem — it never writes the inventory.
class InventoryService {
  static final InventoryService instance = InventoryService._();
  InventoryService._();

  final _logger = AppLogger();
  final _functions = FirebaseFunctions.instance;

  static SpecialItemType? _parseItemName(String name) {
    return SpecialItemType.values.asNameMap()[name];
  }

  /// Fetches the authoritative inventory and returns quantities per type
  /// plus unlocked cosmetics. Returns null on failure.
  Future<Map<SpecialItemType, int>?> fetchQuantities() async {
    final snapshot = await fetchSnapshot();
    return snapshot?.quantities;
  }

  /// Fetches the authoritative inventory snapshot: item quantities/cosmetics
  /// plus the server-tracked XP boost counter (gem-shop purchases, booster
  /// chests and real-money bundles all credit it).
  Future<({Map<SpecialItemType, int> quantities, int purchasedXpBoosts})?>
  fetchSnapshot() async {
    try {
      final result = await _functions.httpsCallable('getInventory').call();
      final data = result.data;
      if (data is! Map) {
        _logger.warning('getInventory returned non-map data');
        return null;
      }

      final specialItems = data['specialItems'];
      if (specialItems is! Map) return null;

      final quantities = <SpecialItemType, int>{};
      specialItems.forEach((key, value) {
        final type = _parseItemName(key.toString());
        if (type != null) {
          quantities[type] = value is num ? value.toInt() : 0;
        }
      });

      final cosmetics = data['cosmetics'];
      if (cosmetics is List) {
        for (final name in cosmetics.whereType<String>()) {
          final type = _parseItemName(name);
          if (type != null) {
            quantities[type] = quantities[type] ?? 1;
          }
        }
      }

      final purchasedXpBoostsValue = data['purchasedXpBoosts'];
      final purchasedXpBoosts = purchasedXpBoostsValue is num
          ? purchasedXpBoostsValue.toInt()
          : 0;

      return (quantities: quantities, purchasedXpBoosts: purchasedXpBoosts);
    } catch (e) {
      _logger.warning('getInventory failed: $e');
      return null;
    }
  }

  /// Consumes a consumable server-authoritatively.
  /// Returns true when the server accepted the consumption.
  Future<bool> useItem(SpecialItemType type, {int quantity = 1}) async {
    try {
      final result = await _functions.httpsCallable('useInventoryItem').call({
        'itemName': type.name,
        'quantity': quantity,
      });
      final data = result.data;
      return data is Map && data['success'] == true;
    } catch (e) {
      _logger.warning('useInventoryItem failed: $e');
      return false;
    }
  }
}
