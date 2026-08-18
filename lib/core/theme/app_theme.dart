import 'package:flutter/material.dart';
import 'theme_constants.dart';
import 'theme_extensions.dart';

class AppTheme {
  AppTheme._();

  static ThemeData? _cachedLight;
  static ThemeData? _cachedDark;
  static ThemeData? _cachedHighContrastLight;
  static ThemeData? _cachedHighContrastDark;

  static ThemeData get light => _cachedLight ??= ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: PremiumColors.primary,
    scaffoldBackgroundColor: PremiumColors.lightBg,
    cardTheme: const CardThemeData(color: Colors.white),
    dividerTheme: DividerThemeData(color: Colors.black.withValues(alpha: 0.08)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: PremiumColors.textDark,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: PremiumColors.primary,
      unselectedItemColor: Colors.black54,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: PremiumColors.lightBg,
      selectedColor: PremiumColors.primary.withValues(alpha: 0.15),
      labelStyle: const TextStyle(color: PremiumColors.textDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    extensions: const [ChestColors.light, GemColors.light, StreakColors.light],
  );

  static ThemeData get dark => _cachedDark ??= ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: PremiumColors.primary,
    scaffoldBackgroundColor: PremiumColors.darkBg,
    cardTheme: const CardThemeData(color: PremiumColors.darkCard),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.08)),
    appBarTheme: const AppBarTheme(
      backgroundColor: PremiumColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PremiumColors.darkSurface,
      selectedItemColor: PremiumColors.primary,
      unselectedItemColor: Colors.white54,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: PremiumColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: PremiumColors.darkSurface,
      selectedColor: PremiumColors.primary.withValues(alpha: 0.15),
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    extensions: const [ChestColors.dark, GemColors.dark, StreakColors.dark],
  );

  static ThemeData
  get highContrastLight => _cachedHighContrastLight ??= light.copyWith(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: PremiumColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          onSurface: Colors.black,
          onSurfaceVariant: const Color(0xFF1A1A1A),
          surfaceContainerHigh: const Color(0xFFE8E8E8),
          surfaceContainerHighest: const Color(0xFFD8D8D8),
        ),
    cardTheme: const CardThemeData(color: Colors.white),
    dividerTheme: DividerThemeData(color: Colors.black.withValues(alpha: 0.3)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: PremiumColors.primary,
      unselectedItemColor: Colors.black54,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFE0E0E0),
      selectedColor: PremiumColors.primary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: Colors.black),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    extensions: const [ChestColors.light, GemColors.light, StreakColors.light],
  );

  static ThemeData
  get highContrastDark => _cachedHighContrastDark ??= dark.copyWith(
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: PremiumColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          onSurface: Colors.white,
          onSurfaceVariant: const Color(0xFFE0E0E0),
          surfaceContainerHigh: const Color(0xFF2A2A2A),
          surfaceContainerHighest: const Color(0xFF353535),
        ),
    cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.3)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      selectedItemColor: PremiumColors.primary,
      unselectedItemColor: Colors.white70,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: PremiumColors.primary.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    extensions: const [ChestColors.dark, GemColors.dark, StreakColors.dark],
  );
}
