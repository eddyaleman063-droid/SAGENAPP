import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/models/chat_message.dart';
import 'empty_chat.dart';
import 'message_bubble.dart';

class MessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String streamingText;
  final ScrollController scrollCtrl;
  const MessageList({
    super.key,
    required this.messages,
    required this.isStreaming,
    required this.streamingText,
    required this.scrollCtrl,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  bool _scrollScheduled = false;

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length ||
        widget.streamingText != oldWidget.streamingText) {
      _scheduleScroll();
    }
  }

  void _scheduleScroll() {
    if (_scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (mounted &&
          widget.scrollCtrl.hasClients &&
          widget.scrollCtrl.offset < 64) {
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
    final messages = widget.messages;

    if (messages.isEmpty) {
      return const EmptyChat();
    }

    final showStreaming = widget.isStreaming && widget.streamingText.isNotEmpty;
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
                text: widget.streamingText,
                time: DateTime.now(),
              ),
              isUser: false,
              isStreaming: true,
            );
          }
          final idx = showStreaming ? i - 1 : i;
          if (idx >= messages.length) return const SizedBox.shrink();
          final msg = messages[messages.length - 1 - idx];
          final isUser = msg.role == ChatRole.user;

          return _AnimatedMessageBubble(
            index: idx,
            child: MessageBubble(
              key: ValueKey(
                'msg_${msg.time.microsecondsSinceEpoch}_${msg.role.name}',
              ),
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
  AnimationController? _ctrl;
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
    ).animate(CurvedAnimation(parent: _ctrl!, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl!, curve: Curves.easeIn);
    _ctrl!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _ctrl?.dispose();
        _ctrl = null;
      }
    });
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl?.forward();
    });
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    _ctrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ctrl == null) return widget.child;
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(opacity: _fadeAnim, child: widget.child),
    );
  }
}
