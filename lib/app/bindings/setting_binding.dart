import 'package:get/get.dart';
import 'package:seetru/presentation/screens/settings/setting_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}