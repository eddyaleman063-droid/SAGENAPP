import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/motivational_quotes_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/ui/widgets/common/premium_loader.dart';

late SharedPreferences prefs;

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildApp({required bool loading, String? message}) {
    return ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        reduceAnimationsProvider.overrideWithValue(false),
        motivationalQuotesServiceProvider.overrideWithValue(
          MotivationalQuotesService.instance,
        ),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PremiumLoader(
            loading: loading,
            message: message ?? 'Cargando...',
            child: const Text('Child Content'),
          ),
        ),
      ),
    );
  }

  testWidgets('shows child content when not loading', (tester) async {
    await tester.pumpWidget(buildApp(loading: false));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Child Content'), findsOneWidget);
  });

  testWidgets('shows overlay when loading', (tester) async {
    await tester.pumpWidget(buildApp(loading: true));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Cargando...'), findsOneWidget);

    await tester.pumpWidget(buildApp(loading: false));
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('shows message text when loading', (tester) async {
    await tester.pumpWidget(buildApp(loading: true, message: 'Preparando...'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Preparando...'), findsOneWidget);

    await tester.pumpWidget(buildApp(loading: false, message: 'Preparando...'));
    await tester.pump(const Duration(seconds: 6));
  });
}
