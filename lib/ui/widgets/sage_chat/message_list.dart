import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/providers/providers.dart';
import 'empty_chat.dart';
import 'message_bubble.dart';

class MessageList extends ConsumerStatefulWidget {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final ScrollController scrollCtrl;
  const MessageList({
    super.key,
    required this.messages,
    required this.isStreaming,
    required this.scrollCtrl,
  });

  @override
  ConsumerState<MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  bool _scrollScheduled = false;

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      _scheduleScroll();
    }
  }

  void _scheduleScroll() {
    if (_scrollScheduled) return;
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (mounted && widget.scrollCtrl.hasClients) {
        final pos = widget.scrollCtrl.position;
        if (pos.maxScrollExtent > 0 &&
            widget.scrollCtrl.offset > pos.maxScrollExtent - 64) {
          widget.scrollCtrl.animateTo(
            pos.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;

    if (messages.isEmpty) {
      return const EmptyChat();
    }

    final streamingText = ref.watch(
      sageAiProvider.select((s) => s.streamingText),
    );
    final showStreaming = widget.isStreaming && streamingText.isNotEmpty;
    final extraItem = showStreaming ? 1 : 0;
    final streamingTime = showStreaming ? DateTime.now() : DateTime(0);

    if (showStreaming) _scheduleScroll();

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
            return RepaintBoundary(
              child: MessageBubble(
                key: const ValueKey('streaming'),
                message: ChatMessage(
                  role: ChatRole.assistant,
                  text: streamingText,
                  time: streamingTime,
                ),
                isUser: false,
                isStreaming: true,
              ),
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
  Timer? _startTimer;
  CurvedAnimation? _slideCurve;
  CurvedAnimation? _fadeCurve;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    if (widget.index < 3) {
      final delay = widget.index * 80;
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );
      _slideCurve = CurvedAnimation(parent: _ctrl!, curve: Curves.easeOut);
      _fadeCurve = CurvedAnimation(parent: _ctrl!, curve: Curves.easeIn);
      _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(_slideCurve!);
      _fadeAnim = _fadeCurve!;
      _startTimer = Timer(Duration(milliseconds: delay), () {
        if (mounted) _ctrl?.forward();
      });
    } else {
      _slideAnim = const AlwaysStoppedAnimation(Offset.zero);
      _fadeAnim = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _ctrl?.dispose();
    _slideCurve?.dispose();
    _fadeCurve?.dispose();
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
