import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool dark;
  final bool enabled;
  final bool isStreaming;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  const InputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.dark,
    required this.enabled,
    required this.onSend,
    this.isStreaming = false,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm + MediaQuery.viewInsetsOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: dark ? PremiumColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(color: context.subtleBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: l?.chatHint ?? l?.chatInputHint ?? '',
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxLines: 4,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: l?.chatHint ?? l?.chatInputHint ?? '',
                  hintStyle: AppTextStyle.bodyMd.copyWith(
                    color: context.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.surfaceCard,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: isStreaming
                ? Container(
                    key: const ValueKey('stop'),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PremiumColors.error.withValues(alpha: 0.9),
                    ),
                    child: Semantics(
                      button: true,
                      label: l?.stop ?? 'Stop',
                      child: IconButton(
                        onPressed: () {
                          ExperienceService.instance.lightHaptic();
                          onStop?.call();
                        },
                        icon: const Icon(Icons.stop_rounded, size: 22),
                        tooltip: l?.stop ?? 'Stop',
                        color: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )
                : Container(
                    key: const ValueKey('send'),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: enabled
                          ? const LinearGradient(
                              colors: PremiumColors.gradientSage,
                            )
                          : null,
                      color: enabled ? null : context.subtle,
                    ),
                    child: Semantics(
                      button: true,
                      label: l?.sendMessage ?? '',
                      child: IconButton(
                        onPressed: enabled
                            ? () {
                                onSend();
                              }
                            : null,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        tooltip: l?.sendMessage ?? '',
                        color: enabled ? Colors.white : context.textDisabled,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
