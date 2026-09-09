import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/theme/theme_constants.dart';

void main() {
  group('AppMotion.resolve', () {
    test('returns the given duration when animations are enabled', () {
      expect(
        AppMotion.resolve(const Duration(milliseconds: 300)),
        const Duration(milliseconds: 300),
      );
    });

    test('returns zero when reduce-motion is active', () {
      expect(
        AppMotion.resolve(
          const Duration(milliseconds: 300),
          reduceAnimations: true,
        ),
        Duration.zero,
      );
    });
  });

  group('AppGradients', () {
    test('shield gradients use the right palettes', () {
      expect(AppGradients.shieldActive().colors, PremiumColors.gradientActive);
      expect(
        AppGradients.shieldAchievement().colors,
        PremiumColors.gradientAchievement,
      );
      expect(AppGradients.shieldFrozen().colors, PremiumColors.gradientFrozen);
      expect(
        AppGradients.shieldLegendary().colors,
        PremiumColors.gradientShieldLegendary,
      );
      expect(
        AppGradients.shieldCrystal().colors,
        PremiumColors.gradientShieldCrystal,
      );
      expect(
        AppGradients.shieldGlow().colors,
        PremiumColors.gradientShieldGlow,
      );
      expect(
        AppGradients.shieldBasic().colors,
        PremiumColors.gradientShieldBasic,
      );
    });

    test('semantic gradients use the right palettes', () {
      expect(AppGradients.sage().colors, PremiumColors.gradientSage);
      expect(AppGradients.safe().colors, PremiumColors.gradientSafe);
      expect(
        AppGradients.suspicious().colors,
        PremiumColors.gradientSuspicious,
      );
      expect(AppGradients.dangerous().colors, PremiumColors.gradientDangerous);
      expect(AppGradients.primaryHeader().colors, PremiumColors.gradientHeader);
    });
  });

  group('AppShadows', () {
    test('card builds a soft offset shadow with default 8% alpha', () {
      final shadows = AppShadows.card();
      expect(shadows, hasLength(1));
      final s = shadows.first;
      expect(s.offset, const Offset(0, 4));
      expect(s.blurRadius, 10);
      expect(s.color.a, closeTo(0.08, 0.002));
    });

    test('card honors color and radius overrides', () {
      final shadows = AppShadows.card(color: Colors.white, blurRadius: 24);
      expect(shadows.first.blurRadius, 24);
      expect(shadows.first.color, Colors.white.withValues(alpha: 0.08));
    });

    test('glow uses intensity/radius/spread', () {
      final shadows = AppShadows.glow(
        color: const Color(0xFF123456),
        intensity: 0.5,
        radius: 8,
        spread: 1,
      );
      expect(shadows, hasLength(1));
      expect(shadows.first.blurRadius, 8);
      expect(shadows.first.spreadRadius, 1);
      expect(shadows.first.offset, Offset.zero);
      expect(shadows.first.color.a, closeTo(0.5, 0.002));
    });

    test('elevated uses default black with intensity alpha', () {
      final shadows = AppShadows.elevated();
      expect(shadows.first.blurRadius, 14);
      expect(shadows.first.offset, const Offset(0, 6));
    });
  });

  group('AppEffects', () {
    test('softGlow uses 15% alpha', () {
      final glow = AppEffects.softGlow(const Color(0xFF00FF00));
      expect(glow.blurRadius, 20);
      expect(glow.spreadRadius, 1);
      expect(glow.color.a, closeTo(0.15, 0.002));
    });

    test('strongGlow uses 30% alpha', () {
      final glow = AppEffects.strongGlow(const Color(0xFFFF0000));
      expect(glow.blurRadius, 30);
      expect(glow.spreadRadius, 4);
      expect(glow.color.a, closeTo(0.3, 0.002));
    });
  });

  group('AppGlassmorphism', () {
    test('input builds a rounded bordered fill for dark', () {
      final deco = AppGlassmorphism.input(dark: true);
      expect(deco, isA<BoxDecoration>());
      expect(deco.borderRadius, BorderRadius.circular(16));
    });

    test('input builds the light variant too', () {
      final deco = AppGlassmorphism.input(dark: false);
      expect(deco, isA<BoxDecoration>());
    });
  });

  group('constants sanity', () {
    test('spacing progresses monotonically', () {
      final values = [
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
        AppSpacing.huge,
      ];
      for (int i = 1; i < values.length; i++) {
        expect(values[i], greaterThan(values[i - 1]));
      }
    });

    test('durations span the expected range', () {
      expect(AppMotion.fast, const Duration(milliseconds: 150));
      expect(AppMotion.celebration, const Duration(milliseconds: 1200));
      expect(AppDurations.checkIn, const Duration(milliseconds: 1500));
    });

    test('text style aliases match their sources', () {
      expect(AppTextStyle.question, AppTextStyle.title);
      expect(AppTextStyle.cardTitle, AppTextStyle.titleSmall);
    });
  });
}
