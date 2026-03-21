import 'package:get/get.dart';
import 'package:seetru/presentation/screens/profile/profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileController>(() => UserProfileController());
  }
}