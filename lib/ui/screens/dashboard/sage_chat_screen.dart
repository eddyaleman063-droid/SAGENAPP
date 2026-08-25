import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/chat_message.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/analytics_service.dart';

import '../../widgets/sage_chat/locked_gatekeeper.dart';
import '../../widgets/sage_chat/header.dart';
import '../../widgets/sage_chat/message_list.dart';
import '../../widgets/sage_chat/typing_indicator.dart';
import '../../widgets/sage_chat/input_bar.dart';

class SageChatScreen extends ConsumerStatefulWidget {
  const SageChatScreen({super.key});

  @override
  ConsumerState<SageChatScreen> createState() => _SageChatScreenState();
}

class _SageChatScreenState extends ConsumerState<SageChatScreen>
    with AutomaticKeepAliveClientMixin {
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients && mounted) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    ref.read(experienceServiceProvider).lightHaptic();
    final sent = await ref.read(sageAiProvider.notifier).sendMessage(text);
    if (!sent || !mounted) return;
    AnalyticsService.instance.track(
      AnalyticEvent.tutorQuery,
      properties: {'query': text},
    );
    _textCtrl.clear();
    _focusNode.unfocus();
    _scrollDown();
  }

  String _resolveLastError(AppLocalizations l, String key) {
    switch (key) {
      case 'daily_limit':
        return l.sageDailyLimitReached;
      case 'connection_weak':
        return l.sageConnectionWeak;
      default:
        return l.errorGeneric;
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dark = context.isDark;
    final l = AppLocalizations.of(context)!;

    final isLocked = ref.watch(sageAiProvider.select((s) => s.isLocked));
    if (isLocked) {
      final blockedLabel = l.chatBlocked;
      return Semantics(
        button: true,
        label: blockedLabel,
        child: GestureDetector(
          onTap: () => ref.read(experienceServiceProvider).errorHaptic(),
          child: LockedGatekeeper(
            lessonsCompleted: ref.watch(
              sageAiProvider.select((s) => s.lessonsCompleted),
            ),
            lessonsRequired: ref.watch(
              sageAiProvider.select((s) => s.lessonsRequired),
            ),
            progress: ref.watch(sageAiProvider.select((s) => s.progress)),
            dark: dark,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: dark ? PremiumColors.darkBg : PremiumColors.lightBg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              _ChatHeaderSection(
                scrollCtrl: _scrollCtrl,
                onClear: () =>
                    ref.read(sageAiProvider.notifier).clearMessages(),
              ),
              Expanded(child: _ChatMessagesSection(scrollCtrl: _scrollCtrl)),
              _ChatErrorBannerSection(
                lastErrorResolver: (key) => _resolveLastError(l, key),
                dark: dark,
              ),
              const _ChatTypingSection(),
              InputBar(
                controller: _textCtrl,
                focusNode: _focusNode,
                dark: dark,
                enabled: !ref.watch(sageAiProvider.select((s) => s.isBusy)),
                isStreaming: ref.watch(
                  sageAiProvider.select((s) => s.isStreaming),
                ),
                onSend: () => _send(_textCtrl.text),
                onStop: () => ref.read(sageAiProvider.notifier).cancelStream(),
              ),
            ],
          ).animate().fadeIn(),
        ),
      ),
    );
  }
}

class _ChatHeaderSection extends ConsumerWidget {
  final ScrollController scrollCtrl;
  final VoidCallback? onClear;
  const _ChatHeaderSection({required this.scrollCtrl, this.onClear});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = ref.watch(sageAiProvider.select((s) => s.isBusy));
    final hasMessages = ref.watch(
      sageAiProvider.select((s) => s.messages.isNotEmpty),
    );
    return SageChatHeader(
      isBusy: isBusy,
      hasMessages: hasMessages,
      onClear: onClear,
    );
  }
}

class _ChatMessagesSection extends ConsumerWidget {
  final ScrollController scrollCtrl;
  const _ChatMessagesSection({required this.scrollCtrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sageState = ref.watch(
      sageAiProvider.select(
        (s) => (
          messages: s.messages,
          isStreaming: s.isStreaming,
          streamingText: s.streamingText,
        ),
      ),
    );
    return MessageList(
      messages: sageState.messages,
      isStreaming: sageState.isStreaming,
      streamingText: sageState.streamingText,
      scrollCtrl: scrollCtrl,
    );
  }
}

class _ChatErrorBannerSection extends ConsumerWidget {
  final String Function(String key) lastErrorResolver;
  final bool dark;
  const _ChatErrorBannerSection({
    required this.lastErrorResolver,
    required this.dark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastError = ref.watch(sageAiProvider.select((s) => s.lastError));
    if (lastError == null) return const SizedBox.shrink();
    return _ErrorBanner(
      message: lastErrorResolver(lastError),
      dark: dark,
      onDismiss: () => ref.read(sageAiProvider.notifier).clearError(),
      onRetry: () {
        final messages = ref.read(sageAiProvider).messages;
        if (messages.isNotEmpty) {
          final lastUser = messages.lastWhere(
            (m) => m.role == ChatRole.user,
            orElse: () => messages.last,
          );
          ref
              .read(sageAiProvider.notifier)
              .sendMessage(lastUser.text, isRetry: true);
        }
      },
    );
  }
}

class _ChatTypingSection extends ConsumerWidget {
  const _ChatTypingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(sageAiProvider.select((s) => s.isLoading));
    if (!isLoading) return const SizedBox.shrink();
    return const TypingIndicator();
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool dark;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;
  const _ErrorBanner({
    required this.message,
    required this.dark,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      color: PremiumColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          Semantics(
            label: AppLocalizations.of(context)?.errorGeneric ?? '',
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: PremiumColors.error,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyle.caption.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          if (onRetry != null)
            Semantics(
              button: true,
              label: AppLocalizations.of(context)?.retry ?? 'Retry',
              child: GestureDetector(
                onTap: onRetry,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: PremiumColors.error,
                  ),
                ),
              ),
            ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: AppLocalizations.of(context)?.close ?? 'Close',
            child: GestureDetector(
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: PremiumColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
