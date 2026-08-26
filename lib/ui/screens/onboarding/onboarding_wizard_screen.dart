import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import '../../../services/experience_service.dart';
import '../../widgets/common/error_boundary.dart';
import '../../widgets/onboarding/wizard_top_bar.dart';
import '../../widgets/onboarding/wizard_sage_section.dart';
import '../../widgets/onboarding/wizard_bottom_bar.dart';
import '../../widgets/onboarding/wizard_presentation_step.dart';
import '../../widgets/onboarding/wizard_single_choice_step.dart';
import '../../widgets/onboarding/wizard_level_step.dart';
import '../../widgets/onboarding/wizard_multi_choice_step.dart';
import '../../widgets/onboarding/wizard_goal_step.dart';
import '../../widgets/onboarding/wizard_commitment_step.dart';
import '../../widgets/onboarding/wizard_confirmation_step.dart';
import 'package:sagen/l10n/app_localizations.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() =>
      _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState
    extends ConsumerState<OnboardingWizardScreen> {
  late PageController _pageCtrl;
  ExperienceService get _exp => ref.read(experienceServiceProvider);

  @override
  void initState() {
    super.initState();
    final savedIndex = ref
        .read(onboardingWizardProvider)
        .currentIndex
        .clamp(0, OnboardingWizardConfig.totalSteps - 1);
    _pageCtrl = PageController(initialPage: savedIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Color get _bgColor =>
      context.isDark ? PremiumColors.deepBackground : PremiumColors.lightBg;

  AppLocalizations get _l => AppLocalizations.of(context)!;

  void _animateToPage(int index) {
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _goNext() {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    notifier.nextStep();
    _animateToPage(ref.read(onboardingWizardProvider).currentIndex);
  }

  void _goBack() {
    final state = ref.read(onboardingWizardProvider);
    if (state.currentIndex > 0) {
      final notifier = ref.read(onboardingWizardProvider.notifier);
      notifier.previousStep();
      _animateToPage(ref.read(onboardingWizardProvider).currentIndex);
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed('welcome');
      }
    }
  }

  void _completeWizard() {
    _exp.mediumHaptic();
    // Snapshot wizard data before autoDispose clears the provider
    final data = ref.read(onboardingWizardProvider).sectionData;
    ref.read(wizardBridgeProvider.notifier).capture(data);
    ref.read(onboardingWizardProvider.notifier).markCompleted();
    context.goNamed('onboarding-flow');
  }

  String _sageMessageForStep(
    int index,
    dynamic data,
    AppLocalizations l,
    WizardStepConfig config,
  ) {
    if (index == 7) {
      if (data is List && data.length == 1) {
        final val = data.first.toString();
        switch (val) {
          case '7':
            return l.onboardingSageStart;
          case '14':
            return l.onboardingSageTwoWeeks;
          case '30':
            return l.onboardingSageMonth;
          case '50':
            return l.onboardingSage50Days;
        }
      } else if (data is List && data.length > 1) {
        return l.onboardingSageExcellent;
      }
    }
    return config.sageMessage;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(
      onboardingWizardProvider.select((s) => s.currentIndex),
    );
    final canContinue = ref.watch(onboardingCanContinueProvider);
    final wizardSteps = OnboardingWizardConfig.localizedSteps(_l);
    final config = wizardSteps[currentIndex];
    final currentData = ref.watch(
      onboardingWizardProvider.select((s) => s.sectionData[currentIndex]),
    );
    final sageMsg = _sageMessageForStep(currentIndex, currentData, _l, config);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: _WizardContent(
            key: const ValueKey('wizard_content'),
            currentIndex: currentIndex,
            canContinue: canContinue,
            wizardSteps: wizardSteps,
            sageMsg: sageMsg,
            pageCtrl: _pageCtrl,
            buildStep: _buildStep,
            onGoBack: _goBack,
            onGoNext: _goNext,
            onComplete: _completeWizard,
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index, List<WizardStepConfig> wizardSteps) {
    Widget step;
    switch (index) {
      case 0:
        step = const WizardPresentationStep();
      case 1:
        step = WizardSingleChoiceStep(stepIndex: 1, stepConfig: wizardSteps[1]);
      case 2:
        step = WizardLevelStep(stepIndex: 2, stepConfig: wizardSteps[2]);
      case 3:
        step = WizardMultiChoiceStep(stepIndex: 3, stepConfig: wizardSteps[3]);
      case 4:
        step = WizardSingleChoiceStep(stepIndex: 4, stepConfig: wizardSteps[4]);
      case 5:
        step = WizardMultiChoiceStep(stepIndex: 5, stepConfig: wizardSteps[5]);
      case 6:
        step = WizardGoalStep(stepIndex: 6, stepConfig: wizardSteps[6]);
      case 7:
        step = WizardCommitmentStep(stepIndex: 7, stepConfig: wizardSteps[7]);
      case 8:
        step = WizardConfirmationStep(stepConfig: wizardSteps[8]);
      default:
        step = const SizedBox.shrink();
    }
    return ErrorBoundary(child: step);
  }
}

class _WizardContent extends StatelessWidget {
  final int currentIndex;
  final bool canContinue;
  final List<WizardStepConfig> wizardSteps;
  final String sageMsg;
  final PageController pageCtrl;
  final Widget Function(int, List<WizardStepConfig>) buildStep;
  final VoidCallback onGoBack;
  final VoidCallback onGoNext;
  final VoidCallback onComplete;

  const _WizardContent({
    super.key,
    required this.currentIndex,
    required this.canContinue,
    required this.wizardSteps,
    required this.sageMsg,
    required this.pageCtrl,
    required this.buildStep,
    required this.onGoBack,
    required this.onGoNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WizardTopBar(currentIndex: currentIndex, onBack: onGoBack),
        WizardSageSection(
          key: ValueKey('sage_${currentIndex}_$sageMsg'),
          emotion: wizardSteps[currentIndex].emotion,
          message: sageMsg,
        ),
        Expanded(
          child: PageView.builder(
            controller: pageCtrl,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: OnboardingWizardConfig.totalSteps,
            itemBuilder: (context, i) => buildStep(i, wizardSteps),
          ),
        ),
        WizardBottomBar(
          currentIndex: currentIndex,
          canContinue: canContinue,
          onNext: onGoNext,
          onComplete: onComplete,
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
