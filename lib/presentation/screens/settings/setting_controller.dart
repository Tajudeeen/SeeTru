import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seetru/app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';


class SettingsController extends GetxController {
  final _box = GetStorage();

  // ── Preferences ────────────────────────────────────────────────────
  final RxBool isDarkMode = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxBool isPriceAlertsEnabled = true.obs;
  final RxBool isVcAlertsEnabled = true.obs;
  final RxBool isSocialAlertsEnabled = true.obs;
  final RxBool isPortfolioAlertsEnabled = true.obs;
  final RxBool isHideBalance = false.obs;
  final RxString currency = 'USD'.obs;
  final RxString language = 'English'.obs;
  final RxString appVersion = '1.0.0 (Build 1)'.obs;

  // ── User info from Firebase ────────────────────────────────────────
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;

  final RxList<String> currencies =
      <String>['USD', 'EUR', 'GBP', 'JPY', 'NGN'].obs;
  final RxList<String> languages =
      <String>['English', 'French', 'Spanish', 'Portuguese'].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    try {
      final user = AuthService.to.currentUser;
      if (user != null) {
        userName.value = user.displayName ?? 'User';
        userEmail.value = user.email ?? '';
      }
    } catch (_) {}
  }

  void _loadPreferences() {
    isDarkMode.value = _box.read('dark_mode') ?? false;
    isBiometricEnabled.value = _box.read('biometric') ?? false;
    isPriceAlertsEnabled.value = _box.read('price_alerts') ?? true;
    isVcAlertsEnabled.value = _box.read('vc_alerts') ?? true;
    isSocialAlertsEnabled.value = _box.read('social_alerts') ?? true;
    isPortfolioAlertsEnabled.value =
        _box.read('portfolio_alerts') ?? true;
    currency.value = _box.read('currency') ?? 'USD';
    language.value = _box.read('language') ?? 'English';
  }

  void toggleDarkMode(bool v) {
    isDarkMode.value = v;
    _box.write('dark_mode', v);
    Get.changeThemeMode(v ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleBiometric(bool v) {
    isBiometricEnabled.value = v;
    _box.write('biometric', v);
  }

  void togglePriceAlerts(bool v) {
    isPriceAlertsEnabled.value = v;
    _box.write('price_alerts', v);
  }

  void toggleVcAlerts(bool v) {
    isVcAlertsEnabled.value = v;
    _box.write('vc_alerts', v);
  }

  void toggleSocialAlerts(bool v) {
    isSocialAlertsEnabled.value = v;
    _box.write('social_alerts', v);
  }

  void togglePortfolioAlerts(bool v) {
    isPortfolioAlertsEnabled.value = v;
    _box.write('portfolio_alerts', v);
  }

  void toggleHideBalance(bool v) {
    isHideBalance.value = v;
    _box.write('hide_balance', v);
  }

  void setCurrency(String c) {
    currency.value = c;
    _box.write('currency', c);
  }

  void setLanguage(String l) {
    language.value = l;
    _box.write('language', l);
  }

  // ✅ Real Firebase sign out
  Future<void> signOut() async {
    try {
      await AuthService.to.signOut();
      Get.offAllNamed(AppRoutes.auth);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Sign out failed. Try again.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void showSnack(String msg) {
    Get.snackbar(
      'Settings',
      msg,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}