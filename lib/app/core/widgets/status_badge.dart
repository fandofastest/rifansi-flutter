import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isApproved;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.isApproved,
  }) : super(key: key);

  Color getStatusColor() {
    if (isApproved) return AppTheme.success;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppTheme.success;
      case 'REJECTED':
        return AppTheme.error;
      case 'PENDING':
        return AppTheme.warning;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData getStatusIcon() {
    if (isApproved) return Icons.check_circle;
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'PENDING':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }

  String getStatusText() {
    if (isApproved) return 'Disetujui';
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'REJECTED':
        return 'Ditolak';
      case 'PENDING':
        return 'Menunggu';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            getStatusText(),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
