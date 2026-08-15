import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            ExcludeSemantics(
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: PremiumColors.gradientSage),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Colors.white,
                ),
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
                    isUser ? AppRadius.xl : AppRadius.sm,
                  ),
                  topRight: const Radius.circular(AppRadius.xl),
                  bottomLeft: const Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(
                    isUser ? AppRadius.sm : AppRadius.xl,
                  ),
                ),
                gradient: isUser
                    ? const LinearGradient(
                        colors: PremiumColors.gradientSage,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : context.surfaceCard,
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: AppTextStyle.body.copyWith(color: Colors.white),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: AppTextStyle.body.copyWith(
                          color: context.textPrimary,
                        ),
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
                        listBullet: AppTextStyle.body.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null) {
                          launchUrl(
                            Uri.parse(href),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}
