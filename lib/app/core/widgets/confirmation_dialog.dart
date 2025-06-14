import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color? confirmColor;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Ya',
    this.cancelText = 'Batal',
    required this.onConfirm,
    required this.onCancel,
    this.confirmColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppTheme.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            cancelText,
            style: GoogleFonts.dmSans(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: GoogleFonts.dmSans(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
