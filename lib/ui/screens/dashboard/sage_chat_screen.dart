import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/analytics_service.dart';

import '../../widgets/sage_chat/locked_gatekeeper.dart';
import '../../widgets/sage_chat/header.dart';
import '../../widgets/sage_chat/message_list.dart';
import '../../widgets/sage_chat/typing_indicator.dart';
import '../../widgets/sage_chat/quick_chips.dart';
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

  void _send(String text) {
    if (text.trim().isEmpty) return;
    ref.read(experienceServiceProvider).lightHaptic();
    AnalyticsService.instance.track(
      AnalyticEvent.tutorQuery,
      properties: {'query': text},
    );
    ref.read(sageAiProvider.notifier).sendMessage(text);
    _textCtrl.clear();
    _focusNode.unfocus();
    _scrollDown();
  }

  void _onChipTap(String text) {
    ref.read(experienceServiceProvider).lightHaptic();
    ref.read(sageAiProvider.notifier).sendMessage(text);
    _scrollDown();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sageState = ref.watch(sageAiProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (sageState.isLocked) {
      return Semantics(
        button: true,
        label: AppLocalizations.of(context)!.chatBlocked,
        child: GestureDetector(
          onTap: () => ref.read(experienceServiceProvider).errorHaptic(),
          child: LockedGatekeeper(sage: sageState, dark: dark),
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
              SageChatHeader(
                dark: dark,
                sage: sageState,
                onClear: () =>
                    ref.read(sageAiProvider.notifier).clearMessages(),
              ),
              Expanded(
                child: MessageList(
                  sage: sageState,
                  scrollCtrl: _scrollCtrl,
                  dark: dark,
                ),
              ),
              if (sageState.errorMessage != null)
                _ErrorBanner(message: sageState.errorMessage!, dark: dark),
              if (sageState.isLoading) const TypingIndicator(),
              if (sageState.suggestionChips.isNotEmpty)
                QuickChips(
                  chips: sageState.suggestionChips,
                  onTap: (t) => _onChipTap(t),
                  dark: dark,
                ),
              InputBar(
                controller: _textCtrl,
                focusNode: _focusNode,
                dark: dark,
                enabled: !sageState.isBusy,
                onSend: () => _send(_textCtrl.text),
              ),
            ],
          ).animate().fadeIn(),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool dark;
  const _ErrorBanner({required this.message, required this.dark});

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
        ],
      ),
    );
  }
}
