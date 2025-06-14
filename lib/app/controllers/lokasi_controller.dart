import 'package:get/get.dart';
import '../data/models/area_model.dart';
import '../data/providers/graphql_service.dart';
import 'dart:async';
import 'dart:io';

class LokasiController extends GetxController {
  final areas = <Area>[].obs;
  final selectedArea = Rxn<Area>();
  final isLoading = false.obs;
  final error = ''.obs;

  // Flag untuk cek apakah area sudah diambil, untuk menghindari fetch berulang kali
  final hasLoadedAreas = false.obs;

  // Timer untuk timeout handling
  Timer? _timeoutTimer;

  @override
  void onInit() {
    super.onInit();
    // _initDefaultArea();
    fetchAreas();
  }

  @override
  void onClose() {
    print('[LokasiController] onClose called - cleaning up resources');

    // Cancel any running timers
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    // Clear observables to prevent memory leaks
    areas.clear();
    selectedArea.value = null;

    print('[LokasiController] onClose completed - all resources cleaned up');
    super.onClose();
  }

  // Inisialisasi area default

  Future<bool> fetchAreas() async {
    // Cancel any existing timer
    _timeoutTimer?.cancel();

    // Jika sudah pernah diambil dan berhasil, tidak perlu fetch lagi
    if (hasLoadedAreas.value && areas.isNotEmpty) {
      print(
          '[LokasiController] Menggunakan area yang sudah di-cache: ${areas.length} areas');
      return true;
    }

    try {
      isLoading.value = true;
      error.value = '';

      print('[LokasiController] Starting fetchAreas');

      // Set timeout with better error handling
      _timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (isLoading.value) {
          print('[LokasiController] Timeout fetchAreas');
          isLoading.value = false;
          error.value = 'Timeout: Koneksi terlalu lama';
          _timeoutTimer = null;
        }
      });

      // Fetch data with timeout
      final result = await Get.find<GraphQLService>()
          .getAllAreas()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException(
            'Timeout saat mengambil data area', const Duration(seconds: 30));
      });

      // Cancel timer if successful
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      if (result.isNotEmpty) {
        print(
            '[LokasiController] fetched areas: ${result.map((e) => e.name).toList()}');
        areas.assignAll(result);
        hasLoadedAreas.value = true;
        isLoading.value = false;
        return true;
      } else {
        areas.clear();
        print('[LokasiController] No areas found');
        isLoading.value = false;
        return true;
      }
    } catch (e) {
      error.value = e.toString();
      print('[LokasiController] fetchAreas error: $e');
      isLoading.value = false;
      return false;
    } finally {
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
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
    );

    return [defaultArea, ...areas];
  }
}
