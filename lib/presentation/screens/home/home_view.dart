import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/data/models/crypto_asset.dart';
import '../../../app/routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // ✅ Fix 4: Obx is scoped only to the loading check — not the full tree
        if (controller.isLoading.value) return const _HomeShimmer();
        return _HomeBody(controller: controller);
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Home Body — extracted so it never rebuilds on isLoading changes
// ─────────────────────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final HomeController controller;
  const _HomeBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _HomeAppBar(controller: controller),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PortfolioHeroCard(controller: controller),
                const SizedBox(height: 24),
                _MarketStatsRow(controller: controller),
                const SizedBox(height: 24),
                const _PromoBanner(),
                const SizedBox(height: 24),
                _FilterTabs(controller: controller),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Trending', onSeeAll: () {}),
                const SizedBox(height: 12),
                _TrendingList(controller: controller),
                const SizedBox(height: 24),
                _GainersLosersSection(controller: controller),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'My Watchlist',
                  onSeeAll: () {},
                  trailing: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.addToken),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        // ✅ Fix 2: withOpacity → fromRGBO throughout
                        color: const Color.fromRGBO(76, 111, 255, 0.08),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _WatchlistSection(controller: controller),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Recent Fundraising',
                  onSeeAll: () {},
                ),
                const SizedBox(height: 12),
                _VCDealsList(controller: controller),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _HomeAppBar extends StatelessWidget {
  final HomeController controller;
  const _HomeAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 70,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.userProfile),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.teal],
                  ),
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'D',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${controller.greeting.value},',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      controller.userName.value,
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.notifications),
              child: Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.settings),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio Hero Card
