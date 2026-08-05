import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';

import 'package:sagen/ui/widgets/common/premium_loader.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/services/app_logger.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/l10n/app_localizations.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;

  Future<void> _resendEmail() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(authProvider.notifier).resendVerificationEmail();
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.verifyEmailSent,
        type: NotificationType.success,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: e.localizedMessage(AppLocalizations.of(context)!),
        type: NotificationType.error,
      );
    } catch (e, st) {
      AppLogger().error('Resend verification failed', e, st);
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.verifyEmailResendError,
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _checkVerified() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await ref.read(authProvider.notifier).checkEmailVerified();
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        SagenNotification.show(
          context,
          message: AppLocalizations.of(context)!.verifyEmailSuccess,
          type: NotificationType.success,
        );
        context.goNamed('main');
      } else {
        SagenNotification.show(
          context,
          message: AppLocalizations.of(context)!.verifyEmailNotVerified,
          type: NotificationType.warning,
        );
      }
    } catch (e, st) {
      AppLogger().error('Check email verified failed', e, st);
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.verifyEmailResendError,
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  void _signOut() async {
    await ref.read(authProvider.notifier).signOut();
    if (!mounted) return;
    context.goNamed('welcome');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: context.surfaceDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PremiumColors.primaryAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 40,
                  color: PremiumColors.primaryAccent,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l.verifyEmailTitle,
                style: AppTextStyle.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textHighEmphasis,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.verifyEmailMessage(auth.email),
                style: AppTextStyle.body.copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl * 2),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Semantics(button: true, label: l.verifyEmailCheckButton, child: ElevatedButton(
                  onPressed: _checking
                      ? null
                      : () {
                          ref.read(experienceServiceProvider).lightHaptic();
                          _checkVerified();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    elevation: 0,
                  ),
                  child: _checking
                      ? const PremiumLoader(loading: true, child: SizedBox(width: 22, height: 22))
                      : Text(
                          l.verifyEmailCheckButton,
                          style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                )),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(button: true, label: l.verifyEmailResendButton, child: TextButton(
                onPressed: _sending
                    ? null
                    : () {
                        ref.read(experienceServiceProvider).lightHaptic();
                        _resendEmail();
                      },
                child: _sending
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        l.verifyEmailResendButton,
                        style: AppTextStyle.body.copyWith(
                          color: PremiumColors.primaryAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
              const SizedBox(height: AppSpacing.md),
              Semantics(button: true, label: l.verifyEmailSignOut, child: TextButton(
                onPressed: () {
                  ref.read(experienceServiceProvider).lightHaptic();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.verifyEmailSignOut),
                      content: Text(l.settingsLogoutConfirm),
                      actions: [
                        Semantics(button: true, label: l.cancelButton, child: TextButton(
                          onPressed: () => context.pop(),
                          child: Text(l.cancelButton),
                        )),
                        Semantics(button: true, label: l.verifyEmailSignOut, child: TextButton(
                          onPressed: () {
                            context.pop();
                            _signOut();
                          },
                          child: Text(l.verifyEmailSignOut),
                        )),
                      ],
                    ),
                  );
                },
                child: Text(
                  l.verifyEmailSignOut,
                  style: AppTextStyle.bodyMd.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              )),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
        ),
      ),
    );
  }
}
