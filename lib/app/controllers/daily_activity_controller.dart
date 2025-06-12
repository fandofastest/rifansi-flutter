import 'package:get/get.dart';
import '../data/models/daily_activity_input.dart';
import '../data/models/daily_activity_response.dart';
import '../data/providers/graphql_service.dart';
import '../data/providers/hive_service.dart';
import './auth_controller.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class DailyActivityController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final activities = <DailyActivityResponse>[].obs;
  final serverActivities = <DailyActivityResponse>[].obs; // Laporan dari server
  final localActivities = <DailyActivity>[].obs; // Laporan lokal
  final isLoading = false.obs;
  final error = ''.obs;
  final searchKeyword = ''.obs;
  Timer? _timeoutTimer;
  final _hiveService = Get.find<HiveService>();

  // Tab controller untuk tab server dan lokal
  late TabController tabController;
  final selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi tab controller dengan 2 tab
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });

    // Mulai dengan langkah pembersihan dan inisialisasi data
    _initData();
  }

  @override
  void onClose() {
    _timeoutTimer?.cancel();
    tabController.dispose();
    super.onClose();
  }

  // Metode inisialisasi data
  Future<void> _initData() async {
    try {
      // Langkah 1: Bersihkan duplikasi data terlebih dahulu
      await cleanupDuplicateActivities();

      // Langkah 2: Ambil data lokal secara terpisah
      await fetchLocalActivities();

      // Langkah 3: Ambil data server
      await fetchServerActivities();
    } catch (e) {
      print('[DailyActivity] Error saat inisialisasi data: $e');
      error.value = 'Terjadi kesalahan saat memuat data: $e';
    }
  }

  // Fungsi untuk mengambil aktivitas lokal (draft)
  Future<void> fetchLocalActivities() async {
    try {
      isLoading.value = true;
      error.value = '';

      final allActivities = await _hiveService.getAllDailyActivities();
      print('[DailyActivity] Loaded ${allActivities.length} local activities');

      // Filter aktivitas lokal yang belum tersinkronisasi
      final List<DailyActivity> draftActivities =
          allActivities.where((activity) => !activity.isSynced).toList();

      // Konversi ke DailyActivityResponse untuk UI
      final List<DailyActivityResponse> draftResponses =
          draftActivities.map((activity) => activity.toResponse()).toList();

      // Update state
      localActivities.value = draftActivities;

      isLoading.value = false;
      print(
          '[DailyActivity] Success: Local activities loaded: ${localActivities.length}');
    } catch (e) {
      print('[DailyActivity] Error loading local activities: $e');
      error.value = e.toString();
      isLoading.value = false;
    }
  }

  // Fungsi untuk fetch aktivitas dari server
  Future<void> fetchServerActivities({String? userId, String? keyword}) async {
    _timeoutTimer?.cancel();

    try {
      isLoading.value = true;
      error.value = '';

      if (keyword != null) searchKeyword.value = keyword;

      _timeoutTimer = Timer(const Duration(seconds: 10), () {
        if (isLoading.value) {
          print('[DailyActivity] Timeout saat fetch activities');
          isLoading.value = false;
          error.value = 'Timeout: Koneksi terlalu lama';
        }
      });

      String? currentUserId = userId;
      if (currentUserId == null) {
        final authController = Get.find<AuthController>();
        if (authController.currentUser.value != null) {
          currentUserId = authController.currentUser.value!.id;
          print(
              '[DailyActivity] Menggunakan user ID dari auth: $currentUserId');
        } else {
          print('[DailyActivity] User belum login');
          error.value = 'User belum login';
          isLoading.value = false;
          return;
        }
      }

      print(
          '[DailyActivity] Memulai fetchActivities, userId: $currentUserId, keyword: $keyword');

      // Ambil data dari server
      final service = Get.find<GraphQLService>();
      final result = await service.fetchWorkReports(userId: currentUserId);
      _timeoutTimer?.cancel();

      // Debug log untuk memeriksa struktur data
      if (result.isNotEmpty) {
        print('============== DATA AKTIVITAS ==============');
        print('SPK Detail: ${result[0].spkDetail}');
        // Location tidak ada di SPKResponse yang baru
        // print('SPK Location: ${result[0].spkDetail?.location}');
        print('Activity location: ${result[0].location}');
        // areaId tidak ada di model response
        // print('Activity areaId: ${result[0].areaId}');
        print('============================================');
      }

      List<DailyActivityResponse> filteredServerActivities = result;
      if (searchKeyword.value.isNotEmpty) {
        final kw = searchKeyword.value.toLowerCase();
        filteredServerActivities = filteredServerActivities.where((activity) {
          return activity.id.toLowerCase().contains(kw) ||
              (activity.spkDetail?.id.toLowerCase().contains(kw) ?? false);
          // areaId tidak ada di model response
          // (activity.areaId?.toLowerCase().contains(kw) ?? false);
        }).toList();
        print(
            '[DailyActivity] Filtered by keyword: ${filteredServerActivities.length} items');
      }

      // Simpan hasil dari server
      serverActivities.value = filteredServerActivities;

      // Urutkan serverActivities dengan yang terbaru di atas
      serverActivities.sort((a, b) {
        try {
          // Coba parse tanggal dari format epoch atau string ISO
          DateTime dateA = _parseActivityDate(a.date);
          DateTime dateB = _parseActivityDate(b.date);
          // Urutkan descending (terbaru di atas)
          return dateB.compareTo(dateA);
        } catch (e) {
          // Jika gagal parsing, gunakan urutan asli
          return 0;
        }
      });

      isLoading.value = false;
      print(
          '[DailyActivity] Success: Server activities loaded: ${serverActivities.length}');
    } catch (e) {
      print('[DailyActivity] Error: $e');
      error.value = e.toString();
      isLoading.value = false;
    } finally {
      _timeoutTimer?.cancel();
      print(
          '[DailyActivity] fetchServerActivities selesai. isLoading: ${isLoading.value}');
    }
  }

  // Metode utama yang dipanggil dari UI untuk refresh data
  Future<void> fetchActivities({String? userId, String? keyword}) async {
    // Reset pencarian jika keyword diberikan
    if (keyword != null) {
      searchKeyword.value = keyword;
    }

    // Ambil data lokal terlebih dahulu
    await fetchLocalActivities();

    // Kemudian ambil data server
    await fetchServerActivities(userId: userId, keyword: keyword);

    // Update activities berdasarkan tab yang aktif
    updateActivitiesByTab();
  }

  // Memperbarui list activities berdasarkan tab yang aktif
  void updateActivitiesByTab() {
    if (selectedTabIndex.value == 0) {
      // Tab 0: Server Activities
      // Urutkan serverActivities dengan yang terbaru di atas
      serverActivities.sort((a, b) {
        try {
          DateTime dateA = _parseActivityDate(a.date);
          DateTime dateB = _parseActivityDate(b.date);
          // Urutkan descending (terbaru di atas)
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });
      activities.value = serverActivities;
    } else {
      // Tab 1: Local Activities (draft)
      // Konversi dari DailyActivity ke DailyActivityResponse untuk UI
      final localResponses = localActivities.map((activity) {
        final response = activity.toResponse();
        return response;
      }).toList();

      // Urutkan local activities juga berdasarkan tanggal terbaru
      localResponses.sort((a, b) {
        try {
          DateTime dateA = _parseActivityDate(a.date);
          DateTime dateB = _parseActivityDate(b.date);
          // Urutkan descending (terbaru di atas)
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      // Debug log untuk membantu troubleshooting
      print(
          '[DailyActivity] Converted ${localResponses.length} local activities to display');
      if (localResponses.isNotEmpty) {
        print(
            '[DailyActivity] Sample draft data: ID=${localResponses[0].id}, status=${localResponses[0].status}, date=${localResponses[0].date}');
      }

      activities.value = localResponses;
    }
  }

  // Method untuk menghapus aktivitas draft berdasarkan ID
  Future<void> deleteDraftActivity(String activityId) async {
    try {
      print('[DailyActivity] Menghapus draft dengan ID: $activityId');

      // Karena sekarang ID pada response adalah localId, kita langsung bisa menggunakan activityId
      await _hiveService.deleteDailyActivity(activityId);

      final all = await _hiveService.getAllDailyActivities();
      print(
          '[Controller] Sisa draft setelah delete: ${all.where((a) => !a.isSynced).length}');
      print('[DailyActivity] Berhasil menghapus dari database activitiesBox');

      Get.snackbar(
        'Sukses',
        'Draft laporan berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      );

      // Refresh data lokal
      await fetchLocalActivities();

      // Update tampilan berdasarkan tab yang aktif
      updateActivitiesByTab();
    } catch (e) {
      print('[DailyActivity] Error menghapus draft activity: $e');
      error.value = 'Gagal menghapus draft: $e';
      Get.snackbar(
        'Error',
        'Gagal menghapus draft: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Method untuk membersihkan data yang terduplikasi (panggil setiap kali aplikasi dibuka)
  Future<void> cleanupDuplicateActivities() async {
    try {
      final allActivities = await _hiveService.getAllDailyActivities();
      print('[DailyActivity] Cleaning up ${allActivities.length} activities');

      final Map<String, List<DailyActivity>> activityMap = {};
      for (var activity in allActivities) {
        String compositeKey = '${activity.spkId}_${activity.date}';
        if (!activityMap.containsKey(compositeKey)) {
          activityMap[compositeKey] = [];
        }
        activityMap[compositeKey]!.add(activity);
      }

      await _hiveService.clearDailyActivities();

      for (var activities in activityMap.values) {
        if (activities.length > 1) {
          activities.sort((a, b) => b.id.compareTo(a.id));
          await _hiveService.saveDailyActivity(activities.first);
          print(
              '[DailyActivity] Kept 1 of ${activities.length} duplicates: ${activities.first.id}');
        } else if (activities.length == 1) {
          await _hiveService.saveDailyActivity(activities.first);
        }
      }

      final remainingActivities = await _hiveService.getAllDailyActivities();
      print(
          '[DailyActivity] Cleanup complete. ${remainingActivities.length} activities remaining');
    } catch (e) {
      print('[DailyActivity] Error cleaning up activities: $e');
    }
  }

  // Helper untuk parsing tanggal dari berbagai format
  DateTime _parseActivityDate(String dateString) {
    try {
      // Coba parse sebagai epoch milliseconds
      final epochMs = int.parse(dateString);
      return DateTime.fromMillisecondsSinceEpoch(epochMs);
    } catch (_) {
      try {
        // Coba parse sebagai ISO date string
        return DateTime.parse(dateString);
      } catch (e) {
        // Fallback ke tanggal sekarang
        return DateTime.now();
      }
    }
  }
}
