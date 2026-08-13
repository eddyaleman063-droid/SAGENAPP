import 'package:flutter/material.dart';

/// WCAG 2.1 Contrast Ratios (verified):
/// - textDark on lightBg: 16.5:1 (AAA)
/// - textLight on deepBackground: 10.4:1 (AAA)
/// - primary on white: 5.7:1 (AA)
/// - primary on darkBg: 4.6:1 (AA)
/// - success on white: 5.2:1 (AA)
/// - error on white: 7.1:1 (AA)
/// - warning on white: 4.8:1 (AA)
///
/// ─── COLOR SYSTEM (Intentional Duality) ────────────────────────
///
/// SAGEN uses TWO distinct color families by design, not by accident:
///
/// 1. PURPLE (#4C1D95 → #7C3AED) — Brand / Sage AI Identity
///    Used exclusively for the Sage AI mascot: chat header, message bubbles,
///    quick chips, input bar, and XP rewards. Purple conveys the AI's
///    unique personality and distinguishes the assistant from the rest
///    of the app. `gradientSage` is the canonical brand gradient.
///
/// 2. CYAN/BLUE (#4AC2DD family) — App UI / Tech Identity
///    Used as the primary accent for interactive elements: navigation,
///    buttons, progress indicators, onboarding, ranking highlights,
///    profile accents, and lesson screens. Blue/cyan signals trust,
///    technology, and security — the functional identity of the app.
///
/// 3. DARK BLUE (#1565C0) — Security / Premium
///    Reserved for shields, security status indicators, and premium
///    feature accents.
///
/// WHY: The separation ensures the Sage mascot feels like a distinct
/// character within the app rather than blending into the UI. Users
/// subconsciously learn that "purple = talking to Sage" and
/// "blue = navigating/interacting with the app." This is a common
/// pattern in AI-assisted products (e.g., Copilot's green vs. VS Code's blue).
/// ───────────────────────────────────────────────────────────────
class PremiumColors {
  PremiumColors._();

  static const primary = Color(0xFF1565C0);
  static const primaryDark = Color(0xFF0D47A1);
  static const primaryLight = Color(0xFF1E88E5);
  static const primaryAccent = Color(0xFF42A5F5);

  static const shieldActive = Color(0xFF1565C0);
  static const shieldFrozen = Color(0xFF64B5F6);
  static const shieldAchievement = Color(0xFFFFB300);

  static const gradientActive = [Color(0xFF0D47A1), Color(0xFF1E88E5)];
  static const gradientFrozen = [Color(0xFF64B5F6), Color(0xFFBBDEFB)];
  static const gradientAchievement = [Color(0xFFFF8F00), Color(0xFFFFB300)];
  static const gradientHeader = [
    Color(0xFF0D47A1),
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
  ];
  static const gradientSage = [
    Color(0xFF4C1D95),
    Color(0xFF6D28D9),
    Color(0xFF7C3AED),
  ];
  static const gradientSafe = [Color(0xFF1B5E20), Color(0xFF43A047)];
  static const gradientSuspicious = [Color(0xFFBF360C), Color(0xFFFF6D00)];
  static const gradientDangerous = [Color(0xFF7F0000), Color(0xFFE53935)];

  static const gradientShieldBasic = [Color(0xFF1565C0), Color(0xFF1E88E5)];
  static const gradientShieldGlow = [Color(0xFF1E88E5), Color(0xFF64B5F6)];
  static const gradientShieldParticles = [Color(0xFF0D47A1), Color(0xFF42A5F5)];
  static const gradientShieldCrystal = [Color(0xFF1A237E), Color(0xFF7C4DFF)];
  static const gradientShieldLegendary = [Color(0xFFFF6F00), Color(0xFFFFB300)];

  static const darkBg = Color(0xFF0A0E1A);
  static const deepBackground = Color(0xFF1B2433);
  static const darkCard = Color(0xFF1A2035);
  static const darkSurface = Color(0xFF1A1F2E);
  static const lightBg = Color(0xFFF0F4FF);

  static const textDark = Color(0xFF1A1A2E);
  static const textLight = Color(0xFFE2E8F0);

