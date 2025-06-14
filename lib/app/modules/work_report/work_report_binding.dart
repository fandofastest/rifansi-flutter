import 'package:get/get.dart';
import '../../controllers/lokasi_controller.dart';
import '../../controllers/daily_activity_controller.dart';

class WorkReportBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut with fenix: false to ensure proper disposal
    Get.lazyPut<DailyActivityController>(
      () => DailyActivityController(),
      fenix: false, // Don't recreate after disposal
    );

    // Pastikan LokasiController sudah terinisialisasi
    if (!Get.isRegistered<LokasiController>()) {
      Get.lazyPut<LokasiController>(
        () => LokasiController(),
        fenix: false,
      );
    }
  }
}
