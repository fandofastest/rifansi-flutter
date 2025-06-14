import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

class EquipmentRepairAccordionCard extends StatefulWidget {
  final Map<String, dynamic> report;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showActions;

  const EquipmentRepairAccordionCard({
    Key? key,
    required this.report,
    this.onApprove,
    this.onReject,
    this.showActions = true,
  }) : super(key: key);

  @override
  State<EquipmentRepairAccordionCard> createState() =>
      _EquipmentRepairAccordionCardState();
}

class _EquipmentRepairAccordionCardState
    extends State<EquipmentRepairAccordionCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = (widget.report['status']?.toString() ?? '').toLowerCase();
    final isRejected = status.contains('rejected');
    final isApproved = status.contains('approved');
    final isPending = status.contains('pending') ||
        status.contains('submitted') ||
        status.contains('open');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRejected
              ? Colors.red.shade300
              : isApproved
                  ? Colors.green.shade300
                  : isPending
                      ? Colors.orange.shade300
                      : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Compact header - always visible
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.report['reportNumber']?.toString() ??
                                  'No Report Number',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: FigmaColors.hitam,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getEquipmentInfo(),
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: FigmaColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getReporterInfo(),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: FigmaColors.abu,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildStatusBadge(),
                          const SizedBox(height: 8),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: FigmaColors.abu,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: FigmaColors.abu),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(widget.report['reportDate']?.toString()),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: FigmaColors.abu,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.warning, size: 14, color: FigmaColors.abu),
                      const SizedBox(width: 4),
                      Text(
                        _getDamageLevel(),
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: FigmaColors.abu,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),

                  // Equipment details
                  _buildDetailRow(
                    icon: Icons.build_circle,
                    label: 'Detail Alat',
                    value: _getEquipmentDetails(),
                  ),
                  const SizedBox(height: 12),

                  // Location
                  if (widget.report['location'] != null)
                    _buildDetailRow(
                      icon: Icons.location_on,
                      label: 'Lokasi',
                      value:
                          widget.report['location']['name']?.toString() ?? '-',
                    ),
                  const SizedBox(height: 12),

                  // Priority
                  if (widget.report['priority'] != null) ...[
                    _buildDetailRow(
                      icon: Icons.priority_high,
                      label: 'Prioritas',
                      value: _getPriorityText(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Problem description
                  if (widget.report['problemDescription'] != null &&
                      widget.report['problemDescription']
                          .toString()
                          .isNotEmpty) ...[
                    Text(
                      'Deskripsi Masalah:',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FigmaColors.abu,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: FigmaColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        widget.report['problemDescription']?.toString() ?? '-',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: FigmaColors.hitam,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Report Images
                  if (widget.report['reportImages'] != null &&
                      (widget.report['reportImages'] as List).isNotEmpty) ...[
                    Text(
                      'Foto Laporan:',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: FigmaColors.abu,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildImageGallery(),
                    const SizedBox(height: 12),
                  ],

                  // Show review info for responded reports
                  if (!isPending && (isApproved || isRejected)) ...[
                    const Divider(height: 16),
                    _buildReviewInfo(),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons for pending reports
                  if (widget.showActions && isPending) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onReject,
                            icon: const Icon(Icons.close, size: 16),
                            label: Text(
                              'Tolak',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FigmaColors.error,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onApprove,
                            icon: const Icon(Icons.check, size: 16),
                            label: Text(
                              'Setujui',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FigmaColors.done,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = (widget.report['status']?.toString() ?? '').toLowerCase();
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
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
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: FigmaColors.abu,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
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
    final reviewedBy = widget.report['reviewedBy'];
    final reviewDate = widget.report['reviewDate'];
    final reviewNotes = widget.report['reviewNotes'];
    final rejectionReason = widget.report['rejectionReason'];

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
          _buildDetailRow(
            icon: Icons.person_outline,
            label: 'Direview oleh',
            value: reviewedBy['fullName']?.toString() ?? '-',
          ),
          const SizedBox(height: 8),
        ],
        if (reviewDate != null) ...[
          _buildDetailRow(
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              rejectionReason.toString(),
              style: GoogleFonts.dmSans(
                fontSize: 12,
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: FigmaColors.abu,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FigmaColors.background,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              reviewNotes.toString(),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: FigmaColors.hitam,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGallery() {
    final images = widget.report['reportImages'] as List? ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 80,
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
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
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
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Error',
                              style: GoogleFonts.dmSans(
                                fontSize: 8,
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

  String _getEquipmentInfo() {
    final equipment = widget.report['equipment'];
    if (equipment == null) return 'Equipment tidak diketahui';

    final code = equipment['equipmentCode']?.toString() ?? '';
    final type = equipment['equipmentType']?.toString() ?? '';

    return '$code - $type';
  }

  String _getEquipmentDetails() {
    final equipment = widget.report['equipment'];
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
    final reportedBy = widget.report['reportedBy'];
    if (reportedBy == null) return '-';

    final fullName = reportedBy['fullName']?.toString() ?? '';
    final role = reportedBy['role']?['roleName']?.toString() ?? '';

    String info = fullName;
    if (role.isNotEmpty) info += ' ($role)';

    return info;
  }

  String _getDamageLevel() {
    final damageLevel = widget.report['damageLevel']?.toString() ?? '';
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
    final priority = widget.report['priority']?.toString() ?? '';
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
