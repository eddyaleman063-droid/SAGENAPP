import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/experience_service.dart';

class ExitConfirmationWrapper extends StatelessWidget {
  final Widget child;

  const ExitConfirmationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.miniGameExitTitle),
            content: Text(l.miniGameExitContent),
            actions: [
              TextButton(
                onPressed: () {
                  ExperienceService.instance.lightHaptic();
                  Navigator.pop(ctx);
                },
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () {
                  ExperienceService.instance.lightHaptic();
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(l.exitText),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}
