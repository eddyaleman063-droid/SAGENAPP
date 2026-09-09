import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/l10n/app_localizations.dart';

void main() {
  group('OnboardingWizardConfig', () {
    final l = lookupAppLocalizations(const Locale('es'));

    test('totalSteps matches the localized step list length', () {
      expect(OnboardingWizardConfig.localizedSteps(l).length, 9);
      expect(OnboardingWizardConfig.totalSteps, 9);
    });

    test('step order matches the expected wizard flow', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      expect(steps[0].type, WizardStepType.presentation);
      expect(steps[1].type, WizardStepType.single);
      expect(steps[2].type, WizardStepType.level);
      expect(steps[3].type, WizardStepType.multi);
      expect(steps[5].type, WizardStepType.multi);
      expect(steps[6].type, WizardStepType.goal);
      expect(steps[7].type, WizardStepType.multi);
      expect(steps[8].type, WizardStepType.confirmation);
    });

    test('every step carries a question and sage message', () {
      for (final step in OnboardingWizardConfig.localizedSteps(l)) {
        expect(step.question, isNotEmpty);
        expect(step.sageMessage, isNotEmpty);
      }
    });

    test('option steps expose options with label and value', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      for (final step in steps) {
        if (step.type == WizardStepType.presentation ||
            step.type == WizardStepType.confirmation) {
          expect(step.options, isEmpty);
        } else {
          expect(step.options, isNotEmpty);
          for (final option in step.options) {
            expect(option.label, isNotEmpty);
            expect(option.value, isNotEmpty);
          }
        }
      }
    });

    test('every option carries an icon', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      for (final step in steps) {
        for (final option in step.options) {
          expect(option.icon, isNotNull);
        }
      }
    });

    test('each localized step equates to a localizedApp step config', () {
      final lEn = lookupAppLocalizations(const Locale('en'));
      final es = OnboardingWizardConfig.localizedSteps(l);
      final en = OnboardingWizardConfig.localizedSteps(lEn);
      expect(es.length, en.length);
      for (int i = 0; i < es.length; i++) {
        expect(es[i].type, en[i].type);
        expect(es[i].emotion, en[i].emotion);
      }
    });
  });
}
