import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/paywall_bottom_sheet.dart';

class SagenSupportCard extends ConsumerWidget {
  const SagenSupportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.md,
      ),
      child: Semantics(
        button: true,
        label: l.sagenPassSupportTitle,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(experienceServiceProvider).lightHaptic();
            PaywallBottomSheet.show(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        PremiumColors.sageWidgetDarkBg,
                        PremiumColors.chatLockedDarkSurface,
                        PremiumColors.gradientSageDark3,
                      ]
                    : [
                        PremiumColors.gradientSupportLight1,
                        PremiumColors.gradientSupportLight2,
                      ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color:
                      (context.isDark
                              ? PremiumColors.shadowDark
                              : PremiumColors.shadowSupportLight)
                          .withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const ExcludeSemantics(
                    child: Icon(
                      Icons.diamond_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.sagenPassSupportTitle,
                        style: AppTextStyle.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.sagenPassSupportSubtitle,
                        style: AppTextStyle.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ExcludeSemantics(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.05),
      ),
    );
  }
}
