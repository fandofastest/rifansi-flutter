import 'package:get/get.dart';
import '../data/models/area_model.dart';
import '../data/providers/graphql_service.dart';

class LokasiController extends GetxController {
  final areas = <Area>[].obs;
  final selectedArea = Rxn<Area>();
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAreas();
  }

  Future<void> fetchAreas() async {
    try {
      isLoading.value = true;
      error.value = '';
      final result = await Get.find<GraphQLService>().getAllAreas();
      print('[LokasiController] fetched areas: \\${result.map((e) => e.name).toList()}');
      areas.assignAll(result);
      if (result.isNotEmpty) selectedArea.value = result.first;
    } catch (e) {
      error.value = e.toString();
      print('[LokasiController] fetchAreas error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectArea(Area area) {
    selectedArea.value = area;
    print('[LokasiController] selected area: \\${area.name}');
  }
} 