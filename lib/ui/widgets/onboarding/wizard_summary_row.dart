import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';

class WizardSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const WizardSummaryRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.5)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.subtitle.copyWith(color: cs.onSurface.withValues(alpha: 0.9),
                height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
