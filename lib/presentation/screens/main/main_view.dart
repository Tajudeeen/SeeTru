import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/profile/profile_view.dart';
import '../home/home_view.dart';
import '../portfolio/portfolio_view.dart';
import '../social/social_view.dart';
import '../history/history_view.dart';
import 'main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static final List<Widget> _screens = [
    const HomeView(),
    const PortfolioView(),
    const SocialView(),
    const HistoryView(),
    const UserProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: _screens,
      )),
      bottomNavigationBar: const _SeeTruBottomNav(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SeeTru Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SeeTruBottomNav extends GetView<MainController> {
  const _SeeTruBottomNav();

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Social',
    ),
    _NavItem(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    _NavItem(
      icon: Icons.pie_chart_outline_rounded,
      activeIcon: Icons.pie_chart_rounded,
      label: 'Portfolio',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDeep,
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Obx(() => Row(
            children: List.generate(_items.length, (index) {
              final isActive = controller.currentIndex.value == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.changePage(index),
                  child: _NavButton(
                    item: _items[index],
                    isActive: isActive,
                    isCenter: index == 2, // Social is the center/featured tab
                  ),
                ),
              );
            }),
          )),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCenter;

  const _NavButton({
    required this.item,
    required this.isActive,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isActive ? 44 : (isCenter ? 48 : 38),
            height: isActive ? 36 : (isCenter ? 40 : 30),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : isCenter && !isActive
                      ? LinearGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.12),
                            AppColors.teal.withOpacity(0.12),
                          ],
                        )
                      : null,
              color: (!isActive && !isCenter) ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(isActive ? 12 : 10),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive
                    ? Colors.white
                    : isCenter
                        ? AppColors.accent
                        : AppColors.textHint,
                size: isCenter && !isActive
                    ? AppSizes.bottomNavIconSize + 2
                    : AppSizes.bottomNavIconSize,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Label
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: AppTextStyles.navLabel.copyWith(
              color: isActive ? AppColors.primary : AppColors.textHint,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}