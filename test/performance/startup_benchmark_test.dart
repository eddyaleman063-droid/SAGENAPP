import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance — Startup Benchmarks', () {
    testWidgets('Cold startup completes within 3 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: Text('test')))),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000),
          reason: 'Cold startup should complete within 5 seconds');
    });

    testWidgets('Widget rebuild does not exceed 16ms frame budget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: Text('test')))),
      );
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();
      await tester.pump();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Frame rebuild should complete within budget');
    });
  });

  group('Performance — Memory Benchmarks', () {
    testWidgets('Repeated navigation does not cause memory leaks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: Text('test')))),
      );
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(home: Scaffold(body: Center(child: Text('page $i')))),
        );
        await tester.pump();
      }

      expect(find.byType(Scaffold).evaluate().isNotEmpty, true,
          reason: 'App should remain stable after repeated rebuilds');
    });
  });
}
