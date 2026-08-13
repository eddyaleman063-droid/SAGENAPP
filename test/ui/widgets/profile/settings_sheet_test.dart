import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/profile/settings_sheet.dart';
import 'package:sagen/ui/widgets/profile/theme_selector.dart';

class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(
    uid: 'test-uid',
    displayName: 'Test User',
    email: 'test@test.com',
    status: AuthStatus.authenticated,
  );
}

class _MockThemeNotifier extends ThemeNotifier {
  @override
  ThemeState build() => const ThemeState(mode: ThemeMode.system);

  @override
  void setMode(ThemeMode mode) {
    state = state.copyWith(
      mode: mode,
      scheduleEnabled: mode == ThemeMode.system ? state.scheduleEnabled : false,
    );
  }
}

class _MockLanguageNotifier extends LanguageNotifier {
  @override
  LanguageState build() => const LanguageState(language: AppLanguage.es);
}

Widget createTestApp(SharedPreferences prefs) => ProviderScope(
  overrides: [
    prefsProvider.overrideWithValue(prefs),
    authProvider.overrideWith(_MockAuthNotifier.new),
    themeProvider.overrideWith(_MockThemeNotifier.new),
    languageProvider.overrideWith(_MockLanguageNotifier.new),
  ],
  child: MaterialApp(
    theme: ThemeData(),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: SettingsSheet()),
  ),
);

void main() {
  group('SettingsSheet', () {
    testWidgets('renders settings title', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      expect(find.text('Ajustes'), findsOneWidget);
    });

    testWidgets('shows tune icon', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    });

    testWidgets('contains ThemeSelector widget', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      expect(find.byType(ThemeSelector), findsOneWidget);
    });

    testWidgets('shows all theme option labels', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      expect(find.text('Sistema'), findsOneWidget);
      expect(find.text('Claro'), findsOneWidget);
      expect(find.text('Oscuro'), findsOneWidget);
    });

    testWidgets('tapping a theme option switches selection', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      final claroIcon = find.byIcon(Icons.light_mode_rounded);
      final iconBefore = tester.widget<Icon>(claroIcon);
      // Before tapping, 'Claro' is not selected, so its icon has a dimmed color
      expect(iconBefore.color, isNot(Colors.white));

      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();

      // After tapping, 'Claro' icon should be white (selected)
      final iconAfter = tester.widget<Icon>(claroIcon);
      expect(iconAfter.color, Colors.white);
    });

    testWidgets('renders drag handle indicator', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(createTestApp(prefs));
      await tester.pumpAndSettle();

      final dragHandle = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints != null &&
            w.constraints!.maxWidth == 40 &&
            w.constraints!.maxHeight == 4,
      );
      expect(dragHandle, findsOneWidget);
    });
  });
}
