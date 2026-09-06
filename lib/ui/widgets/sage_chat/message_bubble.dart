import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/providers/mascot_reaction_provider.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/l10n/app_localizations.dart';

class MessageBubble extends ConsumerStatefulWidget {
  final ChatMessage message;
  final bool isUser;
  final bool isStreaming;
  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.isStreaming = false,
  });

  @override
  ConsumerState<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends ConsumerState<MessageBubble> {
  String _lastText = '';
  bool _lastDark = false;
  Widget? _cachedMarkdown;

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message.text != _lastText) {
      _lastText = widget.message.text;
      _cachedMarkdown = null;
    }
  }

  MarkdownStyleSheet _buildStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      p: AppTextStyle.body.copyWith(color: context.textPrimary),
      strong: AppTextStyle.body.copyWith(
        fontWeight: FontWeight.bold,
        color: context.textPrimary,
      ),
      em: AppTextStyle.body.copyWith(
        fontStyle: FontStyle.italic,
        color: context.textPrimary,
      ),
      code: AppTextStyle.subtitle.copyWith(
        fontFamily: 'monospace',
        color: context.isDark
            ? PremiumColors.codeTextDark
            : PremiumColors.codeTextLight,
        backgroundColor: context.subtle,
      ),
      codeblockDecoration: BoxDecoration(
        color: context.surfaceTinted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      listBullet: AppTextStyle.body.copyWith(color: context.textPrimary),
    );
  }

  Widget _buildMarkdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark != _lastDark) {
      _lastDark = isDark;
      _cachedMarkdown = null;
    }
    _cachedMarkdown ??= MarkdownBody(
      data: widget.message.text,
      styleSheet: _buildStyleSheet(context),
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
        }
      },
    );
    return _cachedMarkdown!;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return RepaintBoundary(
      child: Semantics(
        container: true,
        label:
            '${widget.isUser ? l.messageFromYou : l.messageFromSage}: ${widget.message.text}',
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            mainAxisAlignment: widget.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isUser) ...[
                ExcludeSemantics(
                  child: widget.isStreaming
                      ? Consumer(
                          builder: (context, ref, _) {
                            final emotion = ref.watch(
                              mascotReactionProvider.select(
                                (r) =>
                                    r.overrideEmotion ?? SageEmotion.thinking,
                              ),
                            );
                            return SageEmotionWidget(
                              emotion: emotion,
                              size: 28,
                              animated: true,
                            );
                          },
                        )
                      : const SageEmotionWidget(
                          emotion: SageEmotion.calm,
                          size: 28,
                          animated: false,
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: widget.isUser
                      ? () {
                          Clipboard.setData(
                            ClipboardData(text: widget.message.text),
                          );
                          SagenNotification.show(
                            context,
                            message: l.copiedToClipboard,
                            type: NotificationType.success,
                          );
                          ExperienceService.instance.lightHaptic();
                        }
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          widget.isUser ? AppRadius.xl : AppRadius.sm,
                        ),
                        topRight: const Radius.circular(AppRadius.xl),
                        bottomLeft: const Radius.circular(AppRadius.xl),
                        bottomRight: Radius.circular(
                          widget.isUser ? AppRadius.sm : AppRadius.xl,
                        ),
                      ),
                      gradient: widget.isUser
                          ? const LinearGradient(
                              colors: PremiumColors.gradientSage,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: widget.isUser ? null : context.surfaceCard,
                    ),
                    child: widget.isUser
                        ? Text(
                            widget.message.text,
                            style: AppTextStyle.body.copyWith(
                              color: Colors.white,
                            ),
                          )
                        : widget.isStreaming
                        ? Text(
                            widget.message.text,
                            style: AppTextStyle.body.copyWith(
                              color: context.textPrimary,
                            ),
                          )
                        : _buildMarkdown(context),
                  ),
                ),
              ),
              if (widget.isUser) const SizedBox(width: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}
