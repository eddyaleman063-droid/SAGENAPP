import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/payment_provider.dart';
import '../../../services/app_logger.dart';
import '../../../services/experience_service.dart';
import '../../widgets/common/sagen_notification.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final double donationAmount;

  const PaymentSuccessScreen({super.key, required this.donationAmount});

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _checkCtrl;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    ExperienceService.instance.heavyHaptic();
    _scaleCtrl.forward().then((_) => _checkCtrl.forward());
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _scaleCtrl,
                    curve: Curves.elasticOut,
                  ),
                  child: Semantics(
                    label:
                        AppLocalizations.of(context)?.thankYouForSupport ?? '',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            PremiumColors.success,
                            PremiumColors.success,
                          ],
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _checkCtrl,
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '${l.currencySymbol}${widget.donationAmount.toStringAsFixed(2)}',
                  style: AppTextStyle.display.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 24,
                  color: PremiumColors.success,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Semantics(
                    button: true,
                    label: l.continueText,
                    child: FilledButton(
                      onPressed: _navigated
                          ? null
                          : () async {
                              ExperienceService.instance.lightHaptic();
                              try {
                                _navigated = true;
                                ref.read(paymentProvider.notifier).reset();
                                context.goNamed('main');
                              } catch (e) {
                                AppLogger().error(
                                  'PaymentSuccess: continue failed',
                                  e,
                                );
                                if (mounted) {
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
                        l.continueText,
                        style: AppTextStyle.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
