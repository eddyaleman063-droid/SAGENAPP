import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/ui/screens/registration/name_input_screen.dart';

late SharedPreferences prefs;

Widget buildApp({VoidCallback? onContinue}) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: NameInputScreen(onContinue: onContinue ?? () {})),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('renders name and surname fields', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('continue button disabled when fields are empty', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('continue button enabled when both fields entered', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField).first, 'Ana');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).last, 'Garcia');
    await tester.pump(const Duration(seconds: 1));
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('tapping continue invokes callback', (tester) async {
    var called = false;
    await tester.pumpWidget(buildApp(onContinue: () => called = true));
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField).first, 'Ana');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).last, 'Garcia');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuar'));
    await tester.pump(const Duration(seconds: 1));
    expect(called, isTrue);
  });

  testWidgets('fields trim whitespace', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField).first, '  Ana  ');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField).last, '  Garcia  ');
    await tester.pump(const Duration(seconds: 1));
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuar'),
    );
    expect(button.onPressed, isNotNull);
  });
}
