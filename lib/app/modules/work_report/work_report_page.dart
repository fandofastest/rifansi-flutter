import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/daily_activity_controller.dart';
import '../../controllers/lokasi_controller.dart';
import '../../theme/app_theme.dart';
import '../../data/models/area_model.dart';
import '../../data/models/daily_activity_response.dart';
import '../../routes/app_routes.dart';
import 'widgets/daily_activity_card.dart';
import '../../controllers/auth_controller.dart';

class WorkReportPage extends StatelessWidget {
  const WorkReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller dengan Get.find() daripada GetView untuk lebih fleksibel
    final controller = Get.find<DailyActivityController>();
    final lokasiController = Get.find<LokasiController>();

    // Refresh data saat masuk halaman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load both server and local activities
      controller.fetchServerActivities();
      controller.fetchLocalActivities();
    });

    return Scaffold(
      backgroundColor: FigmaColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(Routes.addWorkReport);
        },
        backgroundColor: FigmaColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pekerjaan'),
      ),
      body: Column(
        children: [
          _buildHeader(context, controller, lokasiController),
          // Status Laporan - dipindahkan ke atas tab
          _buildCompactStatusCard(controller),
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
            child: controller.tabController != null
                ? TabBar(
                    controller: controller.tabController,
                    labelColor: FigmaColors.primary,
                    unselectedLabelColor: FigmaColors.abu,
                    indicatorColor: FigmaColors.primary,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'Laporan Terkirim'),
                      Tab(text: 'Draft Belum Terkirim'),
                    ],
                    onTap: (index) {
                      controller.selectedTabIndex.value = index;
                      controller.updateActivitiesByTab();
                    },
                  )
                : const SizedBox(),
          ),
          Expanded(
            child: controller.tabController != null
                ? TabBarView(
                    controller: controller.tabController,
                    children: [
                      // Tab 1: Laporan Terkirim (Server)
                      _buildActivitiesListOnly(controller),
                      // Tab 2: Draft & Lokal (Local)
                      _buildActivitiesListOnly(controller),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DailyActivityController controller,
      LokasiController lokasiController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [FigmaColors.primary, FigmaColors.error],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
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
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Get.back();
                  } else {
                    Get.offAllNamed('/home');
                  }
                },
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Laporan Kerja',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Show user area if available
                    Obx(() {
                      final authController = Get.find<AuthController>();
                      final userArea = authController.currentUser.value?.area;

                      if (userArea != null &&
                          userArea.id.isNotEmpty &&
                          userArea.name.toLowerCase() != 'allarea') {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withOpacity(0.75),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userArea.name,
                                style: GoogleFonts.dmSans(
                                  color: Colors.white.withOpacity(0.75),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                  ],
                ),
              ),
              // Only show filter if user has AllArea
              Obx(() {
                final authController = Get.find<AuthController>();
                final userArea = authController.currentUser.value?.area;
                final hasAllArea = userArea == null ||
                    userArea.id.isEmpty ||
                    userArea.name.toLowerCase() == 'allarea';

                return Row(
                  children: [
                    if (hasAllArea)
                      GestureDetector(
                        onTap: () {
                          _showPilihLokasiDialog(
                              context, controller, lokasiController);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_alt,
                                  color: FigmaColors.primary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Pilih Lokasi',
                                style: GoogleFonts.dmSans(
                                  color: FigmaColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // Spacer to maintain layout balance
                      const SizedBox(width: 60),
                  ],
                );
              }),
            ],
          ),
          _buildSearchBar(controller),
        ],
      ),
    );
  }

  Widget _buildSearchBar(DailyActivityController controller) {
    final TextEditingController searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: searchController,
                onSubmitted: (value) {
                  controller.fetchServerActivities(keyword: value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari laporan kerja',
                  hintStyle: GoogleFonts.dmSans(
                    color: FigmaColors.hitam.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                controller.fetchServerActivities(
                    keyword: searchController.text);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: FigmaColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPilihLokasiDialog(
      BuildContext context,
      DailyActivityController activityController,
      LokasiController lokasiController) async {
    try {
      // Aktifkan loading state
      lokasiController.isLoading.value = true;

      // Fetch areas (tanpa timeout karena sudah ada di dalam controller)
      await lokasiController.fetchAreas().catchError((e) {
        print('[Dialog Lokasi] Error fetching areas: $e');
        return null;
      });

      // Set loading ke false
      lokasiController.isLoading.value = false;

      // Jika error, tampilkan snackbar
      if (lokasiController.error.value.isNotEmpty) {
        Get.snackbar(
          'Error',
          'Gagal mengambil data lokasi: ${lokasiController.error.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }

      // Area khusus untuk Semua Lokasi
      final allArea = Area(
        id: '',
        name: 'Semua Lokasi',
        location: Location(type: '', coordinates: []),
      );

      List<Area> areaList = [allArea];
      if (lokasiController.areas.isNotEmpty) {
        areaList.addAll(lokasiController.areas);
      }

      Area tempSelected = lokasiController.selectedArea.value ?? allArea;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: FigmaColors.primary,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Pilih Lokasi',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )),
                      ],
                    ),
                  ),
                  if (lokasiController.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (lokasiController.error.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Error: ${lokasiController.error.value}',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.error,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (areaList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Tidak ada lokasi tersedia',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.abu,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.3, // Lebih kecil
                      child: ListView.builder(
                        itemCount: areaList.length,
                        itemBuilder: (context, index) {
                          final area = areaList[index];
                          return RadioListTile<Area>(
                            value: area,
                            groupValue: tempSelected,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => tempSelected = val);
                              }
                            },
                            title: Text(area.name,
                                style: GoogleFonts.dmSans(fontSize: 18)),
                            activeColor: FigmaColors.primary,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FigmaColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            try {
                              lokasiController.selectArea(tempSelected);

                              // Refresh data dengan filter lokasi
                              if (tempSelected.id.isEmpty) {
                                // Semua Lokasi - ambil ulang data tanpa filter
                                activityController.fetchServerActivities();
                              } else {
                                // Filter berdasarkan lokasi setelah mengambil data
                                activityController
                                    .fetchServerActivities()
                                    .then((_) {
                                  // Filter berdasarkan lokasi yang dipilih
                                  final filteredServerActivities =
                                      activityController.serverActivities
                                          .where((activity) =>
                                              activity.location.contains(
                                                  tempSelected.name) ||
                                              (activity.spkDetail?.id ==
                                                  tempSelected.id))
                                          .toList();

                                  final filteredLocalActivities =
                                      activityController
                                          .localActivities
                                          .where((activity) =>
                                              activity.areaId ==
                                              tempSelected.id)
                                          .toList();

                                  // Update kedua list yang difilter
                                  activityController.serverActivities.value =
                                      filteredServerActivities;
                                  activityController.localActivities.value =
                                      filteredLocalActivities;

                                  // Update tampilan sesuai tab yang aktif
                                  activityController.updateActivitiesByTab();
                                });
                              }

                              // Tutup dialog
                              Navigator.pop(context);
                            } catch (e) {
                              print('[Dialog Lokasi] Error selecting area: $e');
                              Get.snackbar(
                                'Error',
                                'Gagal memilih lokasi: $e',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red[100],
                                colorText: Colors.red[900],
                              );
                            }
                          },
                          child: const Text('Terapkan Filter',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('[Dialog Lokasi] Fatal error: $e');
      lokasiController.isLoading.value = false;
      Get.snackbar(
        'Error',
        'Gagal menampilkan dialog lokasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Widget _buildActivitiesList(DailyActivityController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: FigmaColors.primary,
          ),
        );
      }

      if (controller.activities.isEmpty) {
        String message = controller.selectedTabIndex.value == 0
            ? 'Tidak ada laporan terkirim yang ditemukan'
            : 'Tidak ada laporan draft yang tersimpan';

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.selectedTabIndex.value == 0
                    ? Icons.cloud_off_outlined
                    : Icons.edit_note_outlined,
                color: FigmaColors.abu,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.dmSans(
                  color: FigmaColors.abu,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.error.value.isNotEmpty &&
                  controller.selectedTabIndex.value == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 24, right: 24),
                  child: Text(
                    'Error: ${controller.error.value}',
                    style: GoogleFonts.dmSans(
                      color: FigmaColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (controller.selectedTabIndex.value == 0) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchServerActivities(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Muat Ulang'),
                ),
              ],
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          // Refresh both server and local activities
          await controller.fetchServerActivities();
          await controller.fetchLocalActivities();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activities.length,
          itemBuilder: (context, index) {
            final DailyActivityResponse activity = controller.activities[index];

            // Debug info untuk memastikan ID sudah benar
            print(
                '[CARD] Rendering activity: id=${activity.id}, spkId=${activity.spkId}, status=${activity.status}');

            return DailyActivityCard(
              activity: activity,
              onTap: () {
                // Debug logging untuk status detection
                print('[WORK_REPORT_TAP] Activity ${activity.id} tapped!');
                print('[WORK_REPORT_TAP] Status: "${activity.status}"');
                print(
                    '[WORK_REPORT_TAP] Status lowercase: "${activity.status.toLowerCase()}"');

                // Handle different types of activities
                final isDraft =
                    activity.status.toLowerCase().contains('draft') ||
                        activity.status.toLowerCase() == 'in_progress';
                final isWaitingProgress = activity.status
                        .toLowerCase()
                        .contains('menunggu progress') ||
                    activity.status.toLowerCase().contains('waiting');

                print('[WORK_REPORT_TAP] isDraft: $isDraft');
                print(
                    '[WORK_REPORT_TAP] - contains draft: ${activity.status.toLowerCase().contains('draft')}');
                print(
                    '[WORK_REPORT_TAP] - equals in_progress: ${activity.status.toLowerCase() == 'in_progress'}');
                print(
                    '[WORK_REPORT_TAP] isWaitingProgress: $isWaitingProgress');
                print(
                    '[WORK_REPORT_TAP] Will show dialog: ${isDraft || isWaitingProgress}');

                if (isDraft || isWaitingProgress) {
                  // Show dialog for draft confirmation
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDraft
                                  ? Icons.edit_document
                                  : Icons.pending_actions,
                              color: isDraft ? Colors.orange : Colors.blue,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isDraft
                                  ? 'Lanjutkan Pengisian'
                                  : 'Lanjutkan Progress',
                              style: GoogleFonts.dmSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isDraft
                                  ? 'Apakah Anda ingin melanjutkan pengisian laporan kerja ini?'
                                  : 'Apakah Anda ingin melanjutkan pengisian progress pekerjaan?',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.back(); // Tutup dialog
                                    // Navigate to edit page
                                    print(
                                        '[WorkReport] Navigating to edit draft: ${activity.id}');
                                    Get.toNamed(
                                      Routes.addWorkReport,
                                      arguments: {
                                        'spkId': activity.spkId,
                                        'isDraft': true,
                                        'draftId': activity.id,
                                        'activityData':
                                            activity, // Pass the full activity data
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isDraft ? Colors.orange : Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    'Lanjutkan',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // For completed reports, just show info
                  print(
                      '[WorkReport] Viewing completed report: ${activity.id}');
                  print('SPK ID: ${activity.spkId}');
                  print('Status: ${activity.status}');
                }
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildStatusInfoCard(DailyActivityController controller) {
    return Obx(() {
      // Hitung status dari server activities
      final serverActivities = controller.serverActivities;

      int approvedCount = 0;
      int rejectedCount = 0;
      int submittedCount = 0;
      int draftCount = controller.localActivities.length;

      for (var activity in serverActivities) {
        final status = activity.status.toLowerCase();
        if (status.contains('disetujui') || status.contains('approved')) {
          approvedCount++;
        } else if (status.contains('ditolak') || status.contains('rejected')) {
          rejectedCount++;
        } else if (status.contains('submitted') ||
            status.contains('terkirim')) {
          submittedCount++;
        }
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [FigmaColors.primary, FigmaColors.error],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Laporan',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.check_circle,
                    label: 'Disetujui',
                    count: approvedCount,
                    color: Colors.green.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.cancel,
                    label: 'Ditolak',
                    count: rejectedCount,
                    color: Colors.red.shade300,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.send,
                    label: 'Terkirim',
                    count: submittedCount,
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusItem(
                    icon: Icons.edit_note,
                    label: 'Draft',
                    count: draftCount,
                    color: Colors.orange.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesListWithStatus(DailyActivityController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: FigmaColors.primary,
          ),
        );
      }

      if (controller.activities.isEmpty) {
        String message = controller.selectedTabIndex.value == 0
            ? 'Tidak ada laporan terkirim yang ditemukan'
            : 'Tidak ada laporan draft yang tersimpan';

        return SingleChildScrollView(
          child: Column(
            children: [
              // Status card tetap ditampilkan meski list kosong
              _buildStatusInfoCard(controller),
              const SizedBox(height: 32),
              Icon(
                controller.selectedTabIndex.value == 0
                    ? Icons.cloud_off_outlined
                    : Icons.edit_note_outlined,
                color: FigmaColors.abu,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.dmSans(
                  color: FigmaColors.abu,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.error.value.isNotEmpty &&
                  controller.selectedTabIndex.value == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 24, right: 24),
                  child: Text(
                    'Error: ${controller.error.value}',
                    style: GoogleFonts.dmSans(
                      color: FigmaColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (controller.selectedTabIndex.value == 0) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchServerActivities(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Muat Ulang'),
                ),
              ],
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchServerActivities();
        },
        child: CustomScrollView(
          slivers: [
            // Status card sebagai sliver
            SliverToBoxAdapter(
              child: _buildStatusInfoCard(controller),
            ),
            // List laporan sebagai sliver
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Sort activities by updatedAt (newest first)
                  final sortedActivities =
                      List<DailyActivityResponse>.from(controller.activities);
                  sortedActivities.sort((a, b) {
                    try {
                      DateTime dateA = _parseActivityDate(a.updatedAt);
                      DateTime dateB = _parseActivityDate(b.updatedAt);
                      return dateB.compareTo(dateA); // Newest first
                    } catch (e) {
                      // Fallback to date if updatedAt parsing fails
                      try {
                        DateTime dateA = _parseActivityDate(a.date);
                        DateTime dateB = _parseActivityDate(b.date);
                        return dateB.compareTo(dateA);
                      } catch (e2) {
                        return 0;
                      }
                    }
                  });

                  final DailyActivityResponse activity =
                      sortedActivities[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: index == sortedActivities.length - 1 ? 16 : 0,
                    ),
                    child: DailyActivityCard(
                      activity: activity,
                      onTap: () {
                        // Debug logging untuk status detection
                        print(
                            '[WORK_REPORT_SLIVER_TAP] Activity ${activity.id} tapped!');
                        print(
                            '[WORK_REPORT_SLIVER_TAP] Status: "${activity.status}"');
                        print(
                            '[WORK_REPORT_SLIVER_TAP] Status lowercase: "${activity.status.toLowerCase()}"');

                        // Handle different types of activities
                        final isDraft =
                            activity.status.toLowerCase().contains('draft') ||
                                activity.status.toLowerCase() == 'in_progress';
                        final isWaitingProgress = activity.status
                                .toLowerCase()
                                .contains('menunggu progress') ||
                            activity.status.toLowerCase().contains('waiting');

                        print('[WORK_REPORT_SLIVER_TAP] isDraft: $isDraft');
                        print(
                            '[WORK_REPORT_SLIVER_TAP] - contains draft: ${activity.status.toLowerCase().contains('draft')}');
                        print(
                            '[WORK_REPORT_SLIVER_TAP] - equals in_progress: ${activity.status.toLowerCase() == 'in_progress'}');
                        print(
                            '[WORK_REPORT_SLIVER_TAP] isWaitingProgress: $isWaitingProgress');
                        print(
                            '[WORK_REPORT_SLIVER_TAP] Will show dialog: ${isDraft || isWaitingProgress}');

                        if (isDraft || isWaitingProgress) {
                          // Show dialog for draft confirmation
                          Get.dialog(
                            Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isDraft
                                          ? Icons.edit_document
                                          : Icons.pending_actions,
                                      color:
                                          isDraft ? Colors.orange : Colors.blue,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      isDraft
                                          ? 'Lanjutkan Pengisian'
                                          : 'Lanjutkan Progress',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      isDraft
                                          ? 'Apakah Anda ingin melanjutkan pengisian laporan kerja ini?'
                                          : 'Apakah Anda ingin melanjutkan pengisian progress pekerjaan?',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () => Get.back(),
                                          child: Text(
                                            'Batal',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Get.back(); // Tutup dialog
                                            // Navigate to edit page
                                            print(
                                                '[WorkReport] Navigating to edit draft: ${activity.id}');
                                            Get.toNamed(
                                              Routes.addWorkReport,
                                              arguments: {
                                                'spkId': activity.spkId,
                                                'isDraft': true,
                                                'draftId': activity.id,
                                                'activityData':
                                                    activity, // Pass the full activity data
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDraft
                                                ? Colors.orange
                                                : Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            'Lanjutkan',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // For completed reports, just show info
                          print(
                              '[WorkReport] Viewing completed report: ${activity.id}');
                          print('SPK ID: ${activity.spkId}');
                          print('Status: ${activity.status}');
                          // TODO: Add detail view for completed reports
                        }
                      },
                    ),
                  );
                },
                childCount: controller.activities.length,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCompactStatusCard(DailyActivityController controller) {
    return Obx(() {
      // Hitung status dari server activities
      final serverActivities = controller.serverActivities;

      int approvedCount = 0;
      int rejectedCount = 0;
      int submittedCount = 0;
      int draftCount = controller.localActivities.length;

      for (var activity in serverActivities) {
        final status = activity.status.toLowerCase();
        if (status.contains('disetujui') || status.contains('approved')) {
          approvedCount++;
        } else if (status.contains('ditolak') || status.contains('rejected')) {
          rejectedCount++;
        } else if (status.contains('submitted') ||
            status.contains('terkirim')) {
          submittedCount++;
        }
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [FigmaColors.primary, FigmaColors.error],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Laporan',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCompactStatusItem(
                    icon: Icons.check_circle,
                    label: 'Disetujui',
                    count: approvedCount,
                    color: Colors.green.shade300,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatusItem(
                    icon: Icons.cancel,
                    label: 'Ditolak',
                    count: rejectedCount,
                    color: Colors.red.shade300,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatusItem(
                    icon: Icons.send,
                    label: 'Terkirim',
                    count: submittedCount,
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatusItem(
                    icon: Icons.edit_note,
                    label: 'Draft',
                    count: draftCount,
                    color: Colors.orange.shade300,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCompactStatusItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            count.toString(),
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesListOnly(DailyActivityController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: FigmaColors.primary,
          ),
        );
      }

      if (controller.activities.isEmpty) {
        String message = controller.selectedTabIndex.value == 0
            ? 'Tidak ada laporan terkirim yang ditemukan'
            : 'Tidak ada laporan draft yang tersimpan';

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(
                controller.selectedTabIndex.value == 0
                    ? Icons.cloud_off_outlined
                    : Icons.edit_note_outlined,
                color: FigmaColors.abu,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.dmSans(
                  color: FigmaColors.abu,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              if (controller.error.value.isNotEmpty &&
                  controller.selectedTabIndex.value == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 24, right: 24),
                  child: Text(
                    'Error: ${controller.error.value}',
                    style: GoogleFonts.dmSans(
                      color: FigmaColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (controller.selectedTabIndex.value == 0) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.fetchServerActivities(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Muat Ulang'),
                ),
              ],
            ],
          ),
        );
      }

      // Sort activities by updatedAt (newest first)
      final sortedActivities =
          List<DailyActivityResponse>.from(controller.activities);
      sortedActivities.sort((a, b) {
        try {
          DateTime dateA = _parseActivityDate(a.updatedAt);
          DateTime dateB = _parseActivityDate(b.updatedAt);
          return dateB.compareTo(dateA); // Newest first
        } catch (e) {
          // Fallback to date if updatedAt parsing fails
          try {
            DateTime dateA = _parseActivityDate(a.date);
            DateTime dateB = _parseActivityDate(b.date);
            return dateB.compareTo(dateA);
          } catch (e2) {
            return 0;
          }
        }
      });

      return RefreshIndicator(
        onRefresh: () async {
          await controller.fetchServerActivities();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedActivities.length,
          itemBuilder: (context, index) {
            final DailyActivityResponse activity = sortedActivities[index];

            return DailyActivityCard(
              activity: activity,
              onTap: () {
                // Handle different types of activities
                final isDraft = activity.status.toLowerCase().contains('draft');
                final isWaitingProgress =
                    activity.status.toLowerCase().contains('menunggu progress');

                if (isDraft || isWaitingProgress) {
                  // For draft and waiting progress, navigate to edit page
                  print(
                      '[WorkReport] Navigating to edit draft: ${activity.id}');
                  Get.toNamed(
                    Routes.addWorkReport,
                    arguments: {
                      'spkId': activity.spkId,
                      'isDraft': true,
                      'draftId': activity.id,
                      'activityData': activity, // Pass the full activity data
                    },
                  );
                } else {
                  // For completed reports, just show info
                  print(
                      '[WorkReport] Viewing completed report: ${activity.id}');
                  print('SPK ID: ${activity.spkId}');
                  print('Status: ${activity.status}');
                }
              },
            );
          },
        ),
      );
    });
  }

  // Helper method to parse activity date from various formats
  DateTime _parseActivityDate(String dateString) {
    try {
      // Try parsing as epoch milliseconds
      final epochMs = int.parse(dateString);
      return DateTime.fromMillisecondsSinceEpoch(epochMs);
    } catch (_) {
      try {
        // Try parsing as ISO date string
        return DateTime.parse(dateString);
      } catch (e) {
        // Fallback to current date
        return DateTime.now();
      }
    }
  }
}
