import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';

void main() {
  late NotificationType type;

  Widget host({Brightness brightness = Brightness.light}) {
    return MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => SagenNotification.show(
                context,
                message: 'hola mundo',
                type: type,
              ),
              child: const Text('trigger'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> tapTrigger(WidgetTester tester) async {
    await tester.tap(find.text('trigger'));
    await tester.pump();
  }

  group('SagenNotification.show', () {
    testWidgets('renders a success snackbar', (tester) async {
      type = NotificationType.success;
      await tester.pumpWidget(host());
      await tapTrigger(tester);
      expect(find.text('hola mundo'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders an error snackbar', (tester) async {
      type = NotificationType.error;
      await tester.pumpWidget(host());
      await tapTrigger(tester);
      expect(find.text('hola mundo'), findsOneWidget);
      expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    });

    testWidgets('renders a warning snackbar', (tester) async {
      type = NotificationType.warning;
      await tester.pumpWidget(host());
      await tapTrigger(tester);
      expect(find.text('hola mundo'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders an info snackbar in light theme', (tester) async {
      type = NotificationType.info;
      await tester.pumpWidget(host());
      await tapTrigger(tester);
      expect(find.text('hola mundo'), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('renders an info snackbar in dark theme', (tester) async {
      type = NotificationType.info;
      await tester.pumpWidget(host(brightness: Brightness.dark));
      await tapTrigger(tester);
      expect(find.text('hola mundo'), findsOneWidget);
      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('replaces the current snackbar instead of stacking', (
      tester,
    ) async {
      type = NotificationType.success;
      await tester.pumpWidget(host());
      await tapTrigger(tester);
      await tapTrigger(tester);
      expect(find.text('hola mundo'), findsOneWidget);
    });
  });
}
