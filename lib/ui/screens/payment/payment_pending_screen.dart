import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/payment_provider.dart';
import '../../widgets/common/sagen_notification.dart';

class PaymentPendingScreen extends ConsumerWidget {
  const PaymentPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final payment = ref.watch(paymentProvider);
    final pollAttempts = payment.pollAttempts;
    final isPolling = payment.status == PaymentStatus.waitingPayment;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.paymentCancelTitle),
            content: Text(l.paymentCancelContent),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  context.go('/home');
                },
                child: Text(l.exitText),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExcludeSemantics(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: isPolling
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              const SizedBox(
                                width: 100,
                                height: 100,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    PremiumColors.warning,
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: PremiumColors.warning.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.hourglass_top_rounded,
                                  color: PremiumColors.warning,
                                  size: 32,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PremiumColors.warning.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: const Icon(
                              Icons.hourglass_top_rounded,
                              color: PremiumColors.warning,
                              size: 52,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l.paymentPending,
                  style: AppTextStyle.headlineMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l.paymentPendingDescription,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMd.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (isPolling && pollAttempts > 0) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${pollAttempts * 5}s',
                    style: AppTextStyle.body.copyWith(
                      color: context.textDisabled,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Semantics(
                    button: true,
                    label: l.paymentGoHome,
                    child: FilledButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        try {
                          ref.read(paymentProvider.notifier).reset();
                          context.goNamed('main');
                        } catch (e) {
                          if (context.mounted) {
                            SagenNotification.show(
                              context,
                              message: l.errorSomethingWrong,
                              type: NotificationType.error,
                            );
                          }
                        }
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
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          ),
        ),
      ),
    );
  }
}
