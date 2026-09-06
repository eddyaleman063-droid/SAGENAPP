import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/onboarding/wizard_top_bar.dart';

void main() {
  Widget buildApp({required int currentIndex, required VoidCallback onBack}) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WizardTopBar(currentIndex: currentIndex, onBack: onBack),
      ),
    );
  }

  testWidgets('renders back button and step progress bar', (tester) async {
    await tester.pumpWidget(buildApp(currentIndex: 0, onBack: () {}));
    await tester.pump();
    final l = AppLocalizations.of(tester.element(find.byType(IconButton)))!;
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == l.wizardStepLabel(1),
      ),
      findsWidgets,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('calls onBack when the back button is tapped', (tester) async {
    var backCalls = 0;
    await tester.pumpWidget(
      buildApp(currentIndex: 2, onBack: () => backCalls++),
    );
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    expect(backCalls, 1);
  });

  testWidgets('updates progress target when the step changes', (tester) async {
    await tester.pumpWidget(buildApp(currentIndex: 0, onBack: () {}));
    await tester.pump(const Duration(milliseconds: 400));
    final initialProgress = _progressValue(tester);
    await tester.pumpWidget(buildApp(currentIndex: 1, onBack: () {}));
    await tester.pump(const Duration(milliseconds: 400));
    final finalProgress = _progressValue(tester);
    const stepDelta = 1 / OnboardingWizardConfig.totalSteps;
    expect(finalProgress, closeTo(initialProgress + stepDelta, 0.02));
  });
}

double _progressValue(WidgetTester tester) {
  final indicator = tester.widget<LinearProgressIndicator>(
    find.byType(LinearProgressIndicator),
  );
  return indicator.value ?? 0;
}
