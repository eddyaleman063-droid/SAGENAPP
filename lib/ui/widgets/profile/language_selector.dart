import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import '../../../services/analytics_service.dart';
import 'package:sagen/core/theme/app_colors.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final current = ref.watch(languageProvider.select((s) => s.language));
    final options = [
      LanguageOption(value: AppLanguage.es, label: l.languageSpanish),
      LanguageOption(value: AppLanguage.en, label: l.languageEnglish),
      LanguageOption(value: AppLanguage.fr, label: l.languageFrench),
      LanguageOption(value: AppLanguage.pt, label: l.languagePortuguese),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.settingsLanguage,
          style: AppTextStyle.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 2.8,
          children: options.map((opt) {
            final selected = current == opt.value;
            return Semantics(
              button: true,
              selected: selected,
              label: opt.label,
              child: GestureDetector(
                onTap: () {
                  ExperienceService.instance.mediumHaptic();
                  ref.read(languageProvider.notifier).setLanguage(opt.value);
                  AnalyticsService.instance.track(
                    AnalyticEvent.settingsChange,
                    properties: {
                      'setting': 'language',
                      'value': opt.value.code,
                    },
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: selected ? PremiumColors.primary : context.subtle,
                    border: Border.all(
                      color: selected
                          ? PremiumColors.primary
                          : context.subtleBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opt.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.label.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected
                              ? Colors.white
                              : context.iconSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class LanguageOption {
  final AppLanguage value;
  final String label;
  const LanguageOption({required this.value, required this.label});
}
