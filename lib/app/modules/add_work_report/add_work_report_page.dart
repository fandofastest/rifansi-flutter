import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/add_work_report_controller.dart';
import '../../controllers/material_controller.dart';
import '../../controllers/other_cost_controller.dart';
import '../../theme/app_theme.dart';
import '../../data/models/area_model.dart';
import '../../data/models/spk_model.dart';
import '../../data/providers/hive_service.dart';
import './widgets/spk_selection_dialog.dart';
import './widgets/photo_time_step_widget.dart';
import './widgets/work_details_widget.dart';
import './widgets/manpower_step_widget.dart';
import './widgets/equipment_step_widget.dart';
import './widgets/material_step_widget.dart';
import './widgets/other_cost_step_widget.dart';
import 'package:intl/intl.dart';
import '../../data/providers/graphql_service.dart';
import '../../data/models/spk_detail_with_progress_response.dart';

// Kelas untuk menyimpan hasil dari dialog pemilihan area
class AreaPickerResult {
  final Area? selectedArea;
  final bool isApplied;
  final bool shouldReturnToSPK;

  AreaPickerResult(this.selectedArea, this.isApplied, this.shouldReturnToSPK);
}

class AddWorkReportPage extends GetView<AddWorkReportController> {
  const AddWorkReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cek apakah ada data draft yang dikirim
    final args = Get.arguments;
    if (args != null && args['isDraft'] == true) {
      // Tunggu sampai controller siap
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          print('=== MULAI LOAD DATA DRAFT ===');
          print('SPK ID: ${args['spkId']}');

          // Load data draft
          print('Memuat data temporary...');
          await controller.loadTemporaryData(args['spkId']);
          print('Data temporary berhasil dimuat');

          // Log isi data temporary
          print('\n=== ISI DATA TEMPORARY ===');
          print(
              'Selected SPK: ${controller.selectedSpk.value?.spkNo} - ${controller.selectedSpk.value?.title}');
          print('Work Items: ${controller.workItems.value}');
          print('Start Photos: ${controller.startPhotos.value}');
          print('End Photos: ${controller.endPhotos.value}');

          // Format waktu dengan penanganan error
          String formatTime(DateTime? time) {
            if (time == null) return 'null';
            try {
              return DateFormat('dd/MM/yyyy HH:mm').format(time);
            } catch (e) {
              print('Error formatting time: $e');
              return 'invalid time';
            }
          }

          print(
              'Work Start Time: ${formatTime(safeParseDate(controller.workStartTime.value))}');
          print(
              'Work End Time: ${formatTime(safeParseDate(controller.workEndTime.value))}');
          print('Selected Manpower: ${controller.selectedManpower.value}');
          print('Selected Equipment: ${controller.selectedEquipment.value}');
          print('Current Step: ${controller.currentStep.value}');
          print('========================\n');

          // Ambil detail SPK dengan progress
          print('Mengambil detail SPK dengan progress...');
          final graphQLService = Get.find<GraphQLService>();
          final spkDetail =
              await graphQLService.fetchSPKDetailsWithProgress(args['spkId']);
          print('Detail SPK berhasil diambil');

          // Update controller dengan data SPK yang baru
          if (spkDetail != null) {
            print('\n=== UPDATE DATA SPK ===');
            try {
              controller.spkDetailsWithProgress.value = spkDetail;

              // Update workItems di controller dengan data dari SpkDetailWithProgressResponse
              if (spkDetail.dailyActivities.isNotEmpty) {
                final latestActivity = spkDetail.dailyActivities.first;
                controller.workItems.value = latestActivity.workItems
                    .map((item) => {
                          'name': item.name,
                          'description': item.description,
                          'volume': item.boqVolume.nr,
                          'unit': item.unit.name,
                          'unitRate': item.rates.nr.rate,
                          'progress': item.progressAchieved.nr,
                          'actualQuantity': item.actualQuantity.nr,
                          'dailyProgress': item.dailyProgress.nr,
                          'dailyCost': item.dailyCost.nr,
                        })
                    .toList();
              }
              print('Data SPK berhasil diupdate');
              print(
                  'DEBUG: dailyActivities: ${spkDetail.dailyActivities.length}');
            } catch (e) {
              print('Error saat memproses data SPK: $e');
              print('Data SPK yang diterima: $spkDetail');
            }
            print('========================\n');
          }

          // Refresh UI jika perlu
          controller.update();
          print('=== SELESAI LOAD DATA DRAFT ===\n');
        } catch (e) {
          print('Error loading draft and SPK detail: $e');
          Get.snackbar(
            'Error',
            'Gagal memuat detail SPK: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[100],
            colorText: Colors.red[900],
          );
        }
      });
    }

    final materialController = Get.find<MaterialController>();
    final otherCostController = Get.find<OtherCostController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: FigmaColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Biaya Pekerjaan',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.spkList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: FigmaColors.primary,
            ),
          );
        }

        return Column(
          children: [
            // Error message if any
            if (controller.error.value.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Text(
                  controller.error.value,
                  style: GoogleFonts.dmSans(
                    color: Colors.red[800],
                    fontSize: 14,
                  ),
                ),
              ),

            // Stepper content
            Expanded(
              child: _buildVerticalStepper(controller, context),
            ),

            // Bottom navigation buttons
            _buildBottomNavigation(controller, context),
          ],
        );
      }),
    );
  }

  Widget _buildVerticalStepper(
      AddWorkReportController controller, BuildContext context) {
    final materialController = Get.find<MaterialController>();
    final otherCostController = Get.find<OtherCostController>();

    return Stepper(
      currentStep: controller.currentStep.value,
      type: StepperType.vertical,
      physics: const ClampingScrollPhysics(),
      controlsBuilder: (context, details) {
        // Kosongkan kontrolnya, kita sudah punya tombol di bawah
        return const SizedBox.shrink();
      },
      onStepTapped: (step) {
        // Hanya bisa ke step yang pernah dikunjungi
        if (step <= controller.currentStep.value) {
          controller.currentStep.value = step;
        }
      },
      steps: [
        // Step 1: Pilih SPK
        Step(
          title: Text(
            'Pilih SPK',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: _buildSelectSPKStep(controller, context),
          isActive: controller.currentStep.value >= 0,
          state: controller.currentStep.value > 0
              ? StepState.complete
              : StepState.indexed,
        ),

        // Step 2: Foto & Waktu
        Step(
          title: Text(
            'Foto & Waktu',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: PhotoTimeStepWidget(controller: controller),
          isActive: controller.currentStep.value >= 1,
          state: controller.currentStep.value > 1
              ? StepState.complete
              : controller.currentStep.value == 1
                  ? StepState.indexed
                  : StepState.disabled,
        ),

        // Step 3: Detail Pekerjaan
        Step(
          title: Text(
            'Detail Pekerjaan',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: WorkDetailsWidget(controller: controller),
          isActive: controller.currentStep.value >= 2,
          state: controller.currentStep.value > 2
              ? StepState.complete
              : controller.currentStep.value == 2
                  ? StepState.indexed
                  : StepState.disabled,
        ),

        // Step 4: Tenaga Kerja
        Step(
          title: Text(
            'Tenaga Kerja',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: ManpowerStepWidget(controller: controller),
          isActive: controller.currentStep.value >= 3,
          state: controller.currentStep.value > 3
              ? StepState.complete
              : controller.currentStep.value == 3
                  ? StepState.indexed
                  : StepState.disabled,
        ),

        // Step 5: Peralatan
        Step(
          title: Text(
            'Peralatan',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: EquipmentStepWidget(controller: controller),
          isActive: controller.currentStep.value >= 4,
          state: controller.currentStep.value > 4 ||
                  (controller.currentStep.value == 4 &&
                      controller.selectedEquipment.isNotEmpty)
              ? StepState.complete
              : controller.currentStep.value == 4
                  ? StepState.indexed
                  : StepState.disabled,
        ),

        // Step 6: Material
        Step(
          title: Text(
            'Material',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: MaterialStepWidget(controller: materialController),
          isActive: controller.currentStep.value >= 5,
          state: controller.currentStep.value > 5 ||
                  (controller.currentStep.value == 5 &&
                      materialController.selectedMaterials.isNotEmpty)
              ? StepState.complete
              : controller.currentStep.value == 5
                  ? StepState.indexed
                  : StepState.disabled,
        ),

        // Step 7: Biaya Lainnya
        Step(
          title: Text(
            'Biaya Lainnya',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: OtherCostStepWidget(controller: otherCostController),
          isActive: controller.currentStep.value >= 6,
          state: controller.currentStep.value > 6 ||
                  (controller.currentStep.value == 6 &&
                      otherCostController.otherCosts.isNotEmpty)
              ? StepState.complete
              : controller.currentStep.value == 6
                  ? StepState.indexed
                  : StepState.disabled,
        ),

        // Step 8: Rincian Biaya
        Step(
          title: Text(
            'Rincian Biaya',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: _buildCostSummaryStep(
              controller, materialController, otherCostController),
          isActive: controller.currentStep.value >= 7,
          state: controller.currentStep.value > 7
              ? StepState.complete
              : controller.currentStep.value == 7
                  ? StepState.indexed
                  : StepState.disabled,
        ),
      ],
    );
  }

  Widget _buildSelectSPKStep(
      AddWorkReportController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Biaya Pekerjaan',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih SPK untuk melanjutkan',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // SPK Selection Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Get.dialog<Spk>(
                SPKSelectionDialog(controller: controller),
                barrierDismissible: true,
              );

              if (result != null) {
                try {
                  // Set SPK yang dipilih
                  controller.selectSPK(result);

                  // Ambil detail SPK dengan progress
                  final graphQLService = Get.find<GraphQLService>();
                  final spkDetail = await graphQLService
                      .fetchSPKDetailsWithProgress(result.id);

                  // Update controller dengan data SPK yang baru
                  if (spkDetail != null) {
                    controller.spkDetailsWithProgress.value = spkDetail;

                    // Update workItems di controller dengan data dari SpkDetailWithProgressResponse
                    if (spkDetail.dailyActivities.isNotEmpty) {
                      final latestActivity = spkDetail.dailyActivities.first;
                      controller.workItems.value = latestActivity.workItems
                          .map((item) => {
                                'name': item.name,
                                'description': item.description,
                                'volume': item.boqVolume.nr,
                                'unit': item.unit.name,
                                'unitRate': item.rates.nr.rate,
                                'progress': item.progressAchieved.nr,
                                'actualQuantity': item.actualQuantity.nr,
                                'dailyProgress': item.dailyProgress.nr,
                                'dailyCost': item.dailyCost.nr,
                              })
                          .toList();
                    }
                  }

                  // Refresh UI
                  controller.update();
                } catch (e) {
                  print('Error fetching SPK details: $e');
                  Get.snackbar(
                    'Error',
                    'Gagal mengambil detail SPK: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[900],
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FigmaColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment),
                const SizedBox(width: 8),
                const Text('Pilih SPK'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Selected SPK Info
        if (controller.selectedSpk.value != null) ...[
          Text(
            'SPK Terpilih',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildSelectedSPKCard(controller),
        ],
      ],
    );
  }

  Widget _buildSelectedSPKCard(AddWorkReportController controller) {
    final spk = controller.selectedSpk.value!;
    final spkDetail = controller.spkDetailsWithProgress.value;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              spk.title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No. SPK: ${spk.spkNo}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Proyek: ${spk.projectName}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            if (spk.location != null) ...[
              const SizedBox(height: 4),
              Text(
                'Lokasi: ${spk.location!.name}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
            if (spkDetail != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Progress Keseluruhan',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (spkDetail.totalProgress.percentage) / 100,
                backgroundColor: Colors.grey[200],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(FigmaColors.primary),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                '${spkDetail.totalProgress.percentage.toStringAsFixed(2)}% Selesai',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: FigmaColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Biaya: Rp ${NumberFormat("#,##0", "id_ID").format(spkDetail.totalProgress.totalSpent)}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Anggaran: Rp ${NumberFormat("#,##0", "id_ID").format(spkDetail.totalProgress.totalBudget)}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sisa: Rp ${NumberFormat("#,##0", "id_ID").format(spkDetail.totalProgress.remainingBudget)}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
      AddWorkReportController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          if (controller.currentStep.value > 0)
            ElevatedButton(
              onPressed: () => controller.previousStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: FigmaColors.primary,
                elevation: 0,
                side: const BorderSide(color: FigmaColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Kembali',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),

          // Tombol Lanjut atau Isi Progress
          ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () {
                    if (controller.currentStep.value == 7) {
                      // Step terakhir, buka form progress kerja
                      controller.nextStep();
                    } else {
                      // Lanjut ke step berikutnya
                      controller.nextStep();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: FigmaColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        controller.currentStep.value == 7
                            ? 'Isi Progress Kerja'
                            : 'Lanjut',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(
      AddWorkReportController controller, BuildContext context) async {
    final result = await controller.submitWorkReport();
    if (result) {
      Get.back(); // Kembali ke halaman sebelumnya
      Get.snackbar(
        'Sukses',
        'Laporan pekerjaan berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    }
  }

  Widget _buildCostSummaryStep(
    AddWorkReportController controller,
    MaterialController materialController,
    OtherCostController otherCostController,
  ) {
    // Hitung total biaya rental peralatan (tanpa bahan bakar)
    final totalEquipmentRentalCost = controller.selectedEquipment.fold(
      0.0,
      (sum, equipment) {
        // Gunakan tarif harian (rentalRatePerDay) bukan per jam
        final rentalRatePerDay = equipment.selectedContract?.rentalRatePerDay ?? 0.0;
        return sum + rentalRatePerDay;
      },
    );

    // Hitung total biaya bahan bakar
    final totalFuelCost = controller.selectedEquipment.fold(
      0.0,
      (sum, equipment) {
        final fuelUsed = equipment.fuelIn - equipment.fuelRemaining;
        final fuelPricePerLiter =
            equipment.equipment.currentFuelPrice?.pricePerLiter ?? 0.0;
        final totalFuelCost = fuelUsed * fuelPricePerLiter;
        return sum + totalFuelCost;
      },
    );

    // Hitung total biaya tenaga kerja
    final totalManpowerCost = controller.selectedManpower.fold(
      0.0,
      (sum, manpower) => sum + manpower.totalCost,
    );

    // Hitung total biaya material
    final totalMaterialCost = materialController.selectedMaterials.fold(
      0.0,
      (sum, material) =>
          sum + (material.quantity * (material.material.unitRate ?? 0)),
    );

    // Hitung total biaya lainnya
    final totalOtherCost = otherCostController.otherCosts.fold(
      0.0,
      (sum, cost) => sum + cost.amount,
    );

    // Total keseluruhan
    final totalCost = totalEquipmentRentalCost +
        totalFuelCost +
        totalManpowerCost +
        totalMaterialCost +
        totalOtherCost;

    final numberFormat = NumberFormat("#,##0", "id_ID");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rincian Biaya Pekerjaan',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // Biaya Peralatan (hanya rental)
        _buildCostItem(
          'Peralatan',
          'Rp ${numberFormat.format(totalEquipmentRentalCost)}',
          controller.selectedEquipment.length,
          Colors.blue[700]!,
          Icons.construction,
        ),

        // Biaya Bahan Bakar
        _buildCostItem(
          'Bahan Bakar',
          'Rp ${numberFormat.format(totalFuelCost)}',
          controller.selectedEquipment.length,
          Colors.amber[700]!,
          Icons.local_gas_station,
        ),

        // Biaya Tenaga Kerja
        _buildCostItem(
          'Tenaga Kerja',
          'Rp ${numberFormat.format(totalManpowerCost)}',
          controller.selectedManpower.length,
          Colors.green[700]!,
          Icons.people,
        ),

        // Biaya Material
        _buildCostItem(
          'Material',
          'Rp ${numberFormat.format(totalMaterialCost)}',
          materialController.selectedMaterials.length,
          Colors.orange[700]!,
          Icons.inventory,
        ),

        // Biaya Lainnya
        _buildCostItem(
          'Biaya Lain',
          'Rp ${numberFormat.format(totalOtherCost)}',
          otherCostController.otherCosts.length,
          Colors.purple[700]!,
          Icons.miscellaneous_services,
        ),

        const SizedBox(height: 24),

        // Total Biaya
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Biaya',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${numberFormat.format(totalCost)}',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: FigmaColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostItem(
    String title,
    String amount,
    int itemCount,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$itemCount item',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

DateTime? safeParseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    // Jika epoch milliseconds
    try {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } catch (_) {}
  }
  if (value is String) {
    // Coba parse ISO string
    try {
      return DateTime.parse(value);
    } catch (_) {}
    // Coba parse epoch string
    try {
      final epoch = int.parse(value);
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    } catch (_) {}
  }
  return null;
}
