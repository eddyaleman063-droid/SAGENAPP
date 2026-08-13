import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ThemeState', () {
    test('initial state defaults to system mode', () {
      const state = ThemeState();
      expect(state.mode, ThemeMode.system);
      expect(state.scheduleEnabled, false);
    });

    test('copyWith updates mode', () {
      const state = ThemeState();
      final updated = state.copyWith(mode: ThemeMode.dark);
      expect(updated.mode, ThemeMode.dark);
    });

    test('effectiveMode returns mode when schedule disabled', () {
      const state = ThemeState(mode: ThemeMode.dark);
      expect(state.effectiveMode, ThemeMode.dark);
    });

    test('currentTheme returns light theme for light mode', () {
      const state = ThemeState(mode: ThemeMode.light);
      final theme = state.currentTheme;
      expect(theme.brightness, Brightness.light);
    });

    test('currentTheme returns dark theme for dark mode', () {
      const state = ThemeState(mode: ThemeMode.dark);
      final theme = state.currentTheme;
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('ThemeNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('build returns system mode by default', () {
      final state = container.read(themeProvider);
      expect(state.mode, ThemeMode.system);
    });

    test('setMode changes theme mode', () {
      final notifier = container.read(themeProvider.notifier);
      notifier.setMode(ThemeMode.dark);
      expect(container.read(themeProvider).mode, ThemeMode.dark);
    });

    test('setMode disables schedule when not system', () {
      final notifier = container.read(themeProvider.notifier);
      notifier.setScheduleEnabled(true);
      notifier.setMode(ThemeMode.dark);
      final state = container.read(themeProvider);
      expect(state.scheduleEnabled, false);
      expect(state.mode, ThemeMode.dark);
    });

    test('setMode for system preserves schedule state', () {
      final notifier = container.read(themeProvider.notifier);
      notifier.setMode(ThemeMode.system);
      final state = container.read(themeProvider);
      expect(state.scheduleEnabled, false);
    });

    test('setScheduleEnabled enables schedule and sets system mode', () {
      final notifier = container.read(themeProvider.notifier);
      notifier.setMode(ThemeMode.dark);
      notifier.setScheduleEnabled(true);
      final state = container.read(themeProvider);
      expect(state.scheduleEnabled, true);
      expect(state.mode, ThemeMode.system);
    });

    test(
      'setScheduleHours updates start and end hours clamped to valid range',
      () {
        final notifier = container.read(themeProvider.notifier);
        notifier.setScheduleHours(start: 22, end: 6);
        final state = container.read(themeProvider);
        expect(state.scheduleStartHour, 22);
        expect(state.scheduleEndHour, 6);
      },
    );

    test('setScheduleHours clamps out of range values', () {
      final notifier = container.read(themeProvider.notifier);
      notifier.setScheduleHours(start: -5, end: 30);
      final state = container.read(themeProvider);
      expect(state.scheduleStartHour, 0);
      expect(state.scheduleEndHour, 23);
    });
  });
}
