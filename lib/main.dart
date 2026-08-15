import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'core/initialization/service_initializer.dart';
import 'core/theme/theme_constants.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/providers.dart';
import 'router/app_router.dart';
import 'services/app_logger.dart';
import 'services/auth_service.dart';
import 'providers/app_lifecycle_provider.dart';
import 'services/cloud_sync_service.dart';
import 'services/deep_link_service.dart';
import 'ui/widgets/common/ambient_background.dart';
import 'ui/widgets/common/error_boundary.dart';
import 'ui/widgets/chest_listener.dart';
import 'ui/widgets/common/sync_coordinator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final logger = AppLogger();
  logger.setProductionMode(kReleaseMode);

  _setupErrorHandlers(logger);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // Note: onboarding_done flag is set by the onboarding flow itself,
  // NOT here. This just checks if onboarding has been completed before.

  if (kReleaseMode) {
    // Release fallback for uncaught build errors: localized with the persisted
    // language preference (falls back to the system language).
    final errorLocale = _resolveErrorLocale(prefs);
    ErrorWidget.builder = (details) =>
        _ReleaseErrorFallback(locale: errorLocale);
  }

  // Shared service instances — created here to guarantee a single instance
  // shared between the Riverpod tree and deferred initialization.
  final authService = AuthService(logger: logger);
  final cloudSyncService = CloudSyncService(
    authService: authService,
    logger: logger,
  );

  runApp(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        loggerProvider.overrideWithValue(logger),
        authServiceProvider.overrideWithValue(authService),
        cloudSyncServiceProvider.overrideWithValue(cloudSyncService),
      ],
      child: const SagenApp(),
    ),
  );

  // Deferred initialization via centralized service initializer
  Future.microtask(
    () => ServiceInitializer.initialize(
      prefs: prefs,
      logger: logger,
      authService: authService,
      cloudSyncService: cloudSyncService,
    ),
  );
}

/// Resolves the locale for the release error fallback from the persisted
/// language preference; falls back to the system language.
Locale _resolveErrorLocale(SharedPreferences prefs) {
  final saved = prefs.getString('app_language');
  if (saved == 'en') return const Locale('en');
  if (saved == 'es') return const Locale('es');
  return WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'en'
      ? const Locale('en')
      : const Locale('es');
}

/// Release-only last-resort fallback shown when a build throws an error that
/// escapes the in-app error boundary. Localized (es/en) via the app delegates.
class _ReleaseErrorFallback extends StatelessWidget {
  final Locale locale;
  const _ReleaseErrorFallback({required this.locale});

  void _goHome() {
    HapticFeedback.lightImpact();
    rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: PremiumColors.deepBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 48,
                  color: PremiumColors.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'SAGEN',
                  style: AppTextStyle.title.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  '${l?.errorSomethingWrong ?? 'Something went wrong'}\n'
                  '${l?.errorUnexpected ?? 'Returning to a safe state...'}',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyMd.copyWith(
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 80,
                    minHeight: 80,
                  ),
                  child: Semantics(
                    button: true,
                    label: l?.errorRestartApp ?? 'Back to home',
                    child: GestureDetector(
                      onTap: _goHome,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: PremiumColors.primaryAccent,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l?.errorRestartApp ?? 'Back to home',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

void _setupErrorHandlers(AppLogger logger) {
  if (kReleaseMode) {
    try {
      FlutterError.onError = (details) {
        if (Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
        logger.error(
          'FlutterError: ${details.exception}',
          details.exception,
          details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        if (Firebase.apps.isNotEmpty) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        logger.error('PlatformDispatcher error', error, stack);
        return true;
      };
    } catch (e) {
      logger.error('Failed to set up global error handlers', e);
    }
  } else {
    FlutterError.onError = (details) {
      logger.error(
        'FlutterError: ${details.exception}',
        details.exception,
        details.stack,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      logger.error('PlatformDispatcher error', error, stack);
      return true;
    };
  }
}

class SagenApp extends ConsumerStatefulWidget {
  const SagenApp({super.key});

  @override
  ConsumerState<SagenApp> createState() => _SagenAppState();
}

class _SagenAppState extends ConsumerState<SagenApp> {
  StreamSubscription<DeepLinkAction>? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    ref.read(appLifecycleProvider.notifier);
    _deepLinkSub = ref
        .read(deepLinkServiceProvider)
        .actionStream
        .listen(
          _handleDeepLinkAction,
          onError: (e) => AppLogger().warning('Deep link stream error: $e'),
        );
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  void _handleDeepLinkAction(DeepLinkAction action) {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;
    final router = ref.read(routerProvider);

    switch (action) {
      case ProfileDeepLink(:final uid):
        router.goNamed('profile', pathParameters: {'uid': uid});
      case RankingDeepLink():
        router.goNamed('main');
        ref.read(deepLinkServiceProvider).requestTabSwitch(3);
      case LessonDeepLink(stageId: final stageId):
        router.goNamed('lessons', queryParameters: {'stageId': stageId});
      case PaymentSuccessDeepLink(:final externalRef, :final donationAmount):
        final params = <String, String>{};
        if (donationAmount != null) {
          params['amount'] = donationAmount.toString();
        }
        if (externalRef != null) params['external_reference'] = externalRef;
        router.goNamed('payment-success', queryParameters: params);
      case PaymentFailureDeepLink():
        router.goNamed('payment-failure');
      case PaymentPendingDeepLink():
        router.goNamed('payment-pending');
      case UnknownDeepLink():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final lang = ref.watch(languageProvider);
    final router = ref.read(routerProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.currentTheme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: ErrorBoundary(
        child: SyncCoordinator(
          child: AmbientBackground(
            child: MaterialApp.router(
              builder: (context, child) {
                final fontScale = ref
                    .watch(experienceServiceProvider)
                    .fontSizeScale;
                final safeScale = fontScale.clamp(0.8, 1.5);
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(safeScale)),
                  child: ChestListener(child: child ?? const SizedBox.shrink()),
                );
              },
              title: 'SAGEN',
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              theme: theme.currentTheme,
              highContrastTheme: AppTheme.highContrastLight,
              highContrastDarkTheme: AppTheme.highContrastDark,
              key: ValueKey(lang.locale.languageCode),
              locale: lang.hasUserChosen ? lang.locale : null,
              supportedLocales: const [
                Locale('es'),
                Locale('en'),
                Locale('fr'),
                Locale('pt'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeListResolutionCallback: (locales, supported) {
                if (locales != null) {
                  for (final locale in locales) {
                    for (final supportedLocale in supported) {
                      if (supportedLocale.languageCode == locale.languageCode) {
                        return supportedLocale;
                      }
                    }
                  }
                }
                return supported.first;
              },
            ),
          ),
        ),
      ),
    );
  }
}
