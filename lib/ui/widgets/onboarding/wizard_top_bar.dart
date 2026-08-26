import 'package:flutter/material.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/l10n/app_localizations.dart';

class WizardTopBar extends StatefulWidget {
  final int currentIndex;
  final VoidCallback onBack;

  const WizardTopBar({
    super.key,
    required this.currentIndex,
    required this.onBack,
  });

  @override
  State<WizardTopBar> createState() => _WizardTopBarState();
}

class _WizardTopBarState extends State<WizardTopBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late CurvedAnimation _progressCurve;
  late Animation<double> _progressAnim;
  double _displayedProgress = 0;

  @override
  void initState() {
    super.initState();
    final target =
        (widget.currentIndex + 1) / OnboardingWizardConfig.totalSteps;
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _progressCurve = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOutCubic,
    );
    _progressAnim = Tween<double>(
      begin: target,
      end: target,
    ).animate(_progressCurve);
    _displayedProgress = target;
  }

  @override
  void didUpdateWidget(WizardTopBar old) {
    super.didUpdateWidget(old);
    if (widget.currentIndex != old.currentIndex) {
      final newTarget =
          (widget.currentIndex + 1) / OnboardingWizardConfig.totalSteps;
      _progressCtrl.stop();
      _displayedProgress = _progressAnim.value;
      _progressAnim = Tween<double>(
        begin: _displayedProgress,
        end: newTarget,
      ).animate(_progressCurve);
      _progressCtrl.forward(from: 0.0).then((_) {
        _displayedProgress = newTarget;
      });
    }
  }

  @override
  void dispose() {
    _progressCurve.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final targetProgress =
        (widget.currentIndex + 1) / OnboardingWizardConfig.totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l.backButton,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              color: cs.onSurface.withValues(alpha: 0.7),
              onPressed: () {
                ExperienceService.instance.lightHaptic();
                widget.onBack();
              },
              padding: const EdgeInsets.all(18),
              tooltip: l.backButton,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              label: l.wizardStepLabel(widget.currentIndex + 1),
              value: '${(targetProgress * 100).round()}%',
              child: AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PremiumColors.splashBlue.withValues(alpha: 0.8),
                      ),
                      minHeight: 4,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
