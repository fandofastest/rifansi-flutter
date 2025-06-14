import 'package:get/get.dart';
import '../data/providers/graphql_service.dart';
import '../data/models/equipment_model.dart';

class EquipmentController extends GetxController {
  final isLoading = false.obs;
  final equipments = <Equipment>[].obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEquipments();
  }

  Future<void> fetchEquipments() async {
    try {
      isLoading.value = true;
      error.value = '';

      print('[EquipmentController] Fetching equipments with status...');

      final graphQLService = Get.find<GraphQLService>();
      final fetchedEquipments =
          await graphQLService.fetchEquipmentsWithStatus();

      equipments.assignAll(fetchedEquipments);

      print(
          '[EquipmentController] Successfully fetched ${equipments.length} equipments');

      // Debug: Print equipment status distribution
      final statusCounts = <String, int>{};
      for (final equipment in equipments) {
        final status = equipment.serviceStatus ?? 'Unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      print(
          '[EquipmentController] Equipment status distribution: $statusCounts');
    } catch (e) {
      print('[EquipmentController] Error fetching equipments: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Get count of damaged equipment
  int get damagedEquipmentCount {
    return equipments.where((equipment) {
      final status = equipment.serviceStatus?.toLowerCase();
      // Consider equipment as damaged if status contains words like 'rusak', 'broken', 'damaged', 'maintenance', etc.
      return status != null &&
          (status.contains('rusak') ||
              status.contains('broken') ||
              status.contains('damaged') ||
              status.contains('maintenance') ||
              status.contains('repair') ||
              status == 'out_of_service' ||
              status == 'inactive');
    }).length;
  }

  // Get count of ready equipment
  int get readyEquipmentCount {
    return equipments.where((equipment) {
      final status = equipment.serviceStatus?.toLowerCase();
      return status != null &&
          (status.contains('ready') ||
              status.contains('active') ||
              status.contains('available') ||
              status == 'operational');
    }).length;
  }

  // Get all damaged equipment
  List<Equipment> get damagedEquipments {
    return equipments.where((equipment) {
      final status = equipment.serviceStatus?.toLowerCase();
      return status != null &&
          (status.contains('rusak') ||
              status.contains('broken') ||
              status.contains('damaged') ||
              status.contains('maintenance') ||
              status.contains('repair') ||
              status == 'out_of_service' ||
              status == 'inactive');
    }).toList();
  }

  // Refresh equipment data
  Future<void> refreshEquipments() async {
    await fetchEquipments();
  }
}
