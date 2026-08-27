import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/app_colors.dart';

class NameInputScreen extends ConsumerWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const NameInputScreen({super.key, required this.onContinue, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final nameValid = ref.watch(funnelNameValidProvider);
    final notifier = ref.read(registrationFunnelProvider.notifier);

    return Scaffold(
      backgroundColor: context.surfaceDeep,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (onBack != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: onBack,
                              icon: const Icon(Icons.arrow_back_rounded),
                              iconSize: 24,
                              color: context.textSecondary,
                            ),
                          ),
                        const Spacer(flex: 2),
                        Text(
                          l.regNameQuestion,
                          style: AppTextStyle.headline.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Semantics(
                          label: l.regNameHint,
                          child: TextField(
                            maxLength: 100,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.givenName],
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
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xl,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.lg,
                              ),
                              prefixIcon: const Icon(
                                Icons.person_rounded,
                                color: PremiumColors.primary,
                                size: 20,
                              ),
                            ),
                            onChanged: (value) =>
                                notifier.setName(value.trim()),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          label: l.regSurnameHint,
                          child: TextField(
                            maxLength: 100,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.familyName],
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
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xl,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.lg,
                              ),
                              prefixIcon: const Icon(
                                Icons.badge_rounded,
                                color: PremiumColors.primary,
                                size: 20,
                              ),
                            ),
                            onChanged: (value) =>
                                notifier.setSurname(value.trim()),
                            onSubmitted: (_) {
                              if (nameValid) onContinue();
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
                              onPressed: nameValid ? onContinue : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PremiumColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: context.surfaceTinted,
                                disabledForegroundColor: context.textDisabled,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                                elevation: nameValid ? 4 : 0,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
