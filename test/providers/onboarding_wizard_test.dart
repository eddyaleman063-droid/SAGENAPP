import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/onboarding_wizard_provider.dart';

void main() {
  group('OnboardingWizardProvider', () {
    late ProviderContainer container;
    late OnboardingWizardNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(onboardingWizardProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('starts at index 0 with empty sectionData', () {
      final state = container.read(onboardingWizardProvider);
      expect(state.currentIndex, 0);
      expect(state.sectionData, isEmpty);
    });

    test('nextStep advances by one', () {
      notifier.nextStep();
      expect(container.read(onboardingWizardProvider).currentIndex, 1);
    });

    test('nextStep stops at last index', () {
      for (var i = 0; i < 8; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingWizardProvider).currentIndex, 8);
      notifier.nextStep();
      expect(container.read(onboardingWizardProvider).currentIndex, 8);
    });

    test('previousStep goes back by one', () {
      for (var i = 0; i < 3; i++) {
        notifier.nextStep();
      }
      notifier.previousStep();
      expect(container.read(onboardingWizardProvider).currentIndex, 2);
    });

    test('previousStep stops at 0', () {
      notifier.previousStep();
      expect(container.read(onboardingWizardProvider).currentIndex, 0);
    });

    test('setSectionData stores value for given index', () {
      notifier.setSectionData(1, 'Google');
      final state = container.read(onboardingWizardProvider);
      expect(state.sectionData[1], 'Google');
    });

    test('setSectionData overwrites existing value', () {
      notifier.setSectionData(1, 'Google');
      notifier.setSectionData(1, 'YouTube');
      final state = container.read(onboardingWizardProvider);
      expect(state.sectionData[1], 'YouTube');
    });

    test('setSectionData stores list for multi choice', () {
      notifier.setSectionData(3, <String>['shield', 'school']);
      final state = container.read(onboardingWizardProvider);
      expect(state.sectionData[3], <String>['shield', 'school']);
    });

    test('reset clears all state', () {
      notifier.setSectionData(1, 'Google');
      notifier.setSectionData(3, <String>['shield']);
      notifier.reset();
      final state = container.read(onboardingWizardProvider);
      expect(state.currentIndex, 0);
      expect(state.sectionData, isEmpty);
    });
  });

  group('onboardingCanContinueProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('index 0 always allows continue', () {
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 1 requires single selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      notifier.nextStep();
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(1, 'Google');
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 2 requires single selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 2; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(2, '3');
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 3 requires non-empty multi selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 3; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(3, <String>['shield']);
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 4 requires single selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 4; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(4, 'accounts');
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 5 requires non-empty multi selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 5; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(5, <String>['quiz']);
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 6 requires single selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 6; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(6, '10');
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 7 requires non-empty multi selection', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 7; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), false);
      notifier.setSectionData(7, <String>['7']);
      expect(container.read(onboardingCanContinueProvider), true);
    });

    test('index 8 always allows continue', () {
      final notifier = container.read(onboardingWizardProvider.notifier);
      for (var i = 0; i < 8; i++) {
        notifier.nextStep();
      }
      expect(container.read(onboardingCanContinueProvider), true);
    });
  });
}
