import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegistrationMethodsScreen extends StatefulWidget {
  final VoidCallback onEmail;
  final VoidCallback onGoogle;

  const RegistrationMethodsScreen({
    super.key,
    required this.onEmail,
    required this.onGoogle,
  });

  @override
  State<RegistrationMethodsScreen> createState() => _RegistrationMethodsScreenState();
}

class _RegistrationMethodsScreenState extends State<RegistrationMethodsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  Widget _build3DButton({
    required String label,
    Color? color,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return Semantics(button: true, label: label, child: GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: color ?? PremiumColors.authBackground,
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              ),
              left: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              ),
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1.5,
              ),
              bottom: BorderSide(
                color: borderColor ?? PremiumColors.authCardDark,
                width: 4,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyle.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: PremiumColors.authCardLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(button: true, label: l.backButton, child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
          onPressed: () {
            ExperienceService.instance.lightHaptic();
            context.pop();
          },
          tooltip: l.backButton,
        )),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const LinearProgressIndicator(
            value: 0.4,
            backgroundColor: PremiumColors.authBackground,
            valueColor: AlwaysStoppedAnimation<Color>(PremiumColors.progressGreen),
            minHeight: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                l.regMethodTitle,
                style: AppTextStyle.headline.copyWith(
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -10 * _floatController.value),
                    child: child,
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: PremiumColors.accentCyan.withValues(alpha: 0.15),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 150, height: 150, child: ExcludeSemantics(child: SageEmotionWidget(emotion: SageEmotion.neutral))),
                  ],
                ),
              ),
              const Spacer(),
              _build3DButton(
                label: l.authGoogleButton,
                onTap: () {
                  ExperienceService.instance.mediumHaptic();
                  widget.onGoogle();
                },
              ),
              const SizedBox(height: 16),
              _build3DButton(
                label: l.regEmailOption,
                onTap: () {
                  ExperienceService.instance.mediumHaptic();
                  widget.onEmail();
                },
              ),
              const SizedBox(height: 24),
              Semantics(label: '${l.legalRegisterAgree} ${l.legalTerms} ${l.legalAnd} ${l.legalPrivacy}', child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyle.subtitle.copyWith(color: Colors.white54, height: 1.4),
                    children: [
                      TextSpan(text: l.legalRegisterAgree),
                      TextSpan(
                        text: l.legalTerms,
                        style: AppTextStyle.bodyBold.copyWith(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ExperienceService.instance.lightHaptic();
                            launchUrl(Uri.parse('https://sagen.app/terms'));
                          },
                      ),
                      TextSpan(text: l.legalAnd),
                      TextSpan(
                        text: l.legalPrivacy,
                        style: AppTextStyle.bodyBold.copyWith(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ExperienceService.instance.lightHaptic();
                            context.push('/privacy-policy');
                          },
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 8),
            ],
          ).animate().fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }
}
