import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/common/tap_scale.dart';
import 'package:sagen/ui/widgets/profile/settings_sheet.dart';
import 'package:sagen/core/theme/app_colors.dart';

class SettingsActions extends ConsumerWidget {
  final bool dark;
  const SettingsActions({super.key, required this.dark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: TapScale(
            child: OutlinedButton.icon(
              onPressed: () => _showSettings(context, ref),
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: Text(l.settingsTitle),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textSecondary,
                side: BorderSide(color: context.subtleBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: TapScale(
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: Text(l.settingsLogout),
              style: OutlinedButton.styleFrom(
                foregroundColor: PremiumColors.danger,
                side: BorderSide(
                  color: PremiumColors.danger.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref) {
    ref.read(experienceServiceProvider).lightHaptic();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const SettingsSheet(),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    ref.read(experienceServiceProvider).lightHaptic();
    showDialog(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Text(l.settingsLogout),
          content: Text(l.settingsLogoutConfirm),
          actions: [
            Semantics(
              button: true,
              label: l.cancel,
              child: TextButton(
                onPressed: () {
                  ExperienceService.instance.lightHaptic();
                  context.pop();
                },
                child: Text(l.cancel),
              ),
            ),
            Semantics(
              button: true,
              label: l.settingsLogout,
              child: TextButton(
                onPressed: () async {
                  ref.read(experienceServiceProvider).lightHaptic();
                  context.pop();
                  ref.read(notificationServiceProvider).cancelAll();
                  await ref.read(authProvider.notifier).signOut();
                  if (ctx.mounted) {
                    ctx.goNamed('welcome');
                  }
                },
                child: Text(
                  l.settingsLogout,
                  style: AppTextStyle.body.copyWith(
                    color: PremiumColors.danger,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
