import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/smart_promo_service.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/paywall_bottom_sheet.dart';

class PostLessonPromo extends ConsumerStatefulWidget {
  final Widget child;
  final bool showPromo;

  const PostLessonPromo({
    super.key,
    required this.child,
    this.showPromo = false,
  });

  @override
  ConsumerState<PostLessonPromo> createState() => _PostLessonPromoState();
}

class _PostLessonPromoState extends ConsumerState<PostLessonPromo> {
  bool _showBanner = false;

  @override
  void didUpdateWidget(PostLessonPromo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPromo && !oldWidget.showPromo) {
      _checkAndShow();
    }
  }

  Future<void> _checkAndShow() async {
    final service = SmartPromoService.instance;
    if (service.shouldShowPromo()) {
      await service.recordPromoShown();
      if (mounted) {
        setState(() => _showBanner = true);
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) setState(() => _showBanner = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        widget.child,
        if (_showBanner)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Semantics(
              button: true,
              label: l.promoPostLessonTitle,
              child: GestureDetector(
                onTap: () {
                  ref.read(experienceServiceProvider).lightHaptic();
                  setState(() => _showBanner = false);
                  PaywallBottomSheet.show(context);
                },
                onVerticalDragEnd: (_) {
                  setState(() => _showBanner = false);
                  SmartPromoService.instance.dismissForCooldown();
                },
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: dark
                          ? [
                              PremiumColors.gradientPromoDark1,
                              PremiumColors.gradientPromoDark2,
                            ]
                          : [
                              PremiumColors.gradientSupportLight1,
                              PremiumColors.gradientSupportLight2,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const ExcludeSemantics(
                          child: Icon(
                            Icons.diamond_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.promoPostLessonTitle,
                              style: AppTextStyle.titleSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l.promoPostLessonSubtitle,
                              style: AppTextStyle.bodyMd.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ExcludeSemantics(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3),
              ),
            ),
          ),
      ],
    );
  }
}
