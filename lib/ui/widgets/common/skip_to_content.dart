import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

/// Provides a hidden skip-to-content button for screen readers.
/// Place at the top of scrollable screens. When focused via TalkBack/VoiceOver,
/// it announces "Skip to content" and scrolls to [targetKey] on activation.
class SkipToContent extends StatelessWidget {
  final GlobalKey targetKey;
  final String? label;

  const SkipToContent({
    super.key,
    required this.targetKey,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label ?? AppLocalizations.of(context)?.skipToContent ?? '',
      child: InkWell(
        onTap: () {
          final ctx = targetKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        },
        child: const SizedBox(width: 1, height: 1),
      ),
    );
  }
}
