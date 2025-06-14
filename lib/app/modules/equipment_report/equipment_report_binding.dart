import 'package:get/get.dart';
import 'equipment_report_controller.dart';
import '../../data/providers/graphql_service.dart';

class EquipmentReportBinding extends Bindings {
  @override
  void dependencies() {
    // Make sure GraphQLService is available
    if (!Get.isRegistered<GraphQLService>()) {
      Get.lazyPut<GraphQLService>(() => GraphQLService());
    }
    
    // Register the controller
    Get.lazyPut<EquipmentReportController>(() => EquipmentReportController());
  }
} 