import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/onboarding_wizard_config.dart';
import 'prefs_provider.dart';

const _kWizardKey = 'onboarding_wizard_state';
const _kWizardDoneKey = 'onboarding_wizard_completed';

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

  Map<String, dynamic> toJson() => {
    'currentIndex': currentIndex,
    'sectionData': sectionData.map((k, v) => MapEntry(k.toString(), v)),
  };

  factory OnboardingWizardState.fromJson(Map<String, dynamic> json) {
    final raw = json['sectionData'] as Map<String, dynamic>? ?? {};
    return OnboardingWizardState(
      currentIndex: (json['currentIndex'] as num?)?.toInt() ?? 0,
      sectionData: raw.map((k, v) => MapEntry(int.tryParse(k) ?? 0, v)),
    );
  }
}

class OnboardingWizardNotifier
    extends AutoDisposeNotifier<OnboardingWizardState> {
  Timer? _persistTimer;

  @override
  OnboardingWizardState build() {
    ref.onDispose(() => _persistTimer?.cancel());
    final completed = ref.read(prefsProvider).getBool(_kWizardDoneKey) ?? false;
    if (completed) return const OnboardingWizardState();
    return _load();
  }

  OnboardingWizardState _load() {
    try {
      final raw = ref.read(prefsProvider).getString(_kWizardKey);
      if (raw != null && raw.isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return OnboardingWizardState.fromJson(json);
      }
    } catch (_) {}
    return const OnboardingWizardState();
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(milliseconds: 300), _persist);
  }

  void _persist() {
    try {
      final prefs = ref.read(prefsProvider);
      prefs.setString(_kWizardKey, jsonEncode(state.toJson()));
    } catch (_) {}
  }

  void setCurrentIndex(int index) {
    const maxIndex = OnboardingWizardConfig.totalSteps > 0
        ? OnboardingWizardConfig.totalSteps - 1
        : 0;
    state = state.copyWith(currentIndex: index.clamp(0, maxIndex));
    _persist();
  }

  void setSectionData(int index, dynamic data) {
    final updated = Map<int, dynamic>.from(state.sectionData);
    updated[index] = data;
    state = state.copyWith(sectionData: updated);
    _schedulePersist();
  }

  void nextStep() {
    const maxIndex = OnboardingWizardConfig.totalSteps > 0
        ? OnboardingWizardConfig.totalSteps - 1
        : 0;
    if (state.currentIndex < maxIndex) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      _persist();
    }
  }

  void previousStep() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
      _persist();
    }
  }

  void reset() {
    state = const OnboardingWizardState();
    try {
      final prefs = ref.read(prefsProvider);
      prefs.remove(_kWizardKey);
      prefs.setBool(_kWizardDoneKey, false);
    } catch (_) {}
  }

  void markCompleted() {
    try {
      final prefs = ref.read(prefsProvider);
      prefs.setBool(_kWizardDoneKey, true);
      prefs.remove(_kWizardKey);
    } catch (_) {}
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
  final currentIndex = ref.watch(
    onboardingWizardProvider.select((s) => s.currentIndex),
  );
  final sectionData = ref.watch(
    onboardingWizardProvider.select((s) => s.sectionData[currentIndex]),
  );
  switch (currentIndex) {
    case 1:
      return sectionData != null;
    case 2:
      return sectionData != null;
    case 3:
      return sectionData != null &&
          (sectionData is List && sectionData.isNotEmpty);
    case 4:
      return sectionData != null;
    case 5:
      return sectionData != null &&
          (sectionData is List && sectionData.isNotEmpty);
    case 6:
      return sectionData != null;
    case 7:
      return sectionData != null &&
          (sectionData is List && sectionData.isNotEmpty);
    default:
      return true;
  }
});

final onboardingWizardSelectionsProvider = Provider.autoDispose<int>((ref) {
  final data = ref.watch(
    onboardingWizardProvider.select((s) => s.sectionData[7]),
  );
  if (data is List) return data.length;
  return 0;
});

/// Snapshot of wizard sectionData bridged to post-onboarding flow.
/// Saved before navigating away from wizard; consumed once by bridge.
class WizardBridge extends Notifier<Map<int, dynamic>> {
  @override
  Map<int, dynamic> build() => {};

  void capture(Map<int, dynamic> data) {
    state = Map<int, dynamic>.from(data);
  }

  T? get<T>(int index) {
    final d = state[index];
    if (d is T) return d;
    return null;
  }

  void reset() {
    state = {};
  }
}

final wizardBridgeProvider = NotifierProvider<WizardBridge, Map<int, dynamic>>(
  WizardBridge.new,
);
