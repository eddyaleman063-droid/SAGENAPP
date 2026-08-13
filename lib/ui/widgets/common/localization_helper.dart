import 'package:flutter/material.dart';
import 'package:sagen/l10n/app_localizations.dart';

/// Safe accessor for AppLocalizations that avoids force unwraps.
/// Returns the localization object or a fallback if context is not ready.
AppLocalizations l10n(BuildContext context) {
  return AppLocalizations.of(context) ?? const _FallbackLocalizations();
}

/// Minimal fallback that returns raw keys if localization is unavailable.
class _FallbackLocalizations implements AppLocalizations {
  const _FallbackLocalizations();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      '[missing: ${invocation.memberName}]';
}
