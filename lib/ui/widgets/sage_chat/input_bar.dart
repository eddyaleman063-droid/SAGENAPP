import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool dark;
  final bool enabled;
  final VoidCallback onSend;
  const InputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.dark,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
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
              label:
                  AppLocalizations.of(context)?.chatHint ??
                  AppLocalizations.of(context)?.chatInputHint ??
                  '',
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                maxLength: 500,
                maxLines: 4,
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)?.chatHint ??
                      AppLocalizations.of(context)?.chatInputHint ??
                      '',
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled
                  ? const LinearGradient(colors: PremiumColors.gradientSage)
                  : null,
              color: enabled ? null : context.subtle,
            ),
            child: Semantics(
              button: true,
              label: AppLocalizations.of(context)!.sendMessage,
              child: IconButton(
                onPressed: enabled
                    ? () {
                        HapticFeedback.lightImpact();
                        onSend();
                      }
                    : null,
                icon: const Icon(Icons.send_rounded, size: 18),
                tooltip: AppLocalizations.of(context)!.sendMessage,
                color: enabled ? Colors.white : context.textDisabled,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
