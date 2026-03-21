import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/app/routes/app_routes.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/profile/profile_controller.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _ProfileSliverAppBar(controller: controller),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Avatar + info ──────────────────────────────
                _ProfileHeroSection(controller: controller),
                const SizedBox(height: 20),

                // ── Stats row ──────────────────────────────────
                _StatsRow(controller: controller),
                const SizedBox(height: 20),

                // ── Portfolio summary card ─────────────────────
                _PortfolioSummaryCard(controller: controller),
                const SizedBox(height: 20),

                // ── Badges ─────────────────────────────────────
                _BadgesSection(controller: controller),
                const SizedBox(height: 20),

                // ── Quick links ────────────────────────────────
                _QuickLinksSection(),
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
// Sliver App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileSliverAppBar extends StatelessWidget {
  final UserProfileController controller;
  const _ProfileSliverAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
      ),
      actions: [
        GestureDetector(
          onTap: controller.goToSettings,
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 18),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0B1136), Color(0xFF1A2B6D), Color(0xFF243CA0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withOpacity(0.10),
                  ),
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
// Profile hero section
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeroSection extends StatelessWidget {
  final UserProfileController controller;
  const _ProfileHeroSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Column(
        children: [
          // Avatar (overlapping the app bar)
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                Container(
                  width: AppSizes.avatarHero,
                  height: AppSizes.avatarHero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: AppColors.background, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Obx(() => Text(
                          controller.name.value.isNotEmpty
                              ? controller.name.value[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        )),
                  ),
                ),
                const SizedBox(height: 4),
                // Edit avatar button
                GestureDetector(
                  onTap: controller.goToEditProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_rounded,
                            size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('Edit Profile',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontSize: 11,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -28),
            child: Column(
              children: [
                Obx(() => Text(controller.name.value,
                    style: AppTextStyles.displaySmall)),
                const SizedBox(height: 2),
                Obx(() => Text(controller.username.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ))),
                const SizedBox(height: 10),
                Obx(() => Text(controller.bio.value,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis)),
                const SizedBox(height: 10),
                // Meta row
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _MetaItem(
                      icon: Icons.location_on_outlined,
                      label: controller.location.value,
                    ),
                    _MetaItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'Joined ${controller.joinDate.value}',
                    ),
                    _MetaItem(
                      icon: Icons.link_rounded,
                      label: controller.website.value,
                      isLink: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLink;
  const _MetaItem({required this.icon, required this.label, this.isLink = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13,
            color: isLink ? AppColors.accent : AppColors.textHint),
        const SizedBox(width: 4),
        Text(label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isLink ? AppColors.accent : AppColors.textHint,
              fontSize: 12,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final UserProfileController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _StatCell(
              value: controller.watchlistCount.value.toString(),
              label: 'Watchlist',
              icon: Icons.bookmark_rounded,
              color: AppColors.accent,
            ),
            _VertDivider(),
            _StatCell(
              value: controller.alertsCount.value.toString(),
              label: 'Alerts',
              icon: Icons.notifications_rounded,
              color: AppColors.orange,
            ),
            _VertDivider(),
            _StatCell(
              value: controller
                  .formatValue(controller.portfolioValue.value),
              label: 'Portfolio',
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.green,
            ),
            _VertDivider(),
            _StatCell(
              value: '+${controller.portfolioReturn.value.toStringAsFixed(1)}%',
              label: 'Return',
              icon: Icons.trending_up_rounded,
              color: AppColors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.priceSmall.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: AppColors.divider,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _PortfolioSummaryCard extends StatelessWidget {
  final UserProfileController controller;
  const _PortfolioSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1136), Color(0xFF1A2B6D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Portfolio Value',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.formatValue(controller.portfolioValue.value),
                        style: AppTextStyles.priceLarge.copyWith(color: Colors.white),
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Obx(() => Text(
                          '+${controller.portfolioReturn.value.toStringAsFixed(2)}% all time',
                          style: AppTextStyles.positiveChange
                              .copyWith(fontSize: 11),
                        )),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.portfolio),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.teal]),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text('View',
                    style: AppTextStyles.buttonMedium.copyWith(fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badges Section
// ─────────────────────────────────────────────────────────────────────────────
class _BadgesSection extends StatelessWidget {
  final UserProfileController controller;
  const _BadgesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Badges & Achievements',
                  style: AppTextStyles.sectionHeader),
              Obx(() => Text(
                    '${controller.badges.where((b) => b.earned).length}/${controller.badges.length}',
                    style: AppTextStyles.seeAll,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: controller.badges.length,
                itemBuilder: (_, i) {
                  final b = controller.badges[i];
                  return _BadgeCard(badge: b);
                },
              )),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final UserBadge badge;
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: badge.earned ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: badge.earned
              ? badge.color.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: badge.earned
                ? badge.color.withOpacity(0.25)
                : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.color.withOpacity(badge.earned ? 0.15 : 0.06),
              ),
              child: Icon(
                badge.icon,
                color: badge.earned ? badge.color : AppColors.textHint,
                size: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(badge.label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: badge.earned ? AppColors.textPrimary : AppColors.textHint,
                ),
                textAlign: TextAlign.center,
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Links Section
// ─────────────────────────────────────────────────────────────────────────────
class _QuickLinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final links = [
      (Icons.bookmark_outline_rounded, 'Saved Posts', AppColors.accent, () {}),
      (Icons.notifications_outlined, 'Price Alerts', AppColors.orange, () {}),
      (Icons.history_rounded, 'Activity', AppColors.teal, () => Get.toNamed(AppRoutes.activityHistory)),
      (Icons.help_outline_rounded, 'Help & Support', AppColors.textSecondary, () {}),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: List.generate(links.length, (i) {
            final l = links[i];
            return Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 2),
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: l.$3.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(l.$1, color: l.$3, size: 17),
                  ),
                  title: Text(l.$2, style: AppTextStyles.titleMedium),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textHint),
                  onTap: l.$4,
                ),
                if (i < links.length - 1)
                  const Divider(height: 1, indent: 56, color: AppColors.divider),
              ],
            );
          }),
        ),
      ),
    );
  }
}