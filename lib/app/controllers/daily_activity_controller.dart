import 'package:get/get.dart';
import '../data/models/daily_activity_input.dart';
import '../data/models/daily_activity_response.dart';
import '../data/providers/graphql_service.dart';
import '../data/providers/hive_service.dart';
import './auth_controller.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/spk_model.dart';

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
      print('[DailyActivity] Tab changed to index: ${tabController.index}');
      selectedTabIndex.value = tabController.index;
      // Update activities when tab changes
      updateActivitiesByTab();
    });

    // Mulai dengan langkah pembersihan dan inisialisasi data
    _initData();
  }

  @override
  void onClose() {
    print('[DailyActivity] onClose called - cleaning up resources');

    // Cancel any running timers
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    // Dispose tab controller
    if (tabController.hasListeners) {
      tabController.removeListener(() {});
    }
    tabController.dispose();

    // Clear observables to prevent memory leaks
    activities.clear();
    serverActivities.clear();
    localActivities.clear();

    print('[DailyActivity] onClose completed - all resources cleaned up');
    super.onClose();
  }

  // Metode inisialisasi data
  Future<void> _initData() async {
    try {
      print('[DailyActivity] Starting data initialization');

      // Langkah 1: Bersihkan duplikasi data terlebih dahulu
      await cleanupDuplicateActivities().timeout(const Duration(seconds: 15),
          onTimeout: () {
        print('[DailyActivity] Timeout during cleanup, continuing...');
        return;
      });

      // Langkah 2: Ambil data lokal secara terpisah
      await fetchLocalActivities().timeout(const Duration(seconds: 10),
          onTimeout: () {
        print(
            '[DailyActivity] Timeout fetching local activities, continuing...');
        return;
      });

      // Langkah 3: Ambil data server (dengan error handling yang tidak memblokir)
      try {
        await fetchServerActivities().timeout(const Duration(seconds: 30),
            onTimeout: () {
          print(
              '[DailyActivity] Timeout fetching server activities, using local data only');
          return;
        });
      } catch (e) {
        print(
            '[DailyActivity] Server fetch failed, continuing with local data: $e');
        // Don't set error here, just log it
      }

      print('[DailyActivity] Data initialization completed');
    } catch (e) {
      print('[DailyActivity] Error saat inisialisasi data: $e');
      error.value = 'Terjadi kesalahan saat memuat data: $e';
      // Ensure loading is set to false even if there's an error
      isLoading.value = false;
    }
  }

  // Fungsi untuk mengambil aktivitas lokal (draft)
  Future<void> fetchLocalActivities() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Add timeout for local operations too
      final allActivities = await _hiveService
          .getAllDailyActivities()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'Timeout saat mengambil data lokal', const Duration(seconds: 10));
      });

      print('[DailyActivity] Loaded ${allActivities.length} local activities');

      // Debug: Print all activities with their sync status
      for (int i = 0; i < allActivities.length; i++) {
        final activity = allActivities[i];
        print(
            '[DailyActivity] Activity $i: ID=${activity.id}, localId=${activity.localId}, isSynced=${activity.isSynced}, status=${activity.status}, spkId=${activity.spkId}');
      }

      // Filter aktivitas lokal yang belum tersinkronisasi
      final List<DailyActivity> draftActivities =
          allActivities.where((activity) => !activity.isSynced).toList();

      print(
          '[DailyActivity] Found ${draftActivities.length} draft activities (isSynced=false)');

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
  Future<void> fetchServerActivities({String? keyword}) async {
    try {
      // Cancel any existing timer
      _timeoutTimer?.cancel();
      
      isLoading.value = true;
      error.value = '';
      
      // Set up timeout
      _timeoutTimer = Timer(const Duration(seconds: 30), () {
        if (isLoading.value) {
          isLoading.value = false;
          error.value = 'Request timeout. Please try again.';
        }
      });

      final result = await Get.find<GraphQLService>().fetchMyDailyActivity(limit: 20, skip: 0);
      print('[DailyActivity] Raw result: $result');
      
      // Cancel timer since we got a response
      _timeoutTimer?.cancel();
      
      if (result != null) {
        print('[DailyActivity] Result type: ${result.runtimeType}');
        print('[DailyActivity] Result keys: ${result.keys.toList()}');
        
        final activitiesList = result['activities'] as List?;
        print('[DailyActivity] Activities list: $activitiesList');
        
        if (activitiesList != null) {
          print('[DailyActivity] Number of activities: ${activitiesList.length}');
          if (activitiesList.isNotEmpty) {
            print('[DailyActivity] First activity: ${activitiesList.first}');
          }
          
          final activities = activitiesList.map((activity) {
            print('[DailyActivity] Processing activity: $activity');
            
            // Extract area information
            final areaData = activity['area'] as Map<String, dynamic>?;
            final locationName = areaData?['name']?.toString() ?? '';
            
            return DailyActivityResponse(
              id: activity['id']?.toString() ?? '',
              date: activity['date']?.toString() ?? '',
              status: activity['status']?.toString() ?? '',
              location: locationName,
              weather: activity['weather']?.toString() ?? '',
              workStartTime: activity['workStartTime']?.toString() ?? '',
              workEndTime: activity['workEndTime']?.toString() ?? '',
              startImages: [],
              finishImages: [],
              closingRemarks: '',
              progressPercentage: 0.0,
              activityDetails: [],
              equipmentLogs: [],
              manpowerLogs: [],
              materialUsageLogs: [],
              otherCosts: [],
              userDetail: UserResponse(
                id: '',
                username: '',
                fullName: '',
                email: '',
                role: '',
              ),
              createdAt: '',
              updatedAt: '',
              isApproved: false,
              rejectionReason: null,
              area: areaData != null ? AreaResponse.fromJson(areaData) : null,
              approvedBy: null,
              approvedAt: null,
              budgetUsage: null,
              spkDetail: activity['spk'] != null ? SPKResponse.fromJson(activity['spk']) : null,
            );
          }).toList();

          print('[DailyActivity] Processed activities count: ${activities.length}');

          // Filter activities if keyword is provided
          if (keyword != null && keyword.isNotEmpty) {
            final filteredActivities = activities.where((activity) {
              final spkNo = activity.spkDetail?.spkNo.toLowerCase() ?? '';
              final title = activity.spkDetail?.title.toLowerCase() ?? '';
              final searchTerm = keyword.toLowerCase();
              return spkNo.contains(searchTerm) || title.contains(searchTerm);
            }).toList();
            print('[DailyActivity] Filtered activities count: ${filteredActivities.length}');
            serverActivities.value = filteredActivities;
          } else {
            serverActivities.value = activities;
          }

          // Sort activities by date
          serverActivities.sort((a, b) => b.date.compareTo(a.date));
          print('[DailyActivity] Final server activities count: ${serverActivities.length}');
          
          // Update activities based on active tab
          updateActivitiesByTab();
        } else {
          print('[DailyActivity] Activities list is null');
        }
      } else {
        print('[DailyActivity] Result is null');
      }
    } catch (e) {
      error.value = e.toString();
      print('[DailyActivity] Error fetching server activities: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Memperbarui list activities berdasarkan tab yang aktif
  void updateActivitiesByTab() {
    print(
        '[DailyActivity] updateActivitiesByTab called, selectedTabIndex: ${selectedTabIndex.value}');
    print('[DailyActivity] localActivities.length: ${localActivities.length}');
    print(
        '[DailyActivity] serverActivities.length: ${serverActivities.length}');

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
      print(
          '[DailyActivity] Set activities to serverActivities: ${activities.length} items');
    } else {
      // Tab 1: Local Activities (draft)
      // Konversi dari DailyActivity ke DailyActivityResponse untuk UI
      final localResponses = localActivities.map((activity) {
        final response = activity.toResponse();
        print(
            '[DailyActivity] Converting activity: localId=${activity.localId}, status=${activity.status} -> response.id=${response.id}');
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
      print(
          '[DailyActivity] Set activities to localResponses: ${activities.length} items');
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

  // Fungsi untuk fetch aktivitas dari server berdasarkan area (untuk area report)
  Future<void> fetchServerActivitiesByArea({String? areaId}) async {
    // Cancel any existing timer
    _timeoutTimer?.cancel();

    try {
      isLoading.value = true;
      error.value = '';

      // Set timeout with better error handling
      _timeoutTimer = Timer(const Duration(seconds: 15), () {
        if (isLoading.value) {
          print('[DailyActivity] Timeout saat fetch activities by area');
          isLoading.value = false;
          error.value = 'Timeout: Koneksi terlalu lama';
          _timeoutTimer = null;
        }
      });

      String? currentAreaId = areaId;
      if (currentAreaId == null) {
        final authController = Get.find<AuthController>();
        if (authController.currentUser.value?.area != null) {
          currentAreaId = authController.currentUser.value!.area!.id;
          print(
              '[DailyActivity] Menggunakan area ID dari auth: $currentAreaId');
        } else {
          print('[DailyActivity] Area tidak ditemukan');
          error.value = 'Area tidak ditemukan';
          isLoading.value = false;
          _timeoutTimer?.cancel();
          return;
        }
      }

      print(
          '[DailyActivity] Memulai fetchServerActivitiesByArea, areaId: $currentAreaId');

      // Gunakan fungsi GraphQL baru fetchActivityByArea
      final service = Get.find<GraphQLService>();
      final rawResult = await service
          .fetchActivityByArea(areaId: currentAreaId, limit: 100)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw TimeoutException('Timeout saat mengambil data dari server',
            const Duration(seconds: 30));
      });

      // Cancel timer if successful
      _timeoutTimer?.cancel();
      _timeoutTimer = null;

      // DEBUG: Log raw data dari server
      print('[DailyActivity] === RAW AREA DATA DEBUG ===');
      print('[DailyActivity] Raw result: $rawResult');
      print('[DailyActivity] Activities count: ${rawResult['activities']?.length ?? 0}');
      print('[DailyActivity] Total count: ${rawResult['totalCount']}');
      print('[DailyActivity] Has more: ${rawResult['hasMore']}');

      final List<dynamic> activitiesData = rawResult['activities'] ?? [];
      
      for (int i = 0; i < activitiesData.length; i++) {
        final data = activitiesData[i];
        print('[DailyActivity] Raw Area Activity $i:');
        print('  - id: ${data['id']}');
        print('  - status: ${data['status']}');
        print('  - date: ${data['date']}');
        print('  - area: ${data['area']?['name']}');
        print('  - spk: ${data['spk']?['spkNo']}');
        print('  - user: ${data['user']?['fullName']}');
      }
      print('[DailyActivity] === END RAW AREA DATA DEBUG ===');

      // Convert raw Map data to DailyActivityResponse objects
      final List<DailyActivityResponse> result = activitiesData.map<DailyActivityResponse>((data) {
        try {
          // Map the response data to match DailyActivityResponse structure
          final mappedData = {
            'id': data['id']?.toString() ?? '',
            'date': data['date']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            'location': data['area']?['name']?.toString() ?? '',
            'weather': data['weather']?.toString() ?? '',
            'status': data['status']?.toString() ?? '',
            'workStartTime': data['workStartTime']?.toString() ?? '',
            'workEndTime': data['workEndTime']?.toString() ?? '',
            'startImages': [],
            'finishImages': [],
            'closingRemarks': '',
            'progressPercentage': 0.0,
            'activityDetails': [],
            'equipmentLogs': [],
            'manpowerLogs': [],
            'materialUsageLogs': [],
            'otherCosts': [],
            'spkDetail': data['spk'],
            'userDetail': data['user'],
            'createdAt': '',
            'updatedAt': '',
            'isApproved': false,
            'rejectionReason': null,
            'area': data['area'],
            'approvedBy': null,
            'approvedAt': null,
            'budgetUsage': null,
          };

          print('[DailyActivity] Parsing area activity: ${data['id']}');

          final response = DailyActivityResponse.fromJson(mappedData);

          print('  - Final response status: ${response.status}');
          print('  - Final response location: ${response.location}');

          return response;
        } catch (e) {
          print('[DailyActivity] Error parsing area activity data: $e');
          print('[DailyActivity] Raw data: $data');
          // Return a minimal response to avoid breaking the list
          return DailyActivityResponse(
            id: data['id']?.toString() ?? '',
            date: data['date']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            location: data['area']?['name']?.toString() ?? '',
            weather: data['weather']?.toString() ?? '',
            status: data['status']?.toString() ?? '',
            workStartTime: data['workStartTime']?.toString() ?? '',
            workEndTime: data['workEndTime']?.toString() ?? '',
            startImages: [],
            finishImages: [],
            closingRemarks: '',
            progressPercentage: 0.0,
            activityDetails: [],
            equipmentLogs: [],
            manpowerLogs: [],
            materialUsageLogs: [],
            otherCosts: [],
            spkDetail: data['spk'] != null
                ? SPKResponse.fromJson(data['spk'])
                : null,
            userDetail: data['user'] != null
                ? UserResponse.fromJson(data['user'])
                : UserResponse(
                    id: '',
                    username: '',
                    fullName: '',
                    email: '',
                    role: '',
                  ),
            createdAt: '',
            updatedAt: '',
            isApproved: false,
            rejectionReason: null,
            area: data['area'] != null
                ? AreaResponse.fromJson(data['area'])
                : null,
            approvedBy: null,
            approvedAt: null,
            budgetUsage: null,
          );
        }
      }).toList();

      // DEBUG: Log parsed results
      print('[DailyActivity] === PARSED AREA RESULTS DEBUG ===');
      print('[DailyActivity] Parsed area results length: ${result.length}');
      for (int i = 0; i < result.length; i++) {
        final activity = result[i];
        print('[DailyActivity] Parsed Area Activity $i:');
        print('  - id: ${activity.id}');
        print('  - status: ${activity.status}');
        print('  - spkDetail: ${activity.spkDetail?.spkNo}');
        print('  - userDetail: ${activity.userDetail.fullName}');
        print('  - location: ${activity.location}');
      }
      print('[DailyActivity] === END PARSED AREA RESULTS DEBUG ===');

      // Simpan hasil dari server
      serverActivities.value = result;

      // Urutkan serverActivities dengan yang terbaru di atas
      serverActivities.sort((a, b) {
        try {
          DateTime dateA = _parseActivityDate(a.date);
          DateTime dateB = _parseActivityDate(b.date);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      // Update activities berdasarkan tab yang aktif
      updateActivitiesByTab();

      isLoading.value = false;
      print(
          '[DailyActivity] Success: Area server activities loaded: ${serverActivities.length}');
    } catch (e) {
      print('[DailyActivity] Error: $e');
      error.value = e.toString();
      isLoading.value = false;
    } finally {
      _timeoutTimer?.cancel();
      _timeoutTimer = null;
      print(
          '[DailyActivity] fetchServerActivitiesByArea selesai. isLoading: ${isLoading.value}');
    }
  }

  // Get count of approved reports
  int get approvedReportsCount {
    return serverActivities.where((activity) {
      final status = activity.status.toLowerCase();
      return status.contains('approved') ||
          status.contains('disetujui') ||
          activity.isApproved;
    }).length;
  }

  // Get count of rejected reports
  int get rejectedReportsCount {
    return serverActivities.where((activity) {
      final status = activity.status.toLowerCase();
      return status.contains('rejected') || status.contains('ditolak');
    }).length;
  }

  // Get count of pending reports (submitted but not yet approved/rejected)
  int get pendingReportsCount {
    return serverActivities.where((activity) {
      final status = activity.status.toLowerCase();
      return status.contains('submitted') ||
          status.contains('terkirim') ||
          status.contains('pending');
    }).length;
  }

  // Get total reports count (server + local)
  int get totalReportsCount {
    return serverActivities.length + localActivities.length;
  }
}
