import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/work_progress_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/work_progress_model.dart';
import 'package:intl/intl.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../controllers/material_controller.dart';
import '../../../data/models/daily_activity_model.dart';
import '../../../controllers/other_cost_controller.dart';

class WorkProgressForm extends StatelessWidget {
  final WorkProgressController controller;
  final numberFormat = NumberFormat('#,##0.##');

  WorkProgressForm({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final RxBool isSubmitting = false.obs;
  final RxString workProgressSearchQuery = ''.obs;

  // Menghitung progress harian berdasarkan input hari ini
  double _calculateDailyProgressPercentage() {
    if (controller.workProgresses.isEmpty) return 0.0;

    double totalActualVolume = 0.0;
    double totalTargetVolume = 0.0;

    for (var progress in controller.workProgresses) {
      // Hitung volume aktual hari ini (yang diinput user)
      double actualVolume = 0.0;
      double targetVolume = 0.0;

      if (progress.boqVolumeR > 0 && progress.boqVolumeNR > 0) {
        // Jika ada kedua jenis volume, ambil yang aktif (yang lebih besar)
        if (progress.boqVolumeR >= progress.boqVolumeNR) {
          actualVolume = progress.progressVolumeR;
          targetVolume = progress.dailyTargetR;
        } else {
          actualVolume = progress.progressVolumeNR;
          targetVolume = progress.dailyTargetNR;
        }
      } else if (progress.boqVolumeR > 0) {
        actualVolume = progress.progressVolumeR;
        targetVolume = progress.dailyTargetR;
      } else if (progress.boqVolumeNR > 0) {
        actualVolume = progress.progressVolumeNR;
        targetVolume = progress.dailyTargetNR;
      }

      totalActualVolume += actualVolume;
      totalTargetVolume += targetVolume;
    }

    // Progress = (Total Actual Volume / Total Target Volume) * 100
    return totalTargetVolume > 0
        ? (totalActualVolume / totalTargetVolume) * 100
        : 0.0;
  }

  // Menghitung progress percentage sesuai rumus sebenarnya
  double _calculateCorrectProgressPercentage() {
    final spkDetail =
        Get.find<AddWorkReportController>().spkDetailsWithProgress.value;

    if (spkDetail == null || controller.workProgresses.isEmpty) return 0.0;

    // 1. Hitung Total Hari Kerja
    try {
      DateTime? startDate;
      DateTime? endDate;

      // Parse tanggal dari string jika perlu
      if (spkDetail.startDate is String) {
        startDate = DateTime.tryParse(spkDetail.startDate as String);
      } else if (spkDetail.startDate is DateTime) {
        startDate = spkDetail.startDate as DateTime;
      }

      if (spkDetail.endDate is String) {
        endDate = DateTime.tryParse(spkDetail.endDate as String);
      } else if (spkDetail.endDate is DateTime) {
        endDate = spkDetail.endDate as DateTime;
      }

      if (startDate == null || endDate == null) return 0.0;

      final totalWorkDays = ((endDate.difference(startDate).inDays) + 1)
          .clamp(1, double.infinity)
          .toInt();

      // 2. Hitung Total Volume BOQ dari semua work item
      double totalBoqVolume = 0.0;
      for (var progress in controller.workProgresses) {
        totalBoqVolume += (progress.boqVolumeNR + progress.boqVolumeR);
      }

      // 3. Hitung Target Harian
      final dailyTarget = totalBoqVolume / totalWorkDays;

      // 4. Hitung Volume Progress Hari Ini (dari input user)
      double todayProgressVolume = 0.0;
      for (var progress in controller.workProgresses) {
        todayProgressVolume +=
            (progress.progressVolumeNR + progress.progressVolumeR);
      }

      // 5. Hitung Progress Percentage
      final progressPercentage =
          dailyTarget > 0 ? (todayProgressVolume / dailyTarget) * 100 : 0.0;

      // 6. Pembulatan hingga 2 desimal
      return double.parse(progressPercentage.toStringAsFixed(2));
    } catch (e) {
      print('Error calculating correct progress percentage: $e');
      return 0.0;
    }
  }

  // Debug function untuk membandingkan kedua metode perhitungan
  void _debugProgressCalculation() {
    final oldMethod = _calculateDailyProgressPercentage();
    final newMethod = _calculateCorrectProgressPercentage();

    print('=== PROGRESS CALCULATION COMPARISON ===');
    print('Old Method (per item): ${oldMethod.toStringAsFixed(2)}%');
    print('New Method (correct formula): ${newMethod.toStringAsFixed(2)}%');
    print('Difference: ${(newMethod - oldMethod).toStringAsFixed(2)}%');

    final spkDetail =
        Get.find<AddWorkReportController>().spkDetailsWithProgress.value;
    if (spkDetail != null) {
      print('SPK Start Date: ${spkDetail.startDate}');
      print('SPK End Date: ${spkDetail.endDate}');

      // Hitung total BOQ volume
      double totalBoqVolume = 0.0;
      double totalProgressVolume = 0.0;
      for (var progress in controller.workProgresses) {
        totalBoqVolume += (progress.boqVolumeNR + progress.boqVolumeR);
        totalProgressVolume +=
            (progress.progressVolumeNR + progress.progressVolumeR);
      }
      print('Total BOQ Volume: ${totalBoqVolume.toStringAsFixed(2)}');
      print(
          'Total Progress Volume Today: ${totalProgressVolume.toStringAsFixed(2)}');
    }
    print('==========================================');
  }

  // Menghitung total progress kumulatif s/d hari ini
  double _calculateCumulativeProgressPercentage() {
    final spkDetail =
        Get.find<AddWorkReportController>().spkDetailsWithProgress.value;
    final dailyActivities = spkDetail?.dailyActivities ?? [];
    final workItems =
        dailyActivities.isNotEmpty ? dailyActivities.first.workItems : [];

    if (workItems.isEmpty || controller.workProgresses.isEmpty) return 0.0;

    double totalCumulativeVolume = 0.0;
    double totalBoqVolume = 0.0;

    for (int i = 0;
        i < controller.workProgresses.length && i < workItems.length;
        i++) {
      final progress = controller.workProgresses[i];
      final workItem = workItems[i];

      // Tentukan volume yang aktif dan hitung progress kumulatif
      double cumulativeVolume = 0.0;
      double boqVolume = 0.0;

      if (progress.boqVolumeR > 0 && progress.boqVolumeNR > 0) {
        // Jika ada kedua jenis volume, ambil yang aktif (yang lebih besar)
        if (progress.boqVolumeR >= progress.boqVolumeNR) {
          cumulativeVolume =
              workItem.progressAchieved.r + progress.progressVolumeR;
          boqVolume = progress.boqVolumeR;
        } else {
          cumulativeVolume =
              workItem.progressAchieved.nr + progress.progressVolumeNR;
          boqVolume = progress.boqVolumeNR;
        }
      } else if (progress.boqVolumeR > 0) {
        cumulativeVolume =
            workItem.progressAchieved.r + progress.progressVolumeR;
        boqVolume = progress.boqVolumeR;
      } else if (progress.boqVolumeNR > 0) {
        cumulativeVolume =
            workItem.progressAchieved.nr + progress.progressVolumeNR;
        boqVolume = progress.boqVolumeNR;
      }

      totalCumulativeVolume += cumulativeVolume;
      totalBoqVolume += boqVolume;
    }

    // Progress = (Total Cumulative Volume / Total BOQ Volume) * 100
    return totalBoqVolume > 0
        ? (totalCumulativeVolume / totalBoqVolume) * 100
        : 0.0;
  }

  Widget _buildProgressInputs(WorkProgress progress, int index) {
    final spkDetail =
        Get.find<AddWorkReportController>().spkDetailsWithProgress.value;
    final dailyActivities = spkDetail?.dailyActivities ?? [];
    final workItems =
        dailyActivities.isNotEmpty ? dailyActivities.first.workItems : [];
    final workItemDetail = workItems.isNotEmpty ? workItems[index] : null;
    final completedVolume = workItemDetail?.progressAchieved.nr ?? 0.0;
    final remainingVolume = workItemDetail?.boqVolume.nr ?? 0.0;

    // Tentukan jenis BOQ yang aktif
    final bool isN = progress.boqVolumeR > 0;
    final bool isNR = progress.boqVolumeNR > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card utama dengan padding yang lebih kecil
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan harga satuan dan nilai progress
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Harga Satuan (${isN ? 'N' : 'NR'})',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${numberFormat.format(isN ? progress.rateR : progress.rateNR)}/${progress.unit}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FigmaColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Nilai Progress',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          'Rp ${numberFormat.format(progress.totalProgressValue)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: FigmaColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Informasi volume dalam grid yang lebih compact
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Volume BOQ (${isN ? 'N' : 'NR'})',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${numberFormat.format(isN ? progress.boqVolumeR : progress.boqVolumeNR)} ${progress.unit}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Grid untuk informasi volume dengan layout yang lebih rapi (Table 2 kolom)
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      _buildInfoChip(
                          'Target Harian',
                          '${numberFormat.format(isN ? progress.dailyTargetR : progress.dailyTargetNR)} ${progress.unit}',
                          Colors.blue),
                      _buildInfoChip(
                          'Volume Selesai',
                          '${numberFormat.format(completedVolume)} ${progress.unit}',
                          Colors.green),
                    ],
                  ),
                  TableRow(
                    children: [
                      _buildInfoChip(
                          'Volume Sisa',
                          '${numberFormat.format(remainingVolume)} ${progress.unit}',
                          Colors.orange),
                      _buildInfoChip(
                          'Progress Harian',
                          '${numberFormat.format(isN ? progress.dailyProgressPercentageR : progress.dailyProgressPercentageNR)}%',
                          Colors.purple),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Input Progress dengan layout yang lebih compact
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress Hari Ini (${isN ? 'N' : 'NR'})',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextFormField(
                          initialValue: isN
                              ? (progress.progressVolumeR > 0
                                  ? numberFormat
                                      .format(progress.progressVolumeR)
                                  : '')
                              : (progress.progressVolumeNR > 0
                                  ? numberFormat
                                      .format(progress.progressVolumeNR)
                                  : ''),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.dmSans(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Masukkan volume progress',
                            hintStyle: GoogleFonts.dmSans(fontSize: 12),
                            suffixText: progress.unit,
                            suffixStyle: GoogleFonts.dmSans(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          onChanged: (value) {
                            final volume =
                                double.tryParse(value.replaceAll(',', '')) ??
                                    0.0;
                            if (isN) {
                              controller.updateProgressR(index, volume);
                            } else {
                              controller.updateProgressNR(index, volume);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Progress',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.green[700],
                              ),
                            ),
                            Text(
                              '${numberFormat.format(isN ? progress.totalProgressPercentageR : progress.totalProgressPercentageNR)}%',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Remarks dengan style yang lebih compact
              TextFormField(
                initialValue: progress.remarks,
                maxLines: 2,
                style: GoogleFonts.dmSans(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Catatan (opsional)',
                  hintStyle: GoogleFonts.dmSans(fontSize: 12),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                onChanged: (value) {
                  controller.updateRemarks(index, value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context) {
    // Debug perbandingan perhitungan progress
    _debugProgressCalculation();

    final reportController = Get.find<AddWorkReportController>();
    final materialController = Get.find<MaterialController>();
    final otherCostController = Get.find<OtherCostController>();
    final spkDetail = reportController.spkDetailsWithProgress.value;
    final dailyActivities = spkDetail?.dailyActivities ?? [];
    final workItems =
        dailyActivities.isNotEmpty ? dailyActivities.first.workItems : [];

    // Ambil data preview dari SpkDetailWithProgressResponse
    final previewProgressData = {
      'spkId': spkDetail?.id,
      'spkNo': spkDetail?.spkNo,
      'title': spkDetail?.title,
      'projectName': spkDetail?.projectName,
      'contractor': spkDetail?.contractor,
      'location': spkDetail?.location.name,
      'startDate': spkDetail?.startDate,
      'endDate': spkDetail?.endDate,
      'workItems': workItems
          .map((item) => {
                'workItemId': item.id,
                'name': item.name,
                'unit': item.unit.name,
                'boqVolumeNR': item.boqVolume.nr,
                'boqVolumeR': item.boqVolume.r,
                'rateNR': item.rates.nr.rate,
                'rateR': item.rates.r.rate,
                'progressAchievedNR': item.progressAchieved.nr,
                'progressAchievedR': item.progressAchieved.r,
                'actualQuantityNR': item.actualQuantity.nr,
                'actualQuantityR': item.actualQuantity.r,
                'dailyProgressNR': item.dailyProgress.nr,
                'dailyProgressR': item.dailyProgress.r,
                'dailyCostNR': item.dailyCost.nr,
                'dailyCostR': item.dailyCost.r,
                'description': item.description,
              })
          .toList(),
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: FigmaColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Preview Laporan',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SPK Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi SPK',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('No. SPK', spkDetail?.spkNo ?? '-'),
                            _buildInfoRow(
                                'Tanggal',
                                spkDetail?.startDate
                                        ?.toString()
                                        .split(" ")[0] ??
                                    '-'),
                            _buildInfoRow(
                                'Area', spkDetail?.location?.name ?? '-'),
                            // _buildInfoRow(
                            //     'Cuaca', reportController.weather.value),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Progress Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progress Pekerjaan',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Progress Hari Ini',
                                '${_calculateCorrectProgressPercentage().toStringAsFixed(2)}%'),
                            _buildInfoRow('Nilai Progress Hari Ini',
                                'Rp ${numberFormat.format(controller.totalValue.value)}'),
                            _buildInfoRow('Total Progress s/d Hari Ini',
                                '${_calculateCumulativeProgressPercentage().toStringAsFixed(2)}%'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Biaya Info
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rincian Biaya',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rincian Biaya Pekerjaan',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Biaya Peralatan
                            _buildCostItem(
                              'Peralatan',
                              'Rp ${numberFormat.format(reportController.selectedEquipment.fold(0.0, (sum, entry) {
                                // Gunakan tarif harian (rentalRatePerDay) bukan per jam
                                final rentalRatePerDay =
                                    entry.selectedContract?.rentalRatePerDay ??
                                        0.0;
                                final fuelUsed =
                                    entry.fuelIn - entry.fuelRemaining;
                                final fuelPricePerLiter = entry.equipment
                                        .currentFuelPrice?.pricePerLiter ??
                                    0.0;
                                final totalFuelCost =
                                    fuelUsed * fuelPricePerLiter;
                                return sum + rentalRatePerDay + totalFuelCost;
                              }))}',
                              reportController.selectedEquipment.length,
                              Colors.blue[700]!,
                              Icons.construction,
                            ),
                            // Breakdown biaya sewa & BBM per alat
                            ...reportController.selectedEquipment
                                .expand((entry) {
                              // Gunakan tarif harian (rentalRatePerDay) bukan per jam
                              final rentalRatePerDay =
                                  entry.selectedContract?.rentalRatePerDay ??
                                      0.0;
                              final fuelUsed =
                                  entry.fuelIn - entry.fuelRemaining;
                              final fuelPricePerLiter = entry.equipment
                                      .currentFuelPrice?.pricePerLiter ??
                                  0.0;
                              final totalFuelCost =
                                  fuelUsed * fuelPricePerLiter;
                              return [
                                _buildInfoRow(
                                  '  ${entry.equipment.equipmentCode} (Sewa/hari)',
                                  'Rp ${numberFormat.format(rentalRatePerDay)}',
                                ),
                                _buildInfoRow(
                                  '  ${entry.equipment.equipmentCode} (BBM)',
                                  'Rp ${numberFormat.format(totalFuelCost)}',
                                ),
                              ];
                            }),
                            // Breakdown Tenaga Kerja
                            _buildCostItem(
                              'Tenaga Kerja',
                              'Rp ${numberFormat.format(reportController.selectedManpower.fold(0.0, (sum, entry) => sum + entry.totalCost))}',
                              reportController.selectedManpower.length,
                              Colors.green[700]!,
                              Icons.people,
                            ),
                            ...reportController.selectedManpower
                                .map((entry) => _buildInfoRow(
                                      '  ${entry.personnelRole.roleName}',
                                      'Rp ${numberFormat.format(entry.totalCost)}',
                                    )),
                            // Breakdown Material
                            _buildCostItem(
                              'Material',
                              'Rp ${numberFormat.format(materialController.totalCost)}',
                              materialController.selectedMaterials.length,
                              Colors.orange[700]!,
                              Icons.inventory,
                            ),
                            ...materialController.selectedMaterials
                                .map((entry) => _buildInfoRow(
                                      '  ${entry.material.name}',
                                      'Rp ${numberFormat.format((entry.quantity ?? 0) * (entry.material.unitRate ?? 0))}',
                                    )),
                            // Breakdown Biaya Lain
                            _buildCostItem(
                              'Biaya Lain',
                              'Rp ${numberFormat.format(otherCostController.otherCosts.fold(0.0, (sum, cost) => sum + cost.amount))}',
                              otherCostController.otherCosts.length,
                              Colors.purple[700]!,
                              Icons.miscellaneous_services,
                            ),
                            ...otherCostController.otherCosts
                                .map((entry) => _buildInfoRow(
                                      '  ${entry.costType}',
                                      'Rp ${numberFormat.format(entry.amount)}',
                                    )),
                            const Divider(height: 16),
                            _buildInfoRow('Total Biaya',
                                'Rp ${numberFormat.format(getTotalCost(reportController, materialController))}',
                                isBold: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Summary Profit/Loss
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Summary',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildInfoRow('Nilai Progress',
                                'Rp ${numberFormat.format(controller.totalValue.value)}'),
                            _buildInfoRow('Total Biaya',
                                'Rp ${numberFormat.format(getTotalCost(reportController, materialController))}'),
                            const Divider(height: 16),
                            _buildInfoRow('Profit/Loss',
                                'Rp ${numberFormat.format(controller.totalValue.value - getTotalCost(reportController, materialController))}',
                                isBold: true,
                                valueColor: controller.totalValue.value >
                                        getTotalCost(reportController,
                                            materialController)
                                    ? Colors.green[700]
                                    : Colors.red[700]),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Remarks Input
                      Text(
                        'Catatan Laporan',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: reportController.remarks.value,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Masukkan catatan laporan (opsional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          reportController.remarks.value = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Submit Button
                    ElevatedButton(
                      onPressed: () async {
                        // Validasi foto akhir kerja
                        final reportController =
                            Get.find<AddWorkReportController>();
                        if (reportController.endPhotos.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Foto akhir kerja wajib diunggah!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red[100],
                            colorText: Colors.red[900],
                            duration: const Duration(seconds: 3),
                          );
                          return;
                        }

                        // Enhanced validation and debugging
                        print('[WorkProgressForm] === SUBMIT VALIDATION ===');
                        print(
                            'reportController.selectedSpk.value: ${reportController.selectedSpk.value}');
                        print(
                            'reportController.selectedSpk.value?.id: ${reportController.selectedSpk.value?.id}');
                        print(
                            'reportController.selectedSpk.value?.spkNo: ${reportController.selectedSpk.value?.spkNo}');
                        print(
                            'reportController.spkList.length: ${reportController.spkList.length}');

                        // Use the validation method
                        if (!reportController.validateControllerState()) {
                          print(
                              '[WorkProgressForm] ERROR: Controller state validation failed!');
                          Get.snackbar(
                            'Error',
                            'Data tidak lengkap. Silakan kembali dan pastikan SPK sudah dipilih.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red[100],
                            colorText: Colors.red[900],
                            duration: const Duration(seconds: 3),
                          );
                          return;
                        }

                        print(
                            '[WorkProgressForm] Controller state validation passed, proceeding with submit');

                        isSubmitting.value = true;
                        final success =
                            await reportController.submitWorkReport();
                        isSubmitting.value = false;
                        if (success) {
                          Get.back(
                              result: true); // Kembali ke halaman sebelumnya
                          Get.snackbar(
                            'Sukses',
                            'Laporan pekerjaan berhasil disimpan',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green[100],
                            colorText: Colors.green[900],
                            duration: const Duration(seconds: 2),
                          );
                          Get.offAllNamed(
                              '/work-report'); // Kembali ke halaman laporan
                        } else {
                          Get.snackbar(
                            'Error',
                            'Gagal menyimpan laporan: ${reportController.error.value}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red[100],
                            colorText: Colors.red[900],
                            duration: const Duration(seconds: 3),
                          );
                        }
                      },
                      child: Obx(() => isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Submit')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FigmaColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getTotalCost(AddWorkReportController reportController,
      MaterialController materialController) {
    // Biaya peralatan
    final equipmentCost = reportController.selectedEquipment.fold(
      0.0,
      (sum, entry) {
        // Gunakan tarif harian (rentalRatePerDay) bukan per jam
        final rentalRatePerDay =
            entry.selectedContract?.rentalRatePerDay ?? 0.0;
        final fuelUsed = entry.fuelIn - entry.fuelRemaining;
        final fuelPricePerLiter =
            entry.equipment.currentFuelPrice?.pricePerLiter ?? 0.0;
        final totalFuelCost = fuelUsed * fuelPricePerLiter;
        return sum + rentalRatePerDay + totalFuelCost;
      },
    );

    // Biaya tenaga kerja
    final manpowerCost = reportController.selectedManpower.fold(
      0.0,
      (sum, entry) => sum + entry.totalCost,
    );

    // Biaya material
    final materialCost = materialController.totalCost;

    return equipmentCost + manpowerCost + materialCost;
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostItem(
      String label, String value, int count, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            Text(
              '($count)',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final spkDetail =
        Get.find<AddWorkReportController>().spkDetailsWithProgress.value;
    final dailyActivities = spkDetail?.dailyActivities ?? [];
    final workItems =
        dailyActivities.isNotEmpty ? dailyActivities.first.workItems : [];
    print('DEBUG: spkDetailsWithProgress workItems: ${workItems.length} item');
    print('DEBUG: workProgresses: ${controller.workProgresses.length} item');
    final addWorkReportController = Get.find<AddWorkReportController>();
    final RxString sortBy = addWorkReportController.sortBy;
    final RxBool ascending = addWorkReportController.ascending;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: FigmaColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Progress Pekerjaan',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: FigmaColors.primary,
                    ),
                  );
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.error.value,
                      style: GoogleFonts.dmSans(
                        color: Colors.red[800],
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Search Box
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari nama pekerjaan...',
                              prefixIcon: const Icon(Icons.search, size: 18),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              isDense: true,
                            ),
                            style: GoogleFonts.dmSans(fontSize: 13),
                            onChanged: (val) =>
                                workProgressSearchQuery.value = val,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sort Dropdown
                        DropdownButton<String>(
                          value: sortBy.value,
                          items: [
                            DropdownMenuItem(
                                value: 'name',
                                child: Text('Nama',
                                    style: GoogleFonts.dmSans(fontSize: 13))),
                            DropdownMenuItem(
                                value: 'volume',
                                child: Text('Volume',
                                    style: GoogleFonts.dmSans(fontSize: 13))),
                          ],
                          onChanged: (val) {
                            if (val != null) sortBy.value = val;
                          },
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: Colors.black87),
                          underline: Container(),
                        ),
                        IconButton(
                          icon: Icon(
                              ascending.value
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 18),
                          onPressed: () => ascending.value = !ascending.value,
                          tooltip: 'Urutan',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      // --- FILTER & SORT DATA ---
                      itemCount: controller.workProgresses
                          .asMap()
                          .entries
                          .where((entry) =>
                              workProgressSearchQuery.value.isEmpty ||
                              entry.value.workItemName.toLowerCase().contains(
                                  workProgressSearchQuery.value.toLowerCase()))
                          .length,
                      itemBuilder: (context, idx) {
                        // Dapatkan list terfilter & tersortir
                        final filtered = controller.workProgresses
                            .asMap()
                            .entries
                            .where((entry) =>
                                workProgressSearchQuery.value.isEmpty ||
                                entry.value.workItemName.toLowerCase().contains(
                                    workProgressSearchQuery.value
                                        .toLowerCase()))
                            .toList();
                        filtered.sort((a, b) {
                          if (sortBy.value == 'name') {
                            return ascending.value
                                ? a.value.workItemName
                                    .compareTo(b.value.workItemName)
                                : b.value.workItemName
                                    .compareTo(a.value.workItemName);
                          } else {
                            // sort by volume (boqVolumeNR + boqVolumeR)
                            final volA = (a.value.boqVolumeNR ?? 0) +
                                (a.value.boqVolumeR ?? 0);
                            final volB = (b.value.boqVolumeNR ?? 0) +
                                (b.value.boqVolumeR ?? 0);
                            return ascending.value
                                ? volA.compareTo(volB)
                                : volB.compareTo(volA);
                          }
                        });
                        final entry = filtered[idx];
                        final progress = entry.value;
                        final index = entry.key;

                        // Tentukan jenis BOQ yang aktif
                        final bool isN = progress.boqVolumeR > 0;
                        final bool isNR = progress.boqVolumeNR > 0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            title: Text(
                              progress.workItemName,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Volume BOQ: ${numberFormat.format(isN ? progress.boqVolumeR : progress.boqVolumeNR)} ${progress.unit}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Harga: Rp ${numberFormat.format(isN ? progress.rateR : progress.rateNR)}/${progress.unit}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: FigmaColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Rp ${numberFormat.format(progress.totalProgressValue)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: FigmaColors.primary,
                                ),
                              ),
                            ),
                            children: [
                              _buildProgressInputs(progress, index),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            ),
          ),

          // Bottom navigation
          Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info total progress dan biaya
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Progress Fisik',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Obx(() => Text(
                                '${numberFormat.format(controller.totalProgressPercentage)}%',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FigmaColors.primary,
                                ),
                              )),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Nilai Progress',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Obx(() => Text(
                                'Rp ${numberFormat.format(controller.totalValue.value)}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: FigmaColors.primary,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    // Simpan Draft Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final reportController =
                              Get.find<AddWorkReportController>();
                          await reportController.saveTemporaryData();

                          Get.snackbar(
                            'Sukses',
                            'Draft laporan berhasil disimpan',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green[100],
                            colorText: Colors.green[900],
                            duration: const Duration(seconds: 2),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Draft'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Preview Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showPreviewDialog(context);
                        },
                        icon: const Icon(Icons.preview),
                        label: const Text('Preview Laporan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FigmaColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
