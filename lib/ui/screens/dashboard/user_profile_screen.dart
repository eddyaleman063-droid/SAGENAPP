import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/shimmer_loading.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/core/theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;
  const UserProfileScreen({super.key, required this.uid});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: AppLocalizations.of(context)!.backButton,
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: context.iconSecondary),
            onPressed: () {
              ExperienceService.instance.lightHaptic();
              context.pop();
            },
            tooltip: AppLocalizations.of(context)!.backButton,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        key: ValueKey(_retryKey),
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          final l = AppLocalizations.of(context)!;
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: SageEmotionWidget(emotion: SageEmotion.worried),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l.profileError,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMd.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    button: true,
                    label: l.retry,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _retryKey++),
                      child: Text(l.retry),
                    ),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExcludeSemantics(
                      child: SageEmotionWidget(emotion: SageEmotion.worried),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.profileError,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMd.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Semantics(
                      button: true,
                      label: l.backButton,
                      child: ElevatedButton(
                        onPressed: () {
                          ExperienceService.instance.lightHaptic();
                          context.pop();
                        },
                        child: Text(l.backButton),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const _ProfileShimmer();
          }

          final raw = snapshot.data!.data();
          if (raw == null || raw is! Map<String, dynamic>) {
            return const _ProfileShimmer();
          }
          final data = raw;
          final firstName = (data['firstName'] is String)
              ? data['firstName'] as String
              : l.profileDefaultFirstName;
          final lastName = (data['lastName'] is String)
              ? data['lastName'] as String
              : l.profileDefaultLastName;
          final totalXp = (data['learning_total_xp'] is int)
              ? data['learning_total_xp'] as int
              : 0;
          final currentStreak = (data['currentStreak'] is int)
              ? data['currentStreak'] as int
              : 0;
          final level = (data['learning_level'] is int)
              ? data['learning_level'] as int
              : (totalXp ~/ 100) + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PremiumColors.splashBlue,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumColors.splashBlue.withValues(alpha: 0.25),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${firstName.isNotEmpty ? firstName[0] : '?'}${lastName.isNotEmpty ? lastName[0] : '?'}',
                      style: AppTextStyle.display.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.splashBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '$firstName $lastName',
                  style: AppTextStyle.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _StatRow(label: l.profileLevel, value: '$level'),
                _StatRow(label: l.profileTotalXp, value: '$totalXp'),
                _StatRow(
                  label: l.profileStreak,
                  value: l.streakDays(currentStreak),
                ),
              ],
            ).animate().fadeIn().slideY(begin: 0.05),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyle.body.copyWith(color: context.textTertiary),
          ),
          Text(
            value,
            style: AppTextStyle.body.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerLoading(width: 88, height: 88, borderRadius: AppRadius.pill),
          SizedBox(height: AppSpacing.lg),
          ShimmerLoading(width: 140, height: 20),
          SizedBox(height: AppSpacing.xl),
          ShimmerLoading(width: 180, height: 14),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(width: 120, height: 14),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(width: 150, height: 14),
        ],
      ),
    );
  }
}
