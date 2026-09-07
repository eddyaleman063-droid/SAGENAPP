import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:sagen/ui/widgets/common/tap_scale.dart';

/// NUEVO-fix (ronda 18): selector de tamaño de texto en vivo. Replica el patrón
/// visual de ThemeSelector pero su estado vive en ExperienceService (ChangeNotifier)
/// y escala todo el layout vía el MediaQuery.textScaler que ya cablea main.dart.
class FontSizeOption {
  final double value;
  final String label;
  final IconData icon;
  const FontSizeOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class FontSizeSelector extends ConsumerWidget {
  final bool dark;
  const FontSizeSelector({super.key, required this.dark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final options = [
      FontSizeOption(
        value: 0.85,
        label: l.fontSizeSmall,
        icon: Icons.text_fields,
      ),
      FontSizeOption(
        value: 1.0,
        label: l.fontSizeNormal,
        icon: Icons.text_fields,
      ),
      FontSizeOption(
        value: 1.2,
        label: l.fontSizeLarge,
        icon: Icons.text_fields,
      ),
      FontSizeOption(
        value: 1.4,
        label: l.fontSizeXLarge,
        icon: Icons.text_fields,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              const Icon(
                Icons.format_size_rounded,
                size: 18,
                color: PremiumColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.fontSizeTitle,
                style: AppTextStyle.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: options.indexed.map((entry) {
            final i = entry.$1;
            final opt = entry.$2;
            final iconSize = opt.value * 20;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i == options.length - 1 ? 0 : AppSpacing.sm,
                ),
                child: Semantics(
                  button: true,
                  selected: false,
                  label: opt.label,
                  child: TapScale(
                    child: GestureDetector(
                      onTap: () {
                        final exp = ref.read(experienceServiceProvider);
                        exp.mediumHaptic();
                        exp.setFontSizeScale(opt.value);
                        AnalyticsService.instance.track(
                          AnalyticEvent.settingsChange,
                          properties: {
                            'setting': 'font_size',
                            'value': opt.value.toString(),
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          color: context.subtle,
                          border: Border.all(color: context.subtleBorder),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              opt.icon,
                              size: iconSize,
                              color: context.iconSecondary,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              opt.label,
                              style: AppTextStyle.label.copyWith(
                                color: context.iconSecondary,
                              ),
                            ),
                          ],
                        ),
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
