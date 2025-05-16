import 'package:get/get.dart';
import 'package:rifansi/app/data/providers/graphql_service.dart';
import '../data/models/spk_model.dart';
import '../data/models/area_model.dart';

class SpkController extends GetxController {
  final spks = <Spk>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSPKs();
  }

  Future<void> fetchSPKs({String? startDate, String? endDate, Area? area, String? keyword}) async {
    try {
      isLoading.value = true;
      error.value = '';
      if (keyword != null) searchKeyword.value = keyword;
      print('[SPK] Mulai fetchSPKs, startDate: '
          '\x1B[33m$startDate\x1B[0m, endDate: \x1B[33m$endDate\x1B[0m, area: \\${area?.id}, keyword: $keyword');

      final service = Get.find<GraphQLService>();
      final result = await service.fetchSPKs(
        startDate: startDate,
        endDate: endDate,
        locationId: area?.id,
        keyword: keyword ?? searchKeyword.value,
      );
      spks.value = result;
      print('[SPK] Jumlah SPK: \\${spks.length}');
    } catch (e, s) {
      print('[SPK] Error: $e\nStack: $s');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      print('[SPK] fetchSPKs selesai.');
    }
  }
} 