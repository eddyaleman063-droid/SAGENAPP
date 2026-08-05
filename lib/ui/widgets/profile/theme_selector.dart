import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import '../../../services/analytics_service.dart';
import 'package:sagen/core/theme/app_colors.dart';

class ThemeSelector extends ConsumerWidget {
  final bool dark;
  const ThemeSelector({super.key, required this.dark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final effectiveMode = ref.watch(
      themeProvider.select((t) => t.effectiveMode),
    );
    final options = [
      ThemeOption(value: ThemeMode.system, label: l.themeSystemLabel, icon: Icons.settings_brightness_rounded),
      ThemeOption(value: ThemeMode.light, label: l.themeLightLabel, icon: Icons.light_mode_rounded),
      ThemeOption(value: ThemeMode.dark, label: l.themeDarkLabel, icon: Icons.dark_mode_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.themeLabel,
          style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600,
            color: context.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: options.map((opt) {
            final selected = effectiveMode == opt.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: opt == options.last ? 0 : AppSpacing.sm,
                ),
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: opt.label,
                  child: GestureDetector(
                    onTap: () {
                      ExperienceService.instance.mediumHaptic();
                      ref.read(themeProvider.notifier).setMode(opt.value);
                      AnalyticsService.instance.track(AnalyticEvent.settingsChange, properties: {'setting': 'theme', 'value': opt.value.name});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: selected
                            ? PremiumColors.primary
                            : context.subtle,
                        border: Border.all(
                          color: selected
                              ? PremiumColors.primary
                              : context.subtleBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            opt.icon,
                            size: 20,
                            color: selected
                                ? Colors.white
                                : context.iconSecondary,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            opt.label,
                            style: AppTextStyle.label.copyWith(fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: selected
                                  ? Colors.white
                                  : context.iconSecondary),
                          ),
                        ],
                      ),
                    ),
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

class ThemeOption {
  final ThemeMode value;
  final String label;
  final IconData icon;
  const ThemeOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}
