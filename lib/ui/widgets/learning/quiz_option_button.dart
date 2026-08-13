import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/providers.dart';
import '../common/localization_helper.dart';

class QuizOptionButton extends ConsumerWidget {
  final int index;
  final String text;
  final bool selected;
  final bool correct;
  final bool revealed;
  final VoidCallback? onTap;
  final bool disabled;

  const QuizOptionButton({
    super.key,
    required this.index,
    required this.text,
    required this.selected,
    required this.correct,
    required this.revealed,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color bgColor;
    Color? borderColor;
    Color? textColor;
    String? prefix;

    if (disabled) {
      bgColor = Theme.of(context).colorScheme.surfaceContainerHigh;
      borderColor = Colors.transparent;
      textColor = Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.55);
      prefix = '—';
    } else if (revealed) {
      if (correct) {
        bgColor = PremiumColors.success.withValues(alpha: 0.1);
        borderColor = PremiumColors.success;
        textColor = PremiumColors.success;
        prefix = '✓';
      } else if (selected && !correct) {
        bgColor = PremiumColors.error.withValues(alpha: 0.1);
        borderColor = PremiumColors.error;
        textColor = PremiumColors.error;
        prefix = '✗';
      } else {
        bgColor = Theme.of(context).colorScheme.surfaceContainerHigh;
        borderColor = Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.12);
        textColor = Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.54);
      }
    } else {
      bgColor = Theme.of(context).colorScheme.surfaceContainerHigh;
      borderColor = Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.12);
      textColor = context.textPrimary;
    }

    final l = l10n(context);
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final baseLabel = '${letters[index % letters.length]}: $text';
    final stateLabel = revealed
        ? (correct
              ? ', ${l.correctAnswer}'
              : (selected ? ', ${l.incorrectAnswer}' : ''))
        : (selected ? ', ${l.selectedAnswer}' : '');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          button: true,
          selected: selected,
          label: '$baseLabel$stateLabel',
          enabled: !revealed && !disabled,
          child: InkWell(
            onTap: (revealed || disabled)
                ? null
                : () {
                    ref.read(experienceServiceProvider).lightHaptic();
                    onTap?.call();
                  },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: borderColor,
                  width: revealed && (correct || (selected && !correct))
                      ? 1.5
                      : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: selected && revealed && correct
                          ? PremiumColors.success
                          : selected && revealed && !correct
                          ? PremiumColors.error
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        prefix ?? letters[index % letters.length],
                        style: AppTextStyle.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selected && revealed
                              ? Colors.white
                              : textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTextStyle.bodyMd.copyWith(
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
