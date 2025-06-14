import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

class EquipmentRepairCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const EquipmentRepairCard({
    Key? key,
    required this.report,
    this.onApprove,
    this.onReject,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = (report['status']?.toString() ?? '').toLowerCase();
    final isRejected = status.contains('rejected');
    final isApproved = status.contains('approved');
    final isPending = status.contains('pending') ||
        status.contains('submitted') ||
        status.contains('open');

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
                  : isPending
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
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['reportNumber']?.toString() ??
                            'No Report Number',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: FigmaColors.hitam,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getEquipmentInfo(),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: FigmaColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // Equipment details
            _buildInfoRow(
              icon: Icons.build_circle,
              label: 'Alat',
              value: _getEquipmentDetails(),
            ),
            const SizedBox(height: 8),

            // Reporter info
            _buildInfoRow(
              icon: Icons.person,
              label: 'Dilaporkan oleh',
              value: _getReporterInfo(),
            ),
            const SizedBox(height: 8),

            // Location
            if (report['location'] != null)
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Lokasi',
                value: report['location']['name']?.toString() ?? '-',
              ),
            const SizedBox(height: 8),

            // Report date
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal Laporan',
              value: _formatDate(report['reportDate']?.toString()),
            ),
            const SizedBox(height: 8),

            // Damage level
            _buildInfoRow(
              icon: Icons.warning,
              label: 'Tingkat Kerusakan',
              value: _getDamageLevel(),
            ),
            const SizedBox(height: 16),

            // Problem description
            if (report['problemDescription'] != null &&
                report['problemDescription'].toString().isNotEmpty) ...[
              Text(
                'Deskripsi Masalah:',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.abu,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: FigmaColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  report['problemDescription']?.toString() ?? '-',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: FigmaColors.hitam,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Priority
            if (report['priority'] != null) ...[
              _buildInfoRow(
                icon: Icons.priority_high,
                label: 'Prioritas',
                value: _getPriorityText(),
              ),
              const SizedBox(height: 16),
            ],

            // Report Images
            if (report['reportImages'] != null &&
                (report['reportImages'] as List).isNotEmpty) ...[
              Text(
                'Foto Laporan:',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.abu,
                ),
              ),
              const SizedBox(height: 8),
              _buildImageGallery(),
              const SizedBox(height: 16),
            ],

            // Action buttons for pending reports
            if (showActions && isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: Text(
                        'Tolak',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FigmaColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(
                        'Setujui',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FigmaColors.done,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Show review info for responded reports
            if (!isPending && (isApproved || isRejected)) ...[
              const Divider(height: 24),
              _buildReviewInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = (report['status']?.toString() ?? '').toLowerCase();
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String text;

    if (status.contains('approved')) {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      text = 'Disetujui';
    } else if (status.contains('rejected')) {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
      text = 'Ditolak';
    } else {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      icon = Icons.pending;
      text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: FigmaColors.abu,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.abu,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.hitam,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewInfo() {
    final reviewedBy = report['reviewedBy'];
    final reviewDate = report['reviewDate'];
    final reviewNotes = report['reviewNotes'];
    final rejectionReason = report['rejectionReason'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Review:',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FigmaColors.abu,
          ),
        ),
        const SizedBox(height: 8),
        if (reviewedBy != null) ...[
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Direview oleh',
            value: reviewedBy['fullName']?.toString() ?? '-',
          ),
          const SizedBox(height: 8),
        ],
        if (reviewDate != null) ...[
          _buildInfoRow(
            icon: Icons.access_time,
            label: 'Tanggal Review',
            value: _formatDate(reviewDate.toString()),
          ),
          const SizedBox(height: 8),
        ],
        if (rejectionReason != null &&
            rejectionReason.toString().isNotEmpty) ...[
          Text(
            'Alasan Penolakan:',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              rejectionReason.toString(),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
        if (reviewNotes != null && reviewNotes.toString().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Catatan Review:',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: FigmaColors.abu,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: FigmaColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              reviewNotes.toString(),
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: FigmaColors.hitam,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getEquipmentInfo() {
    final equipment = report['equipment'];
    if (equipment == null) return 'Equipment tidak diketahui';

    final code = equipment['equipmentCode']?.toString() ?? '';
    final type = equipment['equipmentType']?.toString() ?? '';

    return '$code - $type';
  }

  String _getEquipmentDetails() {
    final equipment = report['equipment'];
    if (equipment == null) return '-';

    final code = equipment['equipmentCode']?.toString() ?? '';
    final plate = equipment['plateOrSerialNo']?.toString() ?? '';
    final type = equipment['equipmentType']?.toString() ?? '';

    String details = code;
    if (plate.isNotEmpty) details += ' ($plate)';
    if (type.isNotEmpty) details += ' - $type';

    return details;
  }

  String _getReporterInfo() {
    final reportedBy = report['reportedBy'];
    if (reportedBy == null) return '-';

    final fullName = reportedBy['fullName']?.toString() ?? '';
    final role = reportedBy['role']?['roleName']?.toString() ?? '';

    String info = fullName;
    if (role.isNotEmpty) info += ' ($role)';

    return info;
  }

  String _getDamageLevel() {
    final damageLevel = report['damageLevel']?.toString() ?? '';
    switch (damageLevel.toLowerCase()) {
      case 'low':
        return 'Ringan';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Berat';
      case 'critical':
        return 'Kritis';
      default:
        return damageLevel.isNotEmpty ? damageLevel : '-';
    }
  }

  String _getPriorityText() {
    final priority = report['priority']?.toString() ?? '';
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Rendah';
      case 'medium':
        return 'Sedang';
      case 'high':
        return 'Tinggi';
      case 'urgent':
        return 'Mendesak';
      default:
        return priority.isNotEmpty ? priority : '-';
    }
  }

  Widget _buildImageGallery() {
    final images = report['reportImages'] as List? ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = images[index].toString();
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showImageDialog(context, imageUrl, images, index),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey.shade600,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gagal memuat',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String initialImage, List images,
      int initialIndex) {
    final PageController pageController =
        PageController(initialPage: initialIndex);
    final RxInt currentIndex = initialIndex.obs;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          'Foto ${currentIndex.value + 1} dari ${images.length}',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Image viewer
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: images.length,
                  onPageChanged: (index) => currentIndex.value = index,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      child: InteractiveViewer(
                        child: Image.network(
                          images[index].toString(),
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Navigation dots
              if (images.length > 1) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Obx(() => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentIndex.value == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          )),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      // Try parsing as milliseconds first
      if (dateString.contains(RegExp(r'^\d+$'))) {
        final timestamp = int.parse(dateString);
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
      }

      // Try parsing as ISO date string
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
