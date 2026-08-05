import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LanguageState', () {
    test('initial state defaults to Spanish', () {
      const state = LanguageState();
      expect(state.language, AppLanguage.es);
      expect(state.isSpanish, true);
      expect(state.hasUserChosen, false);
    });

    test('locale returns es for Spanish', () {
      const state = LanguageState();
      expect(state.locale.languageCode, 'es');
    });

    test('locale returns en for English', () {
      const state = LanguageState(language: AppLanguage.en);
      expect(state.locale.languageCode, 'en');
    });

    test('copyWith updates language', () {
      const state = LanguageState();
      final updated = state.copyWith(language: AppLanguage.en, userExplicit: true);
      expect(updated.language, AppLanguage.en);
      expect(updated.hasUserChosen, true);
    });
  });

  group('LanguageNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        prefsProvider.overrideWithValue(prefs),
      ]);
    });

    tearDown(() => container.dispose());

    test('build defaults to Spanish when no saved preference', () {
      final state = container.read(languageProvider);
      expect(state.hasUserChosen, false);
    });

    test('setLanguage changes language and marks as user chosen', () {
      final notifier = container.read(languageProvider.notifier);
      notifier.setLanguage(AppLanguage.en);
      final state = container.read(languageProvider);
      expect(state.language, AppLanguage.en);
      expect(state.hasUserChosen, true);
    });

    test('setLanguage persists to storage', () async {
      final notifier = container.read(languageProvider.notifier);
      notifier.setLanguage(AppLanguage.en);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_language'), 'en');
    });

    test('setLanguage toggles back to Spanish', () {
      final notifier = container.read(languageProvider.notifier);
      notifier.setLanguage(AppLanguage.en);
      notifier.setLanguage(AppLanguage.es);
      final state = container.read(languageProvider);
      expect(state.language, AppLanguage.es);
      expect(state.isSpanish, true);
    });
  });
}
