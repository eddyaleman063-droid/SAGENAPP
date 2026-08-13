import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/home/hero_mission_card.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  testWidgetsAnimated('renders title, subtitle and action label', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeroMissionCard(
            title: 'Misión de hoy',
            subtitle: 'Completa una lección',
            actionLabel: 'Empezar',
          ),
        ),
      ),
    );
    expect(find.text('Misión de hoy'), findsOneWidget);
    expect(find.text('Completa una lección'), findsOneWidget);
    expect(find.text('Empezar'), findsOneWidget);
  });

  testWidgetsAnimated('fires onAction when the button is pressed', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeroMissionCard(
            title: 'Misión',
            subtitle: 'Subtítulo',
            actionLabel: 'Empezar',
            onAction: () => pressed++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Empezar'));
    await tester.pump();
    expect(pressed, 1);
  });
}
