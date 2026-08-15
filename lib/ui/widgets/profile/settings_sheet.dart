import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/profile/language_selector.dart';
import 'package:sagen/ui/widgets/profile/theme_selector.dart';
import 'package:sagen/core/theme/app_colors.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.xxl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        color: context.surfaceCard,
        boxShadow: AppShadows.card(color: context.subtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: context.subtle,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 18,
                color: PremiumColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.settingsTitle,
                style: AppTextStyle.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ThemeSelector(dark: dark),
          const SizedBox(height: AppSpacing.xl),
          const LanguageSelector(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
