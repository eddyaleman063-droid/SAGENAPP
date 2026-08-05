import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/theme_constants.dart';

class QuickChips extends StatelessWidget {
  final List<String> chips;
  final ValueChanged<String> onTap;
  final bool dark;
  const QuickChips({super.key, required this.chips, required this.onTap, required this.dark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        itemCount: chips.length,
        itemBuilder: (_, i) => Padding(
          padding: EdgeInsets.only(right: i < chips.length - 1 ? AppSpacing.sm : 0),
          child: Semantics(
            button: true,
            label: chips[i],
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap(chips[i]);
              },
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                gradient: const LinearGradient(colors: PremiumColors.gradientSage, begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: PremiumColors.primaryAccent.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Center(
                child: Text(
                  chips[i],
                  style: AppTextStyle.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
