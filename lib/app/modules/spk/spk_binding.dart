import 'package:get/get.dart';
import '../../controllers/spk_controller.dart';
import '../../controllers/lokasi_controller.dart';

class SpkBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpkController>(
      () => SpkController(),
    );
    Get.lazyPut<LokasiController>(() => LokasiController());
  }
} 