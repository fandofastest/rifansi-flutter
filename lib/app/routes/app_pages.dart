import 'package:get/get.dart';
import '../modules/splash/splash_page.dart';
import '../modules/login/login_page.dart';
import '../modules/home/home_page.dart';
import 'app_routes.dart';
import '../modules/home/home_binding.dart';
import 'auth_middleware.dart';
import '../modules/settings/settings_page.dart';
import '../modules/spk/spk_page.dart';
import '../modules/spk/spk_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
    ),
    GetPage(
      name: Routes.spk,
      page: () => const SpkPage(),
      binding: SpkBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
} 