import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_summary_row.dart';

void main() {
  testWidgets('renders label and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WizardSummaryRow(label: 'Meta', value: 'Mejorar mis notas'),
        ),
      ),
    );
    expect(find.text('Meta'), findsOneWidget);
    expect(find.text('Mejorar mis notas'), findsOneWidget);
  });
}
