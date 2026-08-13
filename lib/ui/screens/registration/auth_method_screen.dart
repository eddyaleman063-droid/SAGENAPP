import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/app_colors.dart';

class AuthMethodScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const AuthMethodScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.surfaceDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                l.regHowContinue,
                style: AppTextStyle.headline.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.regChooseMethod,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Semantics(
                button: true,
                label: l.authGoogleButton,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(registrationFunnelProvider.notifier)
                        .setAuthMethod('google');
                    onContinue();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      color: context.surfaceTinted,
                      border: Border.all(color: context.subtleBorder),
                    ),
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: Image.asset(
                            'assets/ui/google_logo.png',
                            width: 24,
                            height: 24,
                            cacheWidth: 48,
                            cacheHeight: 48,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.g_mobiledata, size: 24),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Text(
                          l.authGoogleButton,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: l.regEmailOption,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(registrationFunnelProvider.notifier)
                        .setAuthMethod('email');
                    onContinue();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      color: context.surfaceTinted,
                      border: Border.all(color: context.subtleBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_rounded,
                          size: 24,
                          color: PremiumColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Text(
                          l.regEmailOption,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
        ),
      ),
    );
  }
}
