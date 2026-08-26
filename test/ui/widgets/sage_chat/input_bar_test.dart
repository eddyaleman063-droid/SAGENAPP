import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/ui/widgets/sage_chat/input_bar.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('InputBar', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    Widget buildApp({
      bool enabled = true,
      bool isStreaming = false,
      VoidCallback? onStop,
    }) {
      return ProviderScope(
        overrides: [prefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: InputBar(
              controller: controller,
              focusNode: focusNode,
              dark: false,
              enabled: enabled,
              isStreaming: isStreaming,
              onSend: () {},
              onStop: onStop,
            ),
          ),
        ),
      );
    }

    testWidgets('renders text field', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('send button is shown when not streaming', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('stop button shown when streaming', (tester) async {
      await tester.pumpWidget(buildApp(isStreaming: true));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
    });

    testWidgets('send button disabled when enabled=false', (tester) async {
      await tester.pumpWidget(buildApp(enabled: false));
      await tester.pump(const Duration(seconds: 1));
      final iconBtn = tester.widget<IconButton>(
        find.descendant(
          of: find.byType(Container),
          matching: find.byType(IconButton),
        ),
      );
      expect(iconBtn.onPressed, isNull);
    });

    testWidgets('typing in field updates controller', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.enterText(find.byType(TextField), 'Hola Sage');
      await tester.pump(const Duration(seconds: 1));
      expect(controller.text, 'Hola Sage');
    });
  });
}
