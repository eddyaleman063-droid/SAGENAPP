import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/app_logger.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/keyboard_aware_layout.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    HapticFeedback.lightImpact();
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authEnterEmailError,
        type: NotificationType.warning,
      );
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authEmailInvalid,
        type: NotificationType.warning,
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (!mounted) return;
      setState(() => _sent = true);
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authRecoveryEmailSentMessage,
        type: NotificationType.success,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: e.localizedMessage(AppLocalizations.of(context)!),
        type: NotificationType.error,
      );
    } catch (e) {
      AppLogger().error('ForgotPassword: send reset email failed', e);
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authSendEmailError,
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: dark
            ? PremiumColors.deepBackground
            : PremiumColors.lightBg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.authForgotPasswordTitle,
            style: AppTextStyle.title.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          centerTitle: false,
          leading: Semantics(
            button: true,
            label: AppLocalizations.of(context)!.backButton,
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: context.textPrimary),
              onPressed: () {
                ExperienceService.instance.lightHaptic();
                context.pop();
              },
              tooltip: AppLocalizations.of(context)!.backButton,
            ),
          ),
        ),
        body: KeyboardAwareLayout(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: _sent
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: PremiumColors.success.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        AppLocalizations.of(
                          context,
                        )!.authRecoveryEmailSentTitle,
                        style: AppTextStyle.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppLocalizations.of(context)!.authRecoveryEmailSentDesc,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyMd.copyWith(
                          color: context.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Semantics(
                          button: true,
                          label: AppLocalizations.of(context)!.authBack,
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.authBack,
                              style: AppTextStyle.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        AppLocalizations.of(context)!.authForgotPasswordTitle,
                        style: AppTextStyle.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppLocalizations.of(context)!.authForgotPasswordDesc,
                        style: AppTextStyle.bodyMd.copyWith(
                          color: context.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      Container(
                        decoration: BoxDecoration(
                          color: context.subtleBorder,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: context.borderSubtle),
                        ),
                        child: Semantics(
                          label: AppLocalizations.of(context)!.regEmailTitle,
                          child: TextField(
                            controller: _emailCtrl,
                            maxLength: 254,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _sendReset(),
                            style: AppTextStyle.body.copyWith(
                              color: context.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.authEmailLabel,
                              hintStyle: AppTextStyle.body.copyWith(
                                color: context.textSecondary,
                              ),
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                size: 20,
                                color: context.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.xl,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Semantics(
                          button: true,
                          label: AppLocalizations.of(context)!.authSendLink,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PremiumColors.primary,
                              foregroundColor: context.textPrimary,
                              disabledBackgroundColor: context.textDisabled,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                              ),
                            ),
                            child: _isLoading
                                ? ExcludeSemantics(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              context.textPrimary,
                                            ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.authSendLink,
                                    style: AppTextStyle.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ).animate().fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }
}
