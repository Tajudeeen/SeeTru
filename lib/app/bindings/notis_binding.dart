import 'package:get/get.dart';
import 'package:seetru/presentation/screens/notification/notis_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}