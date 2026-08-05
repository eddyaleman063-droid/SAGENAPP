import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  const SplashScreen({super.key, this.autoNavigate = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late Animation<Color?> _bgAnim;
  late AnimationController _textCtrl;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;
  bool _phase2 = false;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bgAnim = ColorTween(
      begin: PremiumColors.splashBlue,
      end: PremiumColors.deepBackground,
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeAnim = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _textCtrl.forward();

    // Phase 1: 1 segundo estatico
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _phase2 = true);
      _bgCtrl.forward().then((_) => _navigateToWelcome());
    });
  }

  void _navigateToWelcome() {
    if (!mounted) return;
    if (!widget.autoNavigate) return;
    context.goNamed('welcome');
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)?.loading ?? AppLocalizations.of(context)?.tapToContinue ?? '',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _navigateToWelcome();
        },
        child: AnimatedBuilder(
          animation: _bgAnim,
          builder: (context, _) => Scaffold(
          backgroundColor: _phase2
              ? (dark ? _bgAnim.value ?? PremiumColors.deepBackground : PremiumColors.lightBg)
              : PremiumColors.splashBlue,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _textSlideAnim,
                  child: FadeTransition(
                    opacity: _textFadeAnim,
                    child: Text(
                      AppLocalizations.of(context)!.splashTitle,
                      style: AppTextStyle.hero.copyWith(
                        fontWeight: FontWeight.w900,
                        color: context.textPrimary,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
                if (_phase2)
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Semantics(
                      label: AppLocalizations.of(context)?.loading ?? '',
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.textDisabled,
                          ),
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