import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../controllers/equipment_approval_controller.dart';
import '../../controllers/auth_controller.dart';
import 'widgets/equipment_repair_accordion_card.dart';

class EquipmentApprovalPage extends StatefulWidget {
  const EquipmentApprovalPage({Key? key}) : super(key: key);

  @override
  State<EquipmentApprovalPage> createState() => _EquipmentApprovalPageState();
}

class _EquipmentApprovalPageState extends State<EquipmentApprovalPage>
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
    final controller = Get.find<EquipmentApprovalController>();
    final authController = Get.find<AuthController>();

    // Refresh data when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPendingReports();
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
                      'Approval Alat',
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
                onPressed: () =>
                    Get.find<EquipmentApprovalController>().refreshReports(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(EquipmentApprovalController controller,
      {required bool isPending}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            isPending
                ? 'Daftar Laporan Kerusakan Menunggu Approval'
                : 'Daftar Laporan Kerusakan Sudah Direspons',
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
                        onPressed: () => controller.refreshReports(),
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
              print(
                  '[EQUIPMENT APPROVAL DEBUG] === CHECKING APPROVAL DATA ===');
              print(
                  '[EQUIPMENT APPROVAL DEBUG] Total reports: ${controller.allReports.length}');
              print(
                  '[EQUIPMENT APPROVAL DEBUG] Tab: ${isPending ? "Pending" : "Responded"}');

              // Get filtered reports based on tab
              final filteredReports = isPending
                  ? controller.pendingReportsList
                  : controller.respondedReportsList;

              print(
                  '[EQUIPMENT APPROVAL DEBUG] Filtered reports: ${filteredReports.length}');

              // Log filtered reports
              for (int i = 0; i < filteredReports.length; i++) {
                final report = filteredReports[i];
                print('[EQUIPMENT APPROVAL DEBUG] Filtered Report $i:');
                print('  - ID: ${report['id']}');
                print('  - Status: ${report['status']}');
                print(
                    '  - Equipment: ${report['equipment']?['equipmentCode'] ?? 'N/A'}');
                print(
                    '  - Reporter: ${report['reportedBy']?['fullName'] ?? 'N/A'}');
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
                            ? 'Tidak ada laporan kerusakan yang menunggu approval'
                            : 'Tidak ada laporan kerusakan yang sudah direspons',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.abu,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total laporan: ${controller.allReports.length}',
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
                onRefresh: () => controller.refreshReports(),
                color: FigmaColors.primary,
                child: ListView.builder(
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return EquipmentRepairAccordionCard(
                      report: report,
                      onApprove: isPending
                          ? () => _showApprovalDialog(context, report, true)
                          : null,
                      onReject: isPending
                          ? () => _showApprovalDialog(context, report, false)
                          : null,
                      showActions:
                          isPending, // Only show action buttons in pending tab
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
      BuildContext context, Map<String, dynamic> report, bool isApprove) {
    final TextEditingController remarksController = TextEditingController();
    final TextEditingController technicianController = TextEditingController();
    final TextEditingController costController = TextEditingController();
    final RxString selectedPriority = 'MEDIUM'.obs;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          isApprove ? 'Setujui Laporan Kerusakan' : 'Tolak Laporan Kerusakan',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FigmaColors.hitam,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report info
              Text(
                'Laporan: ${report['reportNumber'] ?? report['id']}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.hitam,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Alat: ${report['equipment']?['equipmentCode'] ?? '-'}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: FigmaColors.abu,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dilaporkan oleh: ${report['reportedBy']?['fullName'] ?? '-'}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: FigmaColors.abu,
                ),
              ),
              const SizedBox(height: 16),

              // Confirmation text
              Text(
                isApprove
                    ? 'Apakah Anda yakin ingin menyetujui laporan kerusakan ini?'
                    : 'Apakah Anda yakin ingin menolak laporan kerusakan ini?',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: FigmaColors.abu,
                ),
              ),
              const SizedBox(height: 16),

              // Review notes/rejection reason
              TextField(
                controller: remarksController,
                decoration: InputDecoration(
                  labelText: isApprove
                      ? 'Catatan Review (wajib)'
                      : 'Alasan Penolakan (wajib)',
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

              // Additional fields for approval
              if (isApprove) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: technicianController,
                  decoration: InputDecoration(
                    labelText: 'Teknisi yang Ditugaskan (opsional)',
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
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: costController,
                  decoration: InputDecoration(
                    labelText: 'Estimasi Biaya (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: FigmaColors.white,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: FigmaColors.primary),
                    ),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Text(
                  'Prioritas:',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.hitam,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                      value: selectedPriority.value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: FigmaColors.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'LOW', child: Text('Rendah')),
                        DropdownMenuItem(
                            value: 'MEDIUM', child: Text('Sedang')),
                        DropdownMenuItem(value: 'HIGH', child: Text('Tinggi')),
                        DropdownMenuItem(
                            value: 'URGENT', child: Text('Mendesak')),
                      ],
                      onChanged: (value) {
                        if (value != null) selectedPriority.value = value;
                      },
                    )),
              ],
            ],
          ),
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
              // Validate required fields
              if (remarksController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  isApprove
                      ? 'Catatan review wajib diisi'
                      : 'Alasan penolakan wajib diisi',
                  backgroundColor: FigmaColors.error,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              try {
                final controller = Get.find<EquipmentApprovalController>();

                if (isApprove) {
                  // Parse estimated cost
                  double? estimatedCost;
                  if (costController.text.trim().isNotEmpty) {
                    estimatedCost = double.tryParse(
                        costController.text.trim().replaceAll(',', ''));
                  }

                  await controller.approveReport(
                    reportId: report['id'].toString(),
                    reviewNotes: remarksController.text.trim(),
                    assignedTechnician:
                        technicianController.text.trim().isNotEmpty
                            ? technicianController.text.trim()
                            : null,
                    estimatedCost: estimatedCost,
                    priority: selectedPriority.value,
                  );
                } else {
                  await controller.rejectReport(
                    reportId: report['id'].toString(),
                    rejectionReason: remarksController.text.trim(),
                  );
                }

                Navigator.pop(context);
              } catch (e) {
                // Error handling is done in the controller
                print('[EQUIPMENT APPROVAL] Dialog error: $e');
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
