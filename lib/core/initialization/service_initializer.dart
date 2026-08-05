import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase_options.dart';
import '../../services/app_logger.dart';
import '../../services/auth_service.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/api_client.dart';
import '../../services/analytics_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/experience_service.dart';
import '../../services/smart_cache.dart';
import '../../services/notification_service.dart';
import '../../services/audio_service.dart';
import '../../services/device_integrity_service.dart';
import '../../services/deep_link_service.dart';
import '../../services/app_lock_service.dart';
import '../../services/performance_service.dart';
import '../../services/device_tier.dart';
import '../../services/smart_promo_service.dart';

/// Centralized service initializer.
/// Encapsulates all initialization logic for easier testing and maintenance.
class ServiceInitializer {
  ServiceInitializer._();

  /// Initializes all deferred services in the correct order.
  /// Firebase must be initialized first since other services depend on it.
  static Future<void> initialize({
    required SharedPreferences prefs,
    required AppLogger logger,
    required AuthService authService,
    required CloudSyncService cloudSyncService,
  }) async {
    _initDeviceTier(logger);

    final firebaseOk = await _initFirebase(logger);
    if (firebaseOk) {
      await _initFirebaseServices(logger);
    }

    await _initAuthService(authService, logger);
    await _initCriticalServices(prefs, cloudSyncService, logger);
    await _initRemainingServices(prefs, logger);
  }

  static void _initDeviceTier(AppLogger logger) {
    try {
      LowEndDeviceDetector.instance.init();
    } catch (e) {
      logger.error('Tier detection failed', e);
    }
  }

  static Future<bool> _initFirebase(AppLogger logger) async {
    try {
      final options = Platform.isIOS
          ? DefaultFirebaseOptions.ios
          : DefaultFirebaseOptions.android;
      await Firebase.initializeApp(options: options);
      logger.info('Firebase initialized successfully');
      return true;
    } catch (e) {
      logger.error('Firebase init failed: $e');
      return await _recoverFirebase(logger);
    }
  }

  static Future<bool> _recoverFirebase(AppLogger logger) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      const channel = MethodChannel('dev.sagen.app/firebase');
      await channel.invokeMethod('recoverFirebaseApp');
      final options = Platform.isIOS
          ? DefaultFirebaseOptions.ios
          : DefaultFirebaseOptions.android;
      await Firebase.initializeApp(options: options);
      logger.info('Firebase recovered and initialized successfully');
      return true;
    } catch (e2) {
      logger.error('Firebase initialization failed: $e2');
      return false;
    }
  }

  static Future<void> _initFirebaseServices(AppLogger logger) async {
    try {
      if (Platform.isIOS) {
        await FirebaseAppCheck.instance.activate(
          appleProvider: AppleProvider.appAttest,
        );
      } else {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
        );
      }
      logger.info('App Check activated');
    } catch (e) {
      logger.error('App Check activation failed', e);
      // In release mode, log the failure but do NOT rethrow.
      // App Check is a defense-in-depth measure; blocking init
      // on failure would make the app unusable if Play Integrity
      // or App Attest has transient issues.
    }

    try {
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
    } catch (e) {
      logger.error('Firestore settings failed', e);
    }

    try {
      FirebaseAnalytics.instance;
    } catch (e) {
      logger.error('Analytics init failed', e);
    }

    try {
      await PerformanceService.instance.init();
    } catch (e) {
      logger.error('Performance monitoring init failed', e);
    }

    if (kReleaseMode) {
      try {
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      } catch (e) {
        logger.error('Crashlytics init failed', e);
      }
    }
  }

  static Future<void> _initAuthService(AuthService authService, AppLogger logger) async {
    try {
      await authService.init();
      logger.info('AuthService initialized');
    } catch (e) {
      logger.error('Auth init failed', e);
    }

    try {
      final user = authService.currentUser;
      if (user != null) {
        await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
        await FirebaseAnalytics.instance.setUserId(id: user.uid);
      }
    } catch (e) {
      logger.error('Crashlytics user ID failed', e);
    }
  }

  static Future<void> _initCriticalServices(
    SharedPreferences prefs,
    CloudSyncService cloudSyncService,
    AppLogger logger,
  ) async {
    await _initSafe('CloudSync', () => cloudSyncService.init(prefs), logger);
    await _initSafe('ApiClient', () => ApiClient.init(), logger);
  }

  static Future<void> _initRemainingServices(SharedPreferences prefs, AppLogger logger) async {
    await Future.wait([
      _initSafe('Analytics', () => AnalyticsService.instance.init(), logger),
      _initSafe('Connectivity', () async { ConnectivityService.instance.start(); }, logger),
      _initSafe('Experience', () => ExperienceService.instance.init(prefs), logger),
      _initSafe('SmartCache', () => SmartCache.init(prefs), logger),
      _initSafe('Notifications', () async {
        await NotificationService.instance.init();
        await NotificationService.instance.scheduleChestReminder();
      }, logger),
      _initSafe('Audio', () async {
        await AudioService.instance.init();
        AudioService.instance.prewarm();
      }, logger),
      _initSafe('DeviceIntegrity', () => DeviceIntegrityService.instance.check(), logger),
      _initSafe('DeepLink', () => DeepLinkService.instance.init(), logger),
      _initSafe('AppLock', () => AppLockService.instance.handleAppStart(), logger),
      _initSafe('SmartPromo', () => SmartPromoService.instance.init(), logger),
    ]);
  }

  /// Initializes a service safely. If it fails, logs the error
  /// but does not block other services from initializing.
  static Future<void> _initSafe(
    String name,
    Future<void> Function() init,
    AppLogger logger,
  ) async {
    try {
      await init().timeout(const Duration(seconds: 10));
    } catch (e) {
      logger.error('$name init failed', e);
    }
  }
}
