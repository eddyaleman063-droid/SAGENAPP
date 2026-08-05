import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/app_colors.dart';

class PasswordInputScreen extends ConsumerWidget {
  final VoidCallback onContinue;

  const PasswordInputScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(registrationFunnelProvider);
    final passwordValid = ref.watch(funnelPasswordValidProvider);

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
                l.regPasswordTitle,
                style: AppTextStyle.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.regPasswordDesc,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const _PasswordField(),
              if (state.password.isNotEmpty && !passwordValid)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    l.authPasswordMinError,
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
                child: Semantics(button: true, label: l.continueText, child: ElevatedButton(
                  onPressed: passwordValid ? onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: context.surfaceTinted,
                    disabledForegroundColor: context.textDisabled,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    elevation: passwordValid ? 4 : 0,
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

class _PasswordField extends ConsumerStatefulWidget {
  const _PasswordField();

  @override
  ConsumerState<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends ConsumerState<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Semantics(label: AppLocalizations.of(context)!.regPasswordTitle, child: TextField(
      maxLength: 128,
      obscureText: _obscured,
      style: AppTextStyle.titleSmall.copyWith(
        color: context.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: '••••••',
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
        prefixIcon: const Icon(Icons.lock_rounded, color: PremiumColors.primary, size: 20),
        suffixIcon: Semantics(button: true, label: _obscured ? AppLocalizations.of(context)!.showPassword : AppLocalizations.of(context)!.hidePassword, child: GestureDetector(
          onTap: () => setState(() => _obscured = !_obscured),
          child: Icon(
            _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: context.textTertiary,
            size: 20,
          ),
        )),
      ),
      onChanged: (value) {
        ref.read(registrationFunnelProvider.notifier).setPassword(value);
      },
    ));
  }
}
