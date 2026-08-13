import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_dynamic_icon_plus/flutter_dynamic_icon_plus.dart';
import '../models/sagen_pass.dart';
import '../providers/streak_provider.dart';
import 'app_logger.dart';

enum SageAppIcon {
  sageDefault,
  sageSleeping,
  sageCurious,
  sageAnnoyed,
  sageFurious,
  sageCrying,
  sageFrozen,
  sageOnFire,
  sageGolden,
}

const Map<SageAppIcon, String> _iconNames = {
  SageAppIcon.sageDefault: 'sage_default',
  SageAppIcon.sageSleeping: 'sage_sleeping',
  SageAppIcon.sageCurious: 'sage_curious',
  SageAppIcon.sageAnnoyed: 'sage_annoyed',
  SageAppIcon.sageFurious: 'sage_furious',
  SageAppIcon.sageCrying: 'sage_crying',
  SageAppIcon.sageFrozen: 'sage_frozen',
  SageAppIcon.sageOnFire: 'sage_onfire',
  SageAppIcon.sageGolden: 'sage_golden',
};

/// Manages dynamic app icon changes based on user streak/pass.
class IconManager {
  SageAppIcon? _lastSetIcon;

  static final IconManager instance = IconManager._();

  IconManager._();

  void evaluateAndApply(StreakState streak, SagenPass pass) {
    final icon = _evaluateIcon(streak, pass);
    if (icon == _lastSetIcon) return;
    unawaited(_applyIcon(icon));
  }

  @visibleForTesting
  SageAppIcon evaluateIconForTesting(StreakState streak, SagenPass pass, {DateTime? now}) {
    return _evaluateIcon(streak, pass, now: now);
  }

  SageAppIcon _evaluateIcon(StreakState streak, SagenPass pass, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final hour = current.hour;

    // Frozen with protector active
    if (streak.isStreakFrozen) return SageAppIcon.sageFrozen;

    // Streak lost (0 days)
    if (streak.currentStreak == 0) return SageAppIcon.sageCrying;

    // 100+ day streak — on fire
    if (streak.currentStreak >= 100) {
      if (_isPremium(pass)) return SageAppIcon.sageGolden;
      return SageAppIcon.sageOnFire;
    }

    // Premium golden for high-level pass users with active streak
    if (_isPremium(pass) && streak.currentStreak >= 7) {
      return SageAppIcon.sageGolden;
    }

    // Time-based
    if (hour >= 0 && hour < 5) return SageAppIcon.sageSleeping;
    if (hour >= 12 && hour < 14) return SageAppIcon.sageCurious;

    // At-risk reminders
    if (streak.status.isAtRisk) {
      if (hour >= 18 && hour < 22) return SageAppIcon.sageAnnoyed;
      if (hour >= 22 || hour < 5) return SageAppIcon.sageFurious;
    }

    return SageAppIcon.sageDefault;
  }

  bool _isPremium(SagenPass pass) => pass.currentLevel >= 25;

  Future<void> _applyIcon(SageAppIcon icon) async {
    try {
      if (await FlutterDynamicIconPlus.supportsAlternateIcons) {
        if (icon == SageAppIcon.sageDefault) {
          await FlutterDynamicIconPlus.setAlternateIconName();
        } else {
          await FlutterDynamicIconPlus.setAlternateIconName(
            iconName: _iconNames[icon] ?? _iconNames[SageAppIcon.sageDefault]!,
            blacklistBrands: ['Redmi'],
            blacklistManufactures: ['Xiaomi'],
            blacklistModels: ['Redmi 200A'],
          );
        }
        _lastSetIcon = icon;
      }
    } catch (e) {
      // Icon changes can fail on certain Android OEMs — log but don't crash
      AppLogger().warning('IconManager: icon change failed for ${_iconNames[icon]}: $e');
    }
  }

  void reset() {
    _lastSetIcon = null;
  }
}
