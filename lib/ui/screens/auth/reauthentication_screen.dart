import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_models.dart';

import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import '../../widgets/common/premium_loader.dart';

class ReauthenticationScreen extends ConsumerStatefulWidget {
  const ReauthenticationScreen({super.key});

  @override
  ConsumerState<ReauthenticationScreen> createState() =>
      _ReauthenticationScreenState();
}

class _ReauthenticationScreenState
    extends ConsumerState<ReauthenticationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  bool get _isOAuthUser {
    // Check if user signed in via Google or Facebook (no password)
    // OAuth users typically don't have a password set
    final auth = ref.read(authProvider);
    // If photoUrl is set from OAuth provider, treat as OAuth user
    return auth.photoUrl != null && auth.photoUrl!.isNotEmpty;
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleReauth() async {
    if (_isOAuthUser) {
      // For OAuth users, try direct deletion without password
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.settingsDeleteAccount),
          content: Text(
            AppLocalizations.of(context)!.settingsDeleteAccountConfirm,
          ),
          actions: [
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.cancel,
              child: TextButton(
                onPressed: () => context.pop(false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ),
            Semantics(
              button: true,
              label: AppLocalizations.of(context)!.settingsDeleteAccount,
              child: TextButton(
                onPressed: () => context.pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: PremiumColors.error,
                ),
                child: Text(
                  AppLocalizations.of(context)!.settingsDeleteAccount,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _isSubmitting = true);
      final l = AppLocalizations.of(context)!;
      final authNotifier = ref.read(authProvider.notifier);

      try {
        await authNotifier.deleteAccount(email: ref.read(authProvider).email);
      } catch (e) {
        if (!mounted) return;
        final errorCode = e is AuthException
            ? e.code
            : ref.read(authProvider).errorMessage ?? 'unknown';
        SagenNotification.show(
          context,
          message: AuthException(errorCode).localizedMessage(l),
          type: NotificationType.error,
        );
        setState(() => _isSubmitting = false);
        return;
      }
      if (!mounted) return;

      final currentAuth = ref.read(authProvider);
      if (currentAuth.errorMessage != null) {
        SagenNotification.show(
          context,
          message: AuthException(currentAuth.errorMessage!).localizedMessage(l),
          type: NotificationType.error,
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    // For email/password users, require password reauthentication
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    // Confirmation dialog for destructive action
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settingsDeleteAccount),
        content: Text(
          AppLocalizations.of(context)!.settingsDeleteAccountConfirm,
        ),
        actions: [
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.cancel,
            child: TextButton(
              onPressed: () => context.pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ),
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.settingsDeleteAccount,
            child: TextButton(
              onPressed: () => context.pop(true),
              style: TextButton.styleFrom(foregroundColor: PremiumColors.error),
              child: Text(AppLocalizations.of(context)!.settingsDeleteAccount),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final l = AppLocalizations.of(context)!;
    final authNotifier = ref.read(authProvider.notifier);
    final auth = ref.read(authProvider);

    try {
      await authNotifier.deleteAccount(
        email: auth.email,
        password: _passwordCtrl.text,
      );
    } catch (e) {
      if (!mounted) return;
      final errorCode = e is AuthException
          ? e.code
          : ref.read(authProvider).errorMessage ?? 'unknown';
      if (errorCode == 'requires_recent_login') {
        SagenNotification.show(
          context,
          message: l.reauthWrongPassword,
          type: NotificationType.error,
        );
      } else {
        SagenNotification.show(
          context,
          message: AuthException(errorCode).localizedMessage(l),
          type: NotificationType.error,
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }
    if (!mounted) return;

    final currentAuth = ref.read(authProvider);
    if (currentAuth.errorMessage != null) {
      final error = currentAuth.errorMessage;
      if (error == 'wrong_password' || error == 'invalid_credential') {
        SagenNotification.show(
          context,
          message: l.reauthWrongPassword,
          type: NotificationType.error,
        );
      } else {
        SagenNotification.show(
          context,
          message: AuthException(error!).localizedMessage(l),
          type: NotificationType.error,
        );
      }
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: l.backButton,
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.textSecondary),
            onPressed: () {
              ref.read(experienceServiceProvider).lightHaptic();
              context.pop();
            },
            tooltip: l.backButton,
          ),
        ),
        title: Text(
          l.reauthTitle,
          style: AppTextStyle.title.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [PremiumColors.deepBackground, PremiumColors.darkBg]
                : [PremiumColors.lightBg, PremiumColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
                bottom:
                    MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    const Icon(
                      Icons.shield_rounded,
                      size: 48,
                      color: PremiumColors.primaryAccent,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.reauthDesc,
                      style: AppTextStyle.body.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Semantics(
                      label: l.authEmailLabel,
                      child: TextFormField(
                        initialValue: auth.email,
                        readOnly: true,
                        style: AppTextStyle.body.copyWith(
                          color: context.textTertiary,
                        ),
                        decoration: InputDecoration(
                          labelText: l.authEmailLabel,
                          labelStyle: AppTextStyle.bodyMd.copyWith(
                            color: context.textTertiary,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            size: 20,
                            color: context.textTertiary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            borderSide: BorderSide(color: context.subtleBorder),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (!_isOAuthUser) ...[
                      Semantics(
                        label: l.authPasswordLabel,
                        child: TextFormField(
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          maxLength: 128,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleReauth(),
                          style: AppTextStyle.body.copyWith(
                            color: context.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: l.authPasswordLabel,
                            labelStyle: AppTextStyle.bodyMd.copyWith(
                              color: context.textTertiary,
                            ),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: context.textTertiary,
                            ),
                            suffixIcon: Semantics(
                              button: true,
                              label: _obscurePassword
                                  ? l.showPassword
                                  : l.hidePassword,
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                  color: PremiumColors.primaryAccent,
                                ),
                                tooltip: _obscurePassword
                                    ? l.showPassword
                                    : l.hidePassword,
                                onPressed: () {
                                  ref
                                      .read(experienceServiceProvider)
                                      .lightHaptic();
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide(
                                color: context.subtleBorder,
                              ),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return l.authPasswordError;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ] else ...[
                      Text(
                        l.reauthOAuthInfo,
                        style: AppTextStyle.caption.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Semantics(
                        button: true,
                        label: l.reauthConfirm,
                        child: ElevatedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  ref
                                      .read(experienceServiceProvider)
                                      .lightHaptic();
                                  HapticFeedback.lightImpact();
                                  _handleReauth();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PremiumColors.primaryAccent,
                            disabledBackgroundColor: context.disabledBg,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: PremiumLoader(
                                    loading: true,
                                    child: SizedBox.expand(),
                                  ),
                                )
                              : Text(
                                  l.reauthConfirm,
                                  style: AppTextStyle.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Semantics(
                        button: true,
                        label: l.cancel,
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(experienceServiceProvider).lightHaptic();
                            context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.textSecondary,
                            side: BorderSide(color: context.subtle),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: Text(
                            l.cancel,
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.05),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
