import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/ambient_background.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _lastError;
  late final void Function(FlutterErrorDetails)? _oldHandler;

  @override
  void initState() {
    super.initState();
    _oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (_lastError != msg) {
        _lastError = msg;
        if (mounted) setState(() {});
      }
      _oldHandler?.call(details);
    };
  }

  @override
  void dispose() {
    FlutterError.onError = _oldHandler;
    super.dispose();
  }

  void _retry() {
    setState(() {
      _lastError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _lastError != null
        ? _ErrorFallback(message: _lastError!, onRetry: _retry)
        : widget.child;
  }
}

class _ErrorFallback extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorFallback({required this.message, this.onRetry});

  void _navigateToRoot(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.go('/');
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = l?.errorSomethingWrong ?? '';
    final desc = l?.errorUnexpected ?? '';
    final retryLabel = l?.errorRetry ?? '';
    final homeLabel = l?.errorRestartApp ?? '';
    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: SageEmotionWidget(emotion: SageEmotion.worried),
                  ),
                  Semantics(
                    label: l?.errorSomethingWrong ?? 'Error',
                    child: const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    title,
                    style: AppTextStyle.headlineMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMd.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  if (onRetry != null)
                    Semantics(
                      button: true,
                      label: retryLabel,
                      child: ElevatedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(retryLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxl,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                  if (onRetry != null) const SizedBox(height: AppSpacing.md),
                  Semantics(
                    button: true,
                    label: homeLabel,
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToRoot(context),
                      icon: const Icon(Icons.home_rounded, size: 18),
                      label: Text(homeLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textSecondary,
                        side: BorderSide(color: context.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
