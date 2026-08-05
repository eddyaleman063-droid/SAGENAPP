import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../services/sage_emotion_service.dart';
import '../../widgets/weekly_calendar_widget.dart';
import 'package:sagen/l10n/app_localizations.dart';

class CommitmentSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback onCommit;

  const CommitmentSelectionScreen({super.key, required this.onCommit});

  @override
  ConsumerState<CommitmentSelectionScreen> createState() => _CommitmentSelectionScreenState();
}

class _CommitmentSelectionScreenState extends ConsumerState<CommitmentSelectionScreen> {
  int? _selectedDays;
  late final Map<String, bool> _weekDays;

  static const _options = [7, 14, 30, 50];

  @override
  void initState() {
    super.initState();
    _weekDays = _buildCurrentWeekDays();
  }

  Map<String, bool> _buildCurrentWeekDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final result = <String, bool>{};
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final key = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      result[key] = date.isBefore(today);
    }
    return result;
  }

  String _goalText(int days, AppLocalizations l) {
    if (days == 7) return l.commit1Week;
    if (days == 14) return l.commit2Weeks;
    if (days == 30) return l.commit1Month;
    return l.commitDays(50);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: dark ? PremiumColors.deepBackground : PremiumColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),
              const Center(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: SageEmotionWidget(
                    emotion: SageEmotion.thinking,
                    size: 90,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.commitChooseGoal,
                style: AppTextStyle.headline.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.commitChooseGoalDesc,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ..._options.map((days) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Semantics(
                      button: true,
                      label: l.commitDays(days),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(experienceServiceProvider).lightHaptic();
                          setState(() => _selectedDays = days);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            color: _selectedDays == days
                                ? PremiumColors.streakOrange.withValues(alpha: 0.1)
                                : dark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.black.withValues(alpha: 0.03),
                            border: Border.all(
                              color: _selectedDays == days
                                  ? PremiumColors.streakOrange
                                  : dark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.06),
                              width: _selectedDays == days ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedDays == days
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 22,
                                color: _selectedDays == days
                                    ? PremiumColors.streakOrange
                                    : dark
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.commitDays(days),
                                      style: AppTextStyle.titleSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _selectedDays == days
                                            ? PremiumColors.streakOrange
                                            : dark
                                                ? Colors.white.withValues(alpha: 0.85)
                                                : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      _goalText(days, l),
                                      style: AppTextStyle.caption.copyWith(
                                        color: context.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedDays == days)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    color: PremiumColors.streakOrange,
                                  ),
                                  child: Text(
                                    l.commitSelected,
                                    style: AppTextStyle.micro.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
              if (_selectedDays != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    color: context.surfaceTinted,
                    border: Border.all(
                      color: context.subtleBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l.commitYourGoal(_selectedDays!),
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: PremiumColors.streakOrange,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      WeeklyCalendarWidget(
                        currentStreak: 0,
                        streakGoal: _selectedDays!,
                        weekDays: _weekDays,
                        isDark: dark,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 1),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Semantics(
                  button: true,
                  label: l.commitButton,
                  child: ElevatedButton(
                    onPressed: _selectedDays != null ? widget.onCommit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.streakOrange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: context.surfaceTinted,
                      disabledForegroundColor: context.textDisabled,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      elevation: _selectedDays != null ? 4 : 0,
                    ),
                    child: Text(
                      l.commitButton,
                      style: AppTextStyle.bodyMd.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ).animate().fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }
}
