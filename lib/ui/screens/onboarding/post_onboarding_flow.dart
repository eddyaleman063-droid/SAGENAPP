import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';

import '../../../services/app_logger.dart';

import '../../screens/lesson/first_lesson_screen.dart';
import '../../screens/lesson/lesson_stats_screen.dart';
import '../../screens/streak/streak_intro_screen.dart';
import '../../screens/registration/profile_hook_screen.dart';
import '../../screens/registration/age_input_screen.dart';
import '../../screens/registration/auth_method_screen.dart';
import '../../screens/registration/email_input_screen.dart';
import '../../screens/registration/password_input_screen.dart';
import '../../screens/registration/name_input_screen.dart';
import '../../screens/registration/profile_success_screen.dart';
import 'post_onboarding_welcome_screen.dart';
import 'route_selection_screen.dart';
import 'motivation_screen.dart';
import 'projection_screen.dart';
import 'starting_point_screen.dart';

typedef _StepBuilder =
    Widget Function(BuildContext context, _PostOnboardingActions actions);

class _PostOnboardingActions {
  final VoidCallback advance;
  final VoidCallback goBack;
  final VoidCallback goToHome;
  final VoidCallback completeRegistration;
  final void Function(String method) onAuthMethodSelected;
  final void Function(int step) jumpToStep;
  final WidgetRef ref;

  const _PostOnboardingActions({
    required this.advance,
    required this.goBack,
    required this.goToHome,
    required this.completeRegistration,
    required this.onAuthMethodSelected,
    required this.jumpToStep,
    required this.ref,
  });
}

class PostOnboardingFlow extends ConsumerStatefulWidget {
  const PostOnboardingFlow({super.key});

  @override
  ConsumerState<PostOnboardingFlow> createState() => _PostOnboardingFlowState();
}

class _PostOnboardingFlowState extends ConsumerState<PostOnboardingFlow> {
  int _step = 0;
  bool _isAuthenticating = false;
  int _authGeneration = 0;
  bool _slidingForward = true;

  static const int _totalSteps = 15;