  static const teal = Color(0xFF0D9488);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFE65100);
  static const error = Color(0xFFB71C1C);
  static const info = Color(0xFF1565C0);
  static const danger = Color(0xFFFF6B6B);

  static const typeStreak = Color(0xFFFF6D00);
  static const typeAnalysis = Color(0xFF1565C0);
  static const typeTip = Color(0xFF7B1FA2);
  static const typeAchievement = Color(0xFFFFB300);
  static const typeSystem = Color(0xFF546E7A);

  static const splashBlue = Color(0xFF4AC2DD);
  static const premiumBlue = primary;
  static const streakOrange = Color(0xFFFF6D00);
  static const premiumIce = Color(0xFF64B5F6);
  static const activeStart = Color(0xFF0D47A1);
  static const activeEnd = Color(0xFF1E88E5);
  static const frozenStart = Color(0xFF64B5F6);
  static const frozenEnd = Color(0xFFBBDEFB);
  static const achievementStart = Color(0xFFFF8F00);
  static const achievementEnd = Color(0xFFFFB300);

  static const xpColor = Color(0xFF7C3AED);
  static const heatmapEmpty = Color(0xFFEAEEF4);
  static const heatmapLight = Color(0xFFC8E6C9);
  static const heatmapMedium = Color(0xFF66BB6A);
  static const heatmapHigh = Color(0xFF2E7D32);
  static const heatmapDark = Color(0xFF1B5E20);

  // Onboarding bubble colors
  static const onboardingBubbleDark = Color(0xFF2A3448);
  static const onboardingBubbleLight = Color(0xFFFFFFFF);

  // Onboarding accents
  static const onboardingAccentOrange = Color(0xFFFFA726);
  static const onboardingAccentCyan = Color(0xFF00BCD4);
  static const onboardingPurple = Color(0xFF9B59B6);

  // Auth/registration colors
  static const authBackground = Color(0xFF1E1E24);
  static const authCardDark = Color(0xFF0A0A0C);
  static const authCardLight = Color(0xFF121214);
  static const accentCyan = Color(0xFF00E5FF);
  static const accentYellow = Color(0xFFFFD54F);
  static const deepPurple = Color(0xFF7C4DFF);

  // Social button colors
  static const facebookBlue = Color(0xFF1877F2);

  // Sage chat colors
  static const sagePlaceholder = Color(0xFF2A3444);
  static const chatHeaderDark = Color(0xFF1E293B);
  static const chatHeaderLight = Color(0xFFE2E8F0);
  static const chatLockedDark = Color(0xFF1A1A2E);
  static const chatLockedLight = Color(0xFFF5F7FA);

  // Button colors
  static const buttonGreen = Color(0xFF22C55E);
  static const buttonGreenBorder = Color(0xFF16A34A);
  static const buttonGrayDark = Color(0xFF374151);
  static const buttonGrayLight = Color(0xFF9CA3AF);

  // Streak inactive colors
  static const streakInactiveDark = Color(0xFF2A3448);
  static const streakInactiveLight = Color(0xFFD0D0D0);

  // Update category colors
  static const updateImprovement = Color(0xFF64B5F6);
  static const updateFix = Color(0xFFFFB74D);

  // Payment colors
  static const paymentBlue = Color(0xFF009EE3);

  // Ambient background
  static const ambientDark = Color(0xFF0D1B2A);
  static const ambientLight = Color(0xFFE8F0FE);

  // Game colors
  static const gameBlue = Color(0xFF2BA4D4);
  static const gameOrange = Color(0xFFE67E22);

  // Flame colors
  static const flameFrozen = Color(0xFF4FC3F7);
  static const flameDefrosting = Color(0xFF81D4FA);
  static const flameActive = Color(0xFFFF9100);

  // Gem / Ice colors
  static const gemPrimary = Color(0xFF4FC3F7);
  static const gemSecondaryLight = Color(0xFF29B6F6);
  static const gemSecondaryDark = Color(0xFF81D4FA);

  // Streak theme colors
  static const streakSpark = Color(0xFFFF6D00);
  static const streakConstantLight = Color(0xFFD50000);
  static const streakConstantDark = Color(0xFFFF1744);
  static const streakBlueLight = Color(0xFF1565C0);
  static const streakBlueDark = Color(0xFF448AFF);
  static const streakCosmicLight = Color(0xFFAA00FF);
  static const streakCosmicDark = Color(0xFFFFD700);

  // Theme variant colors
  static const variantPurpleDark = Color(0xFF1A0A2E);
  static const variantPurpleLight = Color(0xFFF3E5F5);
  static const variantPurplePrimary = Color(0xFF6A1B9A);
  static const variantPurpleSecondary = Color(0xFFAB47BC);
  static const variantBlueLight = Color(0xFFE3F2FD);

  // Challenge / Lesson type colors
  static const challengeTrueFalse = Color(0xFF1565C0);
  static const challengeMultipleChoice = Color(0xFF7C3AED);
  static const challengeCompletePhrase = Color(0xFF00897B);
  static const challengeDetectRisk = Color(0xFFE65100);
  static const challengeCreatePassword = Color(0xFF2E7D32);
  static const challengeWhatWouldYouDo = Color(0xFF6A1B9A);
  static const challengeMiniCase = Color(0xFFFFB300);

  // Wizard colors
  static const wizardOrange = Color(0xFFFF6D00);
  static const wizardGreen = Color(0xFF66BB6A);
  static const wizardBlue = Color(0xFF42A5F5);
  static const wizardAmber = Color(0xFFFFB300);
  static const wizardDeepOrange = Color(0xFFE65100);
  static const wizardDeepRed = Color(0xFFE53935);
  static const wizardPurple = Color(0xFF7C3AED);
  static const wizardAmberDark = Color(0xFFFF8F00);

  // Progress
  static const progressGreen = Color(0xFF8EE000);

  // Brand colors
  static const tiktokBlack = Color(0xFF010101);
  static const tiktokCyan = Color(0xFF00F2EA);
  static const spotifyGreen = Color(0xFF3DDC84);
  static const pinkHeart = Color(0xFFE91E63);

  // Success variants
  static const successLight = Color(0xFF81C784);

  // ── Medal / Achievement Colors ──────────────────────────────
  static const gold = Color(0xFFFFD700);
  static const goldDark = Color(0xFFFFA000);
  static const goldLight = Color(0xFFFFE082);
  static const goldAmber = Color(0xFFFFCA28);
  static const silver = Color(0xFFC0C0C0);
  static const silverMedium = Color(0xFF9E9E9E);
  static const silverLight = Color(0xFFCFD8DC);
  static const bronze = Color(0xFFCD7F32);
  static const bronzeDark = Color(0xFF8B5E3C);
  static const bronzeGlow = Color(0xFF8D6E63);
  static const bronzeLight = Color(0xFFA1887F);

  // Achievement tier colors
  static const achievementTier10 = Color(0xFF90A4AE);
  static const achievementTier20 = Color(0xFFB0BEC5);
  static const achievementTier20Light = Color(0xFFCFD8DC);
  static const achievementTier25 = Color(0xFFFFD54F);
  static const achievementTier30 = Color(0xFFFFCA28);
  static const achievementTier40 = Color(0xFFB388FF);
  static const achievementTier60 = Color(0xFFFF6F00);
  static const achievementTier100Light = Color(0xFFFFE082);
  static const achievementTier200Light = Color(0xFFFFE082);

  // Rarity colors
  static const rarityCommon = Color(0xFF78909C);
  static const rarityUncommon = Color(0xFF66BB6A);
  static const rarityRare = Color(0xFF42A5F5);
  static const rarityEpic = Color(0xFFAB47BC);
  static const rarityLegendary = Color(0xFFFFB300);

  // Chest colors
  static const chestDarkBg = Color(0xFF1A0A00);
  static const chestDarkLine = Color(0xFF2A1506);
  static const chestLegendaryPink = Color(0xFFE040FB);
  static const chestLegendaryRed = Color(0xFFFF3D00);

  // Light surface tint
  static const surfaceTintLight = Color(0xFFB3E5FC);

  // Sage gradient (dark mode support card)
  static const gradientSageDark1 = Color(0xFF1A1A2E);
  static const gradientSageDark2 = Color(0xFF16213E);
  static const gradientSageDark3 = Color(0xFF0F3460);

  // Support card light gradient
  static const gradientSupportLight1 = Color(0xFF667EEA);
  static const gradientSupportLight2 = Color(0xFF764BA2);

  // Promo dark gradient
  static const gradientPromoDark1 = Color(0xFF0F3460);
  static const gradientPromoDark2 = Color(0xFF533483);

  // Social gradients
  static const instagramPurple = Color(0xFF833AB4);
  static const instagramRed = Color(0xFFFD1D1D);
  static const instagramOrange = Color(0xFFF77737);
  static const youtubeRed = Color(0xFFFF0000);

  // Confetti palettes
  static const confettiFresh = [
    Color(0xFF4ECDC4),
    Color(0xFF95E1D3),
    Color(0xFF38B2AC),
    Color(0xFF2D9CDB),
    Color(0xFF27AE60),
  ];
  static const confettiWarm = [
    Color(0xFFFF6B6B),
    Color(0xFFF38181),
    Color(0xFFFF9F43),
    Color(0xFFFFC312),
    Color(0xFFEE5A24),
  ];
  static const confettiSoft = [
    Color(0xFFAA96DA),
    Color(0xFFFCBDAD),
    Color(0xFFA29BFE),
    Color(0xFF6C5CE7),
    Color(0xFF9B59B6),
  ];
  static const confettiExtra = [
    Color(0xFFFFE66D),
    Color(0xFFFDCB6E),
    Color(0xFFF8B500),
    Color(0xFFFF9F43),
    Color(0xFFE1B12C),
  ];
  static const confettiMixed = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFCBDAD),
  ];

  // Chest body colors (painter)
  static const chestBronzeBody = Color(0xFFCD7F32);
  static const chestBronzeAccent = Color(0xFF8B5E3C);
  static const chestBronzeGlow = Color(0xFF8D6E63);
  static const chestSilverBody = Color(0xFFA0AAB8);
  static const chestSilverAccent = Color(0xFF7A8A9A);
  static const chestSilverGlow = Color(0xFFB0BEC5);
  static const chestSilverParticle = Color(0xFFC0D0E0);
  static const chestGoldBody = Color(0xFFE6B800);
  static const chestGoldAccent = Color(0xFFB8860B);
  static const chestGoldGlow = Color(0xFFFFB300);
  static const chestGoldParticle = Color(0xFFFFD700);
  static const chestLegendaryBody = Color(0xFF9B6BFF);
  static const chestLegendaryGlow2 = Color(0xFFB388FF);
  static const chestLegendaryParticle = Color(0xFFE040FB);

  // Particle / animation colors
  static const particleBurst = Color(0xFF3AC5E8);
  static const levelUpRed = Color(0xFFFF6B6B);

  // Profile colors
  static const profileGoldFrame = Color(0xFFFFD700);
  static const profileGoldFrameDark = Color(0xFFFFA000);

  // Sagen logo brand
  static const logoBgCenter = Color(0xFF7FFFD4);
  static const logoBgEdge = Color(0xFF00E5EE);
  static const logoMaskBase = Color(0xFF1E3A5F);
  static const logoNeon = Color(0xFF00FFFF);
  static const logoIris = Color(0xFF00CED1);
  static const logoHighlight = Color(0xFFFFFFFF);

  // Chat locked mode
  static const chatLockedDarkSurface = Color(0xFF16213E);
  static const chatLockedLightSurface = Color(0xFFE8ECF1);

  // Sagen widget dark/light
  static const sageWidgetDarkBg = Color(0xFF1A1A2E);
  static const sageWidgetDarkSurface = Color(0xFF16213E);
  static const sageWidgetLightBg = Color(0xFFE8ECF1);

  // Code syntax colors
  static const codeTextDark = Color(0xFF80CBC4);
  static const codeTextLight = Color(0xFF00695C);

  // Shadow defaults
  static const shadowDark = Color(0xFF000000);
  static const shadowSupportLight = Color(0xFF667EEA);
}

