import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/onboarding_wizard_config.dart';

class OnboardingWizardState {
  final int currentIndex;
  final Map<int, dynamic> sectionData;

  const OnboardingWizardState({
    this.currentIndex = 0,
    this.sectionData = const {},
  });

  OnboardingWizardState copyWith({
    int? currentIndex,
    Map<int, dynamic>? sectionData,
  }) {
    return OnboardingWizardState(
      currentIndex: currentIndex ?? this.currentIndex,
      sectionData: sectionData ?? this.sectionData,
    );
  }
}

class OnboardingWizardNotifier
    extends AutoDisposeNotifier<OnboardingWizardState> {
  @override
  OnboardingWizardState build() => const OnboardingWizardState();

  void setCurrentIndex(int index) {
    const maxIndex = OnboardingWizardConfig.totalSteps > 0
        ? OnboardingWizardConfig.totalSteps - 1
        : 0;
    state = state.copyWith(currentIndex: index.clamp(0, maxIndex));
  }

  void setSectionData(int index, dynamic data) {
    final updated = Map<int, dynamic>.from(state.sectionData);
    updated[index] = data;
    state = state.copyWith(sectionData: updated);
  }

  void nextStep() {
    const maxIndex = OnboardingWizardConfig.totalSteps > 0
        ? OnboardingWizardConfig.totalSteps - 1
        : 0;
    if (state.currentIndex < maxIndex) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void previousStep() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  void reset() {
    state = const OnboardingWizardState();
  }

  T? getData<T>(int index) {
    final d = state.sectionData[index];
    if (d is T) return d;
    return null;
  }
}

final onboardingWizardProvider =
    NotifierProvider.autoDispose<
      OnboardingWizardNotifier,
      OnboardingWizardState
    >(OnboardingWizardNotifier.new);

final onboardingCanContinueProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(onboardingWizardProvider);
  switch (state.currentIndex) {
    case 1:
      return state.sectionData[1] != null;
    case 2:
      return state.sectionData[2] != null;
    case 3:
      final d = state.sectionData[3];
      return d != null && (d is List && d.isNotEmpty);
    case 4:
      return state.sectionData[4] != null;
    case 5:
      final d = state.sectionData[5];
      return d != null && (d is List && d.isNotEmpty);
    case 6:
      return state.sectionData[6] != null;
    case 7:
      final d = state.sectionData[7];
      return d != null && (d is List && d.isNotEmpty);
    default:
      return true;
  }
});

final onboardingWizardSelectionsProvider = Provider.autoDispose<int>((ref) {
  final state = ref.watch(onboardingWizardProvider);
  final data = state.sectionData[7];
  if (data is List) return data.length;
  return 0;
});
