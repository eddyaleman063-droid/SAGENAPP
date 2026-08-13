import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/payment_provider.dart';
import 'package:sagen/providers/providers.dart';

class PaymentFailedScreen extends ConsumerWidget {
  final String? error;

  const PaymentFailedScreen({super.key, this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumColors.error.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: PremiumColors.error,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l.paymentNotCompleted,
                style: AppTextStyle.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMd.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: Semantics(
                        button: true,
                        label: l.paymentTryAgain,
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(experienceServiceProvider).lightHaptic();
                            ref.read(paymentProvider.notifier).reset();
                            context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                          ),
                          child: Text(
                            l.paymentTryAgain,
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: Semantics(
                        button: true,
                        label: l.paymentGoHome,
                        child: FilledButton(
                          onPressed: () {
                            ref.read(experienceServiceProvider).lightHaptic();
                            ref.read(paymentProvider.notifier).reset();
                            context.goNamed('main');
                          },
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                          ),
                          child: Text(
                            l.paymentGoHome,
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        ),
      ),
    );
  }
}
