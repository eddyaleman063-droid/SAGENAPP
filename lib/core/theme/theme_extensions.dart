import 'package:flutter/material.dart';
import 'theme_constants.dart';

class ChestColors extends ThemeExtension<ChestColors> {
  final Color bronze;
  final Color silver;
  final Color gold;
  final Color legendary;

  const ChestColors({
    required this.bronze,
    required this.silver,
    required this.gold,
    required this.legendary,
  });

  @override
  ChestColors copyWith({
    Color? bronze,
    Color? silver,
    Color? gold,
    Color? legendary,
  }) {
    return ChestColors(
      bronze: bronze ?? this.bronze,
      silver: silver ?? this.silver,
      gold: gold ?? this.gold,
      legendary: legendary ?? this.legendary,
    );
  }

  @override
  ChestColors lerp(ChestColors other, double t) {
    return ChestColors(
      bronze: Color.lerp(bronze, other.bronze, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      legendary: Color.lerp(legendary, other.legendary, t)!,
    );
  }

  static const light = ChestColors(
    bronze: PremiumColors.bronzeGlow,
    silver: PremiumColors.silverMedium,
    gold: PremiumColors.rarityLegendary,
    legendary: PremiumColors.wizardOrange,
  );

  static const dark = ChestColors(
    bronze: PremiumColors.bronzeLight,
    silver: PremiumColors.chestSilverGlow,
    gold: PremiumColors.achievementTier30,
    legendary: PremiumColors.rarityLegendary,
  );
}

class GemColors extends ThemeExtension<GemColors> {
  final Color primary;
  final Color secondary;

  const GemColors({required this.primary, required this.secondary});

  @override
  GemColors copyWith({Color? primary, Color? secondary}) {
    return GemColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }

  @override
  GemColors lerp(GemColors other, double t) {
    return GemColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
    );
  }

  static const light = GemColors(
    primary: PremiumColors.gemPrimary,
    secondary: PremiumColors.gemSecondaryLight,
  );

  static const dark = GemColors(
    primary: PremiumColors.gemPrimary,
    secondary: PremiumColors.gemSecondaryDark,
  );
}

class StreakColors extends ThemeExtension<StreakColors> {
  final Color chispa;
  final Color constante;
  final Color azul;
  final Color cosmica;

  const StreakColors({
    required this.chispa,
    required this.constante,
    required this.azul,
    required this.cosmica,
  });

  @override
  StreakColors copyWith({
    Color? chispa,
    Color? constante,
    Color? azul,
    Color? cosmica,
  }) {
    return StreakColors(
      chispa: chispa ?? this.chispa,
      constante: constante ?? this.constante,
      azul: azul ?? this.azul,
      cosmica: cosmica ?? this.cosmica,
    );
  }

  @override
  StreakColors lerp(StreakColors other, double t) {
    return StreakColors(
      chispa: Color.lerp(chispa, other.chispa, t)!,
      constante: Color.lerp(constante, other.constante, t)!,
      azul: Color.lerp(azul, other.azul, t)!,
      cosmica: Color.lerp(cosmica, other.cosmica, t)!,
    );
  }

  static const light = StreakColors(
    chispa: PremiumColors.streakSpark,
    constante: PremiumColors.streakConstantLight,
    azul: PremiumColors.streakBlueLight,
    cosmica: PremiumColors.streakCosmicLight,
  );

  static const dark = StreakColors(
    chispa: PremiumColors.rarityLegendary,
    constante: PremiumColors.streakConstantDark,
    azul: PremiumColors.streakBlueDark,
    cosmica: PremiumColors.gold,
  );
}
