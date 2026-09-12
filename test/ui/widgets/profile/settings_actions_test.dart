import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/notification_service.dart';
import 'package:sagen/ui/widgets/profile/settings_actions.dart';
import 'package:sagen/ui/widgets/profile/settings_sheet.dart';

class _SignOutAuthNotifier extends AuthNotifier {
  int signOutCalls = 0;

  @override
  AuthState build() => const AuthState(
    uid: 'test-uid',
    displayName: 'Test User',
    email: 'test@test.com',
    status: AuthStatus.authenticated,
  );

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }
}

class _MockThemeNotifier extends ThemeNotifier {
  @override
  ThemeState build() => const ThemeState(mode: ThemeMode.system);
}

class _MockLanguageNotifier extends LanguageNotifier {
  @override
  LanguageState build() => const LanguageState(language: AppLanguage.es);
}

class _RecordingNotificationService extends NotificationService {
  _RecordingNotificationService() : super.test();

  int cancelAllCalls = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
  }
}

Widget _wrap({
  required SharedPreferences prefs,
  AuthNotifier? auth,
  NotificationService? notifications,
  bool dark = false,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) =>
            Scaffold(body: SettingsActions(dark: dark)),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      authProvider.overrideWith(() => auth ?? _SignOutAuthNotifier()),
      themeProvider.overrideWith(_MockThemeNotifier.new),
      languageProvider.overrideWith(_MockLanguageNotifier.new),
      notificationServiceProvider.overrideWithValue(
        notifications ?? _RecordingNotificationService(),
      ),
      reduceAnimationsProvider.overrideWithValue(true),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: dark ? ThemeData(brightness: Brightness.dark) : ThemeData(),
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<SharedPreferences> _newPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void _tallView(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('renderiza botones de ajustes y logout', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_wrap(prefs: await _newPrefs()));
    await tester.pump(const Duration(milliseconds: 500));
    final l = AppLocalizations.of(
      tester.element(find.byType(SettingsActions)),
    )!;
    expect(find.text(l.settingsTitle), findsOneWidget);
    expect(find.text(l.settingsLogout), findsOneWidget);
  });

  testWidgets('tap en ajustes abre el settings sheet', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_wrap(prefs: await _newPrefs()));
    await tester.pump(const Duration(milliseconds: 500));
    final l = AppLocalizations.of(
      tester.element(find.byType(SettingsActions)),
    )!;
    await tester.tap(find.text(l.settingsTitle));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsSheet), findsOneWidget);
  });

  testWidgets('tap en logout abre el dialog de confirmacion', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_wrap(prefs: await _newPrefs()));
    await tester.pump(const Duration(milliseconds: 500));
    final l = AppLocalizations.of(
      tester.element(find.byType(SettingsActions)),
    )!;
    await tester.tap(find.text(l.settingsLogout));
    await tester.pumpAndSettle();
    expect(find.text(l.settingsLogoutConfirm), findsOneWidget);
  });

  testWidgets('cancelar no hace signOut', (tester) async {
    _tallView(tester);
    final auth = _SignOutAuthNotifier();
    await tester.pumpWidget(_wrap(prefs: await _newPrefs(), auth: auth));
    await tester.pump(const Duration(milliseconds: 500));
    final l = AppLocalizations.of(
      tester.element(find.byType(SettingsActions)),
    )!;
    await tester.tap(find.text(l.settingsLogout));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(auth.signOutCalls, 0);
  });

  testWidgets('confirmar hace signOut y cancela notificaciones', (
    tester,
  ) async {
    _tallView(tester);
    final auth = _SignOutAuthNotifier();
    final notifications = _RecordingNotificationService();
    await tester.pumpWidget(
      _wrap(prefs: await _newPrefs(), auth: auth, notifications: notifications),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final l = AppLocalizations.of(
      tester.element(find.byType(SettingsActions)),
    )!;
    await tester.tap(find.text(l.settingsLogout));
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.text(l.settingsLogout),
          )
          .last,
    );
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, 1);
    expect(notifications.cancelAllCalls, 1);
  });

  testWidgets('modo oscuro renderiza sin romper', (tester) async {
    _tallView(tester);
    await tester.pumpWidget(_wrap(prefs: await _newPrefs(), dark: true));
    await tester.pump(const Duration(milliseconds: 500));
    final l = AppLocalizations.of(
      tester.element(find.byType(SettingsActions)),
    )!;
    expect(find.text(l.settingsTitle), findsOneWidget);
    expect(find.text(l.settingsLogout), findsOneWidget);
  });
}
