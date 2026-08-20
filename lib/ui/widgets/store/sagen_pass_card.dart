import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';

/// Prominent entry card to the SAGEN Pass season screen.
class SagenPassCard extends ConsumerWidget {
  const SagenPassCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;
    final pass = ref.watch(
      sagenPassProvider.select(
        (p) => (
          isMaxLevel: p.isMaxLevel,
          progressFraction: p.progressFraction,
          currentLevel: p.currentLevel,
        ),
      ),
    );
    final progress = pass.isMaxLevel ? 1.0 : pass.progressFraction;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        0,
      ),
      child: Semantics(
        button: true,
        label: l.sagenPassTitle,
        child: GestureDetector(
          onTap: () {
            ref.read(experienceServiceProvider).lightHaptic();
            context.pushNamed('pass');
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
                        PremiumColors.gradientPromoDark1,
                        PremiumColors.gradientPromoDark2,
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
                      (dark
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
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.sagenPassTitle,
                        style: AppTextStyle.titleSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.passLevel(pass.currentLevel),
                        style: AppTextStyle.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ExcludeSemantics(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              PremiumColors.accentYellow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
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
        ),
      ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideX(begin: 0.05),
    );
  }
}
