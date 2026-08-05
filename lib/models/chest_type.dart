import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../l10n/app_localizations.dart';
import '../core/theme/theme_constants.dart';

/// Rarity tiers for the chest reward system.
@JsonEnum()
enum ChestType {
  bronze,
  silver,
  gold,
  legendary;

  String get label {
    switch (this) {
      case ChestType.bronze: return 'Bronce';
      case ChestType.silver: return 'Plata';
      case ChestType.gold: return 'Oro';
      case ChestType.legendary: return 'Legendario';
    }
  }

  String localizedLabel(AppLocalizations l) {
    switch (this) {
      case ChestType.bronze: return l.chestTypeBronze;
      case ChestType.silver: return l.chestTypeSilver;
      case ChestType.gold: return l.chestTypeGold;
      case ChestType.legendary: return l.chestTypeLegendary;
    }
  }

  Color get color {
    switch (this) {
      case ChestType.bronze: return PremiumColors.bronzeGlow;
      case ChestType.silver: return PremiumColors.silverMedium;
      case ChestType.gold: return PremiumColors.rarityLegendary;
      case ChestType.legendary: return PremiumColors.deepPurple;
    }
  }

  Color get glowColor {
    switch (this) {
      case ChestType.bronze: return PremiumColors.bronzeGlow;
      case ChestType.silver: return PremiumColors.chestSilverGlow;
      case ChestType.gold: return PremiumColors.rarityLegendary;
      case ChestType.legendary: return PremiumColors.chestLegendaryGlow2;
    }
  }

}
