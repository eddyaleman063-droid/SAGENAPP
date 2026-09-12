import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_option_tile.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_single_choice_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = WizardStepConfig(
  question: '¿Cómo supiste de SAGEN?',
  type: WizardStepType.single,
  emotion: SageEmotion.curious,
  sageMessage: 'Perfecto',
  options: [
    WizardOption(
      label: 'Google',
      value: 'Google',
      icon: Icons.g_mobiledata_rounded,
    ),
    WizardOption(
      label: 'Friends',
      value: 'Friends',
      icon: Icons.people_outline_rounded,
    ),
  ],
);

Widget _wrap(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      home: Scaffold(
        body: WizardSingleChoiceStep(stepIndex: 1, stepConfig: _config),
      ),
    ),
  );
}

void main() {
  testWidgets('renderiza pregunta y opciones', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('¿Cómo supiste de SAGEN?'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.byType(WizardSingleChoiceTile), findsNWidgets(2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap guarda la opcion seleccionada', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Google'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardSingleChoiceStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[1];
    expect(data, 'Google');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('reemplaza la seleccion al tocar otra opcion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Google'));
    await tester.pump();
    await tester.tap(find.text('Friends'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final ctx = tester.element(find.byType(WizardSingleChoiceStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[1];
    expect(data, 'Friends');
    await tester.pump(const Duration(seconds: 1));
  });
}
