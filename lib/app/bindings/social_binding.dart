import 'package:get/get.dart';
import 'package:seetru/presentation/screens/social/social_controller.dart';

class SocialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocialController>(() => SocialController());
  }
}