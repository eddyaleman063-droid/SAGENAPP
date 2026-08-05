import 'package:freezed_annotation/freezed_annotation.dart';
import '../l10n/app_localizations.dart';

part 'daily_mission.freezed.dart';
part 'daily_mission.g.dart';

@JsonEnum()
enum MissionType { completeLesson, talkToSage, analyzeLink, perfectLesson, maintainStreak, quickChallenge, detectPhishing }

@JsonEnum()
enum MissionDifficulty { easy, medium, hard }

@JsonEnum()
enum MissionRarity { common, rare, epic }

@JsonEnum()
enum MissionCategory { learning, protection, consistency, awareness, privacy, safeHabits }

@unfreezed
class DailyMission with _$DailyMission {
  DailyMission._();

  factory DailyMission({
    required String id,
    required String title,
    required String description,
    required MissionType type,
    @Default(30) int xpReward,
    @Default(1) int target,
    @Default(MissionDifficulty.easy) MissionDifficulty difficulty,
    @Default(MissionRarity.common) MissionRarity rarity,
    @Default(0) int xpBonus,
    @Default(0) int streakBonus,
    @Default(MissionCategory.learning) MissionCategory category,
    @Default(0) int progress,
    @Default(false) bool completed,
  }) = _DailyMission;

  factory DailyMission.fromJson(Map<String, dynamic> json) => _$DailyMissionFromJson(json);

  double get progressFraction => target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  String localizedTitle(AppLocalizations l) {
    switch (type) {
      case MissionType.perfectLesson: return l.missionPerfectLessonTitle;
      case MissionType.completeLesson: return l.missionActiveLearnerTitle;
      case MissionType.analyzeLink: return l.missionDigitalDetectiveTitle;
      case MissionType.talkToSage: return l.missionChatWithSageTitle;
      case MissionType.maintainStreak: return l.missionActiveStreakTitle;
      case MissionType.quickChallenge: return l.missionExpressChallengeTitle;
      case MissionType.detectPhishing: return l.missionPhishingHunterTitle;
    }
  }

  String localizedDescription(AppLocalizations l) {
    switch (type) {
      case MissionType.perfectLesson: return l.missionPerfectLessonDesc;
      case MissionType.completeLesson: return l.missionActiveLearnerDesc;
      case MissionType.analyzeLink: return l.missionDigitalDetectiveDesc;
      case MissionType.talkToSage: return l.missionChatWithSageDesc;
      case MissionType.maintainStreak: return l.missionActiveStreakDesc;
      case MissionType.quickChallenge: return l.missionExpressChallengeDesc;
      case MissionType.detectPhishing: return l.missionPhishingHunterDesc;
    }
  }
}
