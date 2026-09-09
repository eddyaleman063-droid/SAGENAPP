import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/core/theme/theme_extensions.dart';

void main() {
  group('ChestColors', () {
    const base = ChestColors(
      bronze: Color(0xFF111111),
      silver: Color(0xFF222222),
      gold: Color(0xFF333333),
      legendary: Color(0xFF444444),
    );

    test('copyWith keeps unchanged colors', () {
      final copy = base.copyWith(bronze: const Color(0xFFFFFFFF));
      expect(copy.bronze, const Color(0xFFFFFFFF));
      expect(copy.silver, base.silver);
      expect(copy.gold, base.gold);
      expect(copy.legendary, base.legendary);
    });

    test('lerp interpolates each channel', () {
      const other = ChestColors(
        bronze: Color(0xFFFFFFFF),
        silver: Color(0xFFFFFFFF),
        gold: Color(0xFFFFFFFF),
        legendary: Color(0xFFFFFFFF),
      );
      final mid = base.lerp(other, 0.5);
      for (final c in [mid.bronze, mid.silver, mid.gold, mid.legendary]) {
        expect(c.r, greaterThan(17 / 255));
        expect(c.r, lessThan(1.0));
      }
      expect(base.lerp(other, 0).bronze, base.bronze);
      expect(base.lerp(other, 1).bronze, other.bronze);
    });

    test('lerp at t=0 returns base colors', () {
      final start = base.lerp(base, 0);
      expect(start.bronze, base.bronze);
      expect(start.silver, base.silver);
      expect(start.gold, base.gold);
      expect(start.legendary, base.legendary);
    });

    test('light and dark presets are static consts', () {
      expect(ChestColors.light.bronze, PremiumColors.bronzeGlow);
      expect(ChestColors.light.legendary, PremiumColors.wizardOrange);
      expect(ChestColors.dark.silver, PremiumColors.chestSilverGlow);
      expect(ChestColors.dark.legendary, PremiumColors.rarityLegendary);
    });
  });

  group('GemColors', () {
    const base = GemColors(
      primary: Color(0xFF111111),
      secondary: Color(0xFF222222),
    );

    test('copyWith keeps unchanged colors', () {
      final copy = base.copyWith(primary: const Color(0xFFFFFFFF));
      expect(copy.primary, const Color(0xFFFFFFFF));
      expect(copy.secondary, base.secondary);
    });

    test('lerp interpolates each channel', () {
      const other = GemColors(
        primary: Color(0xFF030303),
        secondary: Color(0xFF030303),
      );
      final quarter = base.lerp(other, 0.25);
      expect(quarter.primary, isNot(base.primary));
      expect(quarter.primary, isNot(other.primary));
      expect(quarter.secondary, isNot(base.secondary));
      expect(quarter.secondary, isNot(other.secondary));
      expect(base.lerp(other, 0).primary, base.primary);
      expect(base.lerp(other, 1).secondary, other.secondary);
    });

    test('light and dark presets use gem palette', () {
      expect(GemColors.light.primary, PremiumColors.gemPrimary);
      expect(GemColors.light.secondary, PremiumColors.gemSecondaryLight);
      expect(GemColors.dark.primary, PremiumColors.gemPrimary);
      expect(GemColors.dark.secondary, PremiumColors.gemSecondaryDark);
    });
  });

  group('StreakColors', () {
    const base = StreakColors(
      chispa: Color(0xFF111111),
      constante: Color(0xFF222222),
      azul: Color(0xFF333333),
      cosmica: Color(0xFF444444),
    );

    test('copyWith keeps unchanged colors', () {
      final copy = base.copyWith(constante: const Color(0xFFFFFFFF));
      expect(copy.constante, const Color(0xFFFFFFFF));
      expect(copy.chispa, base.chispa);
      expect(copy.azul, base.azul);
      expect(copy.cosmica, base.cosmica);
    });

    test('lerp interpolates each channel', () {
      const white = StreakColors(
        chispa: Color(0xFFFFFFFF),
        constante: Color(0xFFFFFFFF),
        azul: Color(0xFFFFFFFF),
        cosmica: Color(0xFFFFFFFF),
      );
      final mid = base.lerp(white, 0.5);
      for (final c in [mid.chispa, mid.constante, mid.azul, mid.cosmica]) {
        expect(c.r, greaterThan(17 / 255));
        expect(c.r, lessThan(1.0));
      }
      expect(base.lerp(white, 0).chispa, base.chispa);
      expect(base.lerp(white, 1).cosmica, white.cosmica);
    });

    test('light and dark presets are static consts', () {
      expect(StreakColors.light.chispa, PremiumColors.streakSpark);
      expect(StreakColors.light.cosmica, PremiumColors.streakCosmicLight);
      expect(StreakColors.dark.chispa, PremiumColors.rarityLegendary);
      expect(StreakColors.dark.cosmica, PremiumColors.gold);
    });
  });

  test('all extension consts are compile-time resolvable', () {
    expect(ChestColors.light, isA<ChestColors>());
    expect(ChestColors.dark, isA<ChestColors>());
    expect(GemColors.light, isA<GemColors>());
    expect(GemColors.dark, isA<GemColors>());
    expect(StreakColors.light, isA<StreakColors>());
    expect(StreakColors.dark, isA<StreakColors>());
  });
}
