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

class WorkReportPage extends StatelessWidget {
  const WorkReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil controller dengan Get.find() daripada GetView untuk lebih fleksibel
    final controller = Get.find<DailyActivityController>();
    final lokasiController = Get.find<LokasiController>();

    // Refresh data saat masuk halaman
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchActivities();
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
                      _buildActivitiesList(controller),
                      // Tab 2: Draft & Lokal (Local)
                      _buildActivitiesList(controller),
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
                onPressed: () => Get.offAllNamed('/home'),
              ),
              Expanded(
                child: Text(
                  'Laporan Kerja',
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Filter lokasi
              GestureDetector(
                onTap: () {
                  _showPilihLokasiDialog(context, controller, lokasiController);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              ),
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
                  controller.fetchActivities(keyword: value);
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
                controller.fetchActivities(keyword: searchController.text);
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
                                activityController.fetchActivities();
                              } else {
                                // Filter berdasarkan lokasi setelah mengambil data
                                activityController.fetchActivities().then((_) {
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
                  onPressed: () => controller.fetchActivities(),
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
          await controller.fetchActivities();
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
                // Tampilkan info tentang aktivitas
                print('Tapped on activity: ${activity.id}');
                print('SPK ID: ${activity.spkId}');
                print('Status: ${activity.status}');

                // TODO: Navigasi ke detail laporan
              },
            );
          },
        ),
      );
    });
  }
}