  @override
  void initState() {
    super.initState();
    // Fresh flow: start with a clean funnel so no stale data from a previous
    // partial attempt leaks into the profile (e.g. an old age/email).
    ref.read(registrationFunnelProvider.notifier).reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bridgeWizardData();
    });
  }

  void _advance() {
    setState(() {
      _slidingForward = true;
      _step++;
      _skipConditionalSteps();
    });
    ref.read(analyticsServiceProvider).trackOnboardingStep(_step);
  }

  void _goBack() {
    if (_step > 0) {
      setState(() {
        _slidingForward = false;
        _step--;
        _reverseSkipConditionalSteps();
      });
      ref.read(analyticsServiceProvider).trackOnboardingStep(_step);
    }
  }

  void _jumpToStep(int step) {
    setState(() => _step = step);
    ref.read(analyticsServiceProvider).trackOnboardingStep(_step);
  }

  void _skipConditionalSteps() {
    final funnel = ref.read(registrationFunnelProvider);
    if (_step == 11 && funnel.authMethod != 'email') {
      _step = 13;
    }
  }

  void _reverseSkipConditionalSteps() {
    final funnel = ref.read(registrationFunnelProvider);
    if (_step == 13 && funnel.authMethod != 'email') {
      _step = 9;
    }
  }

  Future<void> _goToHome() async {
    ref.read(registrationFunnelProvider.notifier).skipToHome();
    final authNotifier = ref.read(authProvider.notifier);
    if (ref.read(authProvider).uid == null) {
      // Guest has no Firebase profile (no uid yet). Enter a fully functional
      // LOCAL demo mode instead of bouncing back to /welcome, which previously
      // created an infinite loop for users tapping "Más adelante".
      authNotifier.enterDemoMode(
        displayName: AppLocalizations.of(context)?.demoStudentName,
      );
    } else {
      await authNotifier.markOnboardingCompleted();
    }
    if (!mounted) return;
    ref.read(analyticsServiceProvider).track(AnalyticEvent.tutorialComplete);
    context.goNamed('main');
  }

  Future<void> _completeRegistration() async {
    if (_isAuthenticating) return;
    final gen = ++_authGeneration;
    setState(() => _isAuthenticating = true);
    final authNotifier = ref.read(authProvider.notifier);
    final funnel = ref.read(registrationFunnelProvider);
    try {
      if (funnel.authMethod == 'google') {
        await authNotifier.signInWithGoogle();
        if (!mounted || gen != _authGeneration) return;
        final auth = ref.read(authProvider);
        if (auth.isAuthenticated) {
          ref.read(registrationFunnelProvider.notifier).clearSensitiveData();
          final profileOk = await _createProfile(auth, funnel);
          if (!mounted || !profileOk) return;
          ref
              .read(analyticsServiceProvider)
              .track(AnalyticEvent.signUp, properties: {'method': 'google'});
          _jumpToStep(14);
        } else {
          SagenNotification.show(
            context,
            message: AuthException(
              auth.errorMessage ?? 'unknown_error',
            ).localizedMessage(AppLocalizations.of(context)!),
          );
        }
      } else if (funnel.authMethod == 'email') {
        final email = funnel.email;
        final password = funnel.password;
        final displayName = '${funnel.name} ${funnel.surname}'.trim();
        await authNotifier.signUpWithEmail(
          displayName: displayName,
          email: email,
          password: password,
        );
        if (!mounted || gen != _authGeneration) return;
        final auth = ref.read(authProvider);
        if (auth.showVerificationScreen || auth.isAuthenticated) {
          ref.read(registrationFunnelProvider.notifier).clearSensitiveData();
          final profileOk = await _createProfile(auth, funnel);
          if (!mounted || !profileOk) return;
          ref
              .read(analyticsServiceProvider)
              .track(AnalyticEvent.signUp, properties: {'method': 'email'});
          _advance();
        } else {
          SagenNotification.show(
            context,
            message: AuthException(
              auth.errorMessage ?? 'unknown_error',
            ).localizedMessage(AppLocalizations.of(context)!),
          );
        }
      }
    } catch (e, stack) {
      AppLogger().error('Registration failed', e, stack);
      // Limpia la credencial ante un error inesperado para que no quede
      // residiendo en el estado global; el email/nombre se conservan por si
      // el usuario reintenta.
      ref.read(registrationFunnelProvider.notifier).clearPassword();
      if (mounted) {
        SagenNotification.show(
          context,
          message: AppLocalizations.of(context)?.errorGeneric ?? 'Error',
        );
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<bool> _createProfile(
    AuthState auth,
    RegistrationFunnelState funnel,
  ) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return false;

    // For social sign-in (e.g. Google) the name step is skipped, so fall back
    // to the display name supplied by the identity provider.
    String firstName = funnel.name;
    String lastName = funnel.surname;
    if (firstName.isEmpty && lastName.isEmpty && auth.displayName.isNotEmpty) {
      final parts = auth.displayName.trim().split(RegExp(r'\s+'));
      firstName = parts.first;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    // Ensure a non-empty name AND a non-empty surname to satisfy the profile
    // schema (Firestore requires both; an empty last name would throw).
    // Google accounts with a single-part display name (e.g. "Alex") had no
    // fallback and left the user stuck — now the whole name is reused.
    if (firstName.isEmpty) {
      firstName =
          AppLocalizations.of(context)?.defaultStudentName ?? 'Estudiante';
    }
    if (lastName.isEmpty) {
      lastName = firstName;
    }

    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await ref
            .read(firestoreServiceProvider)
            .createUserProfile(
              uid: uid,
              firstName: firstName,
              lastName: lastName,
              email: funnel.email.isNotEmpty ? funnel.email : auth.email,
              age: funnel.age,
            );
        return true;
      } catch (e) {
        AppLogger().warning(
          'post_onboarding: _createProfile attempt $attempt failed: $e',
        );
        if (!mounted) return false;
        if (attempt < 2) await Future.delayed(const Duration(seconds: 1));
      }
    }
    if (mounted) {
      SagenNotification.show(
        context,
        message: AppLocalizations.of(context)?.errorGeneric ?? '',
        type: NotificationType.error,
      );
    }
    return false;
  }

  void _onAuthMethodSelected(String method) {
    if (method == 'google') {
      // NUEVO-fix (ronda 9, P6): el Future de _completeRegistration se
      // descartaba; unawaited() lo deja explícito (los errores se manejan
      // dentro del flujo con su propia UI de error/reintento).
      unawaited(_completeRegistration());
    } else {
      _advance();
    }
  }

  void _bridgeWizardData() {
    try {
      final wizardData = ref.read(wizardBridgeProvider);

      // Bridge wizard level (step 2, stored as "1"-"5") to assessmentLevelProvider (0-indexed)
      final wizardLevel = wizardData[2];
      if (wizardLevel != null) {
        final levelIndex = int.tryParse(wizardLevel.toString());
        if (levelIndex != null && ref.read(assessmentLevelProvider) == null) {
          ref.read(assessmentLevelProvider.notifier).state = levelIndex - 1;
        }
      }

      // Bridge wizard daily goal (step 6, stored as "3"/"10"/"15"/"30") to dashboardProvider
      final wizardGoal = wizardData[6];
      if (wizardGoal != null) {
        final minutes = int.tryParse(wizardGoal.toString());
        if (minutes != null) {
          ref.read(dashboardProvider.notifier).setDailyGoalMinutes(minutes);
        }
      }

      // Persist the remaining onboarding answers (source, motivations,
      // interests, learning style, commitment) to analytics so the collected
      // preferences aren't silently discarded after the wizard.
      final source = wizardData[1];
      final motivations = wizardData[3];
      final interests = wizardData[4];
      final learningStyle = wizardData[5];
      final commitment = wizardData[7];
      if (source != null ||
          motivations != null ||
          interests != null ||
          learningStyle != null ||
          commitment != null) {
        ref
            .read(analyticsServiceProvider)
            .track(
              AnalyticEvent.featureUsed,
              properties: {
                'feature': 'wizard_prefs',
                if (source != null) 'wizard_source': source.toString(),
                if (motivations != null)
                  'wizard_motivations': _joinList(motivations),
                if (interests != null) 'wizard_interests': _joinList(interests),
                if (learningStyle != null)
                  'wizard_learning_style': _joinList(learningStyle),
                if (commitment != null)
                  'wizard_commitment': _joinList(commitment),
              },
            );
      }
    } catch (e) {
      AppLogger().warning('post_onboarding: _bridgeWizardData failed: $e');
    }
    ref.read(wizardBridgeProvider.notifier).reset();
  }

  static String _joinList(Object? value) {
    if (value is List) return value.join(',');
    return value.toString();
  }

  static final List<_StepBuilder?> _stepBuilders = [
    // 0: Welcome
    (ctx, a) =>
        PostOnboardingWelcomeScreen(onContinue: a.advance, onBack: a.goToHome),
    // 1: Route selection
    (ctx, a) => RouteSelectionScreen(onContinue: a.advance, onBack: a.goBack),
    // 2: Motivation
    (ctx, a) => MotivationScreen(onContinue: a.advance, onBack: a.goBack),
    // 3: Projection
    (ctx, a) => ProjectionScreen(onContinue: a.advance, onBack: a.goBack),
    // 4: Starting point
    (ctx, a) => StartingPointScreen(onContinue: a.advance, onBack: a.goBack),
    // 5: First lesson
    (ctx, a) => FirstLessonScreen(onComplete: a.advance),
    // 6: Lesson stats
    (ctx, a) => LessonStatsScreen(onRecibirXp: a.advance),
    // 7: Streak intro
    (ctx, a) => StreakIntroScreen(onContinue: a.advance),
    // 8: Profile hook
    (ctx, a) => ProfileHookScreen(
      onCreateProfile: a.advance,
      onSkipToHome: () {
        a.ref.read(registrationFunnelProvider.notifier).skipToHome();
        a.goToHome();
      },
    ),
    // 9: Age input
    (ctx, a) => AgeInputScreen(onContinue: a.advance, onBack: a.goBack),
    // 10: Auth method (overridden inline at _step == 10)
    null,
    // 11: Email input (conditional)
    null,
    // 12: Password input (conditional)
    null,
    // 13: Name input
    (ctx, a) =>
        NameInputScreen(onContinue: a.completeRegistration, onBack: a.goBack),
    // 14: Profile success
    (ctx, a) => const ProfileSuccessScreen(),
  ];

  Widget _buildCurrentStep(_PostOnboardingActions actions) {
    if (_step >= _totalSteps) return const ProfileSuccessScreen();

    if (_step == 10) {
      if (_isAuthenticating) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.xxl),
                TextButton(
                  onPressed: () => setState(() {
                    _isAuthenticating = false;
                    _authGeneration++;
                  }),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ],
            ),
          ),
        );
      }
      return AuthMethodScreen(
        onContinue: () => _onAuthMethodSelected(
          ref.read(registrationFunnelProvider).authMethod,
        ),
        onBack: _goBack,
      );
    }

    if (_step == 11) {
      final authMethod = ref.watch(
        registrationFunnelProvider.select((s) => s.authMethod),
      );
      if (authMethod == 'email') {
        return EmailInputScreen(onContinue: _advance, onBack: _goBack);
      }
      return const SizedBox.shrink();
    }

    if (_step == 12) {
      final authMethod = ref.watch(
        registrationFunnelProvider.select((s) => s.authMethod),
      );
      if (authMethod == 'email') {
        return PasswordInputScreen(onContinue: _advance, onBack: _goBack);
      }
      return const SizedBox.shrink();
    }

    final builder = _stepBuilders[_step];
    return builder != null
        ? builder(context, actions)
        : const ProfileSuccessScreen();
  }

  @override
  Widget build(BuildContext context) {
    final actions = _PostOnboardingActions(
      advance: _advance,
      goBack: _goBack,
      goToHome: _goToHome,
      completeRegistration: _completeRegistration,
      onAuthMethodSelected: _onAuthMethodSelected,
      jumpToStep: _jumpToStep,
      ref: ref,
    );

    if (_step >= _totalSteps) return const ProfileSuccessScreen();

    final progress = (_step / (_totalSteps - 1)).clamp(0.0, 1.0);

    return Column(
      children: [
        if (_step > 0 && _step < _totalSteps - 1)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation(
                  PremiumColors.primaryAccent,
                ),
              ),
            ),
          ),
        Expanded(
          child: _buildCurrentStep(actions)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(
                begin: _slidingForward ? 0.08 : -0.08,
                duration: 300.ms,
                curve: Curves.easeOutCubic,
              ),
        ),
      ],
    );
  }
}
