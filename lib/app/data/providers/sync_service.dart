import 'package:get/get.dart';
import '../models/daily_activity_input.dart';
import '../models/daily_activity_response.dart';
import './hive_service.dart';
import './graphql_service.dart';

class SyncService extends GetxService {
  final _hiveService = Get.find<HiveService>();
  final _graphqlService = Get.find<GraphQLService>();

  // Status sinkronisasi
  final isSyncing = false.obs;
  final syncError = ''.obs;
  final syncProgress = 0.0.obs;

  // Menyimpan laporan baru ke lokal dan mencoba sinkronisasi
  Future<void> saveAndSync(DailyActivity activity) async {
    try {
      // Simpan ke lokal storage
      await _hiveService.saveDailyActivity(activity);

      // Coba sinkronisasi jika ada koneksi
      if (await _hasInternetConnection()) {
        await _syncActivity(activity);
      }
    } catch (e) {
      print('[Sync] Error saving activity: $e');
      syncError.value = e.toString();
    }
  }

  // Mendapatkan aktivitas yang belum tersinkronisasi
  Future<List<DailyActivity>> _getUnsyncedActivities() async {
    final allActivities = await _hiveService.getAllDailyActivities();
    return allActivities.where((activity) => !activity.isSynced).toList();
  }

  // Sinkronisasi semua laporan yang belum tersinkronisasi
  Future<void> syncAll() async {
    if (isSyncing.value) return;

    try {
      isSyncing.value = true;
      syncError.value = '';
      syncProgress.value = 0;

      // Ambil semua laporan yang belum tersinkronisasi
      final unsyncedActivities = await _getUnsyncedActivities();
      if (unsyncedActivities.isEmpty) {
        print('[Sync] No unsynced activities found');
        return;
      }

      print('[Sync] Found ${unsyncedActivities.length} unsynced activities');

      // Sinkronisasi satu per satu
      int successCount = 0;
      for (var activity in unsyncedActivities) {
        try {
          await _syncActivity(activity);
          successCount++;
          syncProgress.value = successCount / unsyncedActivities.length;
        } catch (e) {
          print('[Sync] Error syncing activity ${activity.id}: $e');
          // Lanjut ke activity berikutnya
          continue;
        }
      }

      print(
          '[Sync] Successfully synced $successCount/${unsyncedActivities.length} activities');
    } catch (e) {
      print('[Sync] Error in syncAll: $e');
      syncError.value = e.toString();
    } finally {
      isSyncing.value = false;
      syncProgress.value = 0;
    }
  }

  // Sinkronisasi satu laporan
  Future<void> _syncActivity(DailyActivity activity) async {
    try {
      // Skip jika sudah tersinkronisasi
      if (activity.isSynced) return;

      // Skip jika sudah terlalu banyak percobaan
      if (activity.syncRetryCount >= 3) {
        print('[Sync] Too many retry attempts for activity ${activity.id}');
        return;
      }

      print('[Sync] Syncing activity ${activity.id}');

      // Konversi ke format server
      final serverData = _convertToServerFormat(activity);

      // Kirim ke server menggunakan metode baru
      final result = await _graphqlService.submitDailyReport(serverData);

      // Update status di lokal storage
      final updatedActivity = activity.toSynced(result['id'] ?? '');
      await _hiveService.saveDailyActivity(updatedActivity);

      print(
          '[Sync] Successfully synced activity ${activity.id} with server ID: ${result['id']}');
    } catch (e) {
      print('[Sync] Error syncing activity ${activity.id}: $e');

      // Update status error di lokal storage
      final updatedActivity = activity.toFailed(e.toString());
      await _hiveService.saveDailyActivity(updatedActivity);

      rethrow;
    }
  }

  // Konversi DailyActivity ke format server
  Map<String, dynamic> _convertToServerFormat(DailyActivity activity) {
    // Langsung menggunakan method toRequestJson untuk konversi ke format server
    return activity.toRequestJson()['input'];
  }

  // Cek koneksi internet
  Future<bool> _hasInternetConnection() async {
    try {
      // TODO: Implementasi cek koneksi yang lebih baik
      return true;
    } catch (e) {
      return false;
    }
  }
}
