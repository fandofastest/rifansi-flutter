import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../data/providers/graphql_service.dart';
import '../data/models/area_model.dart' as area_model;
import './auth_controller.dart';

class AreaReportController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // Observables
  final reports = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final searchKeyword = ''.obs;

  // Timer untuk timeout handling
  Timer? _timeoutTimer;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  @override
  void onClose() {
    print('[AreaReport] onClose called - cleaning up resources');

    // Cancel any running timers
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    // Dispose tab controller
    if (tabController.hasListeners) {
      tabController.removeListener(() {});
    }
    tabController.dispose();

    // Clear observables to prevent memory leaks
    reports.clear();

    print('[AreaReport] onClose completed - all resources cleaned up');
    super.onClose();
  }

  // Metode inisialisasi data
  Future<void> _initData() async {
    try {
      print('[AreaReport] Starting data initialization');

      // Get user's area from auth controller
      final authController = Get.find<AuthController>();
      final userArea = authController.currentUser.value?.area;

      if (userArea != null && userArea.id.isNotEmpty) {
        print('[AreaReport] Using user area: ${userArea.name}');
        await fetchReportsByArea(userArea.id);
      } else {
        print('[AreaReport] No user area found');
        error.value = 'Area pengguna tidak ditemukan';
      }

      print('[AreaReport] Data initialization completed');
    } catch (e) {
      print('[AreaReport] Error during initialization: $e');
      error.value = 'Error saat inisialisasi: $e';
    }
  }

  // Fungsi untuk mengambil laporan berdasarkan area
  Future<void> fetchReportsByArea(String areaId) async {
    // Cancel any existing timer
    _timeoutTimer?.cancel();

    try {
      isLoading.value = true;
      error.value = '';

      print('[AreaReport] Fetching reports for area: $areaId');

      // Set timeout with better error handling
      _timeoutTimer = Timer(const Duration(seconds: 30), () {
        if (isLoading.value) {
          print('[AreaReport] Timeout saat fetch reports');
          isLoading.value = false;
          error.value = 'Timeout: Koneksi terlalu lama';
          _timeoutTimer = null;
        }
      });

      final graphQLService = Get.find<GraphQLService>();
      final fetchedReports = await graphQLService
          .fetchLaporanByArea(areaId)
          .timeout(const Duration(seconds: 25), onTimeout: () {
        throw TimeoutException(
            'Timeout saat mengambil data laporan', const Duration(seconds: 25));
      });

      // Cancel timeout timer since we got response
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      reports.value = fetchedReports;
      print('[AreaReport] Fetched ${reports.length} reports for area');

      isLoading.value = false;
    } catch (e) {
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      print('[AreaReport] Error fetching reports by area: $e');
      isLoading.value = false;
      error.value = 'Gagal mengambil data laporan: $e';

      Get.snackbar(
        'Error',
        'Gagal mengambil data laporan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Fungsi untuk refresh data
  Future<void> refreshData() async {
    final authController = Get.find<AuthController>();
    final userArea = authController.currentUser.value?.area;

    if (userArea != null && userArea.id.isNotEmpty) {
      await fetchReportsByArea(userArea.id);
    } else {
      error.value = 'Area pengguna tidak ditemukan';
    }
  }

  // Helper function untuk format tanggal
  String formatDate(String timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }

  // Helper function untuk format waktu
  String formatTime(String? isoString) {
    if (isoString == null) return '-';
    try {
      final date = DateTime.parse(isoString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  // Helper function untuk mendapatkan warna status
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'submitted':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper function untuk mendapatkan icon status
  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'submitted':
        return Icons.pending;
      case 'draft':
        return Icons.edit;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}
