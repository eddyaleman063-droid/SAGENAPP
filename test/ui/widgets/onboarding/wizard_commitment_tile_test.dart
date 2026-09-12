import 'package:flutter/material.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_commitment_tile.dart';

const _option = WizardOption(
  label: 'Todos los días',
  value: 'daily',
  icon: Icons.calendar_today_rounded,
  subtitle: 'Máxima constancia',
);

Widget _wrap({required bool isSelected, required VoidCallback onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: WizardCommitmentTile(
        option: _option,
        isSelected: isSelected,
        onTap: onTap,
      ),
    ),
  );
}

void main() {
  testWidgets('renderiza label, subtitulo e icono', (tester) async {
    await tester.pumpWidget(_wrap(isSelected: false, onTap: () {}));
    expect(find.text('Todos los días'), findsOneWidget);
    expect(find.text('Máxima constancia'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_rounded), findsOneWidget);
  });

  testWidgets('seleccionado muestra check y lo reporta', (tester) async {
    await tester.pumpWidget(_wrap(isSelected: true, onTap: () {}));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('no seleccionado no muestra check', (tester) async {
    await tester.pumpWidget(_wrap(isSelected: false, onTap: () {}));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
  });

  testWidgets('invoca onTap al tocar la fila', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(isSelected: false, onTap: () => taps++));
    await tester.tap(find.text('Todos los días'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('gestiona gesto de tap con GestureDetector', (tester) async {
    await tester.pumpWidget(_wrap(isSelected: false, onTap: () {}));
    expect(find.byType(GestureDetector), findsOneWidget);
  });
}
