import 'package:freezed_annotation/freezed_annotation.dart';
import '../l10n/app_localizations.dart';

part 'quick_challenge.freezed.dart';
part 'quick_challenge.g.dart';

@JsonEnum()
enum QuickChallengeType {
  trueFalse,
  detectRisk,
  safePassword,
  whatWouldYouDo,
  detectPhishing,
}

extension QuickChallengeTypeX on QuickChallengeType {
  String localizedLabel(AppLocalizations l) {
    switch (this) {
      case QuickChallengeType.trueFalse:
        return l.quickChallengeTrueFalse;
      case QuickChallengeType.detectRisk:
        return l.quickChallengeDetectRisk;
      case QuickChallengeType.safePassword:
        return l.quickChallengeSafePassword;
      case QuickChallengeType.whatWouldYouDo:
        return l.quickChallengeWhatWouldYouDo;
      case QuickChallengeType.detectPhishing:
        return l.quickChallengeDetectPhishing;
    }
  }
}

@freezed
class QuickChallenge with _$QuickChallenge {
  const QuickChallenge._();

  const factory QuickChallenge({
    required String id,
    required QuickChallengeType type,
    required String question,
    required String scenario,
    required List<String> options,
    required int correctIndex,
    required String explanation,
    @Default('') String consequenceCorrect,
    @Default('') String consequenceWrong,
    @Default(15) int xpReward,
  }) = _QuickChallenge;

  factory QuickChallenge.fromJson(Map<String, dynamic> json) =>
      _$QuickChallengeFromJson(json);

  bool get isCorrectIndexValid =>
      correctIndex >= 0 && correctIndex < options.length;
}
