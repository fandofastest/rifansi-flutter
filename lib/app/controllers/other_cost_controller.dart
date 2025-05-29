import 'package:get/get.dart';
import '../data/models/daily_activity_model.dart';

class OtherCostController extends GetxController {
  final otherCosts = <OtherCost>[].obs;

  void addOtherCost(OtherCost cost) {
    otherCosts.add(cost);
  }

  void removeOtherCost(String id) {
    otherCosts.removeWhere((cost) => cost.id == id);
  }

  double get totalCost => otherCosts.fold(
        0.0,
        (sum, cost) => sum + cost.amount,
      );
}
