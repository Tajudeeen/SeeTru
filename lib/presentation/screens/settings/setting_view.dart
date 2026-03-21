import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/app/routes/app_routes.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/settings/setting_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
        ),
        title: const Text('Settings', style: AppTextStyles.headlineMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSizes.screenPaddingH, 4, AppSizes.screenPaddingH, 100),
        children: [
          // ── Profile card shortcut ──────────────────────────────
          _ProfileShortcut(),

          const SizedBox(height: 24),

          // ── Appearance ─────────────────────────────────────────
          _SettingsSection(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              Obx(() => _ToggleTile(
                    icon: Icons.dark_mode_rounded,
                    iconColor: const Color(0xFF7C5CBF),
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    value: controller.isDarkMode.value,
                    onChanged: controller.toggleDarkMode,
                  )),
              Obx(() => _ToggleTile(
                    icon: Icons.visibility_off_rounded,
                    iconColor: AppColors.textSecondary,
                    title: 'Hide Balance',
                    subtitle: 'Blur balance on home screen',
                    value: controller.isHideBalance.value,
                    onChanged: controller.toggleHideBalance,
                  )),
              Obx(() => _SelectTile(
                    icon: Icons.language_rounded,
                    iconColor: AppColors.teal,
                    title: 'Language',
                    value: controller.language.value,
                    onTap: () => _showPicker(
                      context,
                      title: 'Select Language',
                      options: controller.languages,
                      selected: controller.language.value,
                      onSelect: controller.setLanguage,
                    ),
                  )),
              Obx(() => _SelectTile(
                    icon: Icons.attach_money_rounded,
                    iconColor: AppColors.green,
                    title: 'Currency',
                    value: controller.currency.value,
                    onTap: () => _showPicker(
                      context,
                      title: 'Select Currency',
                      options: controller.currencies,
                      selected: controller.currency.value,
                      onSelect: controller.setCurrency,
                    ),
                  )),
            ],
          ),

          const SizedBox(height: 16),

          // ── Notifications ──────────────────────────────────────
          _SettingsSection(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            children: [
              Obx(() => _ToggleTile(
                    icon: Icons.show_chart_rounded,
                    iconColor: AppColors.accent,
                    title: 'Price Alerts',
                    subtitle: 'Get notified on target prices',
                    value: controller.isPriceAlertsEnabled.value,
                    onChanged: controller.togglePriceAlerts,
                  )),
              Obx(() => _ToggleTile(
                    icon: Icons.business_center_rounded,
                    iconColor: AppColors.primary,
                    title: 'VC & Fundraising',
                    subtitle: 'New rounds and deals',
                    value: controller.isVcAlertsEnabled.value,
                    onChanged: controller.toggleVcAlerts,
                  )),
              Obx(() => _ToggleTile(
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.teal,
                    title: 'Social Alpha',
                    subtitle: 'KOL posts and trending topics',
                    value: controller.isSocialAlertsEnabled.value,
                    onChanged: controller.toggleSocialAlerts,
                  )),
              Obx(() => _ToggleTile(
                    icon: Icons.pie_chart_rounded,
                    iconColor: AppColors.green,
                    title: 'Portfolio Moves',
                    subtitle: 'Daily P&L and big swings',
                    value: controller.isPortfolioAlertsEnabled.value,
                    onChanged: controller.togglePortfolioAlerts,
                  )),
            ],
          ),

          const SizedBox(height: 16),

          // ── Security ───────────────────────────────────────────
          _SettingsSection(
            title: 'Security',
            icon: Icons.security_rounded,
            children: [
              Obx(() => _ToggleTile(
                    icon: Icons.fingerprint_rounded,
                    iconColor: AppColors.accent,
                    title: 'Biometric Login',
                    subtitle: 'Face ID or Fingerprint',
                    value: controller.isBiometricEnabled.value,
                    onChanged: controller.toggleBiometric,
                  )),
              _ActionTile(
                icon: Icons.lock_reset_rounded,
                iconColor: AppColors.orange,
                title: 'Change Password',
                onTap: () =>
                    controller.showSnack('Change password flow coming'),
              ),
              _ActionTile(
                icon: Icons.devices_rounded,
                iconColor: AppColors.red,
                title: 'Active Sessions',
                onTap: () =>
                    controller.showSnack('Active sessions coming soon'),
              ),
              _ActionTile(
                icon: Icons.shield_outlined,
                iconColor: AppColors.green,
                title: 'Two-Factor Authentication',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.12),
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text('Off',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.orange, fontSize: 10)),
                ),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Data & APIs ────────────────────────────────────────
          _SettingsSection(
            title: 'Data & APIs',
            icon: Icons.api_rounded,
            children: [
              _ActionTile(
                icon: Icons.currency_bitcoin_rounded,
                iconColor: const Color(0xFFF7931A),
                title: 'CoinGecko API',
                trailing: _ConnectedBadge(),
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.accent,
                title: 'CoinMarketCap API',
                trailing: _ConnectedBadge(),
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.teal,
                title: 'CryptoRank API',
                trailing: _ConnectedBadge(),
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.data_usage_rounded,
                iconColor: const Color(0xFFF15025),
                title: 'Dune Analytics API',
                trailing: _ConnectedBadge(),
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.people_rounded,
                iconColor: Colors.black87,
                title: 'X (Twitter) API',
                trailing: _ConnectedBadge(),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── About ──────────────────────────────────────────────
          _SettingsSection(
            title: 'About',
            icon: Icons.info_outline_rounded,
            children: [
              _ActionTile(
                icon: Icons.star_outline_rounded,
                iconColor: AppColors.orange,
                title: 'Rate SeeTru',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.share_rounded,
                iconColor: AppColors.accent,
                title: 'Share App',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.teal,
                title: 'Privacy Policy',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.article_outlined,
                iconColor: AppColors.textSecondary,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _ActionTile(
                icon: Icons.info_rounded,
                iconColor: AppColors.textHint,
                title: 'App Version',
                trailing: Obx(() => Text(
                      controller.appVersion.value,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    )),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Sign Out ───────────────────────────────────────────
          GestureDetector(
            onTap: () => _confirmSignOut(context),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.error.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Text('Sign Out',
                      style: AppTextStyles.buttonMedium
                          .copyWith(color: AppColors.error)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            const Divider(),
            ...options.map((opt) => ListTile(
                  title: Text(opt, style: AppTextStyles.titleMedium),
                  trailing: selected == opt
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.accent, size: 20)
                      : null,
                  onTap: () {
                    onSelect(opt);
                    Get.back();
                  },
                )),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXl)),
        title: const Text('Sign Out', style: AppTextStyles.headlineSmall),
        content: Text(
          'Are you sure you want to sign out of SeeTru?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: AppTextStyles.buttonMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.signOut();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile shortcut card
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileShortcut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.userProfile),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.teal]),
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Center(
                child: Text('A',
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deeen Code',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  Text('deeen@code.com',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text('Edit Profile',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontSize: 11,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Section
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textHint),
            const SizedBox(width: 6),
            Text(title.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textHint,
                  letterSpacing: 1.0,
                  fontSize: 11,
                )),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              return Column(
                children: [
                  children[i],
                  if (i < children.length - 1)
                    const Divider(
                        height: 1,
                        indent: 56,
                        color: AppColors.divider),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTextStyles.bodySmall)
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.border),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(title, style: AppTextStyles.titleMedium),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Select Tile
// ─────────────────────────────────────────────────────────────────────────────
class _SelectTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SelectTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _IconBox(icon: icon, color: iconColor),
      title: Text(title, style: AppTextStyles.titleMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              )),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textHint),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 17),
    );
  }
}

class _ConnectedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 4),
          Text('Connected',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.green,
                fontSize: 10,
              )),
        ],
      ),
    );
  }
}