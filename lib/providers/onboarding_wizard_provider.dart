import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/onboarding_wizard_config.dart';
import '../core/theme/theme_constants.dart';
import '../services/app_logger.dart';
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
    const maxIndex = OnboardingWizardConfig.totalSteps - 1;
    return OnboardingWizardState(
      currentIndex: ((json['currentIndex'] as num?)?.toInt() ?? 0).clamp(
        0,
        maxIndex,
      ),
      sectionData: raw.map(
        (k, v) => MapEntry(
          int.tryParse(k) ?? 0,
          v is List ? List<Object?>.from(v) : v,
        ),
      ),
    );
  }
}

class OnboardingWizardNotifier
    extends AutoDisposeNotifier<OnboardingWizardState> {
  Timer? _persistTimer;
  bool _completed = false;
  late SharedPreferences _prefs;

  @override
  OnboardingWizardState build() {
    _prefs = ref.read(prefsProvider);
    ref.onDispose(() {
      _persistTimer?.cancel();
      if (!_completed) _persist();
    });
    final completed = _prefs.getBool(_kWizardDoneKey) ?? false;
    if (completed) return const OnboardingWizardState();
    return _load();
  }

  OnboardingWizardState _load() {
    try {
      final raw = _prefs.getString(_kWizardKey);
      if (raw != null && raw.isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return OnboardingWizardState.fromJson(json);
      }
    } catch (e, stack) {
      AppLogger().error('Wizard: failed to load state', e, stack);
    }
    return const OnboardingWizardState();
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(AppMotion.normal, _persist);
  }

  void _persist() {
    try {
      _prefs.setString(_kWizardKey, jsonEncode(state.toJson()));
    } catch (e, stack) {
      AppLogger().error('Wizard: failed to persist state', e, stack);
    }
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
      _schedulePersist();
    }
  }

  void previousStep() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
      _schedulePersist();
    }
  }

  void reset() {
    state = const OnboardingWizardState();
    try {
      final prefs = ref.read(prefsProvider);
      prefs.remove(_kWizardKey);
      prefs.setBool(_kWizardDoneKey, false);
    } catch (e, stack) {
      AppLogger().error('Wizard: failed to reset', e, stack);
    }
  }

  void markCompleted() {
    _completed = true;
    _persistTimer?.cancel();
    try {
      final prefs = ref.read(prefsProvider);
      prefs.setBool(_kWizardDoneKey, true);
      prefs.remove(_kWizardKey);
    } catch (e, stack) {
      AppLogger().error('Wizard: failed to mark completed', e, stack);
    }
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

/// Snapshot of wizard sectionData bridged to post-onboarding flow.
/// Saved before navigating away from wizard; consumed once by flow.
/// Deliberately NOT autoDispose: the bridge is written with `ref.read` and
/// read after the navigation frame, so an auto-disposing provider with zero
/// listeners could be disposed (and lose the data) before the flow consumes it.
class WizardBridge extends Notifier<Map<int, dynamic>> {
  @override
  Map<int, dynamic> build() => {};

  void capture(Map<int, dynamic> data) {
    state = Map<int, dynamic>.from(data);
  }

  void reset() {
    state = {};
  }
}

final wizardBridgeProvider = NotifierProvider<WizardBridge, Map<int, dynamic>>(
  WizardBridge.new,
);
