import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ManpowerListWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const ManpowerListWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedManpower.isEmpty
        ? _buildEmptyManpowerMessage()
        : _buildManpowerList(controller)
    );
  }

  Widget _buildEmptyManpowerMessage() {
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
          const Icon(Icons.people_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Belum ada data personel',
            style: GoogleFonts.dmSans(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan data personel dengan menekan tombol di bawah',
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
  
  Widget _buildManpowerList(AddWorkReportController controller) {
    final numberFormat = NumberFormat('#,###.##');
    
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
                flex: 3,
                child: Text(
                  'Jabatan',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Jumlah',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Jam',
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
                  'Biaya/hari',
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
            itemCount: controller.selectedManpower.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[300],
            ),
            itemBuilder: (context, index) {
              final manpower = controller.selectedManpower[index];
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    // Jabatan
                    Expanded(
                      flex: 3,
                      child: Text(
                        manpower.personnelRole.roleName,
                        style: GoogleFonts.dmSans(fontSize: 14),
                      ),
                    ),
                    // Jumlah orang
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${manpower.personCount} orang',
                        style: GoogleFonts.dmSans(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Jam kerja
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${manpower.normalHoursPerPerson} jam',
                        style: GoogleFonts.dmSans(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Biaya per hari
                    Expanded(
                      flex: 3,
                      child: Text(
                        manpower.manpowerDailyRate != null
                          ? 'Rp ${numberFormat.format(manpower.manpowerDailyRate)}'
                          : '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Delete action
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        controller.removeManpowerEntry(manpower.personnelRole.id);
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
        if (controller.selectedManpower.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Ringkasan Tenaga Kerja',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total personel: ${controller.selectedManpower.fold(0, (sum, item) => sum + item.personCount)}',
                  style: GoogleFonts.dmSans(fontSize: 14),
                ),
                Text(
                  'Total jam kerja: ${controller.selectedManpower.fold(0.0, (sum, item) => sum + item.totalNormalHours)} jam',
                  style: GoogleFonts.dmSans(fontSize: 14),
                ),
                Text(
                  'Total biaya: Rp ${numberFormat.format(controller.selectedManpower.fold(0.0, (sum, item) => sum + (item.personCount * (item.manpowerDailyRate ?? 0.0))))}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Perhitungan lembur dilakukan otomatis oleh sistem',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
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