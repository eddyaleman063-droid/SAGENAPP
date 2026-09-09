import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/theme/app_theme.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/core/theme/theme_extensions.dart';

void main() {
  group('AppTheme', () {
    test('light uses M3, light brightness and light background', () {
      final t = AppTheme.light;
      expect(t.useMaterial3, isTrue);
      expect(t.brightness, Brightness.light);
      expect(t.scaffoldBackgroundColor, PremiumColors.lightBg);
    });

    test('dark uses M3, dark brightness and dark background', () {
      final t = AppTheme.dark;
      expect(t.useMaterial3, isTrue);
      expect(t.brightness, Brightness.dark);
      expect(t.scaffoldBackgroundColor, PremiumColors.darkBg);
    });

    test('light registers the light theme extensions', () {
      final t = AppTheme.light;
      expect(t.extension<ChestColors>(), ChestColors.light);
      expect(t.extension<GemColors>(), GemColors.light);
      expect(t.extension<StreakColors>(), StreakColors.light);
    });

    test('dark registers the dark theme extensions', () {
      final t = AppTheme.dark;
      expect(t.extension<ChestColors>(), ChestColors.dark);
      expect(t.extension<GemColors>(), GemColors.dark);
      expect(t.extension<StreakColors>(), StreakColors.dark);
    });

    test(
      'highContrastLight derives from light and keeps contrast colorScheme',
      () {
        final t = AppTheme.highContrastLight;
        expect(t.brightness, Brightness.light);
        expect(t.colorScheme.onSurface, Colors.black);
        expect(
          t.bottomNavigationBarTheme.selectedItemColor,
          PremiumColors.primary,
        );
      },
    );

    test(
      'highContrastDark derives from dark and keeps contrast colorScheme',
      () {
        final t = AppTheme.highContrastDark;
        expect(t.brightness, Brightness.dark);
        expect(t.colorScheme.onSurface, Colors.white);
        expect(t.dialogTheme.backgroundColor, const Color(0xFF1E1E1E));
      },
    );

    test('getters are stable across repeated reads (cached instances)', () {
      expect(identical(AppTheme.light, AppTheme.light), isTrue);
      expect(identical(AppTheme.dark, AppTheme.dark), isTrue);
      expect(
        identical(AppTheme.highContrastLight, AppTheme.highContrastLight),
        isTrue,
      );
      expect(
        identical(AppTheme.highContrastDark, AppTheme.highContrastDark),
        isTrue,
      );
    });

    test('all four themes expose non-null app bar and dialog data', () {
      for (final t in [
        AppTheme.light,
        AppTheme.dark,
        AppTheme.highContrastLight,
        AppTheme.highContrastDark,
      ]) {
        expect(t.appBarTheme, isNotNull);
        expect(t.dialogTheme, isNotNull);
        expect(t.chipTheme, isNotNull);
      }
    });
  });
}
