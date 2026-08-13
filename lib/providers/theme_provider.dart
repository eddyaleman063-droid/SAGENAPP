import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_constants.dart';
import 'prefs_provider.dart';

class ThemeState {
  final ThemeMode mode;
  final bool scheduleEnabled;
  final int scheduleStartHour;
  final int scheduleEndHour;
  final String themeVariant;

  const ThemeState({
    this.mode = ThemeMode.system,
    this.scheduleEnabled = false,
    this.scheduleStartHour = 20,
    this.scheduleEndHour = 7,
    this.themeVariant = 'default',
  });

  ThemeState copyWith({
    ThemeMode? mode,
    bool? scheduleEnabled,
    int? scheduleStartHour,
    int? scheduleEndHour,
    String? themeVariant,
  }) => ThemeState(
    mode: mode ?? this.mode,
    scheduleEnabled: scheduleEnabled ?? this.scheduleEnabled,
    scheduleStartHour: scheduleStartHour ?? this.scheduleStartHour,
    scheduleEndHour: scheduleEndHour ?? this.scheduleEndHour,
    themeVariant: themeVariant ?? this.themeVariant,
  );

  ThemeData get currentTheme {
    final isDark = effectiveMode == ThemeMode.dark;
    final base = isDark ? AppTheme.dark : AppTheme.light;
    switch (themeVariant) {
      case 'blue':
        return base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: PremiumColors.primary,
            secondary: PremiumColors.primaryAccent,
          ),
          scaffoldBackgroundColor: isDark
              ? PremiumColors.ambientDark
              : PremiumColors.variantBlueLight,
        );
      case 'purple':
        return base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: PremiumColors.variantPurplePrimary,
            secondary: PremiumColors.variantPurpleSecondary,
          ),
          scaffoldBackgroundColor: isDark
              ? PremiumColors.variantPurpleDark
              : PremiumColors.variantPurpleLight,
        );
      default:
        return base;
    }
  }

  ThemeMode get effectiveMode {
    if (scheduleEnabled) {
      final hour = DateTime.now().hour;
      final isDarkTime = scheduleStartHour > scheduleEndHour
          ? (hour >= scheduleStartHour || hour < scheduleEndHour)
          : (hour >= scheduleStartHour && hour < scheduleEndHour);
      return isDarkTime ? ThemeMode.dark : ThemeMode.light;
    }
    return mode;
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  late StorageService _storage;

  @override
  ThemeState build() {
    final prefs = ref.read(prefsProvider);
    _storage = StorageService(prefs);
    return _loadFromStorage();
  }

  ThemeState _loadFromStorage() {
    final saved = _storage.getString('theme_mode', 'system');
    return ThemeState(
      mode: _themeModeFromString(saved),
      scheduleEnabled: _storage.getBool('theme_schedule_enabled', false),
      scheduleStartHour: _storage.getInt('theme_schedule_start', 20),
      scheduleEndHour: _storage.getInt('theme_schedule_end', 7),
      themeVariant: _storage.getString('theme_variant', 'default'),
    );
  }

  void setThemeVariant(String variant) {
    state = state.copyWith(themeVariant: variant);
    _storage.setString('theme_variant', variant);
  }

  void setMode(ThemeMode mode) {
    if (mode != ThemeMode.system) {
      state = state.copyWith(mode: mode, scheduleEnabled: false);
    } else {
      state = state.copyWith(mode: mode);
    }
    _storage.setString('theme_mode', _themeModeToString(state.mode));
    _storage.setBool('theme_schedule_enabled', state.scheduleEnabled);
  }

  void setScheduleEnabled(bool enabled) {
    state = state.copyWith(
      scheduleEnabled: enabled,
      mode: enabled ? ThemeMode.system : state.mode,
    );
    _storage.setBool('theme_schedule_enabled', enabled);
  }

  void setScheduleHours({required int start, required int end}) {
    state = state.copyWith(
      scheduleStartHour: start.clamp(0, 23),
      scheduleEndHour: end.clamp(0, 23),
    );
    _storage.setInt('theme_schedule_start', state.scheduleStartHour);
    _storage.setInt('theme_schedule_end', state.scheduleEndHour);
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
