import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? PremiumColors.textLight : PremiumColors.textDark;
    final textSecondary = isDark
        ? PremiumColors.textLight.withValues(alpha: 0.7)
        : PremiumColors.textDark.withValues(alpha: 0.7);

    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: l.backButton,
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: textSecondary),
            onPressed: () {
              ExperienceService.instance.lightHaptic();
              context.pop();
            },
            tooltip: l.backButton,
          ),
        ),
        title: Text(
          l.privacyPolicy,
          style: AppTextStyle.title.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [PremiumColors.deepBackground, PremiumColors.darkBg]
                : [PremiumColors.lightBg, PremiumColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l.privacyPolicyTitle,
                  style: AppTextStyle.headlineMedium.copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.privacyPolicyLastUpdate,
                  style: AppTextStyle.caption.copyWith(color: textSecondary),
                ),
                const SizedBox(height: AppSpacing.xxl),
                _buildSection(
                  context,
                  title: l.privacyPolicySection1Title,
                  body: l.privacyPolicySection1Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection2Title,
                  body: l.privacyPolicySection2Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection3Title,
                  body: l.privacyPolicySection3Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection4Title,
                  body: l.privacyPolicySection4Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection5Title,
                  body: l.privacyPolicySection5Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection6Title,
                  body: l.privacyPolicySection6Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection7Title,
                  body: l.privacyPolicySection7Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection8Title,
                  body: l.privacyPolicySection8Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                _buildSection(
                  context,
                  title: l.privacyPolicySection9Title,
                  body: l.privacyPolicySection9Body,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ).animate().fadeIn().slideY(begin: 0.05),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String body,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.titleSmall.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTextStyle.body.copyWith(
              color: textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