// ─────────────────────────────────────────────────────────────────────────────
class _PortfolioHeroCard extends StatelessWidget {
  final HomeController controller;
  const _PortfolioHeroCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1136), Color(0xFF1A2B6D), Color(0xFF243CA0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              // ✅ Fix 2: withOpacity → fromRGBO
              color: const Color.fromRGBO(76, 111, 255, 0.40),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // ✅ Fix 2: withOpacity → fromRGBO
                  color: Color.fromRGBO(76, 111, 255, 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // ✅ Fix 2: withOpacity → fromRGBO
                  color: Color.fromRGBO(0, 198, 207, 0.10),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Portfolio Value',
                      style: AppTextStyles.bodySmall.copyWith(
                        // ✅ Fix 2: withOpacity → fromRGBO
                        color: const Color.fromRGBO(255, 255, 255, 0.6),
                        fontSize: 12,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.toggleBalanceVisibility,
                      child: Obx(
                        () => Icon(
                          controller.isBalanceVisible.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          // ✅ Fix 2: withOpacity → fromRGBO
                          color: const Color.fromRGBO(255, 255, 255, 0.5),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Obx(
                  () => controller.isBalanceVisible.value
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$24,857',
                              style: AppTextStyles.priceHero.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4,
                                left: 2,
                              ),
                              child: Text(
                                '.43',
                                style: AppTextStyles.priceMedium.copyWith(
                                  // ✅ Fix 2: withOpacity → fromRGBO
                                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          '•••••••',
                          style: AppTextStyles.priceHero.copyWith(
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        // ✅ Fix 2: withOpacity → fromRGBO
                        color: const Color.fromRGBO(0, 200, 83, 0.2),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 200, 83, 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_upward_rounded,
                            color: AppColors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '+3.24% today',
                            style: AppTextStyles.positiveChange.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '+\$779.42',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _QuickActionBtn(
                      icon: Icons.add_rounded,
                      label: 'Deposit',
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _QuickActionBtn(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Swap',
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _QuickActionBtn(
                      icon: Icons.pie_chart_outline_rounded,
                      label: 'Analyse',
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    _QuickActionBtn(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () => Get.toNamed(AppRoutes.activityHistory),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // ✅ Fix 2: withOpacity → fromRGBO
            color: const Color.fromRGBO(255, 255, 255, 0.10),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Market Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _MarketStatsRow extends StatelessWidget {
  final HomeController controller;
  const _MarketStatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 88,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          itemCount: controller.marketStats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final stat = controller.marketStats[i];
            return Container(
              width: 128,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(stat.label, style: AppTextStyles.labelSmall),
                      Icon(
                        stat.icon,
                        size: 14,
                        color: stat.isPositive
                            ? AppColors.green
                            : AppColors.red,
                      ),
                    ],
                  ),
                  Text(stat.value, style: AppTextStyles.priceMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // ✅ Fix 2: withOpacity → fromRGBO
                      color: stat.isPositive
                          ? const Color.fromRGBO(0, 200, 83, 0.1)
                          : const Color.fromRGBO(255, 77, 77, 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      stat.change,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: stat.isPositive
                            ? AppColors.green
                            : AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Promo Banner
// ─────────────────────────────────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        // ✅ Fix 1: Removed fixed height:110 — let content size itself naturally
        // The Column inside was 86px tall but only had 74px (110 - 18*2 padding),
        // causing the 12px overflow. Now the container expands to fit its content.
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A7EFF), Color(0xFF00D2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // ✅ Fix 2: withOpacity → fromRGBO
                  color: Color.fromRGBO(255, 255, 255, 0.08),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // ✅ Fix 2: withOpacity → fromRGBO
                  color: Color.fromRGBO(255, 255, 255, 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // ✅ Fix 1: mainAxisSize.min so column doesn't over-expand
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            // ✅ Fix 2: withOpacity → fromRGBO
                            color: const Color.fromRGBO(255, 255, 255, 0.2),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            'Special Offer',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // ✅ Fix 1: Flexible prevents text from demanding more
                        // space than is available
                        Flexible(
                          child: Text(
                            'Get Pro Intelligence\nUp to 30% off',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unlock VC data, on-chain alerts & more',
                          style: AppTextStyles.bodySmall.copyWith(
                            // ✅ Fix 2: withOpacity → fromRGBO
                            color: const Color.fromRGBO(255, 255, 255, 0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Text(
                      'Explore',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Tabs
// ─────────────────────────────────────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  final HomeController controller;
  const _FilterTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
        ),
        itemCount: controller.filterTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tab = controller.filterTabs[i];
          return Obx(() {
            final isActive = controller.selectedFilter.value == tab;
            return GestureDetector(
              onTap: () => controller.setFilter(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        )
                      : null,
                  color: isActive ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: isActive ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trending List
// ─────────────────────────────────────────────────────────────────────────────
class _TrendingList extends StatelessWidget {
  final HomeController controller;
  const _TrendingList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        height: 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          itemCount: controller.trendingAssets.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final asset = controller.trendingAssets[i];
            return _TrendingCard(asset: asset, controller: controller);
          },
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final CryptoAsset asset;
  final HomeController controller;
  const _TrendingCard({required this.asset, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant,
                ),
                child: Center(
                  child: Text(
                    asset.symbol[0],
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(asset.symbol, style: AppTextStyles.labelMedium),
                    Text(
                      asset.name,
                      style: AppTextStyles.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: asset.sparkline,
                isPositive: asset.isPositive,
              ),
              size: const Size(double.infinity, 32),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  controller.formatPrice(asset.price),
                  style: AppTextStyles.priceSmall.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _ChangeChip(value: asset.change24h),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gainers & Losers Section
// ─────────────────────────────────────────────────────────────────────────────
class _GainersLosersSection extends StatelessWidget {
  final HomeController controller;
  const _GainersLosersSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gainers = controller.gainers.toList();
      final losers = controller.losers.toList();
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
        ),
        child: Row(
          children: [
            Expanded(
              child: _GainersLosersCard(
                title: '🚀 Top Gainers',
                assets: gainers,
                controller: controller,
                isGainer: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GainersLosersCard(
                title: '📉 Top Losers',
                assets: losers,
                controller: controller,
                isGainer: false,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _GainersLosersCard extends StatelessWidget {
  final String title;
  final List<CryptoAsset> assets;
  final HomeController controller;
  final bool isGainer;

  const _GainersLosersCard({
    required this.title,
    required this.assets,
    required this.controller,
    required this.isGainer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSmall),
          const SizedBox(height: 10),
          ...assets.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.symbol,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          controller.formatPrice(a.price),
                          style: AppTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _ChangeChip(value: a.change24h, small: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Watchlist Section
// ✅ Fix 5: Uses ListView.builder for lazy loading instead of .map().toList()
// ─────────────────────────────────────────────────────────────────────────────
class _WatchlistSection extends StatelessWidget {
  final HomeController controller;
  const _WatchlistSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.watchlistAssets.length,
          itemBuilder: (_, i) => _CoinListTile(
            asset: controller.watchlistAssets[i],
            controller: controller,
          ),
        ),
      ),
    );
  }
}

class _CoinListTile extends StatelessWidget {
  final CryptoAsset asset;
  final HomeController controller;
  const _CoinListTile({required this.asset, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  // ✅ Fix 2: withOpacity → fromRGBO
                  Color.fromRGBO(76, 111, 255, 0.15),
                  Color.fromRGBO(0, 198, 207, 0.10),
                ],
              ),
            ),
            child: Center(
              child: Text(
                asset.symbol[0],
                style: const TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: AppTextStyles.titleMedium),
                Text(asset.symbol, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 30,
            child: CustomPaint(
              painter: _SparklinePainter(
                data: asset.sparkline,
                isPositive: asset.isPositive,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.formatPrice(asset.price),
                style: AppTextStyles.priceSmall,
              ),
              const SizedBox(height: 2),
              _ChangeChip(value: asset.change24h, small: true),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VC Deals List
// ✅ Fix 5: Uses ListView.builder for lazy loading instead of .map().toList()
// ─────────────────────────────────────────────────────────────────────────────
class _VCDealsList extends StatelessWidget {
  final HomeController controller;
  const _VCDealsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
        ),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.recentDeals.length,
          itemBuilder: (_, i) => _VCDealTile(deal: controller.recentDeals[i]),
        ),
      ),
    );
  }
}

class _VCDealTile extends StatelessWidget {
  final VCDeal deal;
  const _VCDealTile({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(deal.project, style: AppTextStyles.titleMedium),
                    Text(
                      '\$${deal.amount.toStringAsFixed(0)}${deal.currency}',
                      style: AppTextStyles.priceMedium.copyWith(
                        color: AppColors.green,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _TagChip(label: deal.round),
                    const SizedBox(width: 6),
                    _TagChip(label: deal.category),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  deal.investors.join(' · '),
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.onSeeAll, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.sectionHeader),
          trailing ??
              (onSeeAll != null
                  ? GestureDetector(
                      onTap: onSeeAll,
                      child: Text('See All', style: AppTextStyles.seeAll),
                    )
                  : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _ChangeChip extends StatelessWidget {
  final double value;
  final bool small;
  const _ChangeChip({required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    final isPos = value >= 0;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 5 : 7,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        // ✅ Fix 2: withOpacity → fromRGBO
        color: isPos
            ? const Color.fromRGBO(0, 200, 83, 0.1)
            : const Color.fromRGBO(255, 77, 77, 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPos ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: isPos ? AppColors.green : AppColors.red,
            size: small ? 9 : 10,
          ),
          const SizedBox(width: 1),
          Text(
            '${value.abs().toStringAsFixed(2)}%',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: small ? 9 : 11,
              fontWeight: FontWeight.w700,
              color: isPos ? AppColors.green : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkline Painter
// ─────────────────────────────────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final bool isPositive;

  const _SparklinePainter({required this.data, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final color = isPositive ? AppColors.green : AppColors.red;
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    if (range == 0) return;

    final points = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - minVal) / range * size.height);
      return Offset(x, y);
    });

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            // ✅ Fix 2: withOpacity → fromRGBO
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  // ✅ Fix 3: Compare list contents not references to avoid unnecessary repaints
  bool shouldRepaint(covariant _SparklinePainter old) {
    if (old.isPositive != isPositive) return true;
    if (old.data.length != data.length) return true;
    for (int i = 0; i < data.length; i++) {
      if (old.data[i] != data[i]) return true;
    }
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer Loading
// ─────────────────────────────────────────────────────────────────────────────
class _HomeShimmer extends StatefulWidget {
  const _HomeShimmer();

  @override
  State<_HomeShimmer> createState() => _HomeShimmerState();
}

class _HomeShimmerState extends State<_HomeShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPaddingH),
          child: Column(
            children: [
              const SizedBox(height: 80),
              _shimmerBox(double.infinity, 160, 20),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _shimmerBox(double.infinity, 80, 12)),
                  const SizedBox(width: 10),
                  Expanded(child: _shimmerBox(double.infinity, 80, 12)),
                  const SizedBox(width: 10),
                  Expanded(child: _shimmerBox(double.infinity, 80, 12)),
                ],
              ),
              const SizedBox(height: 20),
              _shimmerBox(double.infinity, 110, 16),
              const SizedBox(height: 20),
              ...List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _shimmerBox(double.infinity, 64, 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double w, double h, double radius) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            const Color(0xFFE8EDFF),
            Color.lerp(
              const Color(0xFFE8EDFF),
              const Color(0xFFD0DBFF),
              ((_animation.value + 1.5) / 3.0).clamp(0.0, 1.0),
            )!,
            const Color(0xFFE8EDFF),
          ],
        ),
      ),
    );
  }
}