import 'package:get/get.dart';

import '../../presentation/screens/add_token/add_token_view.dart';
import '../../presentation/screens/auth/auth_view.dart';
import '../../presentation/screens/edit_profile/edit_profile_view.dart';
import '../../presentation/screens/history/history_view.dart';
import '../../presentation/screens/main/main_view.dart';
import '../../presentation/screens/notification/notis_view.dart';
import '../../presentation/screens/onboarding/onboarding_view.dart';
import '../../presentation/screens/portfolio/portfolio_view.dart';
import '../../presentation/screens/profile/profile_view.dart';
import '../../presentation/screens/settings/setting_view.dart';
import '../../presentation/screens/social/social_view.dart';
import '../../presentation/screens/splash/splash_view.dart';
import '../bindings/add_token_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/edit_profile_binding.dart';
import '../bindings/history_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/notis_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/portfolio_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/setting_binding.dart';
import '../bindings/social_binding.dart';
import '../bindings/splash_binding.dart';

abstract class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String main = '/main';
  static const String home = '/home';
  static const String portfolio = '/portfolio';
  static const String social = '/social';
  static const String history = '/history';
  static const String activityHistory = '/activity-history';
  static const String settings = '/settings';
  static const String userProfile = '/user-profile';
  static const String editProfile = '/edit-profile';
  static const String notifications = '/notifications';
  static const String addToken = '/add-token';
}

class AppPages {
  static const String initial = AppRoutes.splash;

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.portfolio,
      page: () => const PortfolioView(),
      binding: PortfolioBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.social,
      page: () => const SocialView(),
      binding: SocialBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.activityHistory,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.userProfile,
      page: () => const UserProfileView(),
      binding: UserProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.addToken,
      page: () => const AddTokenView(),
      binding: AddTokenBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
    ),
  ];
}
