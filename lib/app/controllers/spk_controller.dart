import 'package:get/get.dart';
import 'package:rifansi/app/data/providers/graphql_service.dart';
import '../data/models/spk_model.dart';
import '../data/models/area_model.dart';
import './auth_controller.dart';

class SpkController extends GetxController {
  final spks = <Spk>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchSPKs();
  }

  Future<void> fetchSPKs(
      {String? startDate, String? endDate, Area? area, String? keyword}) async {
    try {
      isLoading.value = true;
      error.value = '';
      if (keyword != null) searchKeyword.value = keyword;

      // Check user area first
      final authController = Get.find<AuthController>();
      final userArea = authController.currentUser.value?.area;

      print('[SPK] User area: ${userArea?.name} (${userArea?.id})');

      // Determine which area to use for filtering
      String? locationIdToUse;

      if (userArea != null &&
          userArea.id.isNotEmpty &&
          userArea.name.toLowerCase() != 'allarea') {
        // User has specific area (not AllArea), use user's area
        locationIdToUse = userArea.id;
        print(
            '[SPK] Using user area for filter: ${userArea.name} (${userArea.id})');
      } else if (area != null &&
          area.id.isNotEmpty &&
          area.name.toLowerCase() != 'allarea' &&
          area.name.toLowerCase() != 'semua lokasi') {
        // User has AllArea or no area, but specific area is provided via parameter
        locationIdToUse = area.id;
        print(
            '[SPK] Using provided area for filter: ${area.name} (${area.id})');
      } else {
        // No area filter (AllArea or Semua Lokasi)
        locationIdToUse = null;
        print('[SPK] No area filter applied (AllArea or Semua Lokasi)');
      }

      print(
          '[SPK] Mulai fetchSPKs, startDate: $startDate, endDate: $endDate, locationId: $locationIdToUse, keyword: $keyword');

      final service = Get.find<GraphQLService>();
      final result = await service.fetchSPKs(
        startDate: startDate,
        endDate: endDate,
        locationId: locationIdToUse,
        keyword: keyword ?? searchKeyword.value,
      );
      spks.value = result;
      print('[SPK] Jumlah SPK: ${spks.length}');

      // Debug: show first few SPK locations
      if (spks.isNotEmpty) {
        final locations = spks.take(3).map((spk) => spk.location.name).toList();
        print('[SPK] Sample SPK locations: $locations');
      }
    } catch (e, s) {
      print('[SPK] Error: $e\nStack: $s');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      print('[SPK] fetchSPKs selesai.');
    }
  }
}
