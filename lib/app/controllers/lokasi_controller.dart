import 'package:get/get.dart';
import '../data/models/area_model.dart';
import '../data/providers/graphql_service.dart';
import 'dart:async';

class LokasiController extends GetxController {
  final areas = <Area>[].obs;
  final selectedArea = Rxn<Area>();
  final isLoading = false.obs;
  final error = ''.obs;

  // Flag untuk cek apakah area sudah diambil, untuk menghindari fetch berulang kali
  final hasLoadedAreas = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initDefaultArea();
    fetchAreas();
  }

  // Inisialisasi area default
  void _initDefaultArea() {
    final defaultArea = Area(
      id: '',
      name: 'Semua Lokasi',
      location: Location(type: '', coordinates: []),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    selectedArea.value = defaultArea;
  }

  Future<bool> fetchAreas() async {
    // Jika sudah pernah diambil dan berhasil, tidak perlu fetch lagi
    if (hasLoadedAreas.value && areas.isNotEmpty) {
      print(
          '[LokasiController] Menggunakan area yang sudah di-cache: ${areas.length} areas');
      return true;
    }

    try {
      isLoading.value = true;
      error.value = '';

      // Set timeout 5 detik
      final completer = Completer<bool>();

      Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          print('[LokasiController] Timeout fetchAreas');
          completer.complete(false);
        }
      });

      // Fetch data
      Get.find<GraphQLService>().getAllAreas().then((result) {
        if (!completer.isCompleted) {
          if (result.isNotEmpty) {
            print(
                '[LokasiController] fetched areas: ${result.map((e) => e.name).toList()}');
            areas.assignAll(result);
            hasLoadedAreas.value = true;
            completer.complete(true);
          } else {
            areas.clear();
            print('[LokasiController] No areas found');
            completer.complete(true);
          }
        }
      }).catchError((e) {
        if (!completer.isCompleted) {
          error.value = e.toString();
          print('[LokasiController] fetchAreas error: $e');
          completer.complete(false);
        }
      });

      // Tunggu sampai fetch selesai atau timeout
      final success = await completer.future;

      return success;
    } catch (e) {
      error.value = e.toString();
      print('[LokasiController] fetchAreas unexpected error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void selectArea(Area area) {
    selectedArea.value = area;
    print('[LokasiController] selected area: ${area.name}');
  }

  // Mendapatkan semua area termasuk "Semua Lokasi"
  List<Area> getAllAreasWithDefault() {
    final defaultArea = Area(
      id: '',
      name: 'Semua Lokasi',
      location: Location(type: '', coordinates: []),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return [defaultArea, ...areas];
  }
}
