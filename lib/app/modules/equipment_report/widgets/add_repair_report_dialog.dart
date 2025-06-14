import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/equipment_model.dart';
import '../../../data/models/area_model.dart' as area_model;
import '../../../controllers/auth_controller.dart';
import '../equipment_report_controller.dart';

class AddRepairReportDialog extends StatefulWidget {
  final EquipmentReportController controller;
  final List<Equipment> equipmentList;
  final List<area_model.Area> areaList;

  const AddRepairReportDialog({
    Key? key,
    required this.controller,
    required this.equipmentList,
    required this.areaList,
  }) : super(key: key);

  @override
  State<AddRepairReportDialog> createState() => _AddRepairReportDialogState();
}

class _AddRepairReportDialogState extends State<AddRepairReportDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  Equipment? selectedEquipment;
  area_model.Area? currentUserLocation;
  String problemDescription = '';
  String immediateAction = '';
  String damageLevel = 'RINGAN';
  String priority = 'MEDIUM';
  List<WorkPhoto> reportImages = [];
  
  // Controllers
  final _problemController = TextEditingController();
  final _actionController = TextEditingController();

  final List<String> damageLevels = ['RINGAN', 'SEDANG', 'BERAT'];
  final List<String> priorities = ['LOW', 'MEDIUM', 'HIGH'];

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  void _setCurrentLocation() {
    try {
      // Get current user's area from auth controller
      final authController = Get.find<AuthController>();
      final userArea = authController.currentUser.value?.area;
      
      if (userArea != null) {
        setState(() {
          currentUserLocation = userArea;
        });
        print('[AddRepairReport] User area detected: ${userArea.name}');
      } else {
        print('[AddRepairReport] No user area found in auth controller');
        // Fallback to first area if user area is not available
        if (widget.areaList.isNotEmpty) {
          setState(() {
            currentUserLocation = widget.areaList.first;
          });
          print('[AddRepairReport] Using fallback area: ${widget.areaList.first.name}');
        }
      }
    } catch (e) {
      print('[AddRepairReport] Error getting user area: $e');
      // Fallback to first area if there's an error
      if (widget.areaList.isNotEmpty) {
        setState(() {
          currentUserLocation = widget.areaList.first;
        });
        print('[AddRepairReport] Using fallback area due to error: ${widget.areaList.first.name}');
      }
    }
  }

  @override
  void dispose() {
    _problemController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Laporan Kerusakan Alat',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Equipment Selection
                      DropdownButtonFormField<Equipment>(
                        decoration: InputDecoration(
                          labelText: 'Pilih Alat *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: selectedEquipment,
                        items: widget.equipmentList.map((equipment) {
                          return DropdownMenuItem<Equipment>(
                            value: equipment,
                            child: Text(
                              '${equipment.equipmentCode} - ${equipment.equipmentType}',
                              style: GoogleFonts.dmSans(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (Equipment? value) {
                          setState(() {
                            selectedEquipment = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih alat yang rusak';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Current Location Display (Auto-detected)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lokasi Saat Ini',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                  Text(
                                    currentUserLocation?.name ?? 'Lokasi tidak terdeteksi',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Problem Description
                      TextFormField(
                        controller: _problemController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Masalah *',
                          hintText: 'Jelaskan masalah yang terjadi pada alat...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi masalah harus diisi';
                          }
                          if (value.trim().length < 10) {
                            return 'Deskripsi masalah minimal 10 karakter';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          problemDescription = value;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Immediate Action
                      TextFormField(
                        controller: _actionController,
                        decoration: InputDecoration(
                          labelText: 'Tindakan Segera *',
                          hintText: 'Jelaskan tindakan yang sudah dilakukan...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tindakan segera harus diisi';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          immediateAction = value;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Damage Level and Priority Row
                      Row(
                        children: [
                          // Damage Level
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Tingkat Kerusakan *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: damageLevel,
                              items: damageLevels.map((level) {
                                return DropdownMenuItem<String>(
                                  value: level,
                                  child: Text(
                                    level,
                                    style: GoogleFonts.dmSans(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  damageLevel = value ?? 'RINGAN';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Priority
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Prioritas *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: priority,
                              items: priorities.map((prio) {
                                return DropdownMenuItem<String>(
                                  value: prio,
                                  child: Text(
                                    prio,
                                    style: GoogleFonts.dmSans(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  priority = value ?? 'MEDIUM';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Report Images Section
                      Text(
                        'Foto Dokumentasi',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      reportImages.isEmpty
                          ? _buildPhotoSelector(
                              context,
                              'Tambahkan foto kerusakan alat',
                              () => _pickAndUploadImages(),
                            )
                          : _buildPhotoList(reportImages, (photoId) {
                              _removeImage(photoId);
                            }),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.dmSans(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FigmaColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Kirim Laporan',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSelector(BuildContext context, String label, VoidCallback onTap) {
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
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _pickAndUploadImages(),
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

  Future<void> _pickAndUploadImages() async {
    try {
      // Use equipment report controller's image upload functionality
      final newPhotos = await widget.controller.pickAndUploadMultiplePhotos(ImageSource.gallery);
      
      setState(() {
        reportImages.addAll(newPhotos);
      });
      
      if (newPhotos.isNotEmpty) {
        Get.snackbar(
          'Sukses',
          '${newPhotos.length} foto berhasil diunggah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
        );
      }
    } catch (e) {
      print('[AddRepairReport] Error picking images: $e');
      Get.snackbar(
        'Error',
        'Gagal mengambil dan mengunggah foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  void _removeImage(String photoId) {
    setState(() {
      reportImages.removeWhere((photo) => photo.id == photoId);
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      if (currentUserLocation == null) {
        Get.snackbar(
          'Error',
          'Lokasi tidak terdeteksi. Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return;
      }

      final reportData = {
        'equipmentId': selectedEquipment!.id,
        'problemDescription': problemDescription.trim(),
        'damageLevel': damageLevel,
        'reportImages': reportImages.map((photo) => photo.accessUrl).toList(),
        'location': currentUserLocation!.id,
        'immediateAction': immediateAction.trim(),
        'priority': priority,
      };

      widget.controller.createReport(reportData);
      Get.back();
    }
  }
} 