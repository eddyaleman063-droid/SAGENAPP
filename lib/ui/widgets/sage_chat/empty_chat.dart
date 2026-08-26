import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/mascot_reaction_provider.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import '../common/sage_emotion_widget.dart';

class EmptyChat extends ConsumerWidget {
  const EmptyChat({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrideEmotion = ref.watch(
      mascotReactionProvider.select((r) => r.overrideEmotion),
    );
    final emotion = overrideEmotion ?? SageEmotion.curious;
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExcludeSemantics(
            child: SageEmotionWidget(
              emotion: emotion,
              size: 80,
              animated: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l?.chatEmptyTitle ?? l?.chatFallbackTitle ?? '',
            style: AppTextStyle.title.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl * 2),
            child: Text(
              l?.emptyChatSubtitle ?? l?.chatFallbackSubtitle ?? '',
              textAlign: TextAlign.center,
              style: AppTextStyle.subtitle.copyWith(
                color: context.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
