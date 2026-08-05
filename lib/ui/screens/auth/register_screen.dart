import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/auth_models.dart';
import '../../../services/auth_service.dart';

import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../ui/widgets/onboarding/legal_text_block.dart';
import '../../../ui/widgets/shimmer_loading.dart';
import '../../../ui/widgets/auth/auth_social_buttons.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;
  final VoidCallback? onSwitchToLogin;
  final VoidCallback? onComplete;
  const RegisterScreen({super.key, this.isOnboarding = false, this.onSwitchToLogin, this.onComplete});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _ageFocus = FocusNode();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _fieldsValid = false;
  Timer? _validateDebounce;

  static const String _termsUrl = 'https://sagen.app/terms';
  static const String _privacyUrl = 'https://sagen.app/privacy';
  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_validateFields);
    _emailCtrl.addListener(_validateFields);
    _passwordCtrl.addListener(_validateFields);
    _ageCtrl.addListener(_validateFields);
  }

  @override
  void dispose() {
    _validateDebounce?.cancel();
    _nameCtrl.removeListener(_validateFields);
    _emailCtrl.removeListener(_validateFields);
    _passwordCtrl.removeListener(_validateFields);
    _ageCtrl.removeListener(_validateFields);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _ageFocus.dispose();
    super.dispose();
  }

  void _validateFields() {
    _validateDebounce?.cancel();
    _validateDebounce = Timer(const Duration(milliseconds: 300), () {
      final nameOk = _nameCtrl.text.trim().isNotEmpty;
      final emailOk = _emailRegex.hasMatch(_emailCtrl.text.trim());
      final passOk = _passwordRegex.hasMatch(_passwordCtrl.text);
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
      final ageOk = age >= 13;
      final valid = nameOk && emailOk && passOk && ageOk;
      if (valid != _fieldsValid && mounted) {
        setState(() => _fieldsValid = valid);
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_fieldsValid || _isLoading) return;
    HapticFeedback.mediumImpact();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final funnel = ref.read(registrationFunnelProvider.notifier);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    funnel.setAuthMethod('email');
    funnel.setName(_nameCtrl.text.trim());
    funnel.setEmail(email);
    funnel.setPassword(password);
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    funnel.setAge(age);

    final authNotifier = ref.read(authProvider.notifier);
    try {
      await authNotifier.signUpWithEmail(
        displayName: _nameCtrl.text.trim(),
        email: email,
        password: password,
      );
      funnel.clearSensitiveData();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated || auth.showVerificationScreen) {
        ref.read(experienceServiceProvider).successHaptic();
        widget.onComplete?.call();
        if (!widget.isOnboarding && mounted) context.pop(true);
      } else if (auth.errorMessage != null) {
        SagenNotification.show(context, message: AuthException(auth.errorMessage!).localizedMessage(AppLocalizations.of(context)!), type: NotificationType.error);
      }
    } catch (_) {
      funnel.clearSensitiveData();
      if (!mounted) return;
      SagenNotification.show(context, message: AppLocalizations.of(context)!.authCreateAccountError, type: NotificationType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleRegister() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final funnel = ref.read(registrationFunnelProvider.notifier);
    funnel.setAuthMethod('google');
    funnel.setName(_nameCtrl.text.trim());
    funnel.setEmail(_emailCtrl.text.trim());

    final authNotifier = ref.read(authProvider.notifier);
    try {
      await authNotifier.signInWithGoogle();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        ref.read(experienceServiceProvider).successHaptic();
        widget.onComplete?.call();
      } else if (auth.errorMessage != null) {
        SagenNotification.show(context, message: AuthException(auth.errorMessage!).localizedMessage(AppLocalizations.of(context)!), type: NotificationType.error);
      }
    } catch (_) {
      if (!mounted) return;
      SagenNotification.show(context, message: AppLocalizations.of(context)!.authRegisterGoogleError, type: NotificationType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookRegister() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final funnel = ref.read(registrationFunnelProvider.notifier);
    funnel.setAuthMethod('facebook');

    try {
      await ref.read(authServiceProvider).signInWithFacebook();
      if (!mounted) return;
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.refreshCurrentUser();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        ref.read(experienceServiceProvider).successHaptic();
        widget.onComplete?.call();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.code != 'canceled') {
        SagenNotification.show(context, message: e.localizedMessage(AppLocalizations.of(context)!), type: NotificationType.error);
      }
    } catch (_) {
      if (!mounted) return;
      SagenNotification.show(context, message: AppLocalizations.of(context)!.authRegisterFacebookError, type: NotificationType.error);
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
          child: Semantics(label: AppLocalizations.of(context)!.regEmailTitle, child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Semantics(button: true, label: l.closeButton, child: IconButton(
                        icon: Icon(Icons.close, color: context.iconSecondary),
                        onPressed: _onClose,
                        tooltip: l.closeButton,
                      )),
                      const Spacer(),
                      Text(
                        l.authRegisterTitle,
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
                const SizedBox(height: AppSpacing.lg),
                // ── Unified form container ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.subtleBorder,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: context.borderSubtle,
                        ),
                      ),
                      child: Column(
                        children: [
                          Semantics(label: l.authFullName, child: TextFormField(
                            controller: _nameCtrl,
                            focusNode: _nameFocus,
                            maxLength: 100,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                            style: AppTextStyle.body.copyWith(color: context.textPrimary),
                            decoration: InputDecoration(
                              hintText: l.authFullName,
                              hintStyle: AppTextStyle.body.copyWith(color: context.textTertiary),
                              prefixIcon: Icon(Icons.person_outline, size: 20, color: context.textTertiary),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return l.authNameError;
                            return null;
                          },
                        )),
                        Divider(
                          height: 0,
                          color: context.borderSubtle,
                          indent: 16,
                          endIndent: 16,
                        ),
                        Semantics(label: l.authEmailLabel, child: TextFormField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          maxLength: 254,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                          style: AppTextStyle.body.copyWith(color: context.textPrimary),
                          decoration: InputDecoration(
                            hintText: l.authEmailLabel,
                            hintStyle: AppTextStyle.body.copyWith(color: context.textTertiary),
                            prefixIcon: Icon(Icons.mail_outline, size: 20, color: context.textTertiary),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return l.authEmailError;
                              if (!_emailRegex.hasMatch(v.trim())) return l.authEmailError;
                              return null;
                            },
                          )),
                          Divider(
                            height: 0,
                            color: context.borderSubtle,
                            indent: 16,
                            endIndent: 16,
                          ),
                          Semantics(label: l.authPasswordMinHint, child: TextFormField(
                            controller: _passwordCtrl,
                            focusNode: _passwordFocus,
                            maxLength: 128,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _ageFocus.requestFocus(),
                            style: AppTextStyle.body.copyWith(color: context.textPrimary),
                            decoration: InputDecoration(
                              hintText: l.authPasswordMinHint,
                              hintStyle: AppTextStyle.body.copyWith(color: context.textTertiary),
                              prefixIcon: Icon(Icons.lock_outline, size: 20, color: context.textTertiary),
                              suffixIcon: Semantics(button: true, label: _obscurePassword ? l.showPassword : l.hidePassword, child: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  size: 20,
                                  color: PremiumColors.primaryAccent,
                                ),
                                tooltip: _obscurePassword ? l.showPassword : l.hidePassword,
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              )),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return l.authPasswordError;
                              if (!_passwordRegex.hasMatch(v)) return l.authPasswordMinError;
                              return null;
                            },
                          )),
                          Divider(
                            height: 0,
                            color: context.borderSubtle,
                            indent: 16,
                            endIndent: 16,
                          ),
                          Semantics(label: l.registerAgeHint, child: TextFormField(
                            controller: _ageCtrl,
                            focusNode: _ageFocus,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleRegister(),
                            style: AppTextStyle.body.copyWith(color: context.textPrimary),
                            decoration: InputDecoration(
                              hintText: l.registerAgeHint,
                              hintStyle: AppTextStyle.body.copyWith(color: context.textTertiary),
                              prefixIcon: Icon(Icons.cake_outlined, size: 20, color: context.textTertiary),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 18),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return l.registerAgeEmpty;
                              final age = int.tryParse(v);
                              if (age == null || age < 13) return l.registerAgeMin;
                              if (age > 120) return l.registerAgeInvalid;
                              return null;
                            },
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // ── Register button ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: _isLoading
                        ? const ShimmerLoading(width: double.infinity, height: 52, borderRadius: AppRadius.lg)
                        : Semantics(button: true, label: l.authCreateAccount, child: ElevatedButton(
                            onPressed: _fieldsValid ? _handleRegister : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _fieldsValid
                                  ? PremiumColors.primaryAccent
                                  : context.subtleBorder,
                              foregroundColor: context.textPrimary,
                              disabledBackgroundColor: context.subtleBorder,
                              disabledForegroundColor: context.textTertiary,
                              shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              l.authCreateAccount,
                              style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                          )),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: context.borderSubtle)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          l.authOrRegisterWith,
                          style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
                        ),
                      ),
                      Expanded(child: Divider(color: context.borderSubtle)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // ── Social buttons ──
                AuthSocialButtons(
                  onGooglePressed: _handleGoogleRegister,
                  onFacebookPressed: _handleFacebookRegister,
                  isLoading: _isLoading,
                  googleSemanticLabel: l.registerWithGoogle,
                  facebookSemanticLabel: l.registerWithFacebook,
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Center(
                    child: LegalTextBlock(
                      onTerms: () => launchUrl(Uri.parse(_termsUrl), mode: LaunchMode.externalApplication),
                      onPrivacy: () => launchUrl(Uri.parse(_privacyUrl), mode: LaunchMode.externalApplication),
                    ),
                  ),
                ),
                // ── Conditional link ──
                if (widget.isOnboarding)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                    child: Center(
                      child: Semantics(button: true, label: l.authBack, child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          l.authBack,
                            style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
                        ),
                      )),
                    ),
                  )
                else if (widget.onSwitchToLogin != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
                    child: Center(
                      child: Semantics(button: true, label: l.authLoginLink, child: TextButton(
                        onPressed: widget.onSwitchToLogin,
                        child: RichText(
                          text: TextSpan(
                            text: l.authHaveAccount,
                           style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
                            children: [
                              TextSpan(
                                text: l.authLoginLink,
                                style: AppTextStyle.bodyBold.copyWith(
                                  color: PremiumColors.primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                    ),
                  ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
