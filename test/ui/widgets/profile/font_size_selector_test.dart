import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/profile/font_size_selector.dart';

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

Widget createTestApp(SharedPreferences prefs, ExperienceService exp) =>
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        authProvider.overrideWith(_MockAuthNotifier.new),
        themeProvider.overrideWith(_MockThemeNotifier.new),
        languageProvider.overrideWith(_MockLanguageNotifier.new),
        experienceServiceProvider.overrideWithValue(exp),
      ],
      child: MaterialApp(
        theme: ThemeData(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: FontSizeSelector(dark: false)),
      ),
    );

void main() {
  setUp(() {
    SharedPreferences.resetStatic();
  });

  group('FontSizeSelector', () {
    testWidgets('renders title and all four option labels', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final exp = ExperienceService();
      await exp.init(prefs);
      await tester.pumpWidget(createTestApp(prefs, exp));
      await tester.pumpAndSettle();

      expect(find.text('Tamaño del texto'), findsOneWidget);
      expect(find.text('Pequeño'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Grande'), findsOneWidget);
      expect(find.text('Extra grande'), findsOneWidget);
    });

    testWidgets('tapping a size option persists and updates the service', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final exp = ExperienceService();
      await exp.init(prefs);
      await tester.pumpWidget(createTestApp(prefs, exp));
      await tester.pumpAndSettle();

      // Default persisted scale (system-dependent); after we tap Normal
      // it should persist 1.0.
      await tester.tap(find.text('Normal'));
      await tester.pumpAndSettle();

      expect(exp.fontSizeScale, 1.0);
      expect(prefs.getDouble('font_scale'), 1.0);
    });
  });
}
