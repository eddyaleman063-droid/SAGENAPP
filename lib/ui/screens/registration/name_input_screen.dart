import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/app_colors.dart';

class NameInputScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const NameInputScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final nameValid = ref.watch(funnelNameValidProvider);
    final notifier = ref.read(registrationFunnelProvider.notifier);

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
                l.regNameQuestion,
                style: AppTextStyle.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Semantics(label: l.regNameHint, child: TextField(
                maxLength: 100,
                style: AppTextStyle.titleSmall.copyWith(
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l.regNameHint,
                  hintStyle: AppTextStyle.titleSmall.copyWith(
                    color: context.subtle,
                  ),
                  filled: true,
                  fillColor: context.surfaceTinted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  prefixIcon: const Icon(Icons.person_rounded, color: PremiumColors.primary, size: 20),
                ),
                onChanged: (value) => notifier.setName(value),
              )),
              const SizedBox(height: AppSpacing.md),
              Semantics(label: l.regSurnameHint, child: TextField(
                maxLength: 100,
                style: AppTextStyle.titleSmall.copyWith(
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l.regSurnameHint,
                  hintStyle: AppTextStyle.titleSmall.copyWith(
                    color: context.subtle,
                  ),
                  filled: true,
                  fillColor: context.surfaceTinted,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                  prefixIcon: const Icon(Icons.badge_rounded, color: PremiumColors.primary, size: 20),
                ),
                onChanged: (value) => notifier.setSurname(value),
              )),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Semantics(button: true, label: l.continueText, child: ElevatedButton(
                  onPressed: nameValid ? onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.surfaceTinted,
                    disabledForegroundColor: context.textDisabled,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    elevation: nameValid ? 4 : 0,
                  ),
                  child: Text(l.continueText, style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                )),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
        ),
      ),
    );
  }
}
