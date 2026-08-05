import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import '../common/sage_emotion_widget.dart';

class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            const ExcludeSemantics(
              child: SageEmotionWidget(
                emotion: SageEmotion.curious,
                size: 80,
                animated: true,
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppLocalizations.of(context)?.chatEmptyTitle ?? AppLocalizations.of(context)?.chatFallbackTitle ?? '',
            style: AppTextStyle.title.copyWith(fontWeight: FontWeight.bold,
              color: context.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl * 2),
            child: Text(
              AppLocalizations.of(context)?.emptyChatSubtitle ?? AppLocalizations.of(context)?.chatFallbackSubtitle ?? '',
              textAlign: TextAlign.center,
              style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}
