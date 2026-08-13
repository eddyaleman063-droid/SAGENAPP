import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';

class BuyButton extends StatefulWidget {
  final int cost;
  final bool canBuy;
  final bool isLoading;
  final int gemBalance;
  final VoidCallback onBuy;
  const BuyButton({
    super.key,
    required this.cost,
    required this.canBuy,
    this.isLoading = false,
    this.gemBalance = 0,
    required this.onBuy,
  });

  @override
  State<BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends State<BuyButton> {
  bool _purchasing = false;

  void _onTap() {
    if (_purchasing) return;
    ExperienceService.instance.mediumHaptic();
    setState(() => _purchasing = true);
    widget.onBuy();
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = widget.gemBalance >= widget.cost || widget.cost == 0;
    final canBuy =
        widget.canBuy && !_purchasing && !widget.isLoading && canAfford;
    final isFree = widget.cost == 0;
    final l = AppLocalizations.of(context)!;
    return Semantics(
      label: canBuy
          ? (isFree ? l.free : '${widget.cost} ${l.gems}')
          : (!canAfford
                ? '${l.gems} ${widget.gemBalance}/${widget.cost}'
                : l.free),
      button: true,
      enabled: canBuy,
      child: GestureDetector(
        onTap: canBuy
            ? () {
                HapticFeedback.lightImpact();
                _onTap();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: canBuy
                ? const LinearGradient(
                    colors: [
                      PremiumColors.accentCyan,
                      PremiumColors.deepPurple,
                    ],
                  )
                : null,
            color: canBuy ? null : context.surfaceTinted,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_purchasing || widget.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else ...[
                ExcludeSemantics(
                  child: Transform.rotate(
                    angle: 0.785,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: canBuy
                              ? [Colors.white, Colors.white70]
                              : [Colors.white24, Colors.white10],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                isFree ? AppLocalizations.of(context)!.free : '${widget.cost}',
                style: AppTextStyle.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: canBuy ? Colors.white : context.subtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
