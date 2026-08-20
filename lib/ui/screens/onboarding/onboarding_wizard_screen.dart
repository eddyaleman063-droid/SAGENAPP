import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import '../../../services/experience_service.dart';
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
  final bool isFirstLaunch;
  const OnboardingWizardScreen({super.key, this.isFirstLaunch = false});

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
    _pageCtrl = PageController();
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
      context.pop();
    }
  }

  void _completeWizard() {
    _exp.mediumHaptic();
    context.goNamed('onboarding-flow');
  }

  String _sageMessageForStep(
    int index,
    OnboardingWizardState wizardState,
    AppLocalizations l,
  ) {
    final config = OnboardingWizardConfig.localizedSteps(_l)[index];
    if (index == 7) {
      final data = wizardState.sectionData[7];
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
    final sectionDataHash = ref.watch(
      onboardingWizardProvider.select((s) => s.sectionData.hashCode),
    );
    final canContinue = ref.watch(onboardingCanContinueProvider);
    final wizardSteps = OnboardingWizardConfig.localizedSteps(_l);
    final config = wizardSteps[currentIndex];

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Column(
            children: [
              WizardTopBar(currentIndex: currentIndex, onBack: _goBack),
              WizardSageSection(
                key: ValueKey('sage_${currentIndex}_$sectionDataHash'),
                emotion: config.emotion,
                message: _sageMessageForStep(
                  currentIndex,
                  ref.read(onboardingWizardProvider),
                  _l,
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: OnboardingWizardConfig.totalSteps,
                  itemBuilder: (context, i) => _buildStep(i),
                ),
              ),
              WizardBottomBar(
                currentIndex: currentIndex,
                canContinue: canContinue,
                onNext: _goNext,
                onComplete: _completeWizard,
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }

  Widget _buildStep(int index) {
    final wizardSteps = OnboardingWizardConfig.localizedSteps(_l);
    switch (index) {
      case 0:
        return const WizardPresentationStep();
      case 1:
        return WizardSingleChoiceStep(stepIndex: 1, stepConfig: wizardSteps[1]);
      case 2:
        return WizardLevelStep(stepIndex: 2, stepConfig: wizardSteps[2]);
      case 3:
        return WizardMultiChoiceStep(stepIndex: 3, stepConfig: wizardSteps[3]);
      case 4:
        return WizardSingleChoiceStep(stepIndex: 4, stepConfig: wizardSteps[4]);
      case 5:
        return WizardMultiChoiceStep(stepIndex: 5, stepConfig: wizardSteps[5]);
      case 6:
        return WizardGoalStep(stepIndex: 6, stepConfig: wizardSteps[6]);
      case 7:
        return WizardCommitmentStep(
          stepIndex: 7,
          stepConfig: wizardSteps[7],
          sageMessageForStep: _sageMessageForStep,
        );
      case 8:
        return WizardConfirmationStep(
          stepConfig: wizardSteps[8],
          sageMessageForStep: _sageMessageForStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
