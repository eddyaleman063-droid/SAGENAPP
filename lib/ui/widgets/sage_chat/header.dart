import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/sage_ai_provider.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import '../common/sage_emotion_widget.dart';

class SageChatHeader extends ConsumerWidget {
  final bool dark;
  final SageAiChatState sage;
  final VoidCallback? onClear;
  const SageChatHeader({super.key, required this.dark, required this.sage, this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final mascotEmotion = sage.isBusy ? SageEmotion.thinking : SageEmotion.calm;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: PremiumColors.gradientSage, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Row(
        children: [
          SageEmotionWidget(
            emotion: mascotEmotion,
            size: 36,
            animated: true,
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.chatSageTutorLabel,
                style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                l.chatGuideSubtitle,
                style: AppTextStyle.label.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          if (sage.messages.isNotEmpty && !sage.isBusy)
            Semantics(
              button: true,
              label: l.chatClearAction,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l.chatClearTitle),
                      content: Text(l.chatClearMessage),
                      actions: [
                        Semantics(
                          button: true,
                          label: l.chatCancel,
                          child: TextButton(
                            onPressed: () => context.pop(),
                            child: Text(l.chatCancel),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: l.chatClearAction,
                          child: TextButton(
                            onPressed: () {
                              context.pop();
                              onClear?.call();
                            },
                            child: Text(l.chatClearAction),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(l.chatClearAction, style: AppTextStyle.caption.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
