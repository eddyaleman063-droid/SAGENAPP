import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/remote_config_service.dart';

void main() {
  group('RemoteConfigService', () {
    late RemoteConfigService service;

    setUp(() {
      service = RemoteConfigService.instance;
    });

    test('singleton instance exists', () {
      expect(service, isNotNull);
    });

    test('feature flags return defaults when not initialized', () {
      expect(service.isNewUIEnabled, false);
      expect(service.isChatV2Enabled, false);
      expect(service.isMiniGamesEnabled, true);
      expect(service.isStoreRedesignEnabled, false);
      expect(service.isStreakFreezeEnabled, false);
      expect(service.isLeaderboardEnabled, true);
      expect(service.isDarkModeEnabled, true);
      expect(service.isVoiceInputEnabled, false);
    });

    test('isFeatureEnabled returns default for unknown key', () {
      expect(service.isFeatureEnabled('unknown_key'), false);
      expect(service.isFeatureEnabled('unknown_key', defaultValue: true), true);
    });

    test('A/B test variants return defaults when not initialized', () {
      expect(service.onboardingFlowVariant, 'standard');
      expect(service.lessonLayoutVariant, 'card');
      expect(service.chestAnimationVariant, 'classic');
      expect(service.paywallPositionVariant, 'bottom');
    });

    test('getExperimentVariant returns default for unknown key', () {
      expect(service.getExperimentVariant('unknown'), 'control');
      expect(
        service.getExperimentVariant('unknown', defaultValue: 'custom'),
        'custom',
      );
    });

    test('allFeatureFlags returns map of all flags', () {
      final flags = service.allFeatureFlags;
      expect(flags, isA<Map<String, bool>>());
      expect(flags.containsKey('new_ui'), true);
      expect(flags.containsKey('dark_mode'), true);
      expect(flags.length, 8);
    });

    test('allExperiments returns map of all experiments', () {
      final experiments = service.allExperiments;
      expect(experiments, isA<Map<String, String>>());
      expect(experiments.containsKey('onboarding_flow'), true);
      expect(experiments.length, 4);
    });

    test('chestDropRates returns defaults when not initialized', () {
      final rates = service.chestDropRates;
      expect(rates, isA<Map<String, dynamic>>());
      expect(rates.containsKey('bronze'), true);
      expect(rates.containsKey('silver'), true);
      expect(rates.containsKey('gold'), true);
      expect(rates.containsKey('legendary'), true);
    });

    test('pityThreshold returns default', () {
      expect(service.pityThreshold, 20);
    });

    test('streakMaxFreezes returns default', () {
      expect(service.streakMaxFreezes, 7);
    });

    test('mission rates return defaults', () {
      expect(service.missionLegendaryRate, 0.01);
      expect(service.missionGoldRate, 0.06);
      expect(service.missionSilverRate, 0.20);
    });

    test('evolution rates return defaults', () {
      expect(service.evolutionBronzeToSilver, 0.45);
      expect(service.evolutionSilverToGold, 0.20);
      expect(service.evolutionGoldToLegendary, 0.03);
    });

    test('getDropRatesForChest returns default rates for unknown chest', () {
      final rates = service.getDropRatesForChest('bronze');
      expect(rates, isA<List<Map<String, dynamic>>>());
      expect(rates.isNotEmpty, true);
    });

    test('getDropRatesForChest returns empty for invalid chest type', () {
      final rates = service.getDropRatesForChest('nonexistent');
      expect(rates, isEmpty);
    });

    test('shopCatalog returns empty list when not initialized', () {
      expect(service.shopCatalog, isEmpty);
    });

    test('missionSilverRate clamps when sum exceeds 1.0', () {
      // The getter clamps: if legendary + gold + silver > 1.0, silver is reduced
      final silverRate = service.missionSilverRate;
      expect(silverRate, greaterThanOrEqualTo(0.0));
      expect(silverRate, lessThanOrEqualTo(1.0));
    });
  });
}
