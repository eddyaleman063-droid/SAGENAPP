import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/update_entry.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UpdatesScreen extends ConsumerWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final entries = UpdateEntry.all();
    final grouped = _groupByMonth(entries, l);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l.updatesTitle,
          style: AppTextStyle.title.copyWith(
            color: context.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: grouped.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.update_rounded, size: 48, color: context.textTertiary),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l.emptyUpdates,
                    style: AppTextStyle.body.copyWith(color: context.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 80),
        itemCount: grouped.length,
        itemBuilder: (context, i) {
          final month = grouped.keys.elementAt(i);
          final items = grouped[month]!;
          return _MonthSection(key: ValueKey('update_$i'), month: month, entries: items);
        },
      ).animate().fadeIn().slideY(begin: 0.05),
    );
  }

  Map<String, List<UpdateEntry>> _groupByMonth(List<UpdateEntry> entries, AppLocalizations l) {
    final map = <String, List<UpdateEntry>>{};
    for (final e in entries) {
      final key = _monthKey(e.date, l);
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  String _monthKey(DateTime d, AppLocalizations l) {
    final months = [
      l.monthJan, l.monthFeb, l.monthMar, l.monthApr, l.monthMay, l.monthJun,
      l.monthJul, l.monthAug, l.monthSep, l.monthOct, l.monthNov, l.monthDec,
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _MonthSection extends StatelessWidget {
  final String month;
  final List<UpdateEntry> entries;

  const _MonthSection({super.key, required this.month, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xxs),
          child: Text(
            month,
            style: AppTextStyle.title.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ),
        ...entries.map((e) => _UpdateCard(entry: e)),
      ],
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final UpdateEntry entry;

  const _UpdateCard({required this.entry});

  Color _typeColor(BuildContext context) {
    switch (entry.type) {
      case UpdateType.feature:
        return PremiumColors.heatmapMedium;
      case UpdateType.improvement:
        return PremiumColors.updateImprovement;
      case UpdateType.fix:
        return PremiumColors.updateFix;
    }
  }

  IconData get _icon {
    switch (entry.type) {
      case UpdateType.feature:
        return Icons.auto_awesome_rounded;
      case UpdateType.improvement:
        return Icons.trending_up_rounded;
      case UpdateType.fix:
        return Icons.build_rounded;
    }
  }

  String _typeLabel(AppLocalizations l) {
    switch (entry.type) {
      case UpdateType.feature:
        return l.updateTypeFeature;
      case UpdateType.improvement:
        return l.updateTypeImprovement;
      case UpdateType.fix:
        return l.updateTypeFix;
    }
  }

  String _formattedDate(AppLocalizations l) {
    final days = [
      l.dayAbbrMon, l.dayAbbrTue, l.dayAbbrWed,
      l.dayAbbrThu, l.dayAbbrFri, l.dayAbbrSat, l.dayAbbrSun,
    ];
    return '${days[entry.date.weekday - 1]}, ${entry.date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final typeColor = _typeColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: context.shimmerBase,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: ExcludeSemantics(
                child: Icon(_icon, color: typeColor, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      if (entry.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            l.newBadge,
                            style: AppTextStyle.micro.copyWith(
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    entry.description,
                      style: AppTextStyle.subtitle.copyWith(
                        color: context.textSecondary,
                        height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        _typeLabel(l),
                        style: AppTextStyle.tiny.copyWith(
                          fontWeight: FontWeight.w600,
                          color: typeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'v${entry.version}',
                        style: AppTextStyle.label.copyWith(
                          color: context.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formattedDate(l),
                        style: AppTextStyle.label.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
