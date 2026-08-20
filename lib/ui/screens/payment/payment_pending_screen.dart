import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/app_logger.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/payment_provider.dart';
import '../../widgets/common/sagen_notification.dart';
import '../../../utils/localized_names.dart';

class PaymentPendingScreen extends ConsumerStatefulWidget {
  const PaymentPendingScreen({super.key});

  @override
  ConsumerState<PaymentPendingScreen> createState() =>
      _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends ConsumerState<PaymentPendingScreen> {
  bool _navigating = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final payment = ref.watch(
      paymentProvider.select(
        (p) => (
          status: p.status,
          pollAttempts: p.pollAttempts,
          errorMessage: p.errorMessage,
        ),
      ),
    );
    final pollAttempts = payment.pollAttempts;
    final isPolling = payment.status == PaymentStatus.waitingPayment;
    final isFailed = payment.status == PaymentStatus.failed;
    final isCompleted = payment.status == PaymentStatus.completed;

    if (isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
    }

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
                              const ExcludeSemantics(
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      PremiumColors.warning,
                                    ),
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
                        : isFailed
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: PremiumColors.error.withValues(alpha: 0.1),
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: PremiumColors.error,
                              size: 52,
                            ),
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
                  isFailed ? l.paymentNotCompleted : l.paymentPending,
                  style: AppTextStyle.headlineMedium.copyWith(
                    color: isFailed ? PremiumColors.error : context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  isFailed
                      ? resolvePaymentError(payment.errorMessage, l)
                      : l.paymentPendingDescription,
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
                    label: isFailed ? l.paymentTryAgain : l.paymentGoHome,
                    child: FilledButton(
                      onPressed: _navigating
                          ? null
                          : () async {
                              HapticFeedback.lightImpact();
                              try {
                                setState(() => _navigating = true);
                                ref.read(paymentProvider.notifier).reset();
                                if (isFailed) {
                                  context.go('/home');
                                } else {
                                  context.goNamed('main');
                                }
                              } catch (e) {
                                AppLogger().error(
                                  'PaymentPending: go home failed',
                                  e,
                                );
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
                        isFailed ? l.paymentTryAgain : l.paymentGoHome,
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
