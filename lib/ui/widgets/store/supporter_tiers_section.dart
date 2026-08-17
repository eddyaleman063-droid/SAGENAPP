import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/paywall_bottom_sheet.dart';
import 'package:sagen/core/theme/app_colors.dart';

class SupporterTiersSection extends StatelessWidget {
  const SupporterTiersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: donationPackages
          .map(
            (pkg) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _TierCard(pkg: pkg),
            ),
          )
          .toList(),
    );
  }
}

class _TierCard extends StatelessWidget {
  final DonationPackage pkg;
  const _TierCard({required this.pkg});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l.storeSupportTiers,
      child: GestureDetector(
        onTap: () {
          ExperienceService.instance.lightHaptic();
          PaywallBottomSheet.show(context);
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: context.surfaceCard,
            boxShadow: AppShadows.card(),
            border: Border.all(
              color: PremiumColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: const LinearGradient(
                    colors: [
                      PremiumColors.primary,
                      PremiumColors.primaryAccent,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.localizedLabel(l),
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      '${l.currencySymbol}${pkg.price.toStringAsFixed(2)}',
                      style: AppTextStyle.caption.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              ExcludeSemantics(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.subtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
