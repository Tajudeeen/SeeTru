import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  final RxDouble logoScale = 0.0.obs;
  final RxDouble logoOpacity = 0.0.obs;
  final RxDouble taglineOpacity = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    _startAnimations();
  }

  void _startAnimations() async {
    // Phase 1 – logo fades + scales in
    await Future.delayed(const Duration(milliseconds: 200));
    logoOpacity.value = 1.0;
    logoScale.value = 1.0;

    // Phase 2 – tagline fades in
    await Future.delayed(const Duration(milliseconds: 600));
    taglineOpacity.value = 1.0;

    // Phase 3 – navigate after minimum splash time
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigate();
  }

  void _navigate() {
    final bool hasSeenOnboarding =
        _storage.read<bool>('has_seen_onboarding') ?? false;

    // ✅ Check real Firebase auth state
    final isLoggedIn = AuthService.to.isLoggedIn.value;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.main);
    } else if (hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.auth);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}