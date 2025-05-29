import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/other_cost_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/daily_activity_model.dart';
import './other_cost_list_widget.dart';

class OtherCostStepWidget extends StatelessWidget {
  final OtherCostController controller;

  const OtherCostStepWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input biaya lainnya',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // List biaya lainnya yang sudah ditambahkan
        OtherCostListWidget(controller: controller),

        const SizedBox(height: 16),

        // Tombol tambah biaya lainnya
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddOtherCostDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Biaya Lainnya'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FigmaColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddOtherCostDialog(BuildContext context) {
    String costType = '';
    double? amount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tambah Biaya Lainnya',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input jenis biaya
            Text(
              'Jenis Biaya',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: 'Masukkan jenis biaya',
              ),
              onChanged: (value) {
                costType = value;
              },
            ),
            const SizedBox(height: 16),

            // Input biaya
            Text(
              'Biaya',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                prefixText: 'Rp ',
                hintText: '0',
              ),
              onChanged: (value) {
                amount = double.tryParse(value.replaceAll(',', ''));
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Batal',
              style: GoogleFonts.dmSans(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (costType.isNotEmpty && amount != null && amount! > 0) {
                controller.addOtherCost(OtherCost(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  costType: costType,
                  amount: amount!,
                  description: costType,
                ));
                Navigator.pop(context);

                // Tampilkan snackbar konfirmasi
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(
                //     content: Text('Biaya lainnya berhasil ditambahkan'),
                //     backgroundColor: Colors.green,
                //   ),
                // );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FigmaColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
