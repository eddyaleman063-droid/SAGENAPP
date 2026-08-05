import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/sage_emotion_service.dart';
import '../core/theme/theme_constants.dart';

enum WizardStepType {
  presentation,
  single,
  multi,
  level,
  goal,
  confirmation,
}

class WizardStepConfig {
  final String question;
  final WizardStepType type;
  final SageEmotion emotion;
  final String sageMessage;
  final List<WizardOption> options;

  const WizardStepConfig({
    required this.question,
    required this.type,
    required this.emotion,
    required this.sageMessage,
    required this.options,
  });
}

class WizardOption {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;

  const WizardOption({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
  });
}

class OnboardingWizardConfig {
  OnboardingWizardConfig._();

  static const int totalSteps = 9; // Must match localizedSteps().length

  static List<WizardStepConfig> localizedSteps(AppLocalizations l) => [
    WizardStepConfig(
      question: l.wizardWelcomeTitle,
      type: WizardStepType.presentation,
      emotion: SageEmotion.excitedWave,
      sageMessage: l.wizardWelcomeSage,
      options: [],
    ),
    WizardStepConfig(
      question: l.wizardHowFound,
      type: WizardStepType.single,
      emotion: SageEmotion.curious,
      sageMessage: l.wizardHowFoundSage,
      options: [
        WizardOption(label: l.wizardGoogle, value: 'Google', icon: Icons.g_mobiledata_rounded),
        WizardOption(label: l.wizardFacebook, value: 'Facebook', icon: Icons.facebook_rounded),
        WizardOption(label: l.wizardInstagram, value: 'Instagram', icon: Icons.camera_alt_outlined),
        WizardOption(label: l.wizardTikTok, value: 'TikTok', icon: Icons.music_note_rounded),
        WizardOption(label: l.wizardYouTube, value: 'YouTube', icon: Icons.play_circle_outline_rounded),
        WizardOption(label: l.wizardAppStore, value: 'App Store', icon: Icons.store_rounded),
        WizardOption(label: l.wizardFriends, value: 'Friends', icon: Icons.people_outline_rounded),
        WizardOption(label: l.wizardNews, value: 'News', icon: Icons.article_rounded),
        WizardOption(label: l.wizardTV, value: 'TV', icon: Icons.tv_rounded),
        WizardOption(label: l.wizardOther, value: 'Other', icon: Icons.more_horiz_rounded),
      ],
    ),
    WizardStepConfig(
      question: l.wizardHowMuchKnow,
      type: WizardStepType.level,
      emotion: SageEmotion.thinking,
      sageMessage: l.wizardHowMuchKnowSage,
      options: [
        WizardOption(label: l.wizardLevel1, value: '1', icon: Icons.eco_rounded, color: PremiumColors.wizardGreen, subtitle: l.wizardLevel1Sub),
        WizardOption(label: l.wizardLevel2, value: '2', icon: Icons.grass_rounded, color: PremiumColors.wizardBlue, subtitle: l.wizardLevel2Sub),
        WizardOption(label: l.wizardLevel3, value: '3', icon: Icons.park_rounded, color: PremiumColors.wizardAmber, subtitle: l.wizardLevel3Sub),
        WizardOption(label: l.wizardLevel4, value: '4', icon: Icons.forest_rounded, color: PremiumColors.wizardDeepOrange, subtitle: l.wizardLevel4Sub),
        WizardOption(label: l.wizardLevel5, value: '5', icon: Icons.landslide_rounded, color: PremiumColors.wizardPurple, subtitle: l.wizardLevel5Sub),
      ],
    ),
    WizardStepConfig(
      question: l.wizardWhyLearn,
      type: WizardStepType.multi,
      emotion: SageEmotion.curious,
      sageMessage: l.wizardWhyLearnSage,
      options: [
        WizardOption(label: l.wizardProtect, value: 'shield', icon: Icons.shield_rounded),
        WizardOption(label: l.wizardBoostStudies, value: 'school', icon: Icons.school_rounded),
        WizardOption(label: l.wizardCuriosity, value: 'curiosity', icon: Icons.lightbulb_outline_rounded),
        WizardOption(label: l.wizardPrepareWork, value: 'work', icon: Icons.work_outline_rounded),
        WizardOption(label: l.wizardProtectFamily, value: 'family', icon: Icons.family_restroom_rounded),
        WizardOption(label: l.wizardHaveFun, value: 'fun', icon: Icons.celebration_outlined),
      ],
    ),
    WizardStepConfig(
      question: l.wizardWhatLearn,
      type: WizardStepType.single,
      emotion: SageEmotion.curious,
      sageMessage: l.wizardWhatLearnSage,
      options: [
        WizardOption(label: l.wizardProtectAccounts, value: 'accounts', icon: Icons.lock_outline_rounded),
        WizardOption(label: l.wizardDetectScams, value: 'scams', icon: Icons.warning_amber_rounded),
        WizardOption(label: l.wizardSafeBrowsing, value: 'browsing', icon: Icons.language_rounded),
        WizardOption(label: l.wizardProtectPrivacy, value: 'privacy', icon: Icons.visibility_off_rounded),
        WizardOption(label: l.wizardAllAbove, value: 'all', icon: Icons.auto_awesome_rounded),
      ],
    ),
    WizardStepConfig(
      question: l.wizardHowPrefer,
      type: WizardStepType.multi,
      emotion: SageEmotion.calm,
      sageMessage: l.wizardHowPreferSage,
      options: [
        WizardOption(label: l.wizardQuizzes, value: 'quiz', icon: Icons.quiz_rounded),
        WizardOption(label: l.wizardArticles, value: 'article', icon: Icons.article_rounded),
        WizardOption(label: l.wizardVideos, value: 'video', icon: Icons.ondemand_video_rounded),
        WizardOption(label: l.wizardLinks, value: 'link', icon: Icons.link_rounded),
        WizardOption(label: l.wizardChatSage, value: 'chat', icon: Icons.chat_rounded),
      ],
    ),
    WizardStepConfig(
      question: l.wizardTimeDedicate,
      type: WizardStepType.goal,
      emotion: SageEmotion.calm,
      sageMessage: l.wizardTimeSage,
      options: [
        WizardOption(label: l.wizardGoal3, value: '3', icon: Icons.coffee_rounded, color: PremiumColors.wizardGreen, subtitle: l.wizardGoal3Sub),
        WizardOption(label: l.wizardGoal10, value: '10', icon: Icons.timer_rounded, color: PremiumColors.wizardBlue, subtitle: l.wizardGoal10Sub),
        WizardOption(label: l.wizardGoal15, value: '15', icon: Icons.bolt_rounded, color: PremiumColors.wizardAmber, subtitle: l.wizardGoal15Sub),
        WizardOption(label: l.wizardGoal30, value: '30', icon: Icons.local_fire_department_rounded, color: PremiumColors.wizardDeepRed, subtitle: l.wizardGoal30Sub),
      ],
    ),
    WizardStepConfig(
      question: l.wizardCommitment,
      type: WizardStepType.multi,
      emotion: SageEmotion.excited,
      sageMessage: l.wizardCommitmentSage,
      options: [
        WizardOption(label: l.wizardCommit7, value: '7', icon: Icons.local_fire_department_rounded, color: PremiumColors.wizardAmber, subtitle: l.wizardCommit7Sub),
        WizardOption(label: l.wizardCommit14, value: '14', icon: Icons.local_fire_department_rounded, color: PremiumColors.wizardAmberDark, subtitle: l.wizardCommit14Sub),
        WizardOption(label: l.wizardCommit30, value: '30', icon: Icons.local_fire_department_rounded, color: PremiumColors.wizardOrange, subtitle: l.wizardCommit30Sub),
        WizardOption(label: l.wizardCommit50, value: '50', icon: Icons.local_fire_department_rounded, color: PremiumColors.wizardDeepRed, subtitle: l.wizardCommit50Sub),
      ],
    ),
    WizardStepConfig(
      question: l.wizardConfirmed,
      type: WizardStepType.confirmation,
      emotion: SageEmotion.excitedWave,
      sageMessage: l.wizardConfirmedSage,
      options: [],
    ),
  ];
}
