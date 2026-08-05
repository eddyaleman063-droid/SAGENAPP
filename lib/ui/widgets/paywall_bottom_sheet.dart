import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/config/app_config.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/payment_provider.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:url_launcher/url_launcher.dart';

class DonationPackage {
  final int supporterLevel;
  final double price;
  final String labelKey;

  const DonationPackage(this.supporterLevel, this.price, this.labelKey);

  String localizedLabel(AppLocalizations l) {
    switch (labelKey) {
      case 'paywallBasic': return l.paywallBasic;
      case 'paywallPopular': return l.paywallPopular;
      case 'paywallPremium': return l.paywallPremium;
      default: return labelKey;
    }
  }
}

const donationPackages = [
  DonationPackage(1, 3.00, 'paywallBasic'),
  DonationPackage(2, 5.00, 'paywallPopular'),
  DonationPackage(3, 10.00, 'paywallPremium'),
];

class PaywallBottomSheet extends ConsumerWidget {
  final String? userId;

  const PaywallBottomSheet({super.key, this.userId});

  static const String _whatsAppNumber = AppConfig.whatsappNumber;

  static Future<void> show(BuildContext context, {String? userId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallBottomSheet(userId: userId),
    );
  }

  Future<void> _processLocalPayment(BuildContext context, DonationPackage pkg, String? uid) async {
    final l = AppLocalizations.of(context)!;
    final userId = uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final message = l.paywallWhatsAppMessage(l.currencySymbol, pkg.supporterLevel, pkg.price.toStringAsFixed(2), userId);

    try {
      final uri = Uri.https('wa.me', '/$_whatsAppNumber', {'text': message});
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          SagenNotification.show(context, message: l.paywallWhatsAppFallback(message));
        }
      }
    } catch (e) {
      if (context.mounted) {
        SagenNotification.show(context, message: l.paywallWhatsAppError(AppConfig.mercadopagoLink));
      }
    }
  }

  Future<void> _processMpPayment(BuildContext context, WidgetRef ref, DonationPackage pkg) async {
    final l = AppLocalizations.of(context)!;
    final initPoint = await ref.read(paymentProvider.notifier).initiateMercadoPago(
      price: pkg.price,
    );

    if (initPoint == null) {
      if (context.mounted) {
        SagenNotification.show(
          context,
          message: l.paymentMercadoPagoError,
          type: NotificationType.error,
        );
      }
      return;
    }

    try {
      await launchUrl(Uri.parse(initPoint), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        SagenNotification.show(
          context,
          message: l.paywallWhatsAppError(AppConfig.mercadopagoLink),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final paymentState = ref.watch(paymentProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.surfaceBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.subtle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l.paywallSupportUs,
            style: AppTextStyle.titleLg.copyWith(fontWeight: FontWeight.bold,
              color: context.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l.paywallDescription,
            style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...donationPackages.map((pkg) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              children: [
                _PackageCard(
                  pkg: pkg,
                  onTap: () => _processLocalPayment(context, pkg, userId),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: paymentState.status == PaymentStatus.creatingPreference
                        ? null
                        : () => _processMpPayment(context, ref, pkg),
                    icon: paymentState.status == PaymentStatus.creatingPreference
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.payment_rounded, size: 18),
                    label: Text(
                      l.paywallMercadoPago,
                      style: AppTextStyle.subtitle.copyWith(color: PremiumColors.accentCyan),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: PremiumColors.accentCyan,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              l.paywallPaymentMethods,
              style: AppTextStyle.label.copyWith(color: context.textTertiary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final DonationPackage pkg;
  final VoidCallback onTap;

  const _PackageCard({required this.pkg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l.paywallPackageSupporter(pkg.supporterLevel),
      hint: l.paywallPackageLabel(pkg.localizedLabel(l).toLowerCase()),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: context.surfaceCard,
            border: Border.all(
              color: PremiumColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                gradient: const LinearGradient(
                  colors: [PremiumColors.primary, PremiumColors.primaryAccent],
                ),
              ),
              child: const ExcludeSemantics(
                child: Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.paywallPackageSupporter(pkg.supporterLevel),
                    style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold,
                      color: context.textPrimary),
                  ),
                  Text(
                    l.paywallPackageLabel(pkg.localizedLabel(l).toLowerCase()),
                    style: AppTextStyle.caption.copyWith(color: context.textTertiary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                color: PremiumColors.primary,
              ),
              child: Text(
                '${l.currencySymbol}${pkg.price.toStringAsFixed(2)}',
                style: AppTextStyle.bodyMd.copyWith(fontWeight: FontWeight.bold,
                  color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
