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
import '../ui/screens/dashboard/gem_history_screen.dart';
import '../ui/screens/dashboard/user_profile_screen.dart';
import '../ui/screens/lesson/lesson_session_screen.dart';
import '../ui/screens/lesson/lesson_results_screen.dart';
import '../ui/screens/lesson/review_session_screen.dart';
import '../models/learning/quiz_result.dart';
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

/// Route sets used by the redirect logic.
const _publicRoutes = {
  '/welcome',
  '/login',
  '/forgot-password',
  '/onboarding',
  '/onboarding/flow',
  '/payment/success',
  '/payment/failure',
  '/payment/pending',
};

const _preAuthRoutes = {
  '/',
  '/welcome',
  '/login',
  '/forgot-password',
  '/verify-email',
  '/onboarding',
  '/onboarding/flow',
};

const _onboardingRoutes = {'/onboarding', '/onboarding/flow'};

/// True for routes that only make sense once the authenticated user's profile
/// has finished loading (i.e. app screens, not pre-auth/public/onboarding).
bool _isGatedAppRoute(String location) {
  if (_preAuthRoutes.contains(location)) return false;
  if (location == '/') return false;
  return true;
}

/// Helper: slide-from-right transition (most common).
Widget _slideFromRight(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: child,
  );
}

/// Helper: slide-from-bottom + fade (payment screens).
Widget _slideFromBottom(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
    child: FadeTransition(opacity: animation, child: child),
  );
}

/// Helper: simple fade transition.
Widget _fadeIn(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

/// Convenience wrapper for [CustomTransitionPage] with [state.pageKey].
CustomTransitionPage<void> _page(
  GoRouterState state,
  Widget child,
  Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
  transition,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: transition,
  );
}

/// Builds the full [GoRouter] for the app. Exposed as a factory so tests can
/// mount the real route table from any [initialLocation] (bypassing the
/// splash → /main redirect that otherwise builds heavy shells).
@visibleForTesting
GoRouter buildAppRouter({
  GlobalKey<NavigatorState>? navigatorKey,
  String initialLocation = '/',
}) {
  return GoRouter(
    navigatorKey: navigatorKey ?? rootNavigatorKey,
    initialLocation: initialLocation,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(autoNavigate: false),
      ),
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        pageBuilder: (context, state) =>
            _page(state, const WelcomeScreen(), _fadeIn),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          final isOnboarding =
              state.uri.queryParameters['onboarding'] == 'true';
          return _page(
            state,
            LoginScreen(
              isOnboarding: isOnboarding,
              onSwitchToRegister: () => context.goNamed('onboarding'),
            ),
            _slideFromRight,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) =>
            _page(state, const ForgotPasswordScreen(), _fadeIn),
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        pageBuilder: (context, state) =>
            _page(state, const VerifyEmailScreen(), _fadeIn),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _page(state, const OnboardingWizardScreen(), _slideFromRight),
      ),
      GoRoute(
        path: '/onboarding/flow',
        name: 'onboarding-flow',
        pageBuilder: (context, state) =>
            _page(state, const PostOnboardingFlow(), _fadeIn),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        pageBuilder: (context, state) =>
            _page(state, const MainLayout(), _fadeIn),
      ),
      GoRoute(
        path: '/lessons',
        name: 'lessons',
        pageBuilder: (context, state) =>
            _page(state, const LessonsScreen(), _slideFromRight),
      ),
      GoRoute(
        path: '/lesson/:stageId/:lessonId',
        name: 'lesson-session',
        pageBuilder: (context, state) => _page(
          state,
          LessonSessionScreen(
            stageId: state.pathParameters['stageId']!,
            lessonId: state.pathParameters['lessonId']!,
            lessonTitle: state.extra as String? ?? '',
          ),
          _slideFromRight,
        ),
      ),
      GoRoute(
        path: '/lesson/:stageId/:lessonId/results',
        name: 'lesson-results',
        pageBuilder: (context, state) => _page(
          state,
          LessonResultsScreen(
            stageId: state.pathParameters['stageId']!,
            lessonId: state.pathParameters['lessonId']!,
          ),
          _slideFromRight,
        ),
      ),
      GoRoute(
        path: '/review',
        name: 'review-session',
        pageBuilder: (context, state) =>
            _page(state, const ReviewSessionScreen(), _slideFromRight),
      ),
      GoRoute(
        path: '/review-summary',
        name: 'review-summary',
        pageBuilder: (context, state) {
          final result = state.extra is QuizResult
              ? state.extra as QuizResult
              : null;
          if (result == null) {
            final l = AppLocalizations.of(context);
            return _page(
              state,
              Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            l?.errorGeneric ?? '',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.goNamed('main'),
                          icon: const Icon(Icons.home_rounded),
                          label: Text(l?.back.toUpperCase() ?? 'BACK'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _fadeIn,
            );
          }
          return _page(
            state,
            ReviewSummaryScreen(
              result: result,
              onContinue: () => context.goNamed('main'),
            ),
            _fadeIn,
          );
        },
      ),
      GoRoute(
        path: '/streak',
        name: 'streak',
        pageBuilder: (context, state) =>
            _page(state, const DailyStreakScreen(), _fadeIn),
      ),
      GoRoute(
        path: '/pass',
        name: 'pass',
        pageBuilder: (context, state) =>
            _page(state, const SagenPassScreen(), _slideFromRight),
      ),
      GoRoute(
        path: '/gem-history',
        name: 'gem-history',
        pageBuilder: (context, state) =>
            _page(state, const GemHistoryScreen(), _slideFromRight),
      ),
      GoRoute(
        path: '/mini-games',
        name: 'mini-games',
        pageBuilder: (context, state) =>
            _page(state, const MiniGameHub(), _slideFromRight),
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
              child = const MemoryFlipScreen(
                config: MiniGameConfig(type: MiniGameType.memoryFlip),
              );
            case MiniGameType.wordMatch:
              child = const WordMatchScreen(
                config: MiniGameConfig(type: MiniGameType.wordMatch),
              );
            case MiniGameType.speedSort:
              child = const SpeedSortScreen(
                config: MiniGameConfig(type: MiniGameType.speedSort),
              );
            case MiniGameType.patternTrace:
              child = const PatternTraceScreen(
                config: MiniGameConfig(type: MiniGameType.patternTrace),
              );
          }
          return _page(state, child, _slideFromRight);
        },
      ),
      GoRoute(
        path: '/profile/:uid',
        name: 'profile',
        pageBuilder: (context, state) => _page(
          state,
          UserProfileScreen(uid: state.pathParameters['uid']!),
          _slideFromRight,
        ),
      ),
      GoRoute(
        path: '/payment/success',
        name: 'payment-success',
        pageBuilder: (context, state) {
          // El server back_url envía 'amount' (functions/index.js:300) y el
          // deep-link handler normaliza donationAmount→amount (main.dart:284);
          // se acepta además 'donationAmount' por compatibilidad con rutas
          // más antiguas.
          final amountParam =
              state.uri.queryParameters['amount'] ??
              state.uri.queryParameters['donationAmount'];
          final donationAmount = double.tryParse(amountParam ?? '') ?? 0.0;
          return _page(
            state,
            PaymentSuccessScreen(donationAmount: donationAmount),
            _slideFromBottom,
          );
        },
      ),
      GoRoute(
        path: '/payment/failure',
        name: 'payment-failure',
        pageBuilder: (context, state) {
          final error = state.uri.queryParameters['error'];
          return _page(
            state,
            PaymentFailedScreen(error: error),
            _slideFromBottom,
          );
        },
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacy-policy',
        pageBuilder: (context, state) =>
            _page(state, const PrivacyPolicyScreen(), _slideFromRight),
      ),
      GoRoute(
        path: '/payment/pending',
        name: 'payment-pending',
        pageBuilder: (context, state) =>
            _page(state, const PaymentPendingScreen(), _slideFromBottom),
      ),
    ],
    errorBuilder: (context, state) {
      final l = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '404',
                  style: AppTextStyle.hero.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l.notFoundTitle,
                  style: AppTextStyle.title.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.notFoundDescription,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMd.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
                ElevatedButton(
                  onPressed: () => context.goNamed('main'),
                  child: Text(l.notFoundBackHome),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildAppRouter();

  ref.listen(authProvider, (_, _) => router.refresh());
  ref.onDispose(() => router.dispose());

  return router;
});

