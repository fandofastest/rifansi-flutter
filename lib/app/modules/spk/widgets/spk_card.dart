import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/spk_model.dart';
import '../../../routes/app_routes.dart';

class SpkCard extends StatelessWidget {
  final Spk spk;
  final VoidCallback? onTap;
  const SpkCard({Key? key, required this.spk, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          Get.toNamed(Routes.spkDetails, arguments: {'spkId': spk.id});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header orange
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B00),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spk.title,
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          spk.projectName,
                          style: GoogleFonts.dmSans(
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description,
                          color: Color(0xFFFF6B00), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'SPK No: ${spk.spkNo}',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.push_pin,
                          color: Color(0xFFFF6B00), size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Color(0xFFFF6B00), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lokasi : ${spk.location.name}',
                          style: GoogleFonts.dmSans(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          color: Color(0xFFFF6B00), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Status:',
                        style: GoogleFonts.dmSans(fontSize: 13),
                      ),
                      Text(
                        'Aktif', // TODO: Ganti sesuai status spk jika ada field status
                        style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Color(0xFFFF6B00),
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFFFF6B00), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Mulai : ${_formatDate(spk.startDate)}',
                          style: GoogleFonts.dmSans(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event_available,
                          color: Color(0xFFFF6B00), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Selesai : ${_formatDate(spk.endDate)}',
                          style: GoogleFonts.dmSans(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          color: Color(0xFFFF6B00), size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Budget : ${_formatRupiah(spk.budget)}',
                          style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF6B00)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      DateTime? dt;
      if (date is int) {
        dt = DateTime.fromMillisecondsSinceEpoch(date);
      } else if (date is String) {
        // Cek jika string milisecond
        final ms = int.tryParse(date);
        if (ms != null) {
          dt = DateTime.fromMillisecondsSinceEpoch(ms);
        } else {
          dt = DateTime.tryParse(date);
        }
      }
      if (dt == null) return date.toString();
      // Format: Sen, 5 Oktober 2025
      return '${_hari(dt.weekday)}, ${dt.day} ${_bulan(dt.month)} ${dt.year}';
    } catch (_) {
      return date.toString();
    }
  }

  static String _hari(int weekday) {
    switch (weekday) {
      case 1:
        return 'Sen';
      case 2:
        return 'Sel';
      case 3:
        return 'Rab';
      case 4:
        return 'Kam';
      case 5:
        return 'Jum';
      case 6:
        return 'Sab';
      case 7:
        return 'Min';
      default:
        return '';
    }
  }

  static String _bulan(int month) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulan[month];
  }

  static String _formatRupiah(int value) {
    // Format sederhana, bisa pakai intl untuk format lebih baik
    return 'Rp${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
