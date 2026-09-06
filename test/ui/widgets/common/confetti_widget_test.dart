import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/confetti_widget.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox.expand(
          child: Stack(children: [Positioned.fill(child: child)]),
        ),
      ),
    );
  }

  testWidgets('renders level confetti without throwing', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const ConfettiWidget(type: ConfettiType.level, particleCount: 12),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders streak confetti with explicit colors', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const ConfettiWidget(
          type: ConfettiType.streak,
          particleCount: 5,
          colors: [Colors.orange, Colors.amber],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders default mixed palette when type is null', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(const ConfettiWidget(particleCount: 3)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('finishes without leaving pending timers', (tester) async {
    await tester.pumpWidget(buildApp(const ConfettiWidget(particleCount: 4)));
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
}
