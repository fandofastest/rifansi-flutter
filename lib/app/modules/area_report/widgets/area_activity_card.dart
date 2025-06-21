import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/daily_activity_response.dart';
import '../../../data/providers/graphql_service.dart';

class AreaActivityCard extends StatelessWidget {
  final DailyActivityResponse activity;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const AreaActivityCard({
    Key? key,
    required this.activity,
    this.onApprove,
    this.onReject,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = activity.status.toLowerCase();
    final isRejected = status.contains('rejected');
    final isApproved = status.contains('approved');
    final isSubmitted = status.contains('submitted');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRejected
              ? Colors.red.shade300
              : isApproved
                  ? Colors.green.shade300
                  : isSubmitted
                      ? Colors.orange.shade300
                      : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status dan info utama
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon status
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? Colors.red.shade100
                        : isApproved
                            ? Colors.green.shade100
                            : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isRejected
                        ? Icons.cancel_outlined
                        : isApproved
                            ? Icons.check_circle_outlined
                            : Icons.pending_actions,
                    color: isRejected
                        ? Colors.red.shade600
                        : isApproved
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Info utama
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.spkDetail?.title ?? 'Laporan Kerja',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FigmaColors.hitam,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SPK: ${activity.spkDetail?.spkNo ?? activity.id}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: FigmaColors.abu,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRejected
                              ? Colors.red.shade50
                              : isApproved
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isRejected
                                ? Colors.red.shade200
                                : isApproved
                                    ? Colors.green.shade200
                                    : Colors.orange.shade200,
                          ),
                        ),
                        child: Text(
                          isRejected
                              ? 'Ditolak'
                              : isApproved
                                  ? 'Disetujui'
                                  : 'Menunggu Approval',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isRejected
                                ? Colors.red.shade700
                                : isApproved
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tombol detail
                GestureDetector(
                  onTap: () => _showDetailDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: FigmaColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: FigmaColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info detail dalam card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FigmaColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.person_outline,
                    'Dilaporkan oleh',
                    activity.userDetail.fullName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    'Tanggal',
                    _formatDate(activity.date),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Lokasi',
                    activity.location.isNotEmpty ? activity.location : 'N/A',
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tombol aksi - hanya tampil untuk status "Submitted"
            if (showActions &&
                activity.status.toLowerCase().contains('submitted')) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        'Tolak',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Setujui',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (isRejected && activity.rejectionReason != null) ...[
              // Tampilkan alasan penolakan jika ada
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Alasan penolakan: ${activity.rejectionReason}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: FigmaColors.abu,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: FigmaColors.abu,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: FigmaColors.hitam,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final timestamp = int.parse(dateString);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (_) {
      return dateString;
    }
  }

  void _showDetailDialog(BuildContext context) async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Fetch detailed activity data
      final graphQLService = Get.find<GraphQLService>();
      final detailedActivityData = await graphQLService.fetchDailyActivityWithDetailsByActivityId(activity.id);

      // Close loading dialog
      Get.back();

      // Use the detailed activity data for display if available
      DailyActivityResponse displayActivity = activity;
      if (detailedActivityData != null && detailedActivityData is Map<String, dynamic>) {
        try {
          displayActivity = DailyActivityResponse.fromJson(detailedActivityData);
        } catch (e) {
          print('[DEBUG] Error parsing detailed activity data: $e');
          // Fallback to original activity data
          displayActivity = activity;
        }
      }

      final bool isRejected =
          displayActivity.status.toLowerCase().contains('rejected') ||
              displayActivity.status.toLowerCase().contains('ditolak');

      // Show the detail dialog with the fetched data
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
                        : displayActivity.status.toLowerCase().contains('draft')
                            ? Colors.orange
                            : displayActivity.status
                                        .toLowerCase()
                                        .contains('disetujui') ||
                                    displayActivity.status
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
                            : displayActivity.status.toLowerCase().contains('draft')
                                ? Icons.edit_document
                                : displayActivity.status
                                            .toLowerCase()
                                            .contains('disetujui') ||
                                        displayActivity.status
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
                                  displayActivity.rejectionReason?.isNotEmpty == true
                                      ? displayActivity.rejectionReason!
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
                            if (displayActivity.spkDetail != null) ...[
                              _buildDetailRow(
                                  'Judul SPK', displayActivity.spkDetail!.title),
                              _buildDetailRow(
                                  'No. SPK', displayActivity.spkDetail!.spkNo),
                              _buildDetailRow(
                                  'Nama Proyek', displayActivity.spkDetail!.projectName),
                              if (displayActivity.spkDetail!.contractor.isNotEmpty)
                                _buildDetailRow(
                                    'Kontraktor', displayActivity.spkDetail!.contractor),
                            ] else ...[
                              _buildDetailRow('SPK ID', displayActivity.spkId),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Informasi Laporan
                        _buildDetailSection(
                          'Informasi Laporan',
                          [
                            _buildDetailRow('Status', displayActivity.status),
                            _buildDetailRow(
                                'Tanggal', _formatDate(displayActivity.date)),
                            _buildDetailRow(
                                'Lokasi',
                                displayActivity.location.isNotEmpty
                                    ? displayActivity.location
                                    : 'N/A'),
                            _buildDetailRow('Waktu Mulai',
                                _formatTime(displayActivity.workStartTime)),
                            _buildDetailRow('Waktu Selesai',
                                _formatTime(displayActivity.workEndTime)),
                            _buildDetailRow('Progress Harian',
                                '${displayActivity.progressPercentage.toStringAsFixed(2)}%'),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Catatan Penutup
                        if (displayActivity.closingRemarks.isNotEmpty) ...[
                          _buildDetailSection(
                            'Catatan Penutup',
                            [
                              Text(
                                displayActivity.closingRemarks,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Daily Progress Information (NEW)
                        if (detailedActivityData != null && detailedActivityData['dailyProgress'] != null) ...[
                          _buildDetailSection(
                            'Progress Harian',
                            [
                              Builder(
                                builder: (context) {
                                  final dailyProgress = detailedActivityData['dailyProgress'];
                                  final workItemProgress = dailyProgress['workItemProgress'] as List? ?? [];
                                  final totalDailyTarget = dailyProgress['totalDailyTargetBOQ'];
                                  final totalActual = dailyProgress['totalActualBOQ'];
                                  final dailyProgressPercentage = dailyProgress['dailyProgressPercentage'] ?? 0.0;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Overall Progress Summary
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue.shade200),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Progress Harian:',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade800,
                                              ),
                                            ),
                                            Text(
                                              '${dailyProgressPercentage.toStringAsFixed(2)}%',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      
                                      // Work Item Progress Details - Only show items with actual values
                                      Builder(
                                        builder: (context) {
                                          // Filter items that have actual values > 0
                                          final itemsWithActual = workItemProgress.where((item) {
                                            final actualBOQ = item['actualBOQ'];
                                            final actualTotal = actualBOQ?['total'] ?? 0.0;
                                            return actualTotal > 0;
                                          }).toList();

                                          if (itemsWithActual.isNotEmpty) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Detail Progress per Item Pekerjaan (${itemsWithActual.length} item)',
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                ...itemsWithActual.map((item) {
                                                  final targetBOQ = item['targetBOQ'];
                                                  final actualBOQ = item['actualBOQ'];
                                                  final progressPercentage = item['progressPercentage'] ?? 0.0;
                                                  final unit = item['unit'];
                                                  
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 8),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.shade50,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(color: Colors.green.shade200),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            item['workItemName'] ?? 'Unknown Work Item',
                                                            style: GoogleFonts.dmSans(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.black87,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          if (unit != null) ...[
                                                            Text(
                                                              'Unit: ${unit['name']} (${unit['code']})',
                                                              style: GoogleFonts.dmSans(
                                                                fontSize: 11,
                                                                color: Colors.black54,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 4),
                                                          ],
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Target: ${targetBOQ?['total']?.toStringAsFixed(2) ?? '0.00'}',
                                                                style: GoogleFonts.dmSans(
                                                                  fontSize: 12,
                                                                  color: Colors.black54,
                                                                ),
                                                              ),
                                                              Text(
                                                                'Actual: ${actualBOQ?['total']?.toStringAsFixed(2) ?? '0.00'}',
                                                                style: GoogleFonts.dmSans(
                                                                  fontSize: 12,
                                                                  color: Colors.black54,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Progress:',
                                                                style: GoogleFonts.dmSans(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.black87,
                                                                ),
                                                              ),
                                                              Text(
                                                                '${progressPercentage.toStringAsFixed(2)}%',
                                                                style: GoogleFonts.dmSans(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: progressPercentage >= 100 
                                                                    ? Colors.green.shade700 
                                                                    : progressPercentage >= 50 
                                                                      ? Colors.orange.shade700 
                                                                      : Colors.red.shade700,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // Progress bar
                                                          const SizedBox(height: 4),
                                                          LinearProgressIndicator(
                                                            value: progressPercentage / 100,
                                                            backgroundColor: Colors.grey.shade300,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                              progressPercentage >= 100 
                                                                ? Colors.green 
                                                                : progressPercentage >= 50 
                                                                  ? Colors.orange 
                                                                  : Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ],
                                            );
                                          } else {
                                            return const SizedBox.shrink(); // Don't show anything if no items with actual values
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Rincian Item Pekerjaan
                        if (displayActivity.activityDetails.isNotEmpty) ...[
                          _buildDetailSection(
                            'Rincian Item Pekerjaan',
                            [
                              Builder(
                                builder: (context) {
                                  final nonZeroItems = displayActivity.activityDetails.where((detail) {
                                    final progressValue = _calculateProgressValue(detail);
                                    return progressValue > 0;
                                  }).toList();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Progress Pekerjaan (${nonZeroItems.length} dari ${displayActivity.activityDetails.length} item)',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
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
                                                  'Semua item pekerjaan memiliki nilai 0.',
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
                                                  Text(
                                                    'Status: ${detail.status}',
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 11,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Nilai: Rp ${_formatCurrency(totalProgressValue)}',
                                                    style: GoogleFonts.dmSans(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green.shade700,
                                                    ),
                                                  ),
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
                                            'Rp ${_formatCurrency(_calculateTotalProgressValue(displayActivity))}',
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

                        // Analisis Laba Rugi
                        if (displayActivity.activityDetails.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _calculateProfitLoss(displayActivity) >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _calculateProfitLoss(displayActivity) >= 0 ? Colors.green.shade300 : Colors.red.shade300),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Analisis Laba Rugi',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
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
                                      'Rp ${_formatCurrency(_calculateTotalProgressValue(displayActivity))}',
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
                                      'Rp ${_formatCurrency(_calculateGrandTotal(displayActivity))}',
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
                                      '${_calculateProfitLoss(displayActivity) >= 0 ? '+' : ''}Rp ${_formatCurrency(_calculateProfitLoss(displayActivity).abs())}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _calculateProfitLoss(displayActivity) >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _calculateProfitLoss(displayActivity) >= 0 ? 'Menguntungkan' : 'Merugi',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _calculateProfitLoss(displayActivity) >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                                  ),
                                ),
                              ],
                            ),
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
    } catch (e) {
      // Close loading dialog if it's still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Show error dialog
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
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gagal memuat detail aktivitas: $e',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
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
        ),
      );
    }
  }

  // Helper methods
  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "--:--";
    try {
      final dateTime = DateTime.parse(time);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return "--:--";
    }
  }

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

  double _calculateProgressValue(ActivityDetailResponse detail) {
    if (detail.totalProgressValue != null && detail.totalProgressValue! > 0) {
      return detail.totalProgressValue!;
    }
    
    double total = 0.0;
    
    if (detail.actualQuantity.nr > 0 && detail.rateNR != null && detail.rateNR! > 0) {
      total += detail.actualQuantity.nr * detail.rateNR!;
    }
    
    if (detail.actualQuantity.r > 0 && detail.rateR != null && detail.rateR! > 0) {
      total += detail.actualQuantity.r * detail.rateR!;
    }
    
    return total;
  }

  double _calculateTotalProgressValue(DailyActivityResponse activityData) {
    return activityData.activityDetails.fold(
      0.0,
      (sum, detail) => sum + _calculateProgressValue(detail),
    );
  }

  double _calculateGrandTotal(DailyActivityResponse activityData) {
    double total = 0.0;
    
    // Equipment costs
    for (final log in activityData.equipmentLogs) {
      final fuelCost = log.fuelIn * log.fuelPrice;
      final cost = fuelCost + log.rentalRatePerDay;
      total += cost;
    }
    
    // Manpower costs
    for (final log in activityData.manpowerLogs) {
      final cost = log.normalHourlyRate * log.personCount * log.workingHours;
      total += cost;
    }
    
    // Material costs
    for (final log in activityData.materialUsageLogs) {
      final cost = log.quantity * log.unitRate;
      total += cost;
    }
    
    // Other costs
    total += activityData.otherCosts.fold(0.0, (sum, cost) => sum + cost.amount);
    
    return total;
  }

  double _calculateProfitLoss(DailyActivityResponse activityData) {
    return _calculateTotalProgressValue(activityData) - _calculateGrandTotal(activityData);
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: FigmaColors.hitam,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: FigmaColors.background,
            borderRadius: BorderRadius.circular(12),
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
                color: FigmaColors.abu,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: FigmaColors.hitam,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 