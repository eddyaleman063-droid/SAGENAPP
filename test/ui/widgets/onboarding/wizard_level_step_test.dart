import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_level_step.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_level_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = WizardStepConfig(
  question: '¿Cuánto sabes hoy?',
  type: WizardStepType.level,
  emotion: SageEmotion.thinking,
  sageMessage: 'Perfecto',
  options: [
    WizardOption(
      label: 'Principiante',
      value: '1',
      icon: Icons.eco_rounded,
      subtitle: 'Empezando',
    ),
    WizardOption(
      label: 'Intermedio',
      value: '3',
      icon: Icons.forest_rounded,
      subtitle: 'Con experiencia',
    ),
  ],
);

Widget _wrap(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      home: Scaffold(body: WizardLevelStep(stepIndex: 2, stepConfig: _config)),
    ),
  );
}

void main() {
  testWidgets('renderiza pregunta, opciones y subtitulos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('¿Cuánto sabes hoy?'), findsOneWidget);
    expect(find.text('Principiante'), findsOneWidget);
    expect(find.text('Intermedio'), findsOneWidget);
    expect(find.text('Empezando'), findsOneWidget);
    expect(find.byType(WizardLevelTile), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap guarda el nivel elegido', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Intermedio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardLevelStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[2];
    expect(data, '3');
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('sin seleccion no muestra check', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });
}
