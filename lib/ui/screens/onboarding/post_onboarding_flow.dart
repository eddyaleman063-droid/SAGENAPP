import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
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
import '../../screens/auth/login_screen.dart';
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

  static const int _totalSteps = 16;

  void _advance() {
    setState(() => _step++);
    ref.read(analyticsServiceProvider).trackOnboardingStep(_step);
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  void _jumpToStep(int step) {
    setState(() => _step = step);
    ref.read(analyticsServiceProvider).trackOnboardingStep(_step);
  }

  void _goToHome() {
    ref.read(registrationFunnelProvider.notifier).skipToHome();
    ref.read(authProvider.notifier).markOnboardingCompleted();
    ref.read(analyticsServiceProvider).track(AnalyticEvent.tutorialComplete);
    context.goNamed('main');
  }

  Future<void> _completeRegistration() async {
    final authNotifier = ref.read(authProvider.notifier);
    final funnel = ref.read(registrationFunnelProvider);
    if (funnel.authMethod == 'google') {
      await authNotifier.signInWithGoogle();
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        await _createProfile(auth, funnel);
        ref
            .read(analyticsServiceProvider)
            .track(AnalyticEvent.signUp, properties: {'method': 'google'});
        setState(() => _step = 14);
      } else if (auth.errorMessage != null) {
        SagenNotification.show(
          context,
          message: AuthException(
            auth.errorMessage!,
          ).localizedMessage(AppLocalizations.of(context)!),
        );
      }
    } else if (funnel.authMethod == 'email') {
      final password = funnel.password;
      ref.read(registrationFunnelProvider.notifier).clearSensitiveData();
      await authNotifier.signUpWithEmail(
        displayName: '${funnel.name} ${funnel.surname}'.trim(),
        email: funnel.email,
        password: password,
      );
      if (!mounted) return;
      final auth = ref.read(authProvider);
      if (auth.showVerificationScreen || auth.isAuthenticated) {
        await _createProfile(auth, funnel);
        ref
            .read(analyticsServiceProvider)
            .track(AnalyticEvent.signUp, properties: {'method': 'email'});
        _advance();
      } else if (auth.errorMessage != null) {
        SagenNotification.show(
          context,
          message: AuthException(
            auth.errorMessage!,
          ).localizedMessage(AppLocalizations.of(context)!),
        );
      }
    }
  }

  Future<void> _createProfile(
    AuthState auth,
    RegistrationFunnelState funnel,
  ) async {
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid == null) return;
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        await ref
            .read(firestoreServiceProvider)
            .createUserProfile(
              uid: uid,
              firstName: funnel.name,
              lastName: funnel.surname,
              email: funnel.email.isNotEmpty ? funnel.email : auth.email,
              age: funnel.age,
            );
        return;
      } catch (e) {
        AppLogger().warning(
          'post_onboarding: _createProfile attempt $attempt failed: $e',
        );
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
  }

  void _onAuthMethodSelected(String method) {
    if (method == 'google') {
      _completeRegistration();
    } else {
      _advance();
    }
  }

  void _bridgeWizardData() {
    try {
      final wizardData = ref.read(onboardingWizardProvider).sectionData;

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
    } catch (e) {
      AppLogger().warning('post_onboarding: _bridgeWizardData failed: $e');
    }
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
        a.jumpToStep(15);
      },
    ),
    // 9: Age input
    (ctx, a) => AgeInputScreen(onContinue: a.advance),
    // 10: Auth method
    (ctx, a) => AuthMethodScreen(
      onContinue: () {
        a.onAuthMethodSelected('google');
      },
    ),
    // 11: Email input (conditional)
    null,
    // 12: Password input (conditional)
    null,
    // 13: Name input
    (ctx, a) => NameInputScreen(onContinue: a.completeRegistration),
    // 14: Profile success
    (ctx, a) => const ProfileSuccessScreen(),
    // 15: Inline auth (login/register)
    (ctx, a) => const LoginScreen(isOnboarding: true),
  ];

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

    // Bridge wizard data to downstream providers (one-time)
    _bridgeWizardData();

    if (_step == 10) {
      return AuthMethodScreen(
        onContinue: () => _onAuthMethodSelected(
          ref.read(registrationFunnelProvider).authMethod,
        ),
      );
    }

    if (_step == 11) {
      final state = ref.watch(registrationFunnelProvider);
      if (state.authMethod == 'email') {
        return EmailInputScreen(onContinue: _advance);
      }
      // Defer jump to post-frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _jumpToStep(13);
      });
      return const SizedBox.shrink();
    }

    if (_step == 12) {
      final state = ref.watch(registrationFunnelProvider);
      if (state.authMethod == 'email') {
        return PasswordInputScreen(onContinue: _advance);
      }
      // Defer jump to post-frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _jumpToStep(13);
      });
      return const SizedBox.shrink();
    }

    final builder = _stepBuilders[_step];
    return builder != null
        ? builder(context, actions).animate().fadeIn().slideY(begin: 0.05)
        : const ProfileSuccessScreen();
  }
}
