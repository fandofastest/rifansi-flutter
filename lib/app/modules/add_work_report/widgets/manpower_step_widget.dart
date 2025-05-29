import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import './manpower_list_widget.dart';
import './add_manpower_dialog.dart';

class ManpowerStepWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const ManpowerStepWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input jumlah personel dan jam kerja',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        
        // List manpower yang sudah ditambahkan
        ManpowerListWidget(controller: controller),
        
        const SizedBox(height: 16),
        
        // Tombol tambah manpower
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              AddManpowerDialog.show(context, controller);
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Personel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FigmaColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
} 