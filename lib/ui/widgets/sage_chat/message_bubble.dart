import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';

class MessageBubble extends StatefulWidget {
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String _lastText = '';
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
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          mainAxisAlignment: widget.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isUser) ...[
              const ExcludeSemantics(
                child: SageEmotionWidget(
                  emotion: SageEmotion.calm,
                  size: 28,
                  animated: false,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
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
                        style: AppTextStyle.body.copyWith(color: Colors.white),
                      )
                    : _buildMarkdown(context),
              ),
            ),
            if (widget.isUser) const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}
