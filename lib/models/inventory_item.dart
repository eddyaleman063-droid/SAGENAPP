import '../l10n/app_localizations.dart';

enum InventoryItemType {
  focusElixir,
  phoenixFeather,
  sagesMonocle,
  titaniumShield;

  String get displayName {
    switch (this) {
      case InventoryItemType.focusElixir:
        return 'Focus Elixir';
      case InventoryItemType.phoenixFeather:
        return 'Phoenix Feather';
      case InventoryItemType.sagesMonocle:
        return "Sage's Monocle";
      case InventoryItemType.titaniumShield:
        return 'Titanium Shield';
    }
  }

  String localizedDisplayName(AppLocalizations l) {
    switch (this) {
      case InventoryItemType.focusElixir:
        return l.inventoryFocusElixir;
      case InventoryItemType.phoenixFeather:
        return l.inventoryPhoenixFeather;
      case InventoryItemType.sagesMonocle:
        return l.inventorySagesMonocle;
      case InventoryItemType.titaniumShield:
        return l.inventoryTitaniumShield;
    }
  }

  String get description {
    switch (this) {
      case InventoryItemType.focusElixir:
        return 'Double EXP and Gems for 15 min';
      case InventoryItemType.phoenixFeather:
        return 'Revive your streak if lost within 24h';
      case InventoryItemType.sagesMonocle:
        return 'Eliminates 2 wrong answers in a challenge';
      case InventoryItemType.titaniumShield:
        return 'Automatically protects your streak if you miss a day';
    }
  }

  String localizedDescription(AppLocalizations l) {
    switch (this) {
      case InventoryItemType.focusElixir:
        return l.inventoryFocusElixirDesc;
      case InventoryItemType.phoenixFeather:
        return l.inventoryPhoenixFeatherDesc;
      case InventoryItemType.sagesMonocle:
        return l.inventorySagesMonocleDesc;
      case InventoryItemType.titaniumShield:
        return l.inventoryTitaniumShieldDesc;
    }
  }

  String get iconAsset {
    switch (this) {
      case InventoryItemType.focusElixir:
        return '🧪';
      case InventoryItemType.phoenixFeather:
        return '🪶';
      case InventoryItemType.sagesMonocle:
        return '👁️';
      case InventoryItemType.titaniumShield:
        return '🛡️';
    }
  }
}

/// An inventory item with type and quantity.
class InventoryItem {
  final InventoryItemType type;
  final int quantity;

  const InventoryItem({required this.type, this.quantity = 0});

  InventoryItem copyWith({InventoryItemType? type, int? quantity}) {
    return InventoryItem(
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          type == other.type &&
          quantity == other.quantity;

  @override
  int get hashCode => type.hashCode ^ quantity.hashCode;
}
