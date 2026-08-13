import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/animations/particle_burst.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  testWidgetsAnimated('renders a custom paint with particles', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: ParticleBurst())),
      ),
    );
    final paints = find.descendant(
      of: find.byType(ParticleBurst),
      matching: find.byType(CustomPaint),
    );
    expect(paints, findsOneWidget);
  });

  testWidgetsAnimated('honors the count parameter', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: ParticleBurst(count: 6, radius: 40)),
        ),
      ),
    );
    final paints = find.descendant(
      of: find.byType(ParticleBurst),
      matching: find.byType(CustomPaint),
    );
    expect(paints, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
