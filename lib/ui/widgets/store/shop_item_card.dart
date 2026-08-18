import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/shop_provider.dart';
import 'package:sagen/ui/widgets/store/buy_button.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/utils/localized_names.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool isLoading;
  final int gemBalance;
  final VoidCallback onBuy;
  const ShopItemCard({
    super.key,
    required this.item,
    this.isLoading = false,
    this.gemBalance = 0,
    required this.onBuy,
  });

  IconData _iconFor(String asset) {
    switch (asset) {
      case 'palette':
        return Icons.palette_rounded;
      case 'filter_frames':
        return Icons.filter_frames_rounded;
      case 'visibility':
        return Icons.visibility_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'casino':
        return Icons.casino_rounded;
      case 'schedule':
        return Icons.schedule_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'title':
        return Icons.title_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final owned = item.isOwned;
    final l = AppLocalizations.of(context)!;

    return Semantics(
      label:
          '${shopItemLocalizedName(item.id, l)}, ${shopItemLocalizedDescription(item.id, l)}',
      button: true,
      enabled: !owned,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: owned
              ? PremiumColors.success.withValues(alpha: 0.05)
              : context.surfaceCard,
          border: Border.all(
            color: owned
                ? PremiumColors.success.withValues(alpha: 0.2)
                : context.subtleBorder,
          ),
          boxShadow: AppShadows.card(color: context.subtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: owned
                    ? PremiumColors.success.withValues(alpha: 0.1)
                    : PremiumColors.primaryAccent.withValues(alpha: 0.1),
              ),
              child: ExcludeSemantics(
                child: Icon(
                  _iconFor(item.iconAsset),
                  color: owned
                      ? PremiumColors.success
                      : PremiumColors.primaryAccent,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owned
                        ? '${shopItemLocalizedName(item.id, l)} ✓'
                        : shopItemLocalizedName(item.id, l),
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    shopItemLocalizedDescription(item.id, l),
                    style: AppTextStyle.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (owned)
              SizedBox(
                width: 78,
                child: Text(
                  AppLocalizations.of(context)!.acquired,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PremiumColors.success,
                  ),
                ),
              )
            else
              BuyButton(
                cost: item.gemCost,
                canBuy: !owned,
                isLoading: isLoading,
                gemBalance: gemBalance,
                onBuy: onBuy,
              ),
          ],
        ),
      ),
    );
  }
}
