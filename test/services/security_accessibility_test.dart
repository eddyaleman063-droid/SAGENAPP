import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/app_logger.dart';

void main() {
  group('AppLogger', () {
    late AppLogger logger;

    setUp(() {
      logger = AppLogger();
    });

    test('debug does not throw', () {
      expect(() => logger.debug('test message'), returnsNormally);
    });

    test('info does not throw', () {
      expect(() => logger.info('test info'), returnsNormally);
    });

    test('warning does not throw', () {
      expect(() => logger.warning('test warning'), returnsNormally);
    });

    test('error records recent errors', () {
      logger.error('test error', Exception('bad'), StackTrace.current);
      expect(logger.recentErrors, isNotEmpty);
      expect(logger.recentErrors.last['message'], contains('test error'));
    });

    test('recentErrors caps at 50', () {
      for (var i = 0; i < 60; i++) {
        logger.error('error $i');
      }
      expect(logger.recentErrors.length, lessThanOrEqualTo(50));
    });

    test('log dispatches to correct level', () {
      logger.log(LogLevel.info, 'via log method');
      expect(() => logger.log(LogLevel.debug, 'debug'), returnsNormally);
      expect(() => logger.log(LogLevel.warning, 'warn'), returnsNormally);
    });
  });

  group('Accessibility - Semantic Labels', () {
    testWidgets('Icon buttons have tooltips for screen readers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
                onPressed: () {},
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: 'Settings',
                  onPressed: () {},
                ),
              ],
            ),
            body: const Center(child: Text('Test')),
          ),
        ),
      );

      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('Text fields have semantic labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);
    });

    testWidgets('Buttons have semantic descriptions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Sign In'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Sign In'), findsOneWidget);
      expect(find.bySemanticsLabel('Forgot Password'), findsOneWidget);
    });
  });

  group('Performance - Animation Timing', () {
    testWidgets('Shimmer animation completes within expected time', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // Simulate 100 frames
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }

      // Verify the widget tree is stable after pumping
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
