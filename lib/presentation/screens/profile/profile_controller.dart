import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seetru/app/routes/app_routes.dart';

class UserBadge {
  final String label;
  final IconData icon;
  final Color color;
  final bool earned;
  const UserBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.earned,
  });
}

class UserProfileController extends GetxController {
  final _box = GetStorage();

  final RxString name = 'Deeen Code'.obs;
  final RxString email = 'Deeen@email.com'.obs;
  final RxString username = '@Deeen_crypto'.obs;
  final RxString bio =
      'DeFi enthusiast · Long-term holder · BTC & ETH maxi'.obs;
  final RxString joinDate = 'January 2024'.obs;
  final RxString location = 'Lagos, Nigeria'.obs;
  final RxString website = 'Deeencrypto.io'.obs;
  final RxBool isLoading = false.obs;

  // Stats
  final RxInt watchlistCount = 12.obs;
  final RxInt alertsCount = 8.obs;
  final RxDouble portfolioValue = 24857.43.obs;
  final RxDouble portfolioReturn = 29.47.obs;

  // Badges
  final RxList<UserBadge> badges = <UserBadge>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBadges();
    _loadProfile();
  }

  void _loadProfile() {
    name.value = _box.read('user_name') ?? 'Deeen Code';
    email.value = _box.read('user_email') ?? 'Deeen@email.com';
  }

  void _loadBadges() {
    badges.value = [
      const UserBadge(
        label: 'Early Adopter',
        icon: Icons.star_rounded,
        color: Color(0xFFFFD700),
        earned: true,
      ),
      const UserBadge(
        label: 'HODLer',
        icon: Icons.lock_rounded,
        color: Color(0xFFF7931A),
        earned: true,
      ),
      const UserBadge(
        label: 'DeFi Pioneer',
        icon: Icons.account_tree_rounded,
        color: Color(0xFF627EEA),
        earned: true,
      ),
      const UserBadge(
        label: 'Whale Watcher',
        icon: Icons.water_rounded,
        color: Color(0xFF00C6CF),
        earned: false,
      ),
      const UserBadge(
        label: 'VC Tracker',
        icon: Icons.trending_up_rounded,
        color: Color(0xFF9945FF),
        earned: false,
      ),
      const UserBadge(
        label: 'Alpha Hunter',
        icon: Icons.bolt_rounded,
        color: Color(0xFFFFAA38),
        earned: true,
      ),
    ];
  }

  void goToEditProfile() => Get.toNamed(AppRoutes.editProfile);
  void goToSettings() => Get.toNamed(AppRoutes.settings);

  String formatValue(double v) =>
      '\$${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}
