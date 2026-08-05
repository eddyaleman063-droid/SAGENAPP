import '../l10n/app_localizations.dart';

/// Defines a protection level tier with name, description and XP threshold.
class ProtectionTier {
  final int level;
  final String name;
  final String description;
  final int requiredScore;

  const ProtectionTier({
    required this.level,
    required this.name,
    required this.description,
    required this.requiredScore,
  });

  String localizedName(AppLocalizations l) {
    switch (name) {
      case 'Basic': return l.protectionBasic;
      case 'Protected': return l.protectionProtected;
      case 'Guardian': return l.protectionGuardian;
      case 'Cyber Shield': return l.protectionCyberShield;
      case 'Secure Mind': return l.protectionSecureMind;
      case 'Elite Protection': return l.protectionElite;
      default: return name;
    }
  }

  String localizedDescription(AppLocalizations l) {
    switch (name) {
      case 'Basic': return l.protectionBasicDesc;
      case 'Protected': return l.protectionProtectedDesc;
      case 'Guardian': return l.protectionGuardianDesc;
      case 'Cyber Shield': return l.protectionCyberShieldDesc;
      case 'Secure Mind': return l.protectionSecureMindDesc;
      case 'Elite Protection': return l.protectionEliteDesc;
      default: return description;
    }
  }
}

const kProtectionTiers = [
  ProtectionTier(level: 1, name: 'Basic', description: 'Starting to protect yourself', requiredScore: 0),
  ProtectionTier(level: 5, name: 'Protected', description: 'Your first digital habits', requiredScore: 200),
  ProtectionTier(level: 10, name: 'Guardian', description: 'Defending your digital identity', requiredScore: 500),
  ProtectionTier(level: 20, name: 'Cyber Shield', description: 'An active shield', requiredScore: 1200),
  ProtectionTier(level: 35, name: 'Secure Mind', description: 'Security is part of you', requiredScore: 2500),
  ProtectionTier(level: 50, name: 'Elite Protection', description: 'Maximum protection level', requiredScore: 5000),
];

int protectionLevelForScore(int score) {
  int level = 1;
  for (final tier in kProtectionTiers) {
    if (score >= tier.requiredScore) {
      level = tier.level;
    }
  }
  return level;
}

String protectionNameForLevel(int level) {
  String name = kProtectionTiers.first.name;
  for (final tier in kProtectionTiers) {
    if (level >= tier.level) name = tier.name;
  }
  return name;
}

double protectionProgress(int score, int level) {
  int currentRequired = 0;
  int nextRequired = kProtectionTiers.first.requiredScore;
  for (int i = 0; i < kProtectionTiers.length; i++) {
    if (level >= kProtectionTiers[i].level) {
      currentRequired = kProtectionTiers[i].requiredScore;
      nextRequired = i + 1 < kProtectionTiers.length
          ? kProtectionTiers[i + 1].requiredScore
          : kProtectionTiers[i].requiredScore;
    }
  }
  if (nextRequired <= currentRequired) return 1.0;
  return (score - currentRequired) / (nextRequired - currentRequired);
}
