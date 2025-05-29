import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/equipment_model.dart';
import './equipment_list_widget.dart';
import './add_equipment_dialog.dart';

class EquipmentStepWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const EquipmentStepWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input data peralatan yang digunakan',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // Tampilkan daftar peralatan yang sudah dipilih
        EquipmentListWidget(controller: controller),

        const SizedBox(height: 16),

        // Tombol untuk menambahkan peralatan
        Obx(() {
          if (controller.isLoadingEquipment.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: FigmaColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data peralatan...',
                      style: GoogleFonts.dmSans(color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
            );
          }

          if (controller.equipmentList.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat data peralatan',
                    style: GoogleFonts.dmSans(
                      color: Colors.red[800],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.error.value.isNotEmpty
                        ? controller.error.value
                        : 'Silakan coba lagi nanti',
                    style: GoogleFonts.dmSans(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                AddEquipmentDialog.show(context, controller);
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Peralatan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FigmaColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          );
        }),
      ],
    );
  }
}
