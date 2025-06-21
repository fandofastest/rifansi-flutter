import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../data/models/daily_activity_model.dart';

class EquipmentListWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const EquipmentListWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedEquipment.isEmpty
        ? _buildEmptyEquipmentMessage()
        : _buildEquipmentList(controller));
  }

  Widget _buildEmptyEquipmentMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.construction, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Belum ada peralatan yang ditambahkan',
            style: GoogleFonts.dmSans(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan peralatan dengan menekan tombol di bawah',
            style: GoogleFonts.dmSans(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList(AddWorkReportController controller) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: FigmaColors.primary.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'Peralatan',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Jam Kerja',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Status',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 36), // for actions
            ],
          ),
        ),

        // List items
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.selectedEquipment.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final entry = controller.selectedEquipment[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    // Equipment info
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.equipment.equipmentCode,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            entry.equipment.equipmentType,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (entry.selectedContract != null)
                            Text(
                              'Kontrak: ${entry.selectedContract!.contract.contractNo}',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          if (entry.equipment.area != null)
                            Text(
                              'Area: ${entry.equipment.area!.name}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Jam kerja
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${entry.workingHours} jam',
                        style: GoogleFonts.dmSans(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Status
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (entry.isBrokenReported)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange[400]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    size: 12,
                                    color: Colors.orange[800],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Rusak',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green[400]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 12,
                                    color: Colors.green[800],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Normal',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Delete action
                    IconButton(
                      icon:
                          const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        controller.removeEquipmentEntry(entry.equipment.id);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Summary
        if (controller.selectedEquipment.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.construction, size: 18, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Ringkasan Peralatan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total peralatan: ${controller.selectedEquipment.length} unit',
                  style: GoogleFonts.dmSans(fontSize: 14),
                ),
                Text(
                  'Total jam kerja: ${controller.selectedEquipment.fold(0.0, (sum, item) => sum + item.workingHours)} jam',
                  style: GoogleFonts.dmSans(fontSize: 14),
                ),
                const SizedBox(height: 8),
                // Rincian biaya per peralatan
                ...controller.selectedEquipment.map((entry) {
                  // Gunakan tarif harian (rentalRatePerDay) bukan per jam
                  final rentalRatePerDay = entry.selectedContract?.rentalRatePerDay ?? 0.0;

                  // Hitung biaya BBM
                  final fuelUsed = entry.fuelIn - entry.fuelRemaining;
                  final fuelPricePerLiter =
                      entry.equipment.currentFuelPrice?.pricePerLiter ?? 0.0;
                  final totalFuelCost = fuelUsed * fuelPricePerLiter;

                  // Total biaya peralatan
                  final totalCost = rentalRatePerDay + totalFuelCost;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.equipment.equipmentCode,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${NumberFormat("#,##0", "id_ID").format(totalCost)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Rincian sewa
                        Text(
                          'Sewa harian: Rp ${NumberFormat("#,##0", "id_ID").format(rentalRatePerDay)} (${entry.workingHours} jam)',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        // Rincian BBM
                        Text(
                          'BBM: ${fuelUsed.toStringAsFixed(1)}L × Rp ${NumberFormat("#,##0", "id_ID").format(fuelPricePerLiter)}/L = Rp ${NumberFormat("#,##0", "id_ID").format(totalFuelCost)}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(height: 16),
                // Total biaya
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Biaya',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${NumberFormat("#,##0", "id_ID").format(controller.selectedEquipment.fold(0.0, (sum, entry) {
                        // Gunakan tarif harian (rentalRatePerDay) bukan per jam
                        final rentalCost = entry.selectedContract?.rentalRatePerDay ?? 0.0;
                        final fuelCost = (entry.fuelIn - entry.fuelRemaining) *
                            (entry.equipment.currentFuelPrice?.pricePerLiter ??
                                0.0);
                        return sum + rentalCost + fuelCost;
                      }))}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: FigmaColors.primary,
                      ),
                    ),
                  ],
                ),
                if (controller.selectedEquipment
                    .any((item) => item.isBrokenReported))
                  Text(
                    'Ada ${controller.selectedEquipment.where((item) => item.isBrokenReported).length} peralatan dilaporkan rusak',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
