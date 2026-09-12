import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_multi_choice_step.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_option_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = WizardStepConfig(
  question: '¿Por qué quieres aprender?',
  type: WizardStepType.multi,
  emotion: SageEmotion.curious,
  sageMessage: 'Perfecto',
  options: [
    WizardOption(
      label: 'Proteger mis cuentas',
      value: 'shield',
      icon: Icons.shield_rounded,
    ),
    WizardOption(
      label: 'Mejorar estudios',
      value: 'school',
      icon: Icons.school_rounded,
    ),
  ],
);

Widget _wrap(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      home: Scaffold(
        body: WizardMultiChoiceStep(stepIndex: 3, stepConfig: _config),
      ),
    ),
  );
}

void main() {
  testWidgets('renderiza pregunta y opciones con checkbox', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('¿Por qué quieres aprender?'), findsOneWidget);
    expect(find.byType(WizardMultiChoiceTile), findsNWidgets(2));
    expect(
      find.byIcon(Icons.check_box_outline_blank_rounded),
      findsNWidgets(2),
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap agrega la opcion a la lista', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Proteger mis cuentas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardMultiChoiceStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[3];
    expect(data, isA<List>());
    expect((data as List).single, 'shield');
    expect(find.byIcon(Icons.check_box_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('segundo tap remueve la opcion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Proteger mis cuentas'));
    await tester.pump();
    await tester.tap(find.text('Proteger mis cuentas'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardMultiChoiceStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[3];
    expect(data, isA<List>());
    expect((data as List), isEmpty);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('acumula varias opciones', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Proteger mis cuentas'));
    await tester.pump();
    await tester.tap(find.text('Mejorar estudios'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardMultiChoiceStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[3];
    expect((data as List), containsAll(['shield', 'school']));
    await tester.pump(const Duration(seconds: 1));
  });
}
