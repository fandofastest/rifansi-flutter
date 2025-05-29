import 'package:get/get.dart';
import '../../controllers/spk_details_controller.dart';

class SpkDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpkDetailsController>(
      () => SpkDetailsController(spkId: Get.arguments['spkId']),
    );
  }
}
