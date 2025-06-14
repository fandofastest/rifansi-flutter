import 'package:get/get.dart';
import '../data/providers/graphql_service.dart';

class EquipmentApprovalController extends GetxController {
  final isLoading = false.obs;
  final pendingReports = <Map<String, dynamic>>[].obs;
  final allReports = <Map<String, dynamic>>[].obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingReports();
  }

  Future<void> fetchPendingReports() async {
    try {
      isLoading.value = true;
      error.value = '';

      print('[EquipmentApproval] Fetching pending repair reports...');

      final graphQLService = Get.find<GraphQLService>();
      // Fetch all reports from my area (no status filter to get all)
      final fetchedReports = await graphQLService.fetchMyAreaRepairReports();

      // Store all reports for filtering
      allReports.assignAll(fetchedReports);

      // Filter only pending reports for the pending tab
      final pending = fetchedReports.where((report) {
        final status = report['status']?.toString().toLowerCase() ?? '';
        return status == 'pending' || status == 'submitted' || status == 'open';
      }).toList();

      pendingReports.assignAll(pending);

      print(
          '[EquipmentApproval] Successfully fetched ${fetchedReports.length} total reports');
      print('[EquipmentApproval] ${pending.length} pending reports');

      // Debug: Print report status distribution
      final statusCounts = <String, int>{};
      for (final report in fetchedReports) {
        final status = report['status']?.toString() ?? 'Unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
      print('[EquipmentApproval] Report status distribution: $statusCounts');
    } catch (e) {
      print('[EquipmentApproval] Error fetching reports: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Get pending reports (for pending tab) - only unprocessed reports
  List<Map<String, dynamic>> get pendingReportsList {
    return allReports.where((report) {
      final status = report['status']?.toString().toLowerCase() ?? '';
      // Only show truly pending reports, exclude processed ones
      return status == 'pending' || status == 'submitted' || status == 'open';
    }).toList();
  }

  // Get responded reports (for responded tab) - all processed reports
  List<Map<String, dynamic>> get respondedReportsList {
    return allReports.where((report) {
      final status = report['status']?.toString().toLowerCase() ?? '';
      // Show all processed reports (approved, rejected, completed, etc.)
      return status == 'approved' ||
          status == 'rejected' ||
          status == 'closed' ||
          status == 'completed' ||
          status == 'in_progress' ||
          status == 'under_review';
    }).toList();
  }

  // Approve equipment repair report
  Future<void> approveReport({
    required String reportId,
    required String reviewNotes,
    String? assignedTechnician,
    double? estimatedCost,
    String priority = 'MEDIUM',
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('[EquipmentApproval] Approving report: $reportId');

      final graphQLService = Get.find<GraphQLService>();
      await graphQLService.approveEquipmentRepairReport(
        id: reportId,
        reviewNotes: reviewNotes,
        assignedTechnician: assignedTechnician,
        estimatedCost: estimatedCost,
        priority: priority,
      );

      print('[EquipmentApproval] Report approved successfully');

      // Refresh data after approval
      await fetchPendingReports();

      Get.snackbar(
        'Berhasil',
        'Laporan kerusakan alat berhasil disetujui',
        backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
        colorText: Get.theme.colorScheme.primary,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('[EquipmentApproval] Error approving report: $e');
      error.value = e.toString();

      Get.snackbar(
        'Error',
        'Gagal menyetujui laporan: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reject equipment repair report
  Future<void> rejectReport({
    required String reportId,
    required String rejectionReason,
    String? reviewNotes,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('[EquipmentApproval] Rejecting report: $reportId');

      final graphQLService = Get.find<GraphQLService>();
      await graphQLService.rejectEquipmentRepairReport(
        id: reportId,
        rejectionReason: rejectionReason,
        reviewNotes: reviewNotes,
      );

      print('[EquipmentApproval] Report rejected successfully');

      // Refresh data after rejection
      await fetchPendingReports();

      Get.snackbar(
        'Berhasil',
        'Laporan kerusakan alat berhasil ditolak',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('[EquipmentApproval] Error rejecting report: $e');
      error.value = e.toString();

      Get.snackbar(
        'Error',
        'Gagal menolak laporan: $e',
        backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
        colorText: Get.theme.colorScheme.error,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh all data
  Future<void> refreshReports() async {
    await fetchPendingReports();
  }

  // Get report by ID
  Map<String, dynamic>? getReportById(String reportId) {
    try {
      return allReports.firstWhere((report) => report['id'] == reportId);
    } catch (e) {
      return null;
    }
  }

  // Get counts for statistics
  int get totalReportsCount => allReports.length;
  int get pendingReportsCount => pendingReportsList.length;
  int get approvedReportsCount {
    return allReports.where((report) {
      final status = report['status']?.toString().toLowerCase() ?? '';
      return status == 'approved';
    }).length;
  }

  int get rejectedReportsCount {
    return allReports.where((report) {
      final status = report['status']?.toString().toLowerCase() ?? '';
      return status == 'rejected';
    }).length;
  }
}
