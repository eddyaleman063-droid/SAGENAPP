import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'prefs_provider.dart';

enum AppLanguage { es, en }

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
  Locale get locale =>
      language == AppLanguage.es ? const Locale('es') : const Locale('en');
  bool get hasUserChosen => userExplicit;
}

class LanguageNotifier extends Notifier<LanguageState> {
  late StorageService _storage;

  @override
  LanguageState build() {
    final prefs = ref.watch(prefsProvider);
    _storage = StorageService(prefs);

    const key = 'app_language';
    final userExplicit = prefs.containsKey(key);

    if (userExplicit) {
      final saved = _storage.getString(key, 'es');
      return LanguageState(
        language: saved == 'en' ? AppLanguage.en : AppLanguage.es,
        userExplicit: true,
      );
    }

    final sysLocale = ui.PlatformDispatcher.instance.locale;
    return LanguageState(
      language: sysLocale.languageCode == 'en'
          ? AppLanguage.en
          : AppLanguage.es,
    );
  }

  void setLanguage(AppLanguage lang) {
    _storage.setString('app_language', lang == AppLanguage.es ? 'es' : 'en');
    state = state.copyWith(language: lang, userExplicit: true);
  }
}
