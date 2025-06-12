import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PhotoTimeStepWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const PhotoTimeStepWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dokumentasi & Waktu Pekerjaan',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tambahkan foto dokumentasi dan catat waktu pengerjaan',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 20),

        // Tanggal pekerjaan
        Text(
          'Tanggal Pekerjaan',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasPhotos = controller.startPhotos.isNotEmpty ||
              controller.endPhotos.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPhotos)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.blue[700], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Informasi waktu dari metadata foto',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(controller.reportDate.value)}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!hasPhotos)
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              DateFormat('dd MMMM yyyy', 'id_ID')
                                  .format(controller.reportDate.value),
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                              ),
                            )),
                        const Icon(Icons.calendar_today,
                            size: 20, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),

        const SizedBox(height: 16),

        // Waktu mulai dan selesai
        Obx(() {
          final hasStartPhotos = controller.startPhotos.isNotEmpty;
          final hasEndPhotos = controller.endPhotos.isNotEmpty;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waktu Pengerjaan',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hasStartPhotos || hasEndPhotos
                      ? Colors.green[50]
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: hasStartPhotos || hasEndPhotos
                          ? Colors.green[200]!
                          : Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waktu Mulai',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _selectTime(context, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: hasStartPhotos ? Colors.green : Colors.grey,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat('HH:mm').format(controller.workStartTime.value),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: hasStartPhotos ? Colors.green[800] : Colors.black,
                                        ),
                                      ),
                                      if (hasStartPhotos)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (hasStartPhotos)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    'Dari metadata foto',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Waktu Selesai',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _selectTime(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: hasEndPhotos ? Colors.green : Colors.grey,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          controller.workEndTime.value != null
                                              ? DateFormat('HH:mm').format(controller.workEndTime.value!)
                                              : '--:--',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: hasEndPhotos ? Colors.green[800] : Colors.black,
                                          ),
                                        ),
                                        if (hasEndPhotos)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (hasEndPhotos)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Dari metadata foto',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!hasStartPhotos || !hasEndPhotos)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Waktu dapat diisi manual atau otomatis dari metadata foto',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 24),

        // Foto Awal Pekerjaan
        Text(
          'Foto Awal Pekerjaan',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => controller.startPhotos.isEmpty
              ? _buildPhotoSelector(
                  context,
                  'Tambahkan foto awal pekerjaan',
                  () async {
                    final photos = await controller
                        .pickAndUploadMultiplePhotos(ImageSource.gallery);
                    for (var photo in photos) {
                      controller.addStartPhoto(photo);
                    }
                  },
                )
              : _buildPhotoList(controller.startPhotos, (photoId) {
                  controller.removeStartPhoto(photoId);
                }),
        ),
        const SizedBox(height: 16),

        // Foto Akhir Pekerjaan
        Text(
          'Foto Akhir Pekerjaan',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => controller.endPhotos.isEmpty
              ? _buildPhotoSelector(
                  context,
                  'Tambahkan foto akhir pekerjaan',
                  () async {
                    final photos = await controller
                        .pickAndUploadMultiplePhotos(ImageSource.gallery);
                    for (var photo in photos) {
                      controller.addEndPhoto(photo);
                    }
                  },
                )
              : _buildPhotoList(controller.endPhotos, (photoId) {
                  controller.removeEndPhoto(photoId);
                }),
        ),
      ],
    );
  }

  Widget _buildPhotoSelector(
      BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo,
              color: FigmaColors.primary,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoList(List<WorkPhoto> photos, Function(String) onRemove) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return Stack(
              fit: StackFit.expand,
              children: [
                // Photo
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    photo.accessUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
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
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.error_outline, color: Colors.red),
                        ),
                      );
                    },
                  ),
                ),

                // Remove button
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => onRemove(photo.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Add more button
        TextButton.icon(
          onPressed: () async {
            // Get controller
            final controller = Get.find<AddWorkReportController>();

            // Check if this is start or end photos
            if (photos.isNotEmpty && photos == controller.startPhotos) {
              final newPhotos = await controller
                  .pickAndUploadMultiplePhotos(ImageSource.gallery);
              for (var photo in newPhotos) {
                controller.addStartPhoto(photo);
              }
            } else {
              final newPhotos = await controller
                  .pickAndUploadMultiplePhotos(ImageSource.gallery);
              for (var photo in newPhotos) {
                controller.addEndPhoto(photo);
              }
            }
          },
          icon: const Icon(Icons.add_photo_alternate, size: 20),
          label: const Text('Tambah foto'),
          style: TextButton.styleFrom(
            foregroundColor: FigmaColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  void _selectDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: controller.reportDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    ).then((date) {
      if (date != null) {
        controller.setReportDate(date);
      }
    });
  }

  void _selectTime(BuildContext context, bool isStartTime) {
    final initialTime = isStartTime 
        ? TimeOfDay.fromDateTime(controller.workStartTime.value)
        : (controller.workEndTime.value != null 
            ? TimeOfDay.fromDateTime(controller.workEndTime.value!)
            : TimeOfDay.now());

    showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: FigmaColors.primary),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: FigmaColors.primary),
              ),
              dayPeriodColor: Colors.transparent,
              dayPeriodTextColor: FigmaColors.primary,
              dayPeriodBorderSide: BorderSide(color: FigmaColors.primary),
            ),
            colorScheme: ColorScheme.light(
              primary: FigmaColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        final now = DateTime.now();
        final selectedDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        if (isStartTime) {
          controller.setWorkStartTime(selectedDateTime);
        } else {
          controller.setWorkEndTime(selectedDateTime);
        }
      }
    });
  }
}
