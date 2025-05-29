import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_activity_input.dart';

class HiveService extends GetxService {
  static const String DAILY_ACTIVITIES_BOX = 'daily_activities';

  late Box<DailyActivity> _dailyActivitiesBox;

  Future<HiveService> init() async {
    try {
      // Inisialisasi Hive
      final appDocDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocDir.path);

      // Registrasi adapter untuk model
      Hive.registerAdapter(DailyActivityAdapter());
      Hive.registerAdapter(QuantityAdapter());
      Hive.registerAdapter(ActivityDetailAdapter());
      Hive.registerAdapter(EquipmentLogAdapter());
      Hive.registerAdapter(ManpowerLogAdapter());
      Hive.registerAdapter(MaterialUsageLogAdapter());
      Hive.registerAdapter(OtherCostAdapter());

      // Buka box
      _dailyActivitiesBox =
          await Hive.openBox<DailyActivity>(DAILY_ACTIVITIES_BOX);

      print(
          '[HiveService] Initialized successfully with ${_dailyActivitiesBox.length} daily activities');
      return this;
    } catch (e) {
      print('[HiveService] Error initializing: $e');
      rethrow;
    }
  }

  // ====== DAILY ACTIVITY METHODS ======

  // Simpan DailyActivity
  Future<void> saveDailyActivity(DailyActivity activity) async {
    try {
      await _dailyActivitiesBox.put(activity.localId, activity);
      print(
          '[HiveService] DailyActivity saved with local ID: ${activity.localId}');
    } catch (e) {
      print('[HiveService] Error saving DailyActivity: $e');
      rethrow;
    }
  }

  // Ambil DailyActivity berdasarkan localId
  Future<DailyActivity?> getDailyActivity(String localId) async {
    try {
      return _dailyActivitiesBox.get(localId);
    } catch (e) {
      print('[HiveService] Error getting DailyActivity: $e');
      return null;
    }
  }

  // Hapus DailyActivity berdasarkan localId
  Future<void> deleteDailyActivity(String localId) async {
    try {
      await _dailyActivitiesBox.delete(localId);
      print('[HiveService] DailyActivity deleted with local ID: $localId');
    } catch (e) {
      print('[HiveService] Error deleting DailyActivity: $e');
      rethrow;
    }
  }

  // Ambil semua DailyActivity
  Future<List<DailyActivity>> getAllDailyActivities() async {
    try {
      return _dailyActivitiesBox.values.toList();
    } catch (e) {
      print('[HiveService] Error getting all DailyActivities: $e');
      return [];
    }
  }

  // Hapus semua DailyActivity
  Future<void> clearDailyActivities() async {
    try {
      await _dailyActivitiesBox.clear();
      print('[HiveService] All DailyActivities cleared');
    } catch (e) {
      print('[HiveService] Error clearing DailyActivities: $e');
      rethrow;
    }
  }

  // Ambil DailyActivity yang belum tersinkronisasi
  Future<List<DailyActivity>> getUnsyncedActivities() async {
    try {
      final allActivities = await getAllDailyActivities();
      return allActivities.where((activity) => !activity.isSynced).toList();
    } catch (e) {
      print('[HiveService] Error getting unsynced activities: $e');
      return [];
    }
  }

  // Metode untuk menutup box saat aplikasi berhenti
  Future<void> closeBoxes() async {
    try {
      await _dailyActivitiesBox.close();
      print('[HiveService] Daily activities box closed');
    } catch (e) {
      print('[HiveService] Error closing boxes: $e');
      rethrow;
    }
  }
}
