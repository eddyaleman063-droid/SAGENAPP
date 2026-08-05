import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';

/// Shared onboarding progress bar with back button.
/// Replaces the duplicated header pattern across 9+ onboarding screens.
class OnboardingProgressBar extends ConsumerWidget {
  final double progress;
  final VoidCallback? onBack;

  const OnboardingProgressBar({
    super.key,
    required this.progress,
    this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: context.iconSecondary,
            ),
            onPressed: () {
              ref.read(experienceServiceProvider).lightHaptic();
              (onBack ?? () => context.pop())();
            },
            tooltip: AppLocalizations.of(context)!.backButton,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: context.disabledBg,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: PremiumColors.primaryAccent,
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
        ],
      ),
    );
  }
}
