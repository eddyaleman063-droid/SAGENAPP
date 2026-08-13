import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/experience_service.dart';
import '../../../services/sage_emotion_service.dart';
import '../../widgets/common/sage_emotion_widget.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationOptInScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const NotificationOptInScreen({
    super.key,
    required this.onContinue,
    this.onBack,
  });

  Future<void> _requestPermission() async {
    final plugin = FlutterLocalNotificationsPlugin();
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  button: true,
                  label: AppLocalizations.of(context)!.backButton,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      ExperienceService.instance.lightHaptic();
                      (onBack ?? () => context.pop())();
                    },
                    tooltip: AppLocalizations.of(context)!.backButton,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              const SizedBox(
                width: 120,
                height: 120,
                child: SageEmotionWidget(emotion: SageEmotion.happy, size: 120),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                AppLocalizations.of(context)!.onbNotifTitle,
                style: AppTextStyle.headline.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppLocalizations.of(context)!.onbNotifDesc,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.onbNotifTitle,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ExperienceService.instance.mediumHaptic();
                    _requestPermission();
                    onContinue();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: PremiumColors.primaryAccent,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumColors.primaryDark.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.notificationsTitle.toUpperCase(),
                        style: AppTextStyle.titleSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.onbNotifSkip,
                child: TextButton(
                  onPressed: () {
                    ExperienceService.instance.lightHaptic();
                    onContinue();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.onbNotifSkip,
                    style: AppTextStyle.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
            ],
          ).animate().fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }
}
