import 'package:flutter/material.dart';
import 'package:sagen/services/experience_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';

/// Shared onboarding continue button with 3D press effect.
/// Replaces the duplicated GestureDetector + AnimatedContainer pattern across 10+ onboarding screens.
class OnboardingContinueButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const OnboardingContinueButton({
    super.key,
    required this.label,
    this.enabled = true,
    this.onTap,
  });

  @override
  State<OnboardingContinueButton> createState() => _OnboardingContinueButtonState();
}

class _OnboardingContinueButtonState extends State<OnboardingContinueButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) {
    ExperienceService.instance.mediumHaptic();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      enabled: widget.enabled,
      child: GestureDetector(
        onTapDown: widget.enabled ? _onTapDown : null,
        onTapUp: widget.enabled ? _onTapUp : null,
        onTapCancel: widget.enabled ? _onTapCancel : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          transform: _isPressed
              ? Matrix4.translationValues(0, 4, 0)
              : Matrix4.identity(),
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.enabled
                ? PremiumColors.primaryAccent
                : context.disabledBg,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: _isPressed || !widget.enabled
                ? []
                : [
                    const BoxShadow(
                      color: PremiumColors.primaryDark,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: AppTextStyle.titleSmall.copyWith(color: widget.enabled
                    ? context.textPrimary
                    : context.textDisabled,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
