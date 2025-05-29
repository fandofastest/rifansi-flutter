import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/other_cost_controller.dart';
import '../../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class OtherCostListWidget extends StatelessWidget {
  final OtherCostController controller;
  final numberFormat = NumberFormat("#,##0", "id_ID");

  OtherCostListWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.otherCosts.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              'Belum ada biaya lainnya',
              style: GoogleFonts.dmSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.otherCosts.length,
        itemBuilder: (context, index) {
          final cost = controller.otherCosts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                cost.costType,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Rp ${numberFormat.format(cost.amount)}',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => controller.removeOtherCost(cost.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
