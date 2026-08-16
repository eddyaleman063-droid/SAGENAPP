import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/profile/flex_card_widget.dart';
import '../../../services/analytics_service.dart';

class FlexCardShareSheet extends ConsumerStatefulWidget {
  final String displayName;
  final String? photoUrl;
  final int level;
  final int xp;
  final int streak;

  const FlexCardShareSheet({
    super.key,
    required this.displayName,
    this.photoUrl,
    required this.level,
    required this.xp,
    required this.streak,
  });

  @override
  ConsumerState<FlexCardShareSheet> createState() => _FlexCardShareSheetState();
}

class _FlexCardShareSheetState extends ConsumerState<FlexCardShareSheet> {
  final _flexCardKey = GlobalKey<FlexCardWidgetState>();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      margin: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        color: dark ? PremiumColors.deepBackground : Colors.white,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: context.subtle,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: FlexCardWidget(
                key: _flexCardKey,
                displayName: widget.displayName,
                photoUrl: widget.photoUrl,
                level: widget.level,
                xp: widget.xp,
                streak: widget.streak,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)?.shareProfile ?? '',
                child: ElevatedButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: _sharing
                      ? const ExcludeSemantics(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    _sharing ? l.rankingSharing : l.rankingShareButton,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.splashBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: PremiumColors.splashBlue
                        .withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    final bytes = await _flexCardKey.currentState?.capture();
    if (bytes != null && mounted) {
      AnalyticsService.instance.trackFlexCardShared('profile');
      await ref
          .read(shareServiceProvider)
          .shareImage(
            bytes,
            text: AppLocalizations.of(context)?.flexCardJoinAlliance,
            source: 'profile',
          );
    }
    if (mounted) {
      context.pop();
    }
  }
}
