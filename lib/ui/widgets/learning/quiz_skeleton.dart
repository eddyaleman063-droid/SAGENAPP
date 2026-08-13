import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import '../shimmer_loading.dart';
import '../shimmer_scope.dart';

class QuizSkeleton extends StatelessWidget {
  const QuizSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildOptionCard(context, 0.85),
                  _buildOptionCard(context, 0.72),
                  _buildOptionCard(context, 0.78),
                  _buildOptionCard(context, 0.65),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ShimmerLoading(
                width: 36,
                height: 36,
                borderRadius: 10,
                baseColor: context.shimmerBase,
                highlightColor: context.shimmerHighlight,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ShimmerLoading(
                  height: 14,
                  width: 160,
                  baseColor: context.shimmerBase,
                  highlightColor: context.shimmerHighlight,
                ),
              ),
              ShimmerLoading(
                height: 12,
                width: 40,
                baseColor: context.shimmerBase,
                highlightColor: context.shimmerHighlight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ShimmerLoading(
            height: 6,
            width: double.infinity,
            borderRadius: 6,
            baseColor: context.shimmerBase,
            highlightColor: context.shimmerHighlight,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.shimmerBase,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            height: 22,
            width: 100,
            borderRadius: 8,
            baseColor: context.shimmerBase,
            highlightColor: context.shimmerHighlight,
          ),
          const SizedBox(height: AppSpacing.lg),
          ShimmerLoading(
            height: 16,
            width: double.infinity,
            baseColor: context.shimmerBase,
            highlightColor: context.shimmerHighlight,
          ),
          const SizedBox(height: AppSpacing.md),
          ShimmerLoading(
            height: 16,
            width: 200,
            baseColor: context.shimmerBase,
            highlightColor: context.shimmerHighlight,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, double widthFactor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.shimmerBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.subtleBorder),
        ),
        child: Row(
          children: [
            ShimmerLoading(
              width: 28,
              height: 28,
              borderRadius: 8,
              baseColor: context.shimmerBase,
              highlightColor: context.shimmerHighlight,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: widthFactor,
                child: ShimmerLoading(
                  height: 14,
                  baseColor: context.shimmerBase,
                  highlightColor: context.shimmerHighlight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
