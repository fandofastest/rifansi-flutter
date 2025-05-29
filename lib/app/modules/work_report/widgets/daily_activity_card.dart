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

    // Cek status laporan
    final bool isDraft = activity.status.toLowerCase().contains('draft');
    final bool isWaitingProgress =
        activity.status.toLowerCase().contains('menunggu progress');
    final bool isApproved =
        activity.status.toLowerCase().contains('disetujui') ||
            activity.status.toLowerCase().contains('approved');

    return GestureDetector(
      onTap: () {
        if (isDraft || isWaitingProgress) {
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
        } else {
          // Untuk non-draft, langsung panggil callback
          if (onTap != null) {
            onTap!();
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isApproved
              ? Colors.green.shade50
              : isDraft
                  ? Colors.orange.shade50
                  : activity.status.toLowerCase().contains('rejected')
                      ? Colors.red.shade50
                      : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isDraft
              ? Border.all(color: Colors.orange, width: 2)
              : isApproved
                  ? Border.all(color: Colors.green, width: 2)
                  : activity.status.toLowerCase().contains('rejected')
                      ? Border.all(color: Colors.red, width: 2)
                      : isWaitingProgress
                          ? Border.all(color: Colors.blue, width: 2)
                          : isReportFromToday()
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
                        if (isReportFromToday() &&
                            !isDraft &&
                            !isWaitingProgress &&
                            !isApproved)
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
