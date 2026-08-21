import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/providers/sage_ai_provider.dart';
import 'empty_chat.dart';
import 'message_bubble.dart';

class MessageList extends StatefulWidget {
  final SageAiChatState sage;
  final ScrollController scrollCtrl;
  final bool dark;
  const MessageList({
    super.key,
    required this.sage,
    required this.scrollCtrl,
    required this.dark,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool _scrollScheduled = false;

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sage.messages.length != oldWidget.sage.messages.length ||
        widget.sage.streamingText != oldWidget.sage.streamingText) {
      _scheduleScroll();
    }
  }

  void _scheduleScroll() {
    if (_scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (mounted && widget.scrollCtrl.hasClients) {
        widget.scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.sage.messages;

    if (messages.isEmpty) {
      return const EmptyChat();
    }

    final showStreaming =
        widget.sage.isStreaming && widget.sage.streamingText.isNotEmpty;
    final extraItem = showStreaming ? 1 : 0;

    return RepaintBoundary(
      child: ListView.builder(
        controller: widget.scrollCtrl,
        reverse: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.md,
        ),
        itemCount: messages.length + extraItem,
        itemBuilder: (_, i) {
          if (showStreaming && i == 0) {
            return MessageBubble(
              key: const ValueKey('streaming'),
              message: ChatMessage(
                role: ChatRole.assistant,
                text: widget.sage.streamingText,
                time: DateTime.now(),
              ),
              isUser: false,
            );
          }
          final idx = showStreaming ? i - 1 : i;
          if (idx >= messages.length) return const SizedBox.shrink();
          final msg = messages[messages.length - 1 - idx];
          final isUser = msg.role == ChatRole.user;

          return _AnimatedMessageBubble(
            index: idx,
            child: MessageBubble(
              key: ValueKey('msg_${messages.length - 1 - idx}'),
              message: msg,
              isUser: isUser,
            ),
          );
        },
      ),
    );
  }
}

class _AnimatedMessageBubble extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedMessageBubble({required this.index, required this.child});

  @override
  State<_AnimatedMessageBubble> createState() => _AnimatedMessageBubbleState();
}

class _AnimatedMessageBubbleState extends State<_AnimatedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    final delay = widget.index < 3 ? widget.index * 80 : 0;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(opacity: _fadeAnim, child: widget.child),
    );
  }
}
