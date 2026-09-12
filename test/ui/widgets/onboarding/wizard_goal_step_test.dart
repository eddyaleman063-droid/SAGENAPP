import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_goal_step.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = WizardStepConfig(
  question: '¿Cuánto tiempo quieres dedicar?',
  type: WizardStepType.goal,
  emotion: SageEmotion.calm,
  sageMessage: 'Perfecto',
  options: [
    WizardOption(
      label: '3 min',
      value: '3',
      icon: Icons.coffee_rounded,
      subtitle: 'Rápido',
      color: Color(0xFF3FA66B),
    ),
    WizardOption(
      label: '10 min',
      value: '10',
      icon: Icons.timer_rounded,
      subtitle: 'Equilibrado',
    ),
  ],
);

Widget _wrap(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: WizardGoalStep(stepIndex: 6, stepConfig: _config)),
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

    expect(find.text('¿Cuánto tiempo quieres dedicar?'), findsOneWidget);
    expect(find.text('3 min'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('Rápido'), findsOneWidget);
    expect(find.text('Equilibrado'), findsOneWidget);
    expect(find.byIcon(Icons.coffee_rounded), findsOneWidget);
    expect(find.byIcon(Icons.timer_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('no muestra check hasta seleccionar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byIcon(Icons.check_rounded), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap guarda la seccion y marca la opcion seleccionada', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('10 min'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    final ctx = tester.element(find.byType(WizardGoalStep));
    final container = ProviderScope.containerOf(ctx);
    final data = container.read(onboardingWizardProvider).sectionData[6];
    expect(data, '10');
    await tester.pump(const Duration(seconds: 1));
  });
}
