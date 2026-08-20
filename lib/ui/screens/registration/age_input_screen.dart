import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/app_colors.dart';

class AgeInputScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const AgeInputScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final hasAge = ref.watch(registrationFunnelProvider.select((s) => s.age));
    final ageValid = ref.watch(funnelAgeValidProvider);

    return Scaffold(
      backgroundColor: context.surfaceDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                l.regAgeQuestion,
                style: AppTextStyle.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Semantics(
                label: l.regAgeQuestion,
                child: TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  style: AppTextStyle.display.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '0',
                    hintStyle: AppTextStyle.display.copyWith(
                      color: context.subtle,
                    ),
                    filled: true,
                    fillColor: context.surfaceTinted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = int.tryParse(value) ?? 0;
                    ref
                        .read(registrationFunnelProvider.notifier)
                        .setAge(parsed);
                  },
                ),
              ),
              if (hasAge > 0 && !ageValid)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    l.regAgeValidation,
                    style: AppTextStyle.subtitle.copyWith(
                      color: PremiumColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Semantics(
                  button: true,
                  label: l.continueText,
                  child: ElevatedButton(
                    onPressed: ageValid ? onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: context.surfaceTinted,
                      disabledForegroundColor: context.textDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: ageValid ? 4 : 0,
                    ),
                    child: Text(
                      l.continueText,
                      style: AppTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
