import 'package:get/get.dart';
import '../../controllers/daily_activity_controller.dart';
import '../../controllers/lokasi_controller.dart';
import '../../controllers/auth_controller.dart';

class AreaReportBinding extends Bindings {
  @override
  void dependencies() {
    // Gunakan DailyActivityController yang sama dengan work_report
    if (!Get.isRegistered<DailyActivityController>()) {
      Get.lazyPut<DailyActivityController>(
        () => DailyActivityController(),
        fenix: false,
      );
    }

    // Pastikan AuthController sudah terinisialisasi
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(),
        fenix: false,
      );
    }

    // Pastikan LokasiController sudah terinisialisasi
    if (!Get.isRegistered<LokasiController>()) {
      Get.lazyPut<LokasiController>(
        () => LokasiController(),
        fenix: false,
      );
    }
  }
}
