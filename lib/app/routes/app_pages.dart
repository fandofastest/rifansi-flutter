import 'package:get/get.dart';
import '../modules/splash/splash_page.dart';
import '../modules/login/login_page.dart';
import '../modules/home/home_page.dart';
import 'app_routes.dart';
import '../modules/home/home_binding.dart';
import 'auth_middleware.dart';
import 'supervisor_middleware.dart';
import '../modules/settings/settings_page.dart';
import '../modules/spk/spk_page.dart';
import '../modules/spk/spk_binding.dart';
import '../modules/spk/spk_details_page.dart';
import '../modules/spk/spk_details_binding.dart';
import '../modules/work_report/work_report_page.dart';
import '../modules/work_report/work_report_binding.dart';
import '../modules/add_work_report/add_work_report_page.dart';
import '../modules/add_work_report/add_work_report_binding.dart';
import '../modules/equipment_report/equipment_report_page.dart';
import '../modules/equipment_report/equipment_report_binding.dart';
import '../modules/area_report/area_report_page.dart';
import '../modules/area_report/area_report_binding.dart';
import '../modules/equipment_approval/equipment_approval_page.dart';
import '../modules/equipment_approval/equipment_approval_binding.dart';

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
    GetPage(
      name: Routes.spkDetails,
      page: () => const SpkDetailsPage(),
      binding: SpkDetailsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.workReport,
      page: () => const WorkReportPage(),
      binding: WorkReportBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.addWorkReport,
      page: () => const AddWorkReportPage(),
      binding: AddWorkReportBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.equipmentReport,
      page: () => const EquipmentReportPage(),
      binding: EquipmentReportBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.areaReport,
      page: () => const AreaReportPage(),
      binding: AreaReportBinding(),
      middlewares: [AuthMiddleware(), SupervisorMiddleware()],
    ),
    GetPage(
      name: Routes.equipmentApproval,
      page: () => const EquipmentApprovalPage(),
      binding: EquipmentApprovalBinding(),
      middlewares: [AuthMiddleware(), SupervisorMiddleware()],
    ),
  ];
}
