import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    // Tambahkan controller lain jika perlu
  }
} 