import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_confirmation_step.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_summary_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _config = WizardStepConfig(
  question: '¿Todo listo?',
  type: WizardStepType.confirmation,
  emotion: SageEmotion.excitedWave,
  sageMessage: 'Perfecto',
  options: [],
);

Widget _wrap(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: WizardConfirmationStep(stepConfig: _config)),
    ),
  );
}

ProviderContainer _container(WidgetTester tester) {
  final ctx = tester.element(find.byType(WizardConfirmationStep));
  return ProviderScope.containerOf(ctx);
}

void main() {
  testWidgets('muestra guiones cuando no hay datos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    final l = AppLocalizations.of(
      tester.element(find.byType(WizardConfirmationStep)),
    )!;
    expect(find.text('—'), findsNWidgets(3));
    expect(find.text(l.minutes('0')), findsOneWidget);
    expect(find.text(l.summaryOrigin), findsOneWidget);
    expect(find.text(l.summaryReady), findsOneWidget);
    expect(find.byType(WizardSummaryRow), findsNWidgets(4));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('muestra el resumen con los datos capturados', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));

    final container = _container(tester);
    container
        .read(onboardingWizardProvider.notifier)
        .setSectionData(1, 'Google');
    container.read(onboardingWizardProvider.notifier).setSectionData(2, '1');
    container.read(onboardingWizardProvider.notifier).setSectionData(3, [
      'shield',
      'school',
    ]);
    container
        .read(onboardingWizardProvider.notifier)
        .setSectionData(4, 'accounts');
    container.read(onboardingWizardProvider.notifier).setSectionData(5, [
      'quiz',
      'video',
    ]);
    container.read(onboardingWizardProvider.notifier).setSectionData(6, '10');
    container.read(onboardingWizardProvider.notifier).setSectionData(7, [
      '7',
      '30',
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final l = AppLocalizations.of(
      tester.element(find.byType(WizardConfirmationStep)),
    )!;
    expect(find.text('Google'), findsOneWidget);
    expect(find.text(l.wizardLevel1), findsOneWidget);
    expect(
      find.text('${l.wizardProtect}, ${l.wizardBoostStudies}'),
      findsOneWidget,
    );
    expect(find.text(l.wizardProtectAccounts), findsOneWidget);
    expect(find.text('${l.wizardQuizzes}, ${l.wizardVideos}'), findsOneWidget);
    expect(find.text(l.minutes('10')), findsOneWidget);
    expect(
      find.text('${l.wizardCommit7}, ${l.wizardCommit30}'),
      findsOneWidget,
    );
    expect(find.byType(WizardSummaryRow), findsNWidgets(7));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('valor desconocido se muestra tal cual', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(_wrap(prefs));
    await tester.pump(const Duration(milliseconds: 600));

    final container = _container(tester);
    container
        .read(onboardingWizardProvider.notifier)
        .setSectionData(1, 'ValorRaro');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('ValorRaro'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
