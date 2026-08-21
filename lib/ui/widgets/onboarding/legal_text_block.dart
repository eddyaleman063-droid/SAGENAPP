import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class LegalTextBlock extends StatefulWidget {
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;

  const LegalTextBlock({super.key, this.onTerms, this.onPrivacy});

  @override
  State<LegalTextBlock> createState() => _LegalTextBlockState();
}

class _LegalTextBlockState extends State<LegalTextBlock> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTerms ?? () {};
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = widget.onPrivacy ?? () {};
  }

  @override
  void didUpdateWidget(LegalTextBlock old) {
    super.didUpdateWidget(old);
    _termsRecognizer.onTap = widget.onTerms ?? () {};
    _privacyRecognizer.onTap = widget.onPrivacy ?? () {};
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

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
              recognizer: _termsRecognizer,
            ),
            TextSpan(text: l.legalAnd),
            TextSpan(
              text: l.privacyPolicy,
              style: AppTextStyle.tiny.copyWith(
                color: PremiumColors.primaryAccent.withValues(alpha: 0.8),
              ),
              recognizer: _privacyRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}
