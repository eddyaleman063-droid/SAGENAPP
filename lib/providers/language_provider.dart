import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'prefs_provider.dart';

enum AppLanguage {
  es('es'),
  en('en'),
  fr('fr'),
  pt('pt');

  const AppLanguage(this.code);
  final String code;
}

class LanguageState {
  final AppLanguage language;
  final bool userExplicit;

  const LanguageState({
    this.language = AppLanguage.es,
    this.userExplicit = false,
  });

  LanguageState copyWith({AppLanguage? language, bool? userExplicit}) =>
      LanguageState(
        language: language ?? this.language,
        userExplicit: userExplicit ?? this.userExplicit,
      );

  bool get isSpanish => language == AppLanguage.es;
  Locale get locale => Locale(language.code);
  bool get hasUserChosen => userExplicit;
}

class LanguageNotifier extends Notifier<LanguageState> {
  late StorageService _storage;

  static AppLanguage? _languageFromCode(String code) {
    for (final lang in AppLanguage.values) {
      if (lang.code == code) return lang;
    }
    return null;
  }

  @override
  LanguageState build() {
    final prefs = ref.watch(prefsProvider);
    _storage = StorageService(prefs);

    const key = 'app_language';
    final userExplicit = prefs.containsKey(key);

    if (userExplicit) {
      final saved = prefs.getString(key) ?? 'es';
      return LanguageState(
        language: _languageFromCode(saved) ?? AppLanguage.es,
        userExplicit: true,
      );
    }

    // Follow the system language when it maps to a supported locale.
    final sysCode = ui.PlatformDispatcher.instance.locale.languageCode;
    return LanguageState(
      language: _languageFromCode(sysCode) ?? AppLanguage.es,
    );
  }

  void setLanguage(AppLanguage lang) {
    _storage.setString('app_language', lang.code);
    state = state.copyWith(language: lang, userExplicit: true);
  }
}
