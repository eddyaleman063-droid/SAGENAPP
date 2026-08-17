import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/app_logger.dart';
import '../../../core/theme/theme_constants.dart';

import 'package:sagen/ui/widgets/common/premium_loader.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/ui/widgets/common/tip_row.dart';
import 'package:sagen/ui/widgets/store/header.dart';
import 'package:sagen/ui/widgets/store/streak_fire_card.dart';
import 'package:sagen/ui/widgets/store/shop_item_card.dart';
import 'package:sagen/ui/widgets/store/supporter_tiers_section.dart';
import 'package:sagen/ui/widgets/store/daily_chest_card.dart';
import 'package:sagen/core/theme/app_colors.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with AutomaticKeepAliveClientMixin {
  final Set<String> _purchasingItems = {};
  ShopCategory _selectedCategory = ShopCategory.consumables;

  Future<bool> _validatePurchase(String itemId, int cost) async {
    try {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid == null) return false;

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final inventoryRef = userRef.collection('inventory').doc('shop_items');

      final doc = await inventoryRef.get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['items'] is List) {
          final ownedItems = List<String>.from(data['items']);
          if (ownedItems.contains(itemId)) return false;
        }
      }

      // Validate gem balance
      final gemBalance = ref.read(gemProvider).balance;
      if (gemBalance < cost) return false;

      return true;
    } catch (e) {
      AppLogger().warning('StoreScreen: failed to validate purchase: $e');
      return false;
    }
  }

  bool _isOwned(ShopItem item) {
    try {
      final items = ref.read(shopProvider).items;
      return items.any((i) => i.id == item.id && i.isOwned);
    } catch (e) {
      AppLogger().error('StoreScreen: _isOwned check failed', e);
      return false;
    }
  }

  Future<void> _confirmAndBuy(BuildContext context, ShopItem item) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.storeConfirmTitle),
        content: Text(l.storeConfirmMessage(item.name, item.gemCost)),
        actions: [
          Semantics(
            button: true,
            label: l.cancel,
            child: TextButton(
              onPressed: () {
                ExperienceService.instance.lightHaptic();
                context.pop(false);
              },
              child: Text(l.cancel),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ExperienceService.instance.lightHaptic();
              context.pop(true);
            },
            child: Text(l.storeBuyItem(item.id, item.gemCost)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      _buyItem(context, item);
    }
  }

  void _buyItem(BuildContext context, ShopItem item) async {
    if (_purchasingItems.contains(item.id)) return;
    final l = AppLocalizations.of(context)!;
    setState(() {
      _purchasingItems.add(item.id);
    });
    try {
      final exp = ref.read(experienceServiceProvider);
      final isValid = await _validatePurchase(item.id, item.gemCost);
      if (!isValid) {
        exp.errorHaptic();
        if (context.mounted) {
          SagenNotification.show(
            context,
            message: _isOwned(item)
                ? l.storeAlreadyOwned
                : l.storePurchaseFailed,
            type: _isOwned(item)
                ? NotificationType.info
                : NotificationType.error,
          );
        }
        return;
      }

      // Server-authoritative purchase: gems are spent via Cloud Function with
      // the catalog cost. The item unlocks only after the server confirms.
      final result = await ref
          .read(gemProvider.notifier)
          .spendShopGems(item.id);
      if (result != ShopPurchaseResult.success) {
        exp.errorHaptic();
        if (context.mounted) {
          SagenNotification.show(
            context,
            message: result == ShopPurchaseResult.owned
                ? l.storeAlreadyOwned
                : l.storePurchaseFailed,
            type: result == ShopPurchaseResult.owned
                ? NotificationType.info
                : NotificationType.error,
          );
        }
        return;
      }

      ref.read(shopProvider.notifier).unlockItem(item.id);

      // Apply purchase effects
      const themeVariants = {
        'theme_blue': 'blue',
        'theme_purple': 'purple',
        'theme_dark_fire': 'dark_fire',
        'theme_cyber_neon': 'cyber_neon',
      };
      if (item.id == 'xp_boost') {
        ref.read(shopProvider.notifier).activateXpBoost();
      } else if (themeVariants.containsKey(item.id)) {
        ref
            .read(themeProvider.notifier)
            .setThemeVariant(themeVariants[item.id]!);
      }

      // Add special items to inventory
      if (item.specialItemType != null) {
        ref.read(itemProvider.notifier).addItem(item.specialItemType!);
      }

      if (!mounted) return;
      exp.successHaptic();
      if (context.mounted) {
        SagenNotification.show(
          context,
          message: l.storePurchaseSuccess,
          type: NotificationType.success,
        );
      }
    } catch (e) {
      AppLogger().error('StoreScreen: gem purchase failed', e);
      if (context.mounted) {
        SagenNotification.show(
          context,
          message: l.storePurchaseFailed,
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _purchasingItems.remove(item.id);
        });
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final learning = ref.watch(
      learningProvider.select(
        (l) => (isLoading: l.isLoading, errorMessage: l.errorMessage),
      ),
    );
    final shop = ref.watch(shopProvider.select((s) => s.items));
    final streak = ref.watch(streakProvider);
    final gemBalance = ref.watch(gemProvider.select((g) => g.balance));

    if (learning.isLoading) {
      return PremiumLoader(
        loading: true,
        message: l.loading,
        child: Scaffold(backgroundColor: context.surfaceBackground),
      );
    }

    if (learning.errorMessage != null) {
      return Scaffold(
        backgroundColor: context.surfaceBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: context.textTertiary,
                ),
                const SizedBox(height: 16),
                Text(
                  l.errorContentLoadFailed,
                  style: AppTextStyle.bodyLg.copyWith(
                    color: context.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filteredItems = shop
        .where((i) => i.category == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final horizontalPadding = isWide
              ? AppSpacing.xxl * 2.0
              : AppSpacing.xxl.toDouble();
          return SafeArea(
            child: RepaintBoundary(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(shopProvider);
                  ref.invalidate(learningProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(child: StoreHeader()),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.md,
                        horizontalPadding,
                        AppSpacing.md,
                      ),
                      sliver: const SliverToBoxAdapter(child: DailyChestCard()),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.md,
                        horizontalPadding,
                        AppSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l.storeProtectStreak,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: StreakFireCard(streak: streak),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        AppSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l.storeSupportTiers,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: SupporterTiersSection(),
                      ),
                    ),
                    // Gem earning tips
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xl,
                        horizontalPadding,
                        AppSpacing.md,
                      ),
                      sliver: const SliverToBoxAdapter(
                        child: _GemEarningTipsCard(),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        AppSpacing.xl,
                        horizontalPadding,
                        AppSpacing.md,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          l.storePersonalization,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    // Category tabs
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _CategoryTabs(
                          selected: _selectedCategory,
                          onChanged: (cat) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      ),
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(top: AppSpacing.md),
                    ),
                    if (filteredItems.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const ExcludeSemantics(
                                child: SageEmotionWidget(
                                  emotion: SageEmotion.curious,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                l.emptyStore,
                                style: AppTextStyle.bodyMd.copyWith(
                                  color: context.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          100,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((ctx, i) {
                            final item = filteredItems[i];
                            return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md,
                                  ),
                                  child: Semantics(
                                    button: true,
                                    label: item.name,
                                    child: ShopItemCard(
                                      item: item,
                                      isLoading: _purchasingItems.contains(
                                        item.id,
                                      ),
                                      gemBalance: gemBalance,
                                      onBuy: () => _confirmAndBuy(ctx, item),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: (i * 60).ms, duration: 300.ms)
                                .slideX(begin: 0.05);
                          }, childCount: filteredItems.length),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final ShopCategory selected;
  final ValueChanged<ShopCategory> onChanged;

  const _CategoryTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ShopCategory.values.length,
        separatorBuilder: (a, b) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (ctx, i) {
          final cat = ShopCategory.values[i];
          final isSelected = cat == selected;
          return ChoiceChip(
            label: Text(_label(cat, l)),
            selected: isSelected,
            onSelected: (_) => onChanged(cat),
            selectedColor: dark
                ? PremiumColors.accentCyan.withValues(alpha: 0.2)
                : PremiumColors.primary.withValues(alpha: 0.15),
            backgroundColor: context.subtle,
            labelStyle: AppTextStyle.label.copyWith(
              color: isSelected
                  ? (dark ? PremiumColors.accentCyan : PremiumColors.primary)
                  : context.textSecondary,
            ),
          );
        },
      ),
    );
  }

  String _label(ShopCategory cat, AppLocalizations l) {
    switch (cat) {
      case ShopCategory.consumables:
        return l.storeCategoryConsumables;
      case ShopCategory.cosmetics:
        return l.storeCategoryCosmetics;
      case ShopCategory.themes:
        return l.storeCategoryThemes;
    }
  }
}

class _GemEarningTipsCard extends StatelessWidget {
  const _GemEarningTipsCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: context.surfaceCard,
        border: Border.all(color: context.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ExcludeSemantics(
                child: Icon(
                  Icons.diamond_rounded,
                  size: 18,
                  color: PremiumColors.accentYellow,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l.storeHowToEarnGems,
                  style: AppTextStyle.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TipRow(icon: Icons.school_rounded, text: l.storeGemTipLesson),
          TipRow(icon: Icons.star_rounded, text: l.storeGemTipPerfect),
          TipRow(icon: Icons.wb_sunny_rounded, text: l.storeGemTipFirstLesson),
          TipRow(icon: Icons.inventory_2_rounded, text: l.storeGemTipChest),
          TipRow(icon: Icons.task_alt_rounded, text: l.storeGemTipMission),
          TipRow(
            icon: Icons.local_fire_department_rounded,
            text: l.storeGemTipStreak,
          ),
          TipRow(
            icon: Icons.emoji_events_rounded,
            text: l.storeGemTipAchievement,
          ),
        ],
      ),
    );
  }
}
