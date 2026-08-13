import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/app_colors.dart';

class EmailInputScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const EmailInputScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final emailValid = ref.watch(funnelEmailValidProvider);

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
                l.regEmailTitle,
                style: AppTextStyle.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.regEmailDesc,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Semantics(
                label: l.regEmailTitle,
                child: TextField(
                  maxLength: 254,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyle.titleSmall.copyWith(
                    color: context.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l.regEmailHint,
                    hintStyle: AppTextStyle.titleSmall.copyWith(
                      color: context.subtle,
                    ),
                    filled: true,
                    fillColor: context.surfaceTinted,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.lg,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_rounded,
                      color: PremiumColors.primary,
                      size: 20,
                    ),
                  ),
                  onChanged: (value) {
                    ref
                        .read(registrationFunnelProvider.notifier)
                        .setEmail(value);
                  },
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
                    onPressed: emailValid ? onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: context.surfaceTinted,
                      disabledForegroundColor: context.textDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: emailValid ? 4 : 0,
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
          ).animate().fadeIn().slideY(begin: 0.1),
        ),
      ),
    );
  }
}
