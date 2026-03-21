import 'package:get/get.dart';
import '../../presentation/screens/onboarding/onboarding_controller.dart';


class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}