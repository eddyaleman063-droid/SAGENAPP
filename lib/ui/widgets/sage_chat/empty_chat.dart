import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/mascot_reaction_provider.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import '../common/sage_emotion_widget.dart';

class EmptyChat extends ConsumerWidget {
  final ValueChanged<String>? onSuggestionTap;
  const EmptyChat({super.key, this.onSuggestionTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrideEmotion = ref.watch(
      mascotReactionProvider.select((r) => r.overrideEmotion),
    );
    final emotion = overrideEmotion ?? SageEmotion.curious;
    final l = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SageEmotionWidget(emotion: emotion, size: 80, animated: true)
                .animate()
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  delay: 100.ms,
                  duration: 500.ms,
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l?.chatEmptyTitle ?? l?.chatFallbackTitle ?? '',
              style: AppTextStyle.title.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                l?.emptyChatSubtitle ?? l?.chatFallbackSubtitle ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyle.subtitle.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
            const SizedBox(height: AppSpacing.xxl),
            if (onSuggestionTap != null)
              _SuggestionChips(
                    suggestions: [
                      if (l != null) l.chatSuggestionHelpLesson,
                      if (l != null) l.chatSuggestionExplainConcept,
                      if (l != null) l.chatSuggestionQuizMe,
                    ],
                    onTap: onSuggestionTap!,
                  )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideY(begin: 0.1, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;
  const _SuggestionChips({required this.suggestions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < suggestions.length; i++)
          Semantics(
            button: true,
            label: suggestions[i],
            child:
                GestureDetector(
                      onTap: () {
                        ExperienceService.instance.lightHaptic();
                        onTap(suggestions[i]);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(
                            color: PremiumColors.primaryAccent.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Text(
                          suggestions[i],
                          style: AppTextStyle.bodyMd.copyWith(
                            color: PremiumColors.primaryAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 600 + i * 100),
                      duration: 300.ms,
                    )
                    .slideY(
                      begin: 0.1,
                      delay: Duration(milliseconds: 600 + i * 100),
                      duration: 300.ms,
                    ),
          ),
      ],
    );
  }
}
