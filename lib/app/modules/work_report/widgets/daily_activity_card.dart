import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/daily_activity_response.dart';
import '../../../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../controllers/daily_activity_controller.dart';
import '../../../routes/app_routes.dart';

class DailyActivityCard extends StatelessWidget {
  final DailyActivityResponse activity;
  final VoidCallback? onTap;

  const DailyActivityCard({
    Key? key,
    required this.activity,
    this.onTap,
  }) : super(key: key);

  bool isReportFromToday() {
    try {
      DateTime reportDate;
      try {
        // Coba parse sebagai epoch milliseconds
        final epochMs = int.parse(activity.date);
        reportDate = DateTime.fromMillisecondsSinceEpoch(epochMs);
      } catch (_) {
        // Coba parse sebagai ISO date string
        reportDate = DateTime.parse(activity.date);
      }

      final now = DateTime.now();
      return reportDate.year == now.year &&
          reportDate.month == now.month &&
          reportDate.day == now.day;
    } catch (e) {
      return false;
    }
  }

  String getFormattedDate() {
    try {
      // Format: "1697328000000" -> epoch miliseconds
      final epochMs = int.parse(activity.date);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMs);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (_) {
      try {
        // Fallback if it's direct date string
        return DateFormat('dd MMMM yyyy', 'id_ID')
            .format(DateTime.parse(activity.date));
      } catch (e) {
        return activity.date;
      }
    }
  }

  String getFormattedTime(String? time) {
    if (time == null || time.isEmpty) return "--:--";
    try {
      // Coba parse sebagai ISO format
      final dateTime = DateTime.parse(time);
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      print('Error parsing time: $time, Error: $e');
      return "--:--";
    }
  }

  String getFormattedProgressPercentage() {
    // Bulatkan ke bawah dan format ke 2 angka desimal
    final percentage = (activity.progressPercentage * 100).floor() / 100;
    return '${percentage.toStringAsFixed(2)}%';
  }

