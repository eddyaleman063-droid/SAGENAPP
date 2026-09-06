import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/common/benefit_row.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('renders icon and text with semantics label', (tester) async {
    await tester.pumpWidget(
      buildApp(const BenefitRow(icon: Icons.star, text: 'Beneficio A')),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('Beneficio A'), findsOneWidget);
    final semantics = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Beneficio A',
      ),
    );
    expect(semantics.properties.label, 'Beneficio A');
    expect(semantics.excludeSemantics, isFalse);
  });

  testWidgets('supports custom icon color', (tester) async {
    await tester.pumpWidget(
      buildApp(
        const BenefitRow(
          icon: Icons.bolt,
          text: 'Beneficio B',
          iconColor: Colors.green,
        ),
      ),
    );
    final icon = tester.widget<Icon>(find.byIcon(Icons.bolt));
    expect(icon.color, Colors.green);
  });
}
