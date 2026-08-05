import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../l10n/app_localizations.dart';

class AuthSocialButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final bool isLoading;
  final String? googleSemanticLabel;
  final String? facebookSemanticLabel;

  const AuthSocialButtons({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    this.isLoading = false,
    this.googleSemanticLabel,
    this.facebookSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: Semantics(
                button: true,
                label: googleSemanticLabel ?? l.authGoogleButton,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onGooglePressed,
                  icon: Image.asset(
                    'assets/ui/google_logo.png',
                    width: 20, height: 20, cacheWidth: 40, cacheHeight: 40,
                    errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 20),
                  ),
                  label: Text(
                    l.authGoogleButton,
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.subtleBorder,
                    side: BorderSide(
                      color: context.borderSubtle,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: Semantics(
                button: true,
                label: facebookSemanticLabel ?? l.authFacebookButton,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onFacebookPressed,
                  icon: const Icon(
                    Icons.facebook_rounded,
                    size: 20,
                    color: PremiumColors.facebookBlue,
                  ),
                  label: Text(
                    l.authFacebookButton,
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.subtleBorder,
                    side: BorderSide(
                      color: context.borderSubtle,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
