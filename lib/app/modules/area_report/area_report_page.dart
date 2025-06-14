import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../controllers/daily_activity_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/daily_activity_response.dart';
import '../../data/providers/graphql_service.dart';
import 'widgets/area_activity_card.dart';

class AreaReportPage extends StatefulWidget {
  const AreaReportPage({Key? key}) : super(key: key);

  @override
  State<AreaReportPage> createState() => _AreaReportPageState();
}

class _AreaReportPageState extends State<AreaReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RxInt selectedTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      selectedTabIndex.value = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan DailyActivityController yang sama dengan work_report
    final controller = Get.find<DailyActivityController>();
    final authController = Get.find<AuthController>();

    // Refresh data saat masuk halaman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchServerActivitiesByArea();
    });

    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: Column(
        children: [
          _buildHeader(context, authController),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: FigmaColors.primary,
              unselectedLabelColor: FigmaColors.abu,
              indicatorColor: FigmaColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Menunggu Approval'),
                Tab(text: 'Sudah Direspons'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Pending (belum diapprove)
                _buildReportList(controller, isPending: true),
                // Tab 2: Sudah direspons (sudah diapprove)
                _buildReportList(controller, isPending: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthController authController) {
    final userArea = authController.currentUser.value?.area;
    final hasSpecificArea = userArea != null && userArea.id.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: const BoxDecoration(
        color: FigmaColors.primary,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Approval Laporan',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    if (hasSpecificArea) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.75),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            userArea!.name,
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => Get.find<DailyActivityController>()
                    .fetchServerActivitiesByArea(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(DailyActivityController controller,
      {required bool isPending}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            isPending
                ? 'Daftar Laporan Menunggu Approval'
                : 'Daftar Laporan Sudah Direspons',
            style: GoogleFonts.dmSans(
              color: FigmaColors.hitam,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(FigmaColors.primary),
                  ),
                );
              }

              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: FigmaColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.error.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: FigmaColors.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            controller.fetchServerActivitiesByArea(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FigmaColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'Coba Lagi',
                          style:
                              GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Debug logging
              print('[AREA REPORT DEBUG] === CHECKING APPROVAL DATA ===');
              print(
                  '[AREA REPORT DEBUG] Total server activities: ${controller.serverActivities.length}');
              print(
                  '[AREA REPORT DEBUG] Tab: ${isPending ? "Pending" : "Responded"}');

              // Log semua aktivitas
              for (int i = 0; i < controller.serverActivities.length; i++) {
                final activity = controller.serverActivities[i];
                print('[AREA REPORT DEBUG] Activity $i:');
                print('  - ID: ${activity.id}');
                print('  - Status: ${activity.status}');
                print('  - IsApproved: ${activity.isApproved}');
                print('  - SPK: ${activity.spkDetail?.spkNo ?? 'N/A'}');
                print('  - User: ${activity.userDetail.fullName}');
                print('  - Date: ${activity.date}');
              }

              // Filter berdasarkan status: Pending = "Submitted", sisanya = sudah direspons
              final filteredReports =
                  controller.serverActivities.where((activity) {
                final status = activity.status.toLowerCase();
                if (isPending) {
                  // Tab Pending: hanya status "submitted"
                  return status.contains('submitted');
                } else {
                  // Tab Sudah Direspons: selain "submitted" (approved, rejected, dll)
                  return !status.contains('submitted');
                }
              }).toList();

              print(
                  '[AREA REPORT DEBUG] Filtered reports: ${filteredReports.length}');

              // Log filtered reports
              for (int i = 0; i < filteredReports.length; i++) {
                final activity = filteredReports[i];
                print('[AREA REPORT DEBUG] Filtered Report $i:');
                print('  - ID: ${activity.id}');
                print('  - Status: ${activity.status}');
                print('  - IsApproved: ${activity.isApproved}');
                print('  - SPK: ${activity.spkDetail?.spkNo ?? 'N/A'}');
              }

              if (filteredReports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPending
                            ? Icons.pending_actions
                            : Icons.check_circle_outline,
                        size: 64,
                        color: FigmaColors.abu,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPending
                            ? 'Tidak ada laporan yang menunggu approval'
                            : 'Tidak ada laporan yang sudah direspons',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.abu,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total laporan: ${controller.serverActivities.length}',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.abu,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchServerActivitiesByArea(),
                color: FigmaColors.primary,
                child: ListView.builder(
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final activity = filteredReports[index];
                    return AreaActivityCard(
                      activity: activity,
                      onApprove: isPending
                          ? () => _showApprovalDialog(context, activity, true)
                          : null,
                      onReject: isPending
                          ? () => _showApprovalDialog(context, activity, false)
                          : null,
                      showActions:
                          isPending, // Hanya tampilkan tombol aksi di tab pending
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(
      BuildContext context, DailyActivityResponse activity, bool isApprove) {
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isApprove ? 'Setujui Laporan' : 'Tolak Laporan',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FigmaColors.hitam,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Laporan: ${activity.spkDetail?.title ?? activity.id}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: FigmaColors.hitam,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Oleh: ${activity.userDetail.fullName}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: FigmaColors.abu,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isApprove
                  ? 'Apakah Anda yakin ingin menyetujui laporan ini?'
                  : 'Apakah Anda yakin ingin menolak laporan ini?',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: FigmaColors.abu,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(
                labelText:
                    isApprove ? 'Catatan (opsional)' : 'Alasan penolakan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: FigmaColors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: FigmaColors.primary),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.dmSans(
                color: FigmaColors.abu,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final graphQLService = Get.find<GraphQLService>();
                await graphQLService.approveDailyReport(
                  id: activity.id,
                  status: isApprove ? 'Approved' : 'Rejected',
                  remarks: remarksController.text.isNotEmpty
                      ? remarksController.text
                      : null,
                );

                Navigator.pop(context);

                // Refresh data setelah approval
                Get.find<DailyActivityController>()
                    .fetchServerActivitiesByArea();

                Get.snackbar(
                  'Berhasil',
                  isApprove
                      ? 'Laporan berhasil disetujui'
                      : 'Laporan berhasil ditolak',
                  backgroundColor:
                      isApprove ? FigmaColors.done : FigmaColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Navigator.pop(context);
                Get.snackbar(
                  'Error',
                  'Gagal memproses laporan: $e',
                  backgroundColor: FigmaColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? FigmaColors.done : FigmaColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
