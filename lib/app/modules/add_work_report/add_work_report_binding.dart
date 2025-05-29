import 'package:get/get.dart';
import '../../controllers/add_work_report_controller.dart';
import '../../controllers/material_controller.dart';
import '../../controllers/other_cost_controller.dart';
import '../../controllers/work_progress_controller.dart';

class AddWorkReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddWorkReportController>(() => AddWorkReportController());
    Get.lazyPut<MaterialController>(() => MaterialController());
    Get.lazyPut<OtherCostController>(() => OtherCostController());
    Get.lazyPut<WorkProgressController>(() => WorkProgressController());
  }
}
