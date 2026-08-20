import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';

class WizardBottomBar extends ConsumerWidget {
  final int currentIndex;
  final bool canContinue;
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const WizardBottomBar({
    super.key,
    required this.currentIndex,
    required this.canContinue,
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final exp = ref.read(experienceServiceProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentIndex == 0)
            WizardButton(label: l.startText, enabled: true, onPressed: onNext)
          else if (currentIndex == OnboardingWizardConfig.totalSteps - 1) ...[
            WizardButton(
              label: l.onboardingCommitButton,
              enabled: canContinue,
              onPressed: onComplete,
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              button: true,
              label: l.onboardingHaveAccount,
              child: TextButton(
                onPressed: () {
                  exp.lightHaptic();
                  context.goNamed(
                    'login',
                    queryParameters: {'onboarding': 'true'},
                  );
                },
                child: Text(
                  l.onboardingHaveAccount,
                  style: AppTextStyle.caption.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ] else ...[
            WizardButton(
              label: l.continueText,
              enabled: canContinue,
              onPressed: onNext,
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              button: true,
              label: l.skipText,
              child: TextButton(
                onPressed: () {
                  exp.lightHaptic();
                  onComplete();
                },
                child: Text(
                  l.skipText,
                  style: AppTextStyle.caption.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WizardButton extends ConsumerStatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const WizardButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  ConsumerState<WizardButton> createState() => _WizardButtonState();
}

class _WizardButtonState extends ConsumerState<WizardButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _shimmerAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOutSine),
    );
    if (widget.enabled) _shimmerCtrl.repeat();
  }

  @override
  void didUpdateWidget(WizardButton old) {
    super.didUpdateWidget(old);
    if (widget.enabled != old.enabled) {
      if (widget.enabled) {
        _shimmerCtrl.repeat();
      } else {
        _shimmerCtrl.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exp = ref.read(experienceServiceProvider);
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) {
        return AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppEasing.entrance,
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: widget.enabled
                ? LinearGradient(
                    colors: [
                      PremiumColors.splashBlue,
                      PremiumColors.splashBlue.withValues(alpha: 0.8),
                      PremiumColors.splashBlue,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    begin: Alignment(_shimmerAnim.value - 1, 0),
                    end: Alignment(_shimmerAnim.value + 1, 0),
                  )
                : null,
            color: widget.enabled
                ? null
                : cs.outlineVariant.withValues(alpha: 0.3),
            boxShadow: widget.enabled && !exp.reduceShadows
                ? [
                    BoxShadow(
                      color: PremiumColors.splashBlue.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Semantics(
              button: true,
              label: widget.label,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: widget.enabled
                    ? () {
                        exp.lightHaptic();
                        widget.onPressed();
                      }
                    : null,
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: AppMotion.fast,
                    style: AppTextStyle.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.enabled
                          ? Colors.white
                          : cs.onSurface.withValues(alpha: 0.25),
                    ),
                    child: Text(widget.label),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
