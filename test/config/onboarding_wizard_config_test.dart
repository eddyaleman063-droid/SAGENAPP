import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/config/onboarding_wizard_config.dart';
import 'package:sagen/l10n/app_localizations.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('es'));

  group('OnboardingWizardConfig', () {
    test('totalSteps matches localizedSteps length', () {
      expect(OnboardingWizardConfig.localizedSteps(l), hasLength(OnboardingWizardConfig.totalSteps));
      expect(OnboardingWizardConfig.totalSteps, 9);
    });

    test('first step is a presentation step with no options', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      expect(steps.first.type, WizardStepType.presentation);
      expect(steps.first.options, isEmpty);
      expect(steps.first.question, isNotEmpty);
    });

    test('last step is confirmation with no options', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      expect(steps.last.type, WizardStepType.confirmation);
      expect(steps.last.options, isEmpty);
    });

    test('every step has a question, message and emotion', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      for (final step in steps) {
        expect(step.question, isNotEmpty, reason: 'question must not be empty');
        expect(step.sageMessage, isNotEmpty, reason: 'sageMessage must not be empty');
        expect(step.emotion, isNotNull);
      }
    });

    test('single/multi/level/goal steps have non-empty options', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      for (final step in steps) {
        if (step.type == WizardStepType.single ||
            step.type == WizardStepType.multi ||
            step.type == WizardStepType.level ||
            step.type == WizardStepType.goal) {
          expect(step.options, isNotEmpty, reason: '${step.type} step must have options');
        }
      }
    });

    test('every option has label, value and icon', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      for (final step in steps) {
        for (final option in step.options) {
          expect(option.label, isNotEmpty);
          expect(option.value, isNotEmpty);
          expect(option.icon, isNotNull);
        }
      }
    });

    test('option values are unique within each step', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      for (final step in steps) {
        final values = step.options.map((o) => o.value).toSet();
        expect(values, hasLength(step.options.length),
            reason: '${step.question} has duplicated option values');
      }
    });

    test('level step has 5 options with subtitles', () {
      final steps = OnboardingWizardConfig.localizedSteps(l);
      final levelStep = steps.firstWhere((s) => s.type == WizardStepType.level);
      expect(levelStep.options, hasLength(5));
      expect(levelStep.options.every((o) => o.subtitle != null), isTrue);
      expect(levelStep.options.every((o) => o.color != null), isTrue);
    });

    test('WizardOption supports optional color and subtitle', () {
      const withExtras = WizardOption(
        label: 'a',
        value: 'b',
        icon: Icons.shield_rounded,
        color: Colors.blue,
        subtitle: 'sub',
      );
      expect(withExtras.color, Colors.blue);
      expect(withExtras.subtitle, 'sub');

      const minimal = WizardOption(label: 'x', value: 'y', icon: Icons.star_rounded);
      expect(minimal.color, isNull);
      expect(minimal.subtitle, isNull);
    });
  });
}