  // Fungsi untuk mendapatkan warna dan shade untuk status
  (Color, Color) getStatusColors(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return (Colors.orange, Colors.orange[800] ?? Colors.orange);
      case 'menunggu progress':
        return (Colors.blue, Colors.blue[800] ?? Colors.blue);
      case 'selesai':
      case 'disetujui':
        return (Colors.green, Colors.green[800] ?? Colors.green);
      default:
        return (Colors.grey, Colors.grey[800] ?? Colors.grey);
    }
  }

  // Fungsi untuk mendapatkan label status
  Widget buildStatusLabel(String status) {
    final (baseColor, textColor) = getStatusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    final bool isRejected =
        activity.status.toLowerCase().contains('rejected') ||
            activity.status.toLowerCase().contains('ditolak');

    // Debug logging for rejectionReason
    print('[DEBUG] Activity ID: ${activity.id}');
    print('[DEBUG] Activity Status: ${activity.status}');
    print('[DEBUG] isRejected: $isRejected');
    print('[DEBUG] rejectionReason: ${activity.rejectionReason}');
    print(
        '[DEBUG] rejectionReason?.isNotEmpty: ${activity.rejectionReason?.isNotEmpty}');

    // === TAMBAHAN: DEBUGGING ACTIVITY DETAILS ===
    print('[RATE DEBUG] === RAW ACTIVITY DETAILS DEBUG ===');
    print('[RATE DEBUG] Total activityDetails: ${activity.activityDetails.length}');
    for (int i = 0; i < activity.activityDetails.length; i++) {
      final detail = activity.activityDetails[i];
      print('[RATE DEBUG] --- Activity Detail $i ---');
      print('[RATE DEBUG] ID: ${detail.id}');
      print('[RATE DEBUG] Status: ${detail.status}');
      print('[RATE DEBUG] Remarks: ${detail.remarks}');
      print('[RATE DEBUG] actualQuantity.nr: ${detail.actualQuantity.nr}');
      print('[RATE DEBUG] actualQuantity.r: ${detail.actualQuantity.r}');
      print('[RATE DEBUG] rateNR: ${detail.rateNR}');
      print('[RATE DEBUG] rateR: ${detail.rateR}');
      print('[RATE DEBUG] rateDescriptionNR: ${detail.rateDescriptionNR}');
      print('[RATE DEBUG] rateDescriptionR: ${detail.rateDescriptionR}');
      print('[RATE DEBUG] boqVolumeNR: ${detail.boqVolumeNR}');
      print('[RATE DEBUG] boqVolumeR: ${detail.boqVolumeR}');
      print('[RATE DEBUG] totalProgressValue: ${detail.totalProgressValue}');
      print('[RATE DEBUG] progressPercentage: ${detail.progressPercentage}');
      print('[RATE DEBUG] dailyProgressPercentage: ${detail.dailyProgressPercentage}');
      print('[RATE DEBUG] dailyTargetNR: ${detail.dailyTargetNR}');
      print('[RATE DEBUG] dailyTargetR: ${detail.dailyTargetR}');
      
      // Work Item Details
      if (detail.workItem != null) {
        print('[RATE DEBUG] WorkItem ID: ${detail.workItem!.id}');
        print('[RATE DEBUG] WorkItem Name: ${detail.workItem!.name}');
        if (detail.workItem!.unit != null) {
          print('[RATE DEBUG] WorkItem Unit: ${detail.workItem!.unit!.name}');
        }
        // Cek apakah ada field rate di workItem
        print('[RATE DEBUG] WorkItem toString: ${detail.workItem.toString()}');
      } else {
        print('[RATE DEBUG] WorkItem: NULL');
      }
      print('[RATE DEBUG] -------------------');
    }
    print('[RATE DEBUG] === END ACTIVITY DETAILS DEBUG ===');

    // Debug logging for cost data
    print('[COST DEBUG] === RAW ACTIVITY DATA ===');
    print(
        '[COST DEBUG] Equipment logs: ${activity.equipmentLogs.length} items');
    print('[COST DEBUG] Manpower logs: ${activity.manpowerLogs.length} items');
    print(
        '[COST DEBUG] Material logs: ${activity.materialUsageLogs.length} items');
    print('[COST DEBUG] Other costs: ${activity.otherCosts.length} items');

    // Sample data from each category if available
    if (activity.equipmentLogs.isNotEmpty) {
      final sample = activity.equipmentLogs.first;
      print(
          '[COST DEBUG] Sample equipment: ${sample.equipment?.equipmentCode}, hours: ${sample.workingHour}, rate: ${sample.hourlyRate}');
    }

    if (activity.manpowerLogs.isNotEmpty) {
      final sample = activity.manpowerLogs.first;
      print(
          '[COST DEBUG] Sample manpower: ${sample.personnelRole?.roleName}, count: ${sample.personCount}, rate: ${sample.normalHourlyRate}, hours: ${sample.normalHoursPerPerson}');
    }

    if (activity.materialUsageLogs.isNotEmpty) {
      final sample = activity.materialUsageLogs.first;
      print(
          '[COST DEBUG] Sample material: ${sample.material?.name}, qty: ${sample.quantity}, rate: ${sample.unitRate}');
    }

    if (activity.otherCosts.isNotEmpty) {
      final sample = activity.otherCosts.first;
      print(
          '[COST DEBUG] Sample other cost: ${sample.description}, type: ${sample.costType}, amount: ${sample.amount}');
    }

    // Detailed logging for ALL equipment logs
    print('[COST DEBUG] === ALL EQUIPMENT LOGS ===');
    for (int i = 0; i < activity.equipmentLogs.length; i++) {
      final log = activity.equipmentLogs[i];
      print('[COST DEBUG] Equipment $i:');
      print('[COST DEBUG] - ID: ${log.id}');
      print('[COST DEBUG] - Equipment: ${log.equipment}');
      print('[COST DEBUG] - Equipment Code: ${log.equipment?.equipmentCode}');
      print('[COST DEBUG] - Working Hour: ${log.workingHour}');
      print('[COST DEBUG] - Hourly Rate: ${log.hourlyRate}');
      print('[COST DEBUG] - Fuel In: ${log.fuelIn}');
      print('[COST DEBUG] - Fuel Remaining: ${log.fuelRemaining}');
      print('[COST DEBUG] - Is Broken: ${log.isBrokenReported}');
      print('[COST DEBUG] - Remarks: ${log.remarks}');
    }

    // Detailed logging for ALL manpower logs
    print('[COST DEBUG] === ALL MANPOWER LOGS ===');
    for (int i = 0; i < activity.manpowerLogs.length; i++) {
      final log = activity.manpowerLogs[i];
      print('[COST DEBUG] Manpower $i:');
      print('[COST DEBUG] - ID: ${log.id}');
      print('[COST DEBUG] - Personnel Role: ${log.personnelRole}');
      print('[COST DEBUG] - Role Name: ${log.personnelRole?.roleName}');
      print('[COST DEBUG] - Person Count: ${log.personCount}');
      print(
          '[COST DEBUG] - Normal Hours Per Person: ${log.normalHoursPerPerson}');
      print('[COST DEBUG] - Normal Hourly Rate: ${log.normalHourlyRate}');
      print('[COST DEBUG] - Overtime Hourly Rate: ${log.overtimeHourlyRate}');
    }

    // Detailed logging for ALL material logs
    print('[COST DEBUG] === ALL MATERIAL LOGS ===');
    for (int i = 0; i < activity.materialUsageLogs.length; i++) {
      final log = activity.materialUsageLogs[i];
      print('[COST DEBUG] Material $i:');
      print('[COST DEBUG] - ID: ${log.id}');
      print('[COST DEBUG] - Material: ${log.material}');
      print('[COST DEBUG] - Material Name: ${log.material?.name}');
      print('[COST DEBUG] - Quantity: ${log.quantity}');
      print('[COST DEBUG] - Unit Rate: ${log.unitRate}');
      print('[COST DEBUG] - Remarks: ${log.remarks}');
    }

    // Detailed logging for ALL other costs
    print('[COST DEBUG] === ALL OTHER COSTS ===');
    for (int i = 0; i < activity.otherCosts.length; i++) {
      final cost = activity.otherCosts[i];
      print('[COST DEBUG] Other Cost $i:');
      print('[COST DEBUG] - ID: ${cost.id}');
      print('[COST DEBUG] - Cost Type: ${cost.costType}');
      print('[COST DEBUG] - Description: ${cost.description}');
      print('[COST DEBUG] - Amount: ${cost.amount}');
      print('[COST DEBUG] - Receipt Number: ${cost.receiptNumber}');
      print('[COST DEBUG] - Remarks: ${cost.remarks}');
    }

    print('[COST DEBUG] === END RAW DATA ===');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRejected
                      ? Colors.red
                      : activity.status.toLowerCase().contains('draft')
                          ? Colors.orange
                          : activity.status
                                      .toLowerCase()
                                      .contains('disetujui') ||
                                  activity.status
                                      .toLowerCase()
                                      .contains('approved')
                              ? Colors.green
                              : FigmaColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRejected
                          ? Icons.cancel_outlined
                          : activity.status.toLowerCase().contains('draft')
                              ? Icons.edit_document
                              : activity.status
                                          .toLowerCase()
                                          .contains('disetujui') ||
                                      activity.status
                                          .toLowerCase()
                                          .contains('approved')
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Detail Laporan Kerja',
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
                      // Status dengan highlight jika ditolak
                      if (isRejected) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning,
                                      color: Colors.red.shade700, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Laporan Ditolak',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Alasan Penolakan:',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activity.rejectionReason?.isNotEmpty == true
                                    ? activity.rejectionReason!
                                    : 'Tidak ada alasan penolakan yang diberikan. Silakan hubungi supervisor untuk informasi lebih lanjut.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Informasi SPK
                      _buildDetailSection(
                        'Informasi SPK',
                        [
                          if (activity.spkDetail != null) ...[
                            _buildDetailRow(
                                'Judul SPK', activity.spkDetail!.title),
                            _buildDetailRow(
                                'No. SPK', activity.spkDetail!.spkNo),
                            _buildDetailRow(
                                'Nama Proyek', activity.spkDetail!.projectName),
                            if (activity.spkDetail!.contractor.isNotEmpty)
                              _buildDetailRow(
                                  'Kontraktor', activity.spkDetail!.contractor),
                          ] else ...[
                            _buildDetailRow('SPK ID', activity.spkId),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Informasi Laporan
                      _buildDetailSection(
                        'Informasi Laporan',
                        [
                          _buildDetailRow('Status', activity.status),
                          _buildDetailRow('Tanggal', getFormattedDate()),
                          _buildDetailRow(
                              'Lokasi',
                              activity.location ??
                                  activity.spkDetail?.location?.name ??
                                  activity.areaId ??
                                  'N/A'),
                          _buildDetailRow(
                              'Cuaca',
                              activity.weather.isNotEmpty
                                  ? activity.weather
                                  : 'Tidak dicatat'),
                          _buildDetailRow('Waktu Mulai',
                              getFormattedTime(activity.workStartTime)),
                          _buildDetailRow('Waktu Selesai',
                              getFormattedTime(activity.workEndTime)),
                          _buildDetailRow('Progress Harian',
                              getFormattedProgressPercentage()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Catatan Penutup
                      if (activity.closingRemarks.isNotEmpty) ...[
                        _buildDetailSection(
                          'Catatan Penutup',
                          [
                            Text(
                              activity.closingRemarks,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Foto-foto
                      if (activity.startImages.isNotEmpty ||
                          activity.finishImages.isNotEmpty) ...[
                        _buildDetailSection(
                          'Dokumentasi',
                          [
                            if (activity.startImages.isNotEmpty) ...[
                              Text(
                                'Foto Mulai Kerja (${activity.startImages.length})',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: activity.startImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          activity.startImages[index],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.image_not_supported),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (activity.finishImages.isNotEmpty) ...[
                              Text(
                                'Foto Selesai Kerja (${activity.finishImages.length})',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: activity.finishImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          activity.finishImages[index],
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(
                                                  Icons.image_not_supported),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Informasi Biaya (jika ada)
                      if (activity.activityDetails.isNotEmpty ||
                          activity.equipmentLogs.isNotEmpty ||
                          activity.manpowerLogs.isNotEmpty ||
                          activity.materialUsageLogs.isNotEmpty ||
                          activity.otherCosts.isNotEmpty) ...[
                        
                        // === TAMBAHAN: Rincian Item Pekerjaan ===
                        if (activity.activityDetails.isNotEmpty) ...[
                          _buildDetailSection(
                            'Rincian Item Pekerjaan',
                            [
                              // Filter item yang tidak 0
                              Builder(
                                builder: (context) {
                                  final nonZeroItems = activity.activityDetails.where((detail) {
                                    final progressValue = _calculateProgressValue(detail);
                                    final hasValidNR = detail.actualQuantity.nr > 0 && (detail.rateNR ?? 0.0) > 0;
                                    final hasValidR = detail.actualQuantity.r > 0 && (detail.rateR ?? 0.0) > 0;
                                    return progressValue > 0 || hasValidNR || hasValidR;
                                  }).toList();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Progress Pekerjaan (${nonZeroItems.length} dari ${activity.activityDetails.length} item)',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (nonZeroItems.length < activity.activityDetails.length) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '${activity.activityDetails.length - nonZeroItems.length} item dengan nilai 0 disembunyikan',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      if (nonZeroItems.isEmpty) ...[
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.orange.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Semua item pekerjaan memiliki nilai 0. Periksa data volume dan tarif.',
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 12,
                                                    color: Colors.orange.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ] else ...[
                                        ...nonZeroItems.map((detail) {
                                          final totalProgressValue = _calculateProgressValue(detail);
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: Colors.blue.shade200),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    detail.workItem?.name ?? 'Unknown Work Item',
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          _buildVolumeText(detail),
                                                          style: GoogleFonts.dmSans(
                                                            fontSize: 12,
                                                            color: Colors.black54,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          _buildRateText(detail),
                                                          style: GoogleFonts.dmSans(
                                                            fontSize: 12,
                                                            color: Colors.black54,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Status: ${detail.status}',
                                                        style: GoogleFonts.dmSans(
                                                          fontSize: 11,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Nilai: Rp ${_formatCurrency(totalProgressValue)}',
                                                        style: GoogleFonts.dmSans(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: totalProgressValue > 0 ? Colors.green.shade700 : Colors.red.shade700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (detail.remarks.isNotEmpty) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Catatan: ${detail.remarks}',
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 11,
                                                        color: Colors.black54,
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ],
                                      const SizedBox(height: 8),
                                      Divider(color: Colors.grey.shade300),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Nilai Progress:',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${_formatCurrency(_calculateTotalProgressValue())}',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildDetailSection(
                          'Rincian Biaya',
                          [
                            // Equipment Costs
                            if (activity.equipmentLogs.isNotEmpty) ...[
                              Text(
                                'Biaya Peralatan (${activity.equipmentLogs.length} item)',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...activity.equipmentLogs.map((log) {
                                final fuelCost = log.fuelIn * log.fuelPrice;
                                final cost = fuelCost + log.rentalRatePerDay;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          log.equipment?.equipmentCode ??
                                              'Unknown Equipment',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${log.workingHour.toStringAsFixed(1)} jam',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Rp ${_formatCurrency(cost)}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Divider(color: Colors.grey.shade300),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal Peralatan:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(_calculateEquipmentTotal())}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Manpower Costs
                            if (activity.manpowerLogs.isNotEmpty) ...[
                              Text(
                                'Biaya Tenaga Kerja (${activity.manpowerLogs.length} item)',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...activity.manpowerLogs.map((log) {
                                final cost = log.normalHourlyRate *
                                    log.personCount *
                                    log.workingHours;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          log.personnelRole?.roleName ??
                                              'Unknown Role',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${log.personCount} orang',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Rp ${_formatCurrency(cost)}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Divider(color: Colors.grey.shade300),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal Tenaga Kerja:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(_calculateManpowerTotal())}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Material Costs
                            if (activity.materialUsageLogs.isNotEmpty) ...[
                              Text(
                                'Biaya Material (${activity.materialUsageLogs.length} item)',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...activity.materialUsageLogs.map((log) {
                                final totalCost = log.quantity * log.unitRate;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          log.material?.name ??
                                              'Unknown Material',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${log.quantity.toStringAsFixed(1)}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Rp ${_formatCurrency(totalCost)}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange.shade700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Divider(color: Colors.grey.shade300),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal Material:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(_calculateMaterialTotal())}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Other Costs
                            if (activity.otherCosts.isNotEmpty) ...[
                              Text(
                                'Biaya Lain-lain (${activity.otherCosts.length} item)',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...activity.otherCosts.map((cost) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          cost.description,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          cost.costType,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Rp ${_formatCurrency(cost.amount)}',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.purple.shade700,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Divider(color: Colors.grey.shade300),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal Biaya Lain:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(_calculateOtherCostsTotal())}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Grand Total
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: FigmaColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        FigmaColors.primary.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL BIAYA:',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FigmaColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatCurrency(_calculateGrandTotal())}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: FigmaColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // === TAMBAHAN: Analisis Laba Rugi ===
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _calculateProfitLoss() >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _calculateProfitLoss() >= 0 ? Colors.green.shade300 : Colors.red.shade300),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'NILAI PROGRESS:',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${_formatCurrency(_calculateTotalProgressValue())}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'TOTAL BIAYA:',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Rp ${_formatCurrency(_calculateGrandTotal())}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey.shade400),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'LABA/RUGI HARIAN:',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        '${_calculateProfitLoss() >= 0 ? '+' : ''}Rp ${_formatCurrency(_calculateProfitLoss().abs())}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _calculateProfitLoss() >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _calculateProfitLoss() >= 0 ? 'Menguntungkan' : 'Merugi',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _calculateProfitLoss() >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: FigmaColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for cost calculations
  String _formatCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  double _calculateEquipmentTotal() {
    print('[COST DEBUG] === EQUIPMENT CALCULATION ===');
    print(
        '[COST DEBUG] Equipment logs count: ${activity.equipmentLogs.length}');

    double total = 0.0;
    for (int i = 0; i < activity.equipmentLogs.length; i++) {
      final log = activity.equipmentLogs[i];

      // Calculate fuel cost: fuelIn * fuelPrice
      final fuelCost = log.fuelIn * log.fuelPrice;

      // Total equipment cost: fuel cost + rental rate per day
      final cost = fuelCost + log.rentalRatePerDay;

      print(
          '[COST DEBUG] Equipment $i: ${log.equipment?.equipmentCode ?? "Unknown"}');
      print('[COST DEBUG] - Fuel In: ${log.fuelIn}L');
      print('[COST DEBUG] - Fuel Price: Rp ${log.fuelPrice}/L');
      print('[COST DEBUG] - Fuel Cost: Rp $fuelCost');
      print('[COST DEBUG] - Rental Rate Per Day: Rp ${log.rentalRatePerDay}');
      print('[COST DEBUG] - Total Cost: Rp $cost');
      total += cost;
    }

    print('[COST DEBUG] Equipment total: $total');
    print('[COST DEBUG] === END EQUIPMENT ===');
    return total;
  }

  double _calculateManpowerTotal() {
    print('[COST DEBUG] === MANPOWER CALCULATION ===');
    print('[COST DEBUG] Manpower logs count: ${activity.manpowerLogs.length}');

    double total = 0.0;
    for (int i = 0; i < activity.manpowerLogs.length; i++) {
      final log = activity.manpowerLogs[i];

      // From the GraphQL response, we have:
      // - hourlyRate: 42540.125 (mapped to normalHourlyRate)
      // - personCount: 1
      // - workingHours: 8
      // So the calculation should be: hourlyRate * personCount * workingHours
      final cost = log.normalHourlyRate * log.personCount * log.workingHours;

      print(
          '[COST DEBUG] Manpower $i: ${log.personnelRole?.roleName ?? "Unknown"}');
      print('[COST DEBUG] - Person count: ${log.personCount}');
      print('[COST DEBUG] - Hourly rate: ${log.normalHourlyRate}');
      print('[COST DEBUG] - Working hours: ${log.workingHours}');
      print('[COST DEBUG] - Cost: $cost');
      total += cost;
    }

    print('[COST DEBUG] Manpower total: $total');
    print('[COST DEBUG] === END MANPOWER ===');
    return total;
  }

  double _calculateMaterialTotal() {
    print('[COST DEBUG] === MATERIAL CALCULATION ===');
    print(
        '[COST DEBUG] Material logs count: ${activity.materialUsageLogs.length}');

    double total = 0.0;
    for (int i = 0; i < activity.materialUsageLogs.length; i++) {
      final log = activity.materialUsageLogs[i];
      final cost = log.quantity * log.unitRate;
      print('[COST DEBUG] Material $i: ${log.material?.name ?? "Unknown"}');
      print('[COST DEBUG] - Quantity: ${log.quantity}');
      print('[COST DEBUG] - Unit rate: ${log.unitRate}');
      print('[COST DEBUG] - Cost: $cost');
      total += cost;
    }

    print('[COST DEBUG] Material total: $total');
    print('[COST DEBUG] === END MATERIAL ===');
    return total;
  }

  double _calculateOtherCostsTotal() {
    print('[COST DEBUG] === OTHER COSTS CALCULATION ===');
    print('[COST DEBUG] Other costs count: ${activity.otherCosts.length}');

    double total = 0.0;
    for (int i = 0; i < activity.otherCosts.length; i++) {
      final cost = activity.otherCosts[i];
      print('[COST DEBUG] Other cost $i: ${cost.description}');
      print('[COST DEBUG] - Cost type: ${cost.costType}');
      print('[COST DEBUG] - Amount: ${cost.amount}');
      total += cost.amount;
    }

    print('[COST DEBUG] Other costs total: $total');
    print('[COST DEBUG] === END OTHER COSTS ===');
    return total;
  }

  double _calculateGrandTotal() {
    final equipmentTotal = _calculateEquipmentTotal();
    final manpowerTotal = _calculateManpowerTotal();
    final materialTotal = _calculateMaterialTotal();
    final otherCostsTotal = _calculateOtherCostsTotal();
    final grandTotal =
        equipmentTotal + manpowerTotal + materialTotal + otherCostsTotal;

    print('[COST DEBUG] === GRAND TOTAL CALCULATION ===');
    print('[COST DEBUG] Equipment total: $equipmentTotal');
    print('[COST DEBUG] Manpower total: $manpowerTotal');
    print('[COST DEBUG] Material total: $materialTotal');
    print('[COST DEBUG] Other costs total: $otherCostsTotal');
    print('[COST DEBUG] GRAND TOTAL: $grandTotal');
    print('[COST DEBUG] === END GRAND TOTAL ===');

    return grandTotal;
  }

  double _calculateTotalProgressValue() {
    print('[PROGRESS DEBUG] === CALCULATING TOTAL PROGRESS VALUE ===');
    print('[PROGRESS DEBUG] Number of activity details: ${activity.activityDetails.length}');
    
    double total = 0.0;
    for (int i = 0; i < activity.activityDetails.length; i++) {
      final detail = activity.activityDetails[i];
      final itemValue = _calculateProgressValue(detail);
      total += itemValue;
      print('[PROGRESS DEBUG] Item $i value: $itemValue, Running total: $total');
    }
    
    print('[PROGRESS DEBUG] FINAL TOTAL PROGRESS VALUE: $total');
    print('[PROGRESS DEBUG] =============================================');
    return total;
  }

  double _calculateProgressValue(ActivityDetailResponse detail) {
    // === DEBUG LOGGING ===
    print('[PROGRESS DEBUG] === ACTIVITY DETAIL: ${detail.id} ===');
    print('[PROGRESS DEBUG] Work Item: ${detail.workItem?.name ?? "Unknown"}');
    print('[PROGRESS DEBUG] totalProgressValue from response: ${detail.totalProgressValue}');
    print('[PROGRESS DEBUG] actualQuantity.nr: ${detail.actualQuantity.nr}');
    print('[PROGRESS DEBUG] actualQuantity.r: ${detail.actualQuantity.r}');
    print('[PROGRESS DEBUG] rateNR: ${detail.rateNR}');
    print('[PROGRESS DEBUG] rateR: ${detail.rateR}');
    print('[PROGRESS DEBUG] rateDescriptionNR: ${detail.rateDescriptionNR}');
    print('[PROGRESS DEBUG] rateDescriptionR: ${detail.rateDescriptionR}');
    print('[PROGRESS DEBUG] boqVolumeNR: ${detail.boqVolumeNR}');
    print('[PROGRESS DEBUG] boqVolumeR: ${detail.boqVolumeR}');
    print('[PROGRESS DEBUG] status: ${detail.status}');
    print('[PROGRESS DEBUG] remarks: ${detail.remarks}');
    
    // Gunakan totalProgressValue jika tersedia, jika tidak hitung manual
    if (detail.totalProgressValue != null && detail.totalProgressValue! > 0) {
      print('[PROGRESS DEBUG] Using totalProgressValue: ${detail.totalProgressValue}');
      print('[PROGRESS DEBUG] ========================================');
      return detail.totalProgressValue!;
    }
    
    // Fallback: hitung manual berdasarkan actualQuantity dan rate yang ada
    final volumeNR = detail.actualQuantity.nr;
    final volumeR = detail.actualQuantity.r;
    final rateNR = detail.rateNR ?? 0.0;
    final rateR = detail.rateR ?? 0.0;
    
    double totalManual = 0.0;
    
    // Hanya hitung jika volume dan rate > 0
    if (volumeNR > 0 && rateNR > 0) {
      final manualCalcNR = volumeNR * rateNR;
      totalManual += manualCalcNR;
      print('[PROGRESS DEBUG] - volumeNR ($volumeNR) × rateNR ($rateNR) = $manualCalcNR');
    } else if (volumeNR > 0 || rateNR > 0) {
      print('[PROGRESS DEBUG] - volumeNR ($volumeNR) × rateNR ($rateNR) = 0 (salah satu adalah 0)');
    }
    
    if (volumeR > 0 && rateR > 0) {
      final manualCalcR = volumeR * rateR;
      totalManual += manualCalcR;
      print('[PROGRESS DEBUG] - volumeR ($volumeR) × rateR ($rateR) = $manualCalcR');
    } else if (volumeR > 0 || rateR > 0) {
      print('[PROGRESS DEBUG] - volumeR ($volumeR) × rateR ($rateR) = 0 (salah satu adalah 0)');
    }
    
    print('[PROGRESS DEBUG] - Total manual: $totalManual');
    print('[PROGRESS DEBUG] ========================================');
    
    return totalManual;
  }

  double _calculateProfitLoss() {
    double totalProgressValue = _calculateTotalProgressValue();
    double totalCost = _calculateGrandTotal();
    return totalProgressValue - totalCost;
  }

  String _buildVolumeText(ActivityDetailResponse detail) {
    List<String> volumeTexts = [];
    
    if (detail.actualQuantity.nr > 0) {
      volumeTexts.add('${detail.actualQuantity.nr.toStringAsFixed(1)} (NR)');
    }
    if (detail.actualQuantity.r > 0) {
      volumeTexts.add('${detail.actualQuantity.r.toStringAsFixed(1)} (R)');
    }
    
    if (volumeTexts.isNotEmpty) {
      return 'Volume: ${volumeTexts.join(' | ')} ${detail.workItem?.unit?.name ?? ''}';
    } else {
      return 'Volume: N/A';
    }
  }

  String _buildRateText(ActivityDetailResponse detail) {
    List<String> rateTexts = [];
    
    // Hanya tampilkan rate jika ada volume yang sesuai
    if (detail.actualQuantity.nr > 0 && detail.rateNR != null && detail.rateNR! > 0) {
      rateTexts.add('Rp ${_formatCurrency(detail.rateNR!)} (NR)');
    }
    if (detail.actualQuantity.r > 0 && detail.rateR != null && detail.rateR! > 0) {
      rateTexts.add('Rp ${_formatCurrency(detail.rateR!)} (R)');
    }
    
    if (rateTexts.isNotEmpty) {
      return 'Rate: ${rateTexts.join(' | ')}';
    } else {
      return 'Rate: N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug output untuk memeriksa nilai lokasi lebih detail
    print("\n============= INFO AKTIVITAS ${activity.id} =============");
    print("1. SPK Detail: ${activity.spkDetail}");
    if (activity.spkDetail != null) {
      print("2. SPK Detail Location Object: ${activity.spkDetail!.location}");
      if (activity.spkDetail!.location != null) {
        print("3. SPK Location Name: ${activity.spkDetail!.location!.name}");
        print("4. SPK Location ID: ${activity.spkDetail!.location!.id}");
      } else {
        print("3. SPK Location Object is NULL");
      }
    } else {
      print("2. SPK Detail is NULL");
    }
    print("5. Activity Location String: '${activity.location}'");
    print("6. Activity Area ID: '${activity.areaId}'");
    print("7. Activity Status: '${activity.status}'");
    print("=============================================\n");

    // Ambil lokasi dari activity
    final String locationText = activity.location ??
        activity.spkDetail?.location?.name ??
        activity.areaId ??
        'N/A';

    // Cek status laporan dengan debug logging
    final bool isDraft = activity.status.toLowerCase().contains('draft') ||
        activity.status.toLowerCase() == 'in_progress';
    final bool isWaitingProgress =
        activity.status.toLowerCase().contains('menunggu progress') ||
            activity.status.toLowerCase().contains('waiting');
    final bool isApproved =
        activity.status.toLowerCase().contains('disetujui') ||
            activity.status.toLowerCase().contains('approved') ||
            activity.status.toLowerCase().contains('completed');
    final bool isRejected =
        activity.status.toLowerCase().contains('rejected') ||
            activity.status.toLowerCase().contains('ditolak');
    final bool isTodayReport = isReportFromToday();

    // Debug logging untuk status
    print("8. isDraft: $isDraft (draft OR in_progress)");
    print(
        "9. isWaitingProgress: $isWaitingProgress (menunggu progress OR waiting)");
    print("10. isApproved: $isApproved (disetujui OR approved OR completed)");
    print("11. isRejected: $isRejected (rejected OR ditolak)");
    print("12. isTodayReport: $isTodayReport");
    print(
        "13. Final color logic - isDraft: $isDraft, will use orange: ${isDraft ? 'YES' : 'NO'}");
    print("14. Status exact match check:");
    print(
        "    - Contains 'draft': ${activity.status.toLowerCase().contains('draft')}");
    print(
        "    - Equals 'in_progress': ${activity.status.toLowerCase() == 'in_progress'}");
    print(
        "    - Status equals 'draft': ${activity.status.toLowerCase() == 'draft'}");
    print(
        "    - Status starts with 'draft': ${activity.status.toLowerCase().startsWith('draft')}");
    print("=============================================\n");

    return GestureDetector(
      onTap: () {
        print("[CARD TAP] Activity ${activity.id} tapped!");
        print("[CARD TAP] Status: ${activity.status}");
        print("[CARD TAP] isDraft: $isDraft");
        print("[CARD TAP] isWaitingProgress: $isWaitingProgress");
        print("[CARD TAP] onTap handler provided: ${onTap != null}");

        // For draft and waiting progress, use internal handling instead of parent
        if (isDraft || isWaitingProgress) {
          print("[CARD TAP] Using internal draft handling");
          // Tampilkan dialog konfirmasi untuk draft dan menunggu progress
          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDraft ? Icons.edit_document : Icons.pending_actions,
                      color: isDraft ? Colors.orange : Colors.blue,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isDraft ? 'Lanjutkan Pengisian' : 'Lanjutkan Progress',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isDraft
                          ? 'Apakah Anda ingin melanjutkan pengisian laporan kerja ini?'
                          : 'Apakah Anda ingin melanjutkan pengisian progress pekerjaan?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.back(); // Tutup dialog
                            // Navigasi ke halaman add work report dengan data yang sudah ada
                            Get.toNamed(
                              Routes.addWorkReport,
                              arguments: {
                                'spkId': activity.spkId,
                                'isDraft': true,
                                'draftId': activity.id,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDraft ? Colors.orange : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Lanjutkan',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          return; // Don't call parent handler for draft
        }

        // Prioritize parent onTap handler for non-draft items
        if (onTap != null) {
          print("[CARD TAP] Calling parent onTap handler");
          onTap!();
          return;
        }

        print("[CARD TAP] No handler available");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDraft
              ? Colors.orange.shade50
              : isWaitingProgress
                  ? Colors.blue.shade50
                  : isRejected
                      ? Colors.red.shade50
                      : isApproved
                          ? Colors.green.shade50
                          : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isDraft
              ? Border.all(color: Colors.orange, width: 2)
              : isWaitingProgress
                  ? Border.all(color: Colors.blue, width: 2)
                  : isRejected
                      ? Border.all(color: Colors.red, width: 2)
                      : isApproved
                          ? Border.all(color: Colors.green, width: 2)
                          : isTodayReport
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 120,
              decoration: BoxDecoration(
                color: isDraft
                    ? Colors.orange
                    : isWaitingProgress
                        ? Colors.blue
                        : const Color(0xFFFF6B00),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isDraft || isWaitingProgress
                    ? Icon(
                        isDraft ? Icons.edit_document : Icons.pending_actions,
                        color: Colors.white,
                        size: 36,
                      )
                    : Image.asset(
                        'assets/images/thumbnail_work.png',
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.build,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row untuk tag status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Indicator hari ini (jika laporan dibuat hari ini)
                        if (isTodayReport &&
                            !isDraft &&
                            !isWaitingProgress &&
                            !isApproved &&
                            !isRejected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Hari Ini',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),

                        // Status badge
                        buildStatusLabel(activity.status),

                        // Tombol detail (hide untuk draft)
                        if (!isDraft)
                          GestureDetector(
                            onTap: () => _showDetailDialog(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: FigmaColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: FigmaColors.primary,
                                size: 20,
                              ),
                            ),
                          ),

                        // Tombol hapus hanya untuk draft
                        if (isDraft)
                          GestureDetector(
                            onTap: () {
                              // Tampilkan dialog konfirmasi hapus
                              Get.dialog(
                                Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.delete_forever,
                                          color: Colors.red,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Hapus Draft?',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Apakah Anda yakin ingin menghapus draft laporan ini? Tindakan ini tidak dapat dibatalkan.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              onPressed: () => Get.back(),
                                              child: Text(
                                                'Batal',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 16,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Log ID saat penghapusan untuk debugging
                                                print(
                                                    '[DELETE] Menghapus draft ID: ${activity.id}');

                                                // Lakukan penghapusan draft
                                                final controller = Get.find<
                                                    DailyActivityController>();
                                                controller.deleteDraftActivity(
                                                    activity.id);
                                                Get.back(); // Tutup dialog
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text(
                                                'Hapus',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // SPK Title and ID
                    if (activity.spkDetail != null &&
                        activity.spkDetail!.title.isNotEmpty) ...[
                      Text(
                        activity.spkDetail!.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FigmaColors.hitam,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No. SPK: ${activity.spkDetail!.spkNo.isNotEmpty ? activity.spkDetail!.spkNo : 'Draft'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: FigmaColors.abu,
                        ),
                      ),
                    ] else ...[
                      Text(
                        isDraft
                            ? 'Draft Laporan'
                            : 'Work Report ID: ${activity.id}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FigmaColors.hitam,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SPK ID: ${activity.spkId}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: FigmaColors.abu,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart,
                          color: FigmaColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Progress Harian: ${getFormattedProgressPercentage()}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: FigmaColors.hitam,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Status row
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: FigmaColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Status: ${activity.status}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: FigmaColors.hitam,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: FigmaColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Lokasi: $locationText',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: FigmaColors.hitam,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: FigmaColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tanggal: ${getFormattedDate()}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: FigmaColors.hitam,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: FigmaColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Waktu Mulai: ${getFormattedTime(activity.workStartTime)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Waktu Selesai: ${getFormattedTime(activity.workEndTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
