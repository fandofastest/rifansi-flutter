import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';

class WorkDetailsWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const WorkDetailsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final workItems = controller.workItems;

      if (workItems.isEmpty) {
        return Center(
          child: Text(
            'Tidak ada detail pekerjaan',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        );
      }

      // Fungsi untuk mengurutkan item
      List<Map<String, dynamic>> sortedItems = List.from(workItems);
      sortedItems.sort((a, b) {
        if (controller.sortBy.value == 'name') {
          return controller.ascending.value
              ? (a['name'] ?? '').compareTo(b['name'] ?? '')
              : (b['name'] ?? '').compareTo(a['name'] ?? '');
        } else if (controller.sortBy.value == 'volume') {
          final volumeA = (a['volume'] ?? 0).toDouble();
          final volumeB = (b['volume'] ?? 0).toDouble();
          return controller.ascending.value
              ? volumeA.compareTo(volumeB)
              : volumeB.compareTo(volumeA);
        }
        return 0;
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Pekerjaan',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Urutkan:',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: controller.sortBy.value,
                    items: [
                      DropdownMenuItem(
                        value: 'name',
                        child: Text(
                          'Nama',
                          style: GoogleFonts.dmSans(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'volume',
                        child: Text(
                          'Volume',
                          style: GoogleFonts.dmSans(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.sortBy.value = value;
                      }
                    },
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    underline: Container(),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.ascending.value
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                    ),
                    onPressed: () {
                      controller.ascending.value = !controller.ascending.value;
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Table(
              border: TableBorder.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  children: [
                    _buildHeaderCell('Nama Pekerjaan'),
                    _buildHeaderCell('Volume'),
                  ],
                ),
                // Data rows
                ...sortedItems
                    .map((item) => TableRow(
                          children: [
                            _buildDataCell(item['name'] ?? ''),
                            _buildDataCell(
                                '${item['volume'] ?? 0} ${item['unit'] ?? ''}'),
                          ],
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
