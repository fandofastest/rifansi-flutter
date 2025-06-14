import 'package:get/get.dart';
import '../../controllers/equipment_approval_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/providers/graphql_service.dart';

class EquipmentApprovalBinding extends Bindings {
  @override
  void dependencies() {
    // Register EquipmentApprovalController
    Get.lazyPut<EquipmentApprovalController>(
      () => EquipmentApprovalController(),
      fenix: false,
    );

    // Ensure AuthController is initialized
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(),
        fenix: false,
      );
    }

    // Ensure GraphQLService is initialized
    if (!Get.isRegistered<GraphQLService>()) {
      Get.lazyPut<GraphQLService>(
        () => GraphQLService(),
        fenix: false,
      );
    }
  }
}