/// Pure redirect decision, extracted from [_redirect] so it can be tested in
/// isolation with any [AuthState] + location.
@visibleForTesting
String? resolveRedirect(AuthState auth, String location) {
  // Phase 1: Still loading → force splash (except anywhere the user is
  // legitimately mid-registration). BUG-fix: sin esta exención, el redirect a
  // '/' durante AuthStatus.loading desmontaba PostOnboardingFlow mientras
  // signInWithGoogle( ) mostraba el diálogo nativo de Google, abortando el
  // registro: el widget se desmontaba antes de _createProfile y el usuario
  // quedaba en un bucle de registro sin perfil.
  if (auth.isUninitialized || auth.isLoading) {
    if (location == '/' || _onboardingRoutes.contains(location)) return null;
    return '/';
  }

  // Phase 2: Not authenticated.
  if (!auth.isAuthenticated) {
    if (auth.pendingVerification && auth.uid != null) {
      if (_onboardingRoutes.contains(location)) return null;
      if (location != '/verify-email') return '/verify-email';
      return null;
    }
    if (location == '/') return '/welcome';
    if (!_publicRoutes.contains(location)) return '/welcome';
    return null;
  }

  // Phase 3: Authenticated.
  if (!auth.profileLoaded) {
    // Profile not loaded yet — do not let the user reach gated app screens
    // (e.g. /main) during the loading window.
    if (_isGatedAppRoute(location)) return '/';
    return null;
  }
  if (_preAuthRoutes.contains(location)) {
    return auth.onboardingCompleted ? '/main' : '/onboarding/flow';
  }
  if (!auth.onboardingCompleted && !_onboardingRoutes.contains(location)) {
    return '/onboarding/flow';
  }

  return null;
}

/// Centralized redirect logic.
String? _redirect(BuildContext context, GoRouterState state) {
  return resolveRedirect(
    ProviderScope.containerOf(context).read(authProvider),
    state.matchedLocation,
  );
}
