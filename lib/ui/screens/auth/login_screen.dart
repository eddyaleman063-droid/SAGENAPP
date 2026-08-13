import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/auth_models.dart';
import '../../../services/auth_service.dart';
import '../../../services/analytics_service.dart';

import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../ui/widgets/onboarding/legal_text_block.dart';
import '../../../ui/widgets/auth/auth_social_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  final VoidCallback? onSwitchToRegister;
  const LoginScreen({
    super.key,
    this.isOnboarding = false,
    this.onSwitchToRegister,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _fieldsValid = false;
  Timer? _validateDebounce;

  static const String _termsUrl = 'https://sagen.app/terms';
  static const String _privacyUrl = 'https://sagen.app/privacy';

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_validateFields);
    _passwordCtrl.addListener(_validateFields);
  }

  @override
  void dispose() {
    _validateDebounce?.cancel();
    _emailCtrl.removeListener(_validateFields);
    _passwordCtrl.removeListener(_validateFields);
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _validateFields() {
    _validateDebounce?.cancel();
    _validateDebounce = Timer(const Duration(milliseconds: 150), () {
      final email = _emailCtrl.text.trim();
      final emailValid =
          email.isNotEmpty &&
          RegExp(
            r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
          ).hasMatch(email);
      final valid = emailValid && _passwordCtrl.text.isNotEmpty;
      if (valid != _fieldsValid && mounted) {
        setState(() => _fieldsValid = valid);
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_fieldsValid || _isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authNotifier = ref.read(authProvider.notifier);
    try {
      await authNotifier.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        ref.read(experienceServiceProvider).successHaptic();
        AnalyticsService.instance.track(AnalyticEvent.signIn);
      } else if (auth.errorMessage != null) {
        SagenNotification.show(
          context,
          message: AuthException(
            auth.errorMessage!,
          ).localizedMessage(AppLocalizations.of(context)!),
          type: NotificationType.error,
        );
      }
    } catch (_) {
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authLoginError,
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final authNotifier = ref.read(authProvider.notifier);
    try {
      await authNotifier.signInWithGoogle();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        ref.read(experienceServiceProvider).successHaptic();
        AnalyticsService.instance.track(AnalyticEvent.signIn);
      } else if (auth.errorMessage != null) {
        SagenNotification.show(
          context,
          message: AuthException(
            auth.errorMessage!,
          ).localizedMessage(AppLocalizations.of(context)!),
          type: NotificationType.error,
        );
      }
    } catch (_) {
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authGoogleError,
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookLogin() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final authNotifier = ref.read(authProvider.notifier);
    try {
      await authNotifier.signInWithFacebook();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        ref.read(experienceServiceProvider).successHaptic();
        AnalyticsService.instance.track(AnalyticEvent.signIn);
      } else if (auth.errorMessage != null) {
        SagenNotification.show(
          context,
          message: AuthException(
            auth.errorMessage!,
          ).localizedMessage(AppLocalizations.of(context)!),
          type: NotificationType.error,
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code != 'canceled') {
        SagenNotification.show(
          context,
          message: e.localizedMessage(AppLocalizations.of(context)!),
          type: NotificationType.error,
        );
      }
    } catch (_) {
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)!.authFacebookError,
        type: NotificationType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onClose() => context.pop();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onClose();
      },
      child: Scaffold(
        backgroundColor: context.surfaceDeep,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: l.closeButton,
                        child: IconButton(
                          icon: Icon(Icons.close, color: context.textSecondary),
                          onPressed: _onClose,
                          tooltip: l.closeButton,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l.authLoginTitle,
                        style: AppTextStyle.title.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.subtleBorder,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: context.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          Semantics(
                            label: l.authEmailLabel,
                            child: TextFormField(
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              maxLength: 254,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) =>
                                  _passwordFocus.requestFocus(),
                              style: AppTextStyle.body.copyWith(
                                color: context.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: l.authEmailLabel,
                                hintStyle: AppTextStyle.body.copyWith(
                                  color: context.textSecondary,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: 20,
                                  color: context.textSecondary,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: 18,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return l.authEmailError;
                                }
                                if (!RegExp(
                                  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(v.trim())) {
                                  return l.authEmailInvalid;
                                }
                                return null;
                              },
                            ),
                          ),
                          Divider(
                            height: 0,
                            color: context.borderSubtle,
                            indent: 16,
                            endIndent: 16,
                          ),
                          Semantics(
                            label: l.authPasswordLabel,
                            child: TextFormField(
                              controller: _passwordCtrl,
                              focusNode: _passwordFocus,
                              maxLength: 128,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              style: AppTextStyle.body.copyWith(
                                color: context.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: l.authPasswordLabel,
                                hintStyle: AppTextStyle.body.copyWith(
                                  color: context.textSecondary,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 20,
                                  color: context.textSecondary,
                                ),
                                suffixIcon: IconButton(
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
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: 18,
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
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // ── Login button ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Semantics(
                      button: true,
                      label: l.authLoginButton,
                      child: ElevatedButton(
                        onPressed: _fieldsValid && !_isLoading
                            ? () {
                                HapticFeedback.lightImpact();
                                _handleLogin();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fieldsValid && !_isLoading
                              ? PremiumColors.primaryAccent
                              : context.subtleBorder,
                          foregroundColor: context.textPrimary,
                          disabledBackgroundColor: context.subtleBorder,
                          disabledForegroundColor: context.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    context.textPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                l.authLoginButton,
                                style: AppTextStyle.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // ── Reset password ──
                Center(
                  child: Semantics(
                    button: true,
                    label: l.authForgotPasswordButton,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              context.pushNamed('forgot-password');
                            },
                      child: Text(
                        l.authForgotPasswordButton,
                        style: AppTextStyle.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: PremiumColors.primaryAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                // ── Spacer: pushes bottom block down ──
                const Spacer(),
                // ── Social buttons ──
                AuthSocialButtons(
                  onGooglePressed: _handleGoogleLogin,
                  onFacebookPressed: _handleFacebookLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Center(
                    child: LegalTextBlock(
                      onTerms: () => launchUrl(
                        Uri.parse(_termsUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      onPrivacy: () => launchUrl(
                        Uri.parse(_privacyUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ),
                ),
                // ── Conditional link ──
                if (widget.isOnboarding)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.sm,
                    ),
                    child: Center(
                      child: Semantics(
                        button: true,
                        label: l.authBack,
                        child: TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            l.authBack,
                            style: AppTextStyle.subtitle.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (widget.onSwitchToRegister != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.sm,
                    ),
                    child: Center(
                      child: Semantics(
                        button: true,
                        label: l.authCreateAccount,
                        child: TextButton(
                          onPressed: widget.onSwitchToRegister,
                          child: RichText(
                            text: TextSpan(
                              text: l.authNoAccount,
                              style: AppTextStyle.subtitle.copyWith(
                                color: context.textTertiary,
                              ),
                              children: [
                                TextSpan(
                                  text: l.authCreateAccount,
                                  style: AppTextStyle.bodyBold.copyWith(
                                    color: PremiumColors.primaryAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
