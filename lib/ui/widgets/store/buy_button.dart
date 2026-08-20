import 'package:flutter/material.dart';
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
  bool _showSuccess = false;

  void _onTap() {
    if (_purchasing) return;
    ExperienceService.instance.mediumHaptic();
    setState(() {
      _purchasing = true;
      _showSuccess = false;
    });
    widget.onBuy();
  }

  @override
  void didUpdateWidget(covariant BuyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mounted) return;
    final loadingFinished =
        oldWidget.isLoading && !widget.isLoading && _purchasing;
    final itemBecameOwned = oldWidget.canBuy && !widget.canBuy && _purchasing;
    if (loadingFinished || itemBecameOwned) {
      if (itemBecameOwned) {
        setState(() {
          _purchasing = false;
          _showSuccess = true;
        });
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() => _showSuccess = false);
        });
      } else {
        setState(() => _purchasing = false);
      }
    }
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
                : l.storeAlreadyOwned),
      button: true,
      enabled: canBuy,
      child: GestureDetector(
        onTap: canBuy ? _onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: _showSuccess
                ? const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                  )
                : canBuy
                ? const LinearGradient(
                    colors: [
                      PremiumColors.accentCyan,
                      PremiumColors.deepPurple,
                    ],
                  )
                : null,
            color: _showSuccess
                ? null
                : (canBuy ? null : context.surfaceTinted),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_purchasing || widget.isLoading)
                    const ExcludeSemantics(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (_showSuccess)
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
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
                    _showSuccess
                        ? l.storeAlreadyOwned
                        : (isFree ? l.free : '${widget.cost}'),
                    style: AppTextStyle.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (!canAfford && !isFree && !_purchasing && !widget.isLoading)
                Text(
                  l.storeNeedMoreGems(
                    widget.cost - widget.gemBalance,
                    widget.gemBalance,
                    widget.cost,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.tiny.copyWith(color: PremiumColors.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
