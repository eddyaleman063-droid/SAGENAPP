import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';

class WeeklyCalendarWidget extends StatelessWidget {
  final int currentStreak;
  final int streakGoal;
  final Map<String, bool> weekDays;
  final bool isDark;

  const WeeklyCalendarWidget({
    super.key,
    required this.currentStreak,
    required this.streakGoal,
    required this.weekDays,
    required this.isDark,
  });

  static List<String> dayLabels(AppLocalizations l) => [
    l.dayShortMon, l.dayShortTue, l.dayShortWed, l.dayShortThu,
    l.dayShortFri, l.dayShortSat, l.dayShortSun,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final date = startOfWeek.add(Duration(days: i));
            final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            final isCompleted = weekDays[key] ?? false;
            final isToday = date.year == today.year && date.month == today.month && date.day == today.day;

            return _DayCircle(
              label: dayLabels(l)[i],
              isCompleted: isCompleted,
              isToday: isToday,
              isDark: isDark,
              dayNumber: date.day,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l.streakCurrentProgress(currentStreak, streakGoal),
          style: AppTextStyle.bodyMd.copyWith(fontWeight: FontWeight.w600,
            color: context.textSecondary),
        ),
      ],
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isToday;
  final bool isDark;
  final int dayNumber;

  const _DayCircle({
    required this.label,
    required this.isCompleted,
    required this.isToday,
    required this.isDark,
    required this.dayNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? PremiumColors.streakOrange
                : isToday
                    ? PremiumColors.splashBlue.withValues(alpha: 0.2)
                    : Colors.transparent,
            border: isToday && !isCompleted
                ? Border.all(color: PremiumColors.splashBlue, width: 2)
                : null,
          ),
          child: isCompleted
              ? const ExcludeSemantics(
                  child: Icon(Icons.check, size: 18, color: Colors.white),
                )
              : Center(
                  child: Text(
                    label,
                    style: AppTextStyle.caption.copyWith(fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday
                          ? PremiumColors.splashBlue
                          : context.textTertiary),
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          '$dayNumber',
          style: AppTextStyle.tiny.copyWith(color: context.textTertiary),
        ),
      ],
    );
  }
}
