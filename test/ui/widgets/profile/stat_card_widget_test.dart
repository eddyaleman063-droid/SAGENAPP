import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/profile/stat_card_widget.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  testWidgetsAnimated('renders value, label and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCardWidget(
            icon: Icons.star,
            value: '1.2k',
            label: 'XP total',
            iconColor: Colors.amber,
          ),
        ),
      ),
    );
    expect(find.text('1.2k'), findsOneWidget);
    expect(find.text('XP total'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgetsAnimated('uses accentColor for the value text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatCardWidget(
            icon: Icons.star,
            value: '10',
            label: 'Días',
            iconColor: Colors.amber,
            accentColor: Colors.purple,
          ),
        ),
      ),
    );
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Días'), findsOneWidget);
  });
}
