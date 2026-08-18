import 'package:sagen/l10n/app_localizations.dart';

/// Localized name/description lookup for shop items by ID.
/// Keeps English defaults in the provider (data layer) while allowing
/// the UI to display fully localized strings.
String shopItemLocalizedName(String id, AppLocalizations l) {
  switch (id) {
    case 'focus_elixir':
      return l.shopItemFocusElixirName;
    case 'xp_boost':
      return l.shopItemXpBoostName;
    case 'luck_boost':
      return l.shopItemLuckBoostName;
    case 'sage_monocle':
      return l.shopItemSageMonocleName;
    case 'time_warp':
      return l.shopItemTimeWarpName;
    case 'titanium_shield':
      return l.shopItemTitaniumShieldName;
    case 'phoenix_feather':
      return l.shopItemPhoenixFeatherName;
    case 'avatar_frame_neon':
      return l.shopItemNeonFrameName;
    case 'avatar_frame_galaxy':
      return l.shopItemGalaxyFrameName;
    case 'avatar_frame_dragon':
      return l.shopItemDragonFrameName;
    case 'avatar_frame_crystal':
      return l.shopItemCrystalFrameName;
    case 'avatar_frame_skull':
      return l.shopItemSkullFrameName;
    case 'title_storm_breaker':
      return l.shopItemTitleStormBreakerName;
    case 'title_cyber_sage':
      return l.shopItemTitleCyberSageName;
    case 'title_shadow_hacker':
      return l.shopItemTitleShadowHackerName;
    case 'title_night_guardian':
      return l.shopItemTitleNightGuardianName;
    case 'title_digital_phoenix':
      return l.shopItemTitleDigitalPhoenixName;
    case 'effect_digital_rain':
      return l.shopItemEffectDigitalRainName;
    case 'effect_fire_trail':
      return l.shopItemEffectFireTrailName;
    case 'theme_blue':
      return l.shopItemThemeBlueName;
    case 'theme_purple':
      return l.shopItemThemePurpleName;
    case 'theme_dark_fire':
      return l.shopItemThemeDarkFireName;
    case 'theme_cyber_neon':
      return l.shopItemThemeCyberNeonName;
    default:
      return id;
  }
}

/// Localized description lookup for shop items by ID.
String shopItemLocalizedDescription(String id, AppLocalizations l) {
  switch (id) {
    case 'focus_elixir':
      return l.shopItemFocusElixirDesc;
    case 'xp_boost':
      return l.shopItemXpBoostDesc;
    case 'luck_boost':
      return l.shopItemLuckBoostDesc;
    case 'sage_monocle':
      return l.shopItemSageMonocleDesc;
    case 'time_warp':
      return l.shopItemTimeWarpDesc;
    case 'titanium_shield':
      return l.shopItemTitaniumShieldDesc;
    case 'phoenix_feather':
      return l.shopItemPhoenixFeatherDesc;
    case 'avatar_frame_neon':
      return l.shopItemNeonFrameDesc;
    case 'avatar_frame_galaxy':
      return l.shopItemGalaxyFrameDesc;
    case 'avatar_frame_dragon':
      return l.shopItemDragonFrameDesc;
    case 'avatar_frame_crystal':
      return l.shopItemCrystalFrameDesc;
    case 'avatar_frame_skull':
      return l.shopItemSkullFrameDesc;
    case 'title_storm_breaker':
      return l.shopItemTitleStormBreakerDesc;
    case 'title_cyber_sage':
      return l.shopItemTitleCyberSageDesc;
    case 'title_shadow_hacker':
      return l.shopItemTitleShadowHackerDesc;
    case 'title_night_guardian':
      return l.shopItemTitleNightGuardianDesc;
    case 'title_digital_phoenix':
      return l.shopItemTitleDigitalPhoenixDesc;
    case 'effect_digital_rain':
      return l.shopItemEffectDigitalRainDesc;
    case 'effect_fire_trail':
      return l.shopItemEffectFireTrailDesc;
    case 'theme_blue':
      return l.shopItemThemeBlueDesc;
    case 'theme_purple':
      return l.shopItemThemePurpleDesc;
    case 'theme_dark_fire':
      return l.shopItemThemeDarkFireDesc;
    case 'theme_cyber_neon':
      return l.shopItemThemeCyberNeonDesc;
    default:
      return id;
  }
}

/// Localized title for daily missions by ID.
String missionLocalizedTitle(String id, AppLocalizations l) {
  switch (id) {
    case 'm1':
      return l.missionPerfectLessonTitle;
    case 'm2':
      return l.missionActiveLearnerTitle;
    case 'm3':
      return l.missionDigitalDetectiveTitle;
    case 'm4':
      return l.missionChatWithSageTitle;
    case 'm5':
      return l.missionActiveStreakTitle;
    case 'm6':
      return l.missionExpressChallengeTitle;
    case 'm7':
      return l.missionPhishingHunterTitle;
    case 'm8':
      return l.mission3QueriesTitle;
    case 'm9':
      return l.missionConstantProtectorTitle;
    default:
      return id;
  }
}

/// Localized description for daily missions by ID.
String missionLocalizedDescription(String id, AppLocalizations l) {
  switch (id) {
    case 'm1':
      return l.missionPerfectLessonDesc;
    case 'm2':
      return l.missionActiveLearnerDesc;
    case 'm3':
      return l.missionDigitalDetectiveDesc;
    case 'm4':
      return l.missionChatWithSageDesc;
    case 'm5':
      return l.missionActiveStreakDesc;
    case 'm6':
      return l.missionExpressChallengeDesc;
    case 'm7':
      return l.missionPhishingHunterDesc;
    case 'm8':
      return l.mission3QueriesDesc;
    case 'm9':
      return l.missionConstantProtectorDesc;
    default:
      return id;
  }
}

/// Resolve payment error messages from provider to localized strings.
String resolvePaymentError(String? errorMessage, AppLocalizations l) {
  switch (errorMessage) {
    case 'You must be signed in to donate':
      return l.paymentErrorNotSignedIn;
    case 'Could not get session. Please sign in again.':
      return l.paymentErrorSessionExpired;
    case 'Invalid product':
      return l.paymentErrorInvalidProduct;
    case 'Could not start payment. Please try again.':
      return l.paymentErrorStartFailed;
    case 'Could not register payment. Please try again.':
      return l.paymentErrorRegisterFailed;
    case 'Payment expired. Please try again.':
      return l.paymentErrorExpired;
    case 'Payment was cancelled or did not complete':
      return l.paymentErrorCancelled;
    default:
      return errorMessage ?? l.paymentNotCompleted;
  }
}
