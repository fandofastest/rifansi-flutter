import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'equipment_report_controller.dart';
import 'widgets/add_repair_report_dialog.dart';

class EquipmentReportPage extends GetView<EquipmentReportController> {
  const EquipmentReportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: FigmaColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Laporan Alat',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: FigmaColors.primary,
            ),
          );
        }

        return Column(
          children: [
            // Header with Add Report Button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daftar Laporan Kerusakan Alat',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Show Add Repair Report Dialog
                      if (controller.equipmentList.isEmpty || controller.areaList.isEmpty) {
                        Get.snackbar(
                          'Info',
                          'Sedang memuat data alat dan lokasi...',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange[100],
                          colorText: Colors.orange[900],
                        );
                        return;
                      }
                      
                      showDialog(
                        context: context,
                        builder: (context) => AddRepairReportDialog(
                          controller: controller,
                          equipmentList: controller.equipmentList,
                          areaList: controller.areaList,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Lapor Kerusakan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FigmaColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Reports List
            Expanded(
              child: controller.reports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.construction,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada laporan kerusakan alat',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Laporan kerusakan alat akan muncul di sini',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.reports.length,
                      itemBuilder: (context, index) {
                        final report = controller.reports[index];
                        return _buildReportCard(report);
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with equipment info and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['equipment']?['equipmentCode'] ?? 'Unknown',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        report['equipment']?['equipmentType'] ?? 'Unknown Type',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (report['equipment']?['plateOrSerialNo'] != null)
                        Text(
                          report['equipment']['plateOrSerialNo'],
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(report['status']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report['status'] ?? 'Unknown',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(report['status']),
                        ),
                      ),
                    ),
                    if (report['priority'] != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(report['priority']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          report['priority'],
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getPriorityColor(report['priority']),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Problem description
            Text(
              'Masalah:',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              report['problemDescription'] ?? 'No description',
              style: GoogleFonts.dmSans(
                fontSize: 14,
              ),
            ),
            
            // Location - Always show for debugging
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report['location'] != null 
                        ? (report['location']['name'] ?? 'Location name not available')
                        : 'No location data',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: report['location'] != null ? Colors.grey[600] : Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),

            // Assigned Technician
            if (report['assignedTechnician'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Teknisi: ',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      report['assignedTechnician'],
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Review Information
            if (report['reviewedBy'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Direview oleh: ${report['reviewedBy']['fullName']}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    if (report['reviewNotes'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        report['reviewNotes'],
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Cost Information
            if (report['estimatedCost'] != null || report['actualCost'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    if (report['estimatedCost'] != null) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimasi Biaya',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: Colors.orange[600],
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(report['estimatedCost'])}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (report['actualCost'] != null) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biaya Aktual',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: Colors.orange[600],
                              ),
                            ),
                            Text(
                              'Rp ${_formatCurrency(report['actualCost'])}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Footer with damage level and report number
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: _getDamageLevelColor(report['damageLevel']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report['damageLevel'] ?? 'Unknown',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getDamageLevelColor(report['damageLevel']),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'No: ${report['reportNumber'] ?? 'Unknown'}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getDamageLevelColor(String? damageLevel) {
    switch (damageLevel?.toUpperCase()) {
      case 'RINGAN':
        return Colors.green;
      case 'SEDANG':
        return Colors.orange;
      case 'BERAT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount is num) {
      return amount.toString();
    } else if (amount is String) {
      return amount;
    } else {
      throw Exception("Unsupported format for currency");
    }
  }

  Color _getPriorityColor(String? priority) {
    // Implementasi untuk mendapatkan warna berdasarkan prioritas
    // Contoh: Menggunakan warna berdasarkan prioritas
    switch (priority?.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
} 