import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/daily_activity_response.dart';
import '../../work_report/widgets/daily_activity_card.dart';

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
                  _buildInfoRow(
                    Icons.trending_up_outlined,
                    'Progress',
                    '${activity.progressPercentage.toStringAsFixed(1)}%',
                  ),
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
                          _buildDetailRow(
                              'Tanggal', _formatDate(activity.date)),
                          _buildDetailRow(
                              'Lokasi',
                              activity.location.isNotEmpty
                                  ? activity.location
                                  : 'N/A'),
                          _buildDetailRow('Waktu Mulai',
                              _formatTime(activity.workStartTime)),
                          _buildDetailRow('Waktu Selesai',
                              _formatTime(activity.workEndTime)),
                          _buildDetailRow('Progress Harian',
                              '${activity.progressPercentage.toStringAsFixed(2)}%'),
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
                      if (activity.equipmentLogs.isNotEmpty ||
                          activity.manpowerLogs.isNotEmpty ||
                          activity.materialUsageLogs.isNotEmpty ||
                          activity.otherCosts.isNotEmpty) ...[
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

  // Helper methods untuk dialog detail
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

  double _calculateEquipmentTotal() {
    double total = 0.0;
    for (final log in activity.equipmentLogs) {
      final fuelCost = log.fuelIn * log.fuelPrice;
      final cost = fuelCost + log.rentalRatePerDay;
      total += cost;
    }
    return total;
  }

  double _calculateManpowerTotal() {
    double total = 0.0;
    for (final log in activity.manpowerLogs) {
      final cost = log.normalHourlyRate * log.personCount * log.workingHours;
      total += cost;
    }
    return total;
  }

  double _calculateMaterialTotal() {
    double total = 0.0;
    for (final log in activity.materialUsageLogs) {
      final cost = log.quantity * log.unitRate;
      total += cost;
    }
    return total;
  }

  double _calculateOtherCostsTotal() {
    double total = 0.0;
    for (final cost in activity.otherCosts) {
      total += cost.amount;
    }
    return total;
  }

  double _calculateGrandTotal() {
    return _calculateEquipmentTotal() +
        _calculateManpowerTotal() +
        _calculateMaterialTotal() +
        _calculateOtherCostsTotal();
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
