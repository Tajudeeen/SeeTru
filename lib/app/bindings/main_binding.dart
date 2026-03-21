import 'package:get/get.dart';
import 'package:seetru/app/bindings/history_binding.dart';
import 'package:seetru/app/bindings/home_binding.dart';
import 'package:seetru/app/bindings/portfolio_binding.dart';
import 'package:seetru/app/bindings/profile_binding.dart';
import 'package:seetru/app/bindings/social_binding.dart';
import 'package:seetru/presentation/screens/main/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());

    HomeBinding().dependencies();
    PortfolioBinding().dependencies();
    SocialBinding().dependencies();
    HistoryBinding().dependencies();
    UserProfileBinding().dependencies();
  }
}
