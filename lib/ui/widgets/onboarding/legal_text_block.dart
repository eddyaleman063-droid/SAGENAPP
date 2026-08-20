import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class LegalTextBlock extends StatelessWidget {
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  const LegalTextBlock({super.key, this.onTerms, this.onPrivacy});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Semantics(
      label:
          '${l.legalRegisterAgree} ${l.legalTerms} ${l.legalAnd} ${l.privacyPolicy}',
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyle.label.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            height: 1.5,
          ),
          children: [
            TextSpan(text: l.legalRegisterAgree),
            TextSpan(
              text: l.legalTerms,
              style: AppTextStyle.tiny.copyWith(
                color: PremiumColors.primaryAccent.withValues(alpha: 0.8),
              ),
              recognizer: TapGestureRecognizer()..onTap = onTerms ?? () {},
            ),
            TextSpan(text: l.legalAnd),
            TextSpan(
              text: l.privacyPolicy,
              style: AppTextStyle.tiny.copyWith(
                color: PremiumColors.primaryAccent.withValues(alpha: 0.8),
              ),
              recognizer: TapGestureRecognizer()..onTap = onPrivacy ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
