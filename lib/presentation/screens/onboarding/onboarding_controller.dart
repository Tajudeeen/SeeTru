import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seetru/app/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final _storage = GetStorage();

  final RxInt currentPage = 0.obs;
  final int totalPages = 3;

  // Per-page animation state
  final RxDouble contentOpacity = 0.0.obs;
  final RxDouble contentOffset = 40.0.obs;

  @override
  void onReady() {
    super.onReady();
    _animatePageIn();
  }

  void _animatePageIn() async {
    await Future.delayed(const Duration(milliseconds: 80));
    contentOpacity.value = 1.0;
    contentOffset.value = 0.0;
  }

  void onPageChanged(int page) {
    currentPage.value = page;
    contentOpacity.value = 0.0;
    contentOffset.value = 30.0;
    _animatePageIn();
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() {
    _storage.write('has_seen_onboarding', true);
    Get.offAllNamed(AppRoutes.auth);
  }

  bool get isLastPage => currentPage.value == totalPages - 1;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}