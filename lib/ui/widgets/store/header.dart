import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';

class StoreHeader extends ConsumerStatefulWidget {
  const StoreHeader({super.key});

  @override
  ConsumerState<StoreHeader> createState() => _StoreHeaderState();
}

class _StoreHeaderState extends ConsumerState<StoreHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  int _prevBalance = 0;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final gemBalance = ref.watch(gemProvider.select((g) => g.balance));
    if (gemBalance > _prevBalance && _prevBalance > 0) {
      _glowController.forward(from: 0);
    }
    _prevBalance = gemBalance;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
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
                  style: AppTextStyle.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Semantics(
                label: AppLocalizations.of(
                  context,
                )!.gemBalanceLabel(gemBalance),
                container: true,
                child: AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    final glow = _glowAnimation.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: glow > 0
                            ? [
                                BoxShadow(
                                  color: PremiumColors.accentCyan.withValues(
                                    alpha: glow * 0.6,
                                  ),
                                  blurRadius: 12 * glow,
                                  spreadRadius: 2 * glow,
                                ),
                              ]
                            : null,
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
                                  colors: [
                                    PremiumColors.accentCyan,
                                    PremiumColors.deepPurple,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              '$gemBalance',
                              key: ValueKey(gemBalance),
                              style: AppTextStyle.subtitle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Semantics(
                button: true,
                label: l.gemHistoryTitle,
                child: IconButton(
                  icon: const Icon(
                    Icons.history_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pushNamed('gem-history'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    minimumSize: Size.zero,
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
