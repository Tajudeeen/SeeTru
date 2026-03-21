import 'package:get/get.dart';
import 'package:seetru/presentation/screens/add_token/add_token_controller.dart';

class AddTokenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddTokenController>(() => AddTokenController());
  }
}