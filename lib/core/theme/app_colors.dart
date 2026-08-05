import 'package:flutter/material.dart';
import 'theme_constants.dart';

/// Theme-aware color accessors.
///
/// Note: See `theme_constants.dart` for the full color system documentation.
/// This file exposes computed colors that adapt to light/dark mode.
/// Interactive accent colors (splashBlue family) and Sage brand colors
/// (gradientSage family) are defined in `PremiumColors` and should NOT
/// be duplicated here — use them directly from `PremiumColors`.
extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isHighContrast {
    final onSurface = Theme.of(this).colorScheme.onSurface;
    return (isDark && onSurface == Colors.white) ||
        (!isDark && onSurface == Colors.black);
  }

  Color get textPrimary => isDark ? Colors.white : PremiumColors.textDark;
  Color get textSecondary {
    if (isHighContrast) return isDark ? Colors.white : const Color(0xFF1A1A1A);
    return isDark ? Colors.white70 : Colors.black54;
  }

  Color get textTertiary {
    if (isHighContrast) return isDark ? Colors.white : Colors.black87;
    return isDark ? Colors.white54 : Colors.black54;
  }

  Color get textDisabled => isDark ? Colors.white38 : Colors.black38;

  Color get surfaceCard => isDark ? PremiumColors.darkCard : Colors.white;
  Color get surfaceBackground => isDark ? PremiumColors.darkBg : PremiumColors.lightBg;

  Color get subtle => isDark ? Colors.white12 : Colors.black12;
  Color get subtleBorder => isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
  Color get surfaceTinted => isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04);
  Color get borderSubtle => isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

  Color get shimmerBase => isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06);
  Color get shimmerHighlight => isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.12);

  Color get disabledBg => isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.12);
  Color get surfaceDeep => isDark ? PremiumColors.deepBackground : PremiumColors.lightBg;
  Color get textHighEmphasis => isDark ? Colors.white : PremiumColors.textDark;
  Color get iconSecondary {
    if (isHighContrast) return isDark ? Colors.white : Colors.black87;
    return isDark ? Colors.white70 : Colors.black54;
  }

  // ── Semantic convenience getters ──────────────────────
  Color get colorSuccess => PremiumColors.success;
  Color get colorWarning => PremiumColors.warning;
  Color get colorError => PremiumColors.error;
  Color get colorInfo => PremiumColors.info;
  Color get colorAccentCyan => PremiumColors.accentCyan;
  Color get colorDeepPurple => const Color(0xFF7C4DFF);
}
