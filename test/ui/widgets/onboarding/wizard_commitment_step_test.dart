import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_commitment_step.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_commitment_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = WizardStepConfig(
  question: '¿Cada cuánto te comprometes?',
  type: WizardStepType.multi,
  emotion: SageEmotion.excited,
  sageMessage: 'Tu compromiso importa',
  options: [
    WizardOption(
      label: '7 días',
      value: '7',
      icon: Icons.local_fire_department_rounded,
      subtitle: 'Arranque',
    ),
    WizardOption(
      label: '30 días',
      value: '30',
      icon: Icons.local_fire_department_rounded,
      subtitle: 'Constancia',
    ),
  ],
);

Widget _wrap(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      home: Scaffold(
        body: WizardCommitmentStep(stepIndex: 7, stepConfig: _config),
      ),
    ),
  );
}

void main() {
  testWidgets('renderiza burbuja sage, pregunta y opciones', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Tu compromiso importa'), findsOneWidget);
    expect(find.byIcon(Icons.local_fire_department_rounded), findsNWidgets(3));
    expect(find.text('¿Cada cuánto te comprometes?'), findsOneWidget);
    expect(find.byType(WizardCommitmentTile), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap agrega el compromiso a la lista', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('7 días'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardCommitmentStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[7];
    expect((data as List).single, '7');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('segundo tap remueve el compromiso', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('7 días'));
    await tester.pump();
    await tester.tap(find.text('7 días'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardCommitmentStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[7];
    expect((data as List), isEmpty);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('acumula varios compromisos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('7 días'));
    await tester.pump();
    await tester.tap(find.text('30 días'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardCommitmentStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[7];
    expect((data as List), containsAll(['7', '30']));
    await tester.pump(const Duration(seconds: 1));
  });
}
