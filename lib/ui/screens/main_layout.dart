import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import '../../core/theme/theme_constants.dart';
import '../../services/analytics_service.dart';
import '../../services/audio_service.dart';
import '../widgets/common/level_up_celebration.dart';
import 'package:sagen/core/theme/app_colors.dart';

import 'dashboard/dashboard_home_screen.dart';
import 'dashboard/store_screen.dart';
import 'dashboard/sage_chat_screen.dart';
import 'dashboard/ranking_screen.dart';
import 'dashboard/profile_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  final int initialTab;
  const MainLayout({super.key, this.initialTab = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late PageController _pageCtrl;
  bool _animating = false;
  StreamSubscription<int>? _tabSub;
  StreamSubscription<int>? _levelUpSub;

  static List<_TabItem> tabs(BuildContext context) => [
    _TabItem(label: AppLocalizations.of(context)!.navHome, icon: Icons.home_rounded),
    _TabItem(label: AppLocalizations.of(context)!.navChest, icon: Icons.card_giftcard_rounded),
    _TabItem(label: AppLocalizations.of(context)!.navSage, icon: Icons.auto_awesome_rounded),
    _TabItem(label: AppLocalizations.of(context)!.navRanking, icon: Icons.leaderboard_rounded),
    _TabItem(label: AppLocalizations.of(context)!.navProfile, icon: Icons.person_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: widget.initialTab);
    _tabSub = ref.read(deepLinkServiceProvider).tabSwitchStream.listen((tab) {
      if (mounted) _onTabTap(tab);
    });
    _levelUpSub = ref.read(learningProvider.notifier).onLevelUp.listen((newLevel) {
      if (!mounted) return;
      AudioService.instance.playLevelUp();
      showLevelUpCelebration(context, newLevel);
    });
  }

  @override
  void dispose() {
    _tabSub?.cancel();
    _levelUpSub?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_animating || index == ref.read(dashboardProvider).activeTab) return;
    ref.read(experienceServiceProvider).lightHaptic();
    final tabNames = ['home', 'store', 'sage', 'ranking', 'profile'];
    AnalyticsService.instance.trackScreen(tabNames[index]);
    setState(() => _animating = true);
    ref.read(dashboardProvider.notifier).setActiveTab(index);
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    ).then((_) {
      if (!mounted) return;
      setState(() => _animating = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(dashboardProvider.select((d) => d.activeTab));
    final isDemo = ref.watch(authProvider.select((a) => a.isDemoMode));
    final hasUnclaimedChest = ref.watch(gamificationProvider.select((g) => g.hasUnclaimedChest));

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: Stack(
        children: [
          Column(
            children: [
              if (isDemo)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  color: PremiumColors.warning.withValues(alpha: 0.9),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          AppLocalizations.of(context)?.demoModeOffline ?? '',
                          style: AppTextStyle.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    DashboardHomeScreen(),
                    StoreScreen(),
                    SageChatScreen(),
                    RankingScreen(),
                    ProfileScreen(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.lg,
            child: _PremiumNavBar(
              currentIndex: activeTab,
              onTap: _onTabTap,
              showChestBadge: hasUnclaimedChest,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}

class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showChestBadge;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
    this.showChestBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tabItems = _MainLayoutState.tabs(context);
    return Container(
      height: 84,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: context.surfaceCard,
        border: Border.all(
          color: context.subtleBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(tabItems.length, (i) {
          final selected = i == currentIndex;
          final item = tabItems[i];
          return Expanded(
            child: Semantics(
              button: true,
              label: item.label,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(i);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: selected
                          ? PremiumColors.splashBlue
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Badge(
                        isLabelVisible: showChestBadge && i == 1,
                        backgroundColor: PremiumColors.achievementEnd,
                        smallSize: 8,
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: selected
                              ? PremiumColors.splashBlue
                              : context.iconSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: AppTextStyle.bodyMd.copyWith(
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected
                              ? PremiumColors.splashBlue
                              : context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
