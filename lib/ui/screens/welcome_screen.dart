import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sagen_touch_response.dart';
import 'package:sagen/providers/providers.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              children: [
                // ── Top block: robot + brand ──────────────────────
                RepaintBoundary(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const RepaintBoundary(
                          child: SageEmotionWidget(
                            emotion: SageEmotion.excitedWave,
                            size: 160,
                            animated: true,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.appName,
                          style: AppTextStyle.display.copyWith(
                            fontWeight: FontWeight.w900,
                            color: PremiumColors.primaryAccent.withValues(
                              alpha: 0.95,
                            ),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Tagline ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.huge,
                  ),
                  child: Text(
                    l.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),
                // ── Buttons ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      Semantics(
                        button: true,
                        label: l.welcomeStartButton,
                        child: SagenTouchResponse(
                          onTap: () {
                            context.pushNamed('onboarding');
                          },
                          child: Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              color: PremiumColors.primaryAccent,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumColors.primaryAccent.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l.welcomeStartButton,
                                    style: AppTextStyle.bodyLg.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Semantics(
                        button: true,
                        label: l.welcomeLoginButton,
                        child: SagenTouchResponse(
                          onTap: () {
                            context.pushNamed('login');
                          },
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                l.welcomeLoginButton,
                                style: AppTextStyle.title.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.80),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // ── Demo mode button (offline, for live presentation) ──
                      const SizedBox(height: AppSpacing.lg),
                      Semantics(
                        button: true,
                        label: l.demoModeLabel,
                        child: SagenTouchResponse(
                          onTap: () {
                            ref.read(authProvider.notifier).enterDemoMode();
                            context.go('/main');
                          },
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wifi_off_rounded,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    AppLocalizations.of(
                                          context,
                                        )?.demoModeLabel ??
                                        '',
                                    style: AppTextStyle.label.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