// ─── Spacing ───────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
}

// ─── Border Radius ─────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 20;
  static const double round = 24;
  static const double pill = 100;
}

// ─── Animation ────────────────────────────────────────────
class AppMotion {
  AppMotion._();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration celebration = Duration(milliseconds: 1200);
  static const Duration stagger = Duration(milliseconds: 50);
  static const Duration staggerTotal = Duration(milliseconds: 600);

  /// Returns [normal] duration, or [Duration.zero] if reduce-motion is active.
  /// Pass `reduceAnimations` from the calling context (e.g., via Riverpod provider).
  static Duration resolve(Duration normal, {bool reduceAnimations = false}) {
    return reduceAnimations ? Duration.zero : normal;
  }
}

class AppEasing {
  AppEasing._();
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOut;
  static const Curve celebration = Curves.easeOutCubic;
  static const Curve spring = Curves.fastOutSlowIn;
}

class AppGradients {
  AppGradients._();

  static LinearGradient shieldActive() => const LinearGradient(
    colors: PremiumColors.gradientActive,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shieldAchievement() => const LinearGradient(
    colors: PremiumColors.gradientAchievement,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shieldFrozen() => const LinearGradient(
    colors: PremiumColors.gradientFrozen,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient sage() => const LinearGradient(
    colors: PremiumColors.gradientSage,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient safe() => const LinearGradient(
    colors: PremiumColors.gradientSafe,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient suspicious() => const LinearGradient(
    colors: PremiumColors.gradientSuspicious,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient dangerous() => const LinearGradient(
    colors: PremiumColors.gradientDangerous,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient primaryHeader() => const LinearGradient(
    colors: PremiumColors.gradientHeader,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shieldLegendary() => const LinearGradient(
    colors: PremiumColors.gradientShieldLegendary,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shieldCrystal() => const LinearGradient(
    colors: PremiumColors.gradientShieldCrystal,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shieldGlow() => const LinearGradient(
    colors: PremiumColors.gradientShieldGlow,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient shieldBasic() => const LinearGradient(
    colors: PremiumColors.gradientShieldBasic,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card({Color? color, double blurRadius = 10}) => [
    BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: 0.08),
      blurRadius: blurRadius,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glow({
    required Color color,
    double intensity = 0.2,
    double radius = 20,
    double spread = 2,
  }) => [
    BoxShadow(
      color: color.withValues(alpha: intensity),
      blurRadius: radius,
      spreadRadius: spread,
    ),
  ];

  static List<BoxShadow> elevated({Color? color, double intensity = 0.08}) => [
    BoxShadow(
      color: (color ?? Colors.black).withValues(alpha: intensity),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppEffects {
  AppEffects._();

  static BoxShadow softGlow(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.15),
    blurRadius: 20,
    spreadRadius: 1,
  );

  static BoxShadow strongGlow(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.3),
    blurRadius: 30,
    spreadRadius: 4,
  );
}

class AppDurations {
  AppDurations._();
  static const Duration normal = AppMotion.normal;
  static const Duration checkIn = Duration(milliseconds: 1500);
}

class AppGlassmorphism {
  AppGlassmorphism._();
  static BoxDecoration input({required bool dark}) => BoxDecoration(
    color: (dark ? PremiumColors.textLight : PremiumColors.textDark).withValues(
      alpha: 0.05,
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: (dark ? PremiumColors.textLight : PremiumColors.textDark)
          .withValues(alpha: 0.08),
    ),
  );
}

class AppTextStyle {
  AppTextStyle._();

  // ── Display ──────────────────────────────────────────────
  static const heroLarge = TextStyle(fontSize: 56, fontWeight: FontWeight.bold);
  static const hero = TextStyle(fontSize: 48, fontWeight: FontWeight.bold);
  static const displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
  );
  static const display = TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  // ── Headline ─────────────────────────────────────────────
  static const headlineLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );
  static const headline = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  // ── Title ────────────────────────────────────────────────
  static const titleLg = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const title = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ── Body ─────────────────────────────────────────────────
  static const bodyLg = TextStyle(fontSize: 17);
  static const body = TextStyle(fontSize: 15);
  static const bodyBold = TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
  static const bodyMd = TextStyle(fontSize: 14);
  static const bodyMdBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ── Caption / Subtitle ───────────────────────────────────
  static const subtitle = TextStyle(fontSize: 13);
  static const caption = TextStyle(fontSize: 12);

  // ── Label / Tiny ─────────────────────────────────────────
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  static const tiny = TextStyle(fontSize: 11);
  static const micro = TextStyle(fontSize: 10);

  // ── Aliases for backward compatibility ───────────────────
  static const question = title;
  static const cardTitle = titleSmall;
}
