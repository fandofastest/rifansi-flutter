import 'package:get/get.dart';
import '../../controllers/lokasi_controller.dart';
import '../../controllers/daily_activity_controller.dart';

class WorkReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyActivityController>(() => DailyActivityController());
    
    // Pastikan LokasiController sudah terinisialisasi
    if (!Get.isRegistered<LokasiController>()) {
      Get.lazyPut<LokasiController>(() => LokasiController());
    }
  }
} 