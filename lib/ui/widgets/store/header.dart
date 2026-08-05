import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';

class StoreHeader extends ConsumerWidget {
  final bool dark;
  const StoreHeader({super.key, required this.dark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final gemBalance = ref.watch(gemProvider.select((g) => g.balance));
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.xl),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: PremiumColors.gradientHeader,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.storeTitle,
                  style: AppTextStyle.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
               Semantics(
                label: 'Saldo de gemas: $gemBalance',
                container: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [PremiumColors.accentCyan, PremiumColors.deepPurple],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '$gemBalance',
                        style: AppTextStyle.subtitle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
