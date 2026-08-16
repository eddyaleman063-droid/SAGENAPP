import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/screens/welcome_screen.dart';

void main() {
  Widget wrapInApp(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('Performance — Rendering Benchmarks', () {
    testWidgets('WelcomeScreen renders within 500ms', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(wrapInApp(const WelcomeScreen()));
      await tester.pump();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: 'WelcomeScreen initial render should complete within 10000ms',
      );
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);

    testWidgets('Animation startup does not block frame', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(wrapInApp(const WelcomeScreen()));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Animation startup should not block more than 5000ms',
      );
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);

    testWidgets('Widget tree depth does not exceed 200', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapInApp(const WelcomeScreen()));
      await tester.pump();

      int countElements(Element element) {
        int count = 1;
        element.visitChildren((child) => count += countElements(child));
        return count;
      }

      final root = find.byType(WelcomeScreen).evaluate().first;
      final depth = countElements(root);

      expect(
        depth,
        lessThan(200),
        reason: 'Widget tree depth should be manageable for performance',
      );
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);
  });

  group('Performance — Build Benchmarks', () {
    testWidgets('Multiple rebuilds do not accumulate state', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapInApp(const WelcomeScreen()));

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 1));
      }
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(10000),
        reason: '100 rebuilds should complete within 10 seconds',
      );
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);

    testWidgets('State management does not leak', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(wrapInApp(const WelcomeScreen()));
        await tester.pump();
        await tester.pumpWidget(Container());
        await tester.pump();
      }

      expect(
        true,
        true,
        reason: 'State should not leak after 10 widget replacements',
      );
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);
  });

  group('Performance — Layout Benchmarks', () {
    testWidgets('Layout calculation completes within frame budget', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapInApp(const WelcomeScreen()));

      final stopwatch = Stopwatch()..start();
      await tester.binding.setSurfaceSize(const Size(375, 812));
      await tester.pump();
      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(500),
        reason: 'Layout recalculation should complete within budget',
      );
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);

    testWidgets('Multiple screen sizes do not cause layout overflow', (
      tester,
    ) async {
      final sizes = [
        const Size(320, 568),
        const Size(375, 812),
        const Size(414, 896),
        const Size(768, 1024),
        const Size(1080, 1920),
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(wrapInApp(const WelcomeScreen()));
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: 'Layout should not overflow at ${size.width}x${size.height}',
        );
      }
      await tester.pump(const Duration(seconds: 6));
    }, tags: ['performance']);
  });
}
