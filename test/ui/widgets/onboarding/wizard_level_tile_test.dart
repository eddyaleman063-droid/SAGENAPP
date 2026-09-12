import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_level_tile.dart';

const _option = WizardOption(
  label: 'Intermedio',
  value: '3',
  icon: Icons.forest_rounded,
  subtitle: 'Con experiencia',
  color: Color(0xFFF59E0B),
);

Widget _wrap({required bool isSelected, required VoidCallback onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: WizardLevelTile(
        option: _option,
        isSelected: isSelected,
        onTap: onTap,
      ),
    ),
  );
}

void main() {
  testWidgets('renderiza label, subtitulo, icono y barra', (tester) async {
    await tester.pumpWidget(_wrap(isSelected: false, onTap: () {}));
    expect(find.text('Intermedio'), findsOneWidget);
    expect(find.text('Con experiencia'), findsOneWidget);
    expect(find.byIcon(Icons.forest_rounded), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('seleccionado muestra check y barra llena', (tester) async {
    await tester.pumpWidget(_wrap(isSelected: true, onTap: () {}));
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, closeTo(0.6, 0.001));
  });

  testWidgets('seleccionado con valor no numerico no llena la barra', (
    tester,
  ) async {
    const opt = WizardOption(
      label: 'Custom',
      value: 'abc',
      icon: Icons.star_rounded,
      subtitle: 'X',
      color: Color(0xFF3FA66B),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WizardLevelTile(option: opt, isSelected: true, onTap: () {}),
        ),
      ),
    );
    final progress = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(progress.value, 0.0);
  });

  testWidgets('tap invoca onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_wrap(isSelected: false, onTap: () => taps++));
    await tester.tap(find.text('Intermedio'));
    await tester.pump();
    expect(taps, 1);
  });
}
