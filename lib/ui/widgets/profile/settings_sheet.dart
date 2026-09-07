import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/profile/language_selector.dart';
import 'package:sagen/ui/widgets/profile/font_size_selector.dart';
import 'package:sagen/ui/widgets/profile/theme_selector.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:sagen/services/experience_service.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late final ExperienceService _exp;

  @override
  void initState() {
    super.initState();
    // NUEVO-fix (ronda 17): escuchamos el ChangeNotifier directamente en vez de
    // depender de un ChangeNotifierProvider (que haría dispose del singleton).
    _exp = ref.read(experienceServiceProvider);
    _exp.addListener(_onExperienceChanged);
  }

  @override
  void dispose() {
    _exp.removeListener(_onExperienceChanged);
    super.dispose();
  }

  void _onExperienceChanged() {
    if (mounted) setState(() {});
  }

  void _toggle(
    Future<void> Function(bool value) setter,
    bool next,
    String setting,
  ) {
    _exp.mediumHaptic();
    unawaited(setter(next));
    AnalyticsService.instance.track(
      AnalyticEvent.settingsChange,
      properties: {'setting': setting, 'value': next.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final l = AppLocalizations.of(context)!;

    // NUEVO-fix (ronda 17): el panel de experiencia por fin expone los toggles
    // de sonido/vibración/reducir animaciones que el servicio ya soportaba pero
    // no tenían UI (accesibilidad: silenciar sonidos, reducir animaciones).

    return Container(
      margin: const EdgeInsets.all(AppSpacing.xxl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        color: context.surfaceCard,
        boxShadow: AppShadows.card(color: context.subtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: context.subtle,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 18,
                color: PremiumColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.settingsTitle,
                style: AppTextStyle.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          ThemeSelector(dark: dark),
          const SizedBox(height: AppSpacing.lg),
          const LanguageSelector(),
          const SizedBox(height: AppSpacing.lg),
          // NUEVO-fix (ronda 18): selector de tamaño de fuente reactivo en vivo.
          FontSizeSelector(dark: dark),
          const SizedBox(height: AppSpacing.lg),
          _ExperienceSwitch(
            value: _exp.soundEnabled,
            icon: Icons.volume_up_rounded,
            label: l.sounds,
            subtitle: l.soundsSubtitle,
            onChanged: (v) => _toggle(_exp.setSoundEnabled, v, 'sound'),
          ),
          _ExperienceSwitch(
            value: _exp.hapticEnabled,
            icon: Icons.vibration_rounded,
            label: l.hapticFeedback,
            subtitle: l.hapticSubtitle,
            onChanged: (v) => _toggle(_exp.setHapticEnabled, v, 'haptics'),
          ),
          _ExperienceSwitch(
            value: _exp.reduceAnimations,
            icon: Icons.animation_rounded,
            label: l.reduceAnimations,
            subtitle: l.reduceAnimationsSubtitle,
            onChanged: (v) =>
                _toggle(_exp.setReduceAnimations, v, 'reduce_animations'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}

class _ExperienceSwitch extends StatelessWidget {
  const _ExperienceSwitch({
    required this.value,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final IconData icon;
  final String label;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.subtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: PremiumColors.primary,
        secondary: Icon(icon, size: 20, color: context.iconSecondary),
        title: Text(
          label,
          style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyle.label.copyWith(color: context.textSecondary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
      ),
    );
  }
}
