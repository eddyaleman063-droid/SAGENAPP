import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/theme_constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/providers.dart';
import '../ui/screens/splash_screen.dart';
import '../ui/screens/welcome_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/forgot_password_screen.dart';
import '../ui/screens/auth/verify_email_screen.dart';
import '../ui/screens/onboarding/onboarding_wizard_screen.dart';
import '../ui/screens/onboarding/post_onboarding_flow.dart';
import '../ui/screens/main_layout.dart';
import '../ui/screens/dashboard/lessons_screen.dart';
import '../ui/screens/dashboard/sagen_pass_screen.dart';
import '../ui/screens/dashboard/user_profile_screen.dart';
import '../ui/screens/lesson/lesson_session_screen.dart';
import '../ui/screens/lesson/lesson_results_screen.dart';
import '../ui/screens/lesson/learning_session_screen.dart';
import '../models/learning/quiz_score.dart';
import '../ui/screens/lesson/session_summary_screen.dart';
import '../ui/screens/lesson/habit_transition_screen.dart';
import '../ui/screens/streak/daily_streak_screen.dart';
import '../ui/screens/payment/payment_success_screen.dart';
import '../ui/screens/payment/payment_failed_screen.dart';
import '../ui/screens/payment/payment_pending_screen.dart';
import '../ui/screens/legal/privacy_policy_screen.dart';
import '../ui/screens/mini_game/mini_game_hub.dart';
import '../ui/screens/mini_game/memory_flip_screen.dart';
import '../ui/screens/mini_game/word_match_screen.dart';
import '../ui/screens/mini_game/speed_sort_screen.dart';
import '../ui/screens/mini_game/pattern_trace_screen.dart';
import '../models/mini_game.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final location = state.matchedLocation;

      if (auth.isUninitialized || auth.isLoading) {
        if (location != '/') return '/';
        return null;
      }

      if (!auth.isAuthenticated) {
        // Usuario logueado pero con email sin verificar: llevarlo a la
        // pantalla de verificación en vez de tratarlo como un visitante.
        // El flujo de onboarding continúa sin interrupción.
        if (auth.pendingVerification && auth.uid != null) {
          const onboardingRoutes = {'/onboarding', '/onboarding/flow'};
          if (onboardingRoutes.contains(location)) return null;
          if (location != '/verify-email') return '/verify-email';
          return null;
        }
        if (location == '/') return '/welcome';
        final publicRoutes = <String>{
          '/welcome', '/login', '/forgot-password',
          '/onboarding', '/onboarding/flow',
          '/payment/success', '/payment/failure', '/payment/pending',
        };
        if (!publicRoutes.contains(location)) return '/welcome';
        return null;
      }

      if (auth.isAuthenticated) {
        if (!auth.profileLoaded) return null;
        final authRoutes = <String>{
          '/', '/welcome', '/login', '/forgot-password', '/verify-email',
          '/onboarding', '/onboarding/flow',
        };
        if (authRoutes.contains(location)) {
          return auth.onboardingCompleted ? '/main' : '/onboarding/flow';
        }
        if (!auth.onboardingCompleted && location != '/onboarding/flow') {
          return '/onboarding/flow';
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(autoNavigate: false),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          final isOnboarding = state.uri.queryParameters['onboarding'] == 'true';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: LoginScreen(isOnboarding: isOnboarding),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                  child: child,
                ),
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const VerifyEmailScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const OnboardingWizardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/onboarding/flow',
        name: 'onboarding-flow',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const PostOnboardingFlow(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/lessons',
        name: 'lessons',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const LessonsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/lesson/:stageId/:lessonId',
        name: 'lesson-session',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: LessonSessionScreen(
            stageId: state.pathParameters['stageId']!,
            lessonId: state.pathParameters['lessonId']!,
            lessonTitle: state.extra as String? ?? '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/lesson/:stageId/:lessonId/results',
        name: 'lesson-results',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: LessonResultsScreen(
            stageId: state.pathParameters['stageId']!,
            lessonId: state.pathParameters['lessonId']!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/learning/:stageId/:lessonId',
        name: 'learning-session',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: LearningSessionScreen(
            stageId: state.pathParameters['stageId']!,
            lessonId: state.pathParameters['lessonId']!,
            lessonTitle: state.extra as String? ?? '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/quiz-summary',
        name: 'quiz-summary',
        pageBuilder: (context, state) {
          final score = state.extra is QuizScoreCalculator ? state.extra as QuizScoreCalculator : null;
          if (score == null) {
            final l = AppLocalizations.of(context);
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: Scaffold(body: Center(child: Text(l?.errorGeneric ?? ''))),
              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
            );
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: SessionSummaryScreen(score: score),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          );
        },
      ),
      GoRoute(
        path: '/habit-transition',
        name: 'habit-transition',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const HabitTransitionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/streak',
        name: 'streak',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const DailyStreakScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      GoRoute(
        path: '/pass',
        name: 'pass',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SagenPassScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/mini-games',
        name: 'mini-games',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const MiniGameHub(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/mini-game/:type',
        name: 'mini-game',
        pageBuilder: (context, state) {
          final type = state.pathParameters['type']!;
          final miniGameType = MiniGameType.values.firstWhere(
            (t) => t.name == type,
            orElse: () => MiniGameType.memoryFlip,
          );
          Widget child;
          switch (miniGameType) {
            case MiniGameType.memoryFlip:
              child = const MemoryFlipScreen(config: MiniGameConfig(type: MiniGameType.memoryFlip));
            case MiniGameType.wordMatch:
              child = const WordMatchScreen(config: MiniGameConfig(type: MiniGameType.wordMatch));
            case MiniGameType.speedSort:
              child = const SpeedSortScreen(config: MiniGameConfig(type: MiniGameType.speedSort));
            case MiniGameType.patternTrace:
              child = const PatternTraceScreen(config: MiniGameConfig(type: MiniGameType.patternTrace));
          }
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: child,
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                  child: child,
                ),
          );
        },
      ),
      GoRoute(
        path: '/profile/:uid',
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: UserProfileScreen(
            uid: state.pathParameters['uid']!,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/payment/success',
        name: 'payment-success',
        pageBuilder: (context, state) {
          final donationParam = state.uri.queryParameters['donationAmount'];
          final donationAmount = double.tryParse(donationParam ?? '') ?? 0.0;
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PaymentSuccessScreen(donationAmount: donationAmount),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
      ),
      GoRoute(
        path: '/payment/failure',
        name: 'payment-failure',
        pageBuilder: (context, state) {
          final error = state.uri.queryParameters['error'];
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: PaymentFailedScreen(error: error),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                  .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: FadeTransition(opacity: animation, child: child),
            ),
          );
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const PrivacyPolicyScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: child,
              ),
        ),
      ),
      GoRoute(
        path: '/payment/pending',
        name: 'payment-pending',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const PaymentPendingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: FadeTransition(opacity: animation, child: child),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) {
      final l = AppLocalizations.of(context)!;
      return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: AppTextStyle.hero.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.notFoundTitle,
                style: AppTextStyle.title.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.notFoundDescription,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.goNamed('welcome'),
                child: Text(l.notFoundBackHome),
              ),
            ],
          ),
        ),
      ),
    );
    },
  );

  ref.listen(authProvider, (_, _) => router.refresh());
  ref.onDispose(() => router.dispose());

  return router;
});
