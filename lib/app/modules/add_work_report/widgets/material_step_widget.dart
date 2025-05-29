import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/material_controller.dart';
import '../../../theme/app_theme.dart';
import './material_list_widget.dart';
import './add_material_dialog.dart';

class MaterialStepWidget extends StatelessWidget {
  final MaterialController controller;

  const MaterialStepWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input material yang digunakan',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // List material yang sudah ditambahkan
        MaterialListWidget(controller: controller),

        const SizedBox(height: 16),

        // Tombol tambah material
        Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: FigmaColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data material...',
                      style: GoogleFonts.dmSans(color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
            );
          }

          if (controller.error.value.isNotEmpty) {
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
                    'Gagal memuat data material',
                    style: GoogleFonts.dmSans(
                      color: Colors.red[800],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.error.value,
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
                AddMaterialDialog.show(context, controller);
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Material'),
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
