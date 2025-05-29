import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../controllers/lokasi_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/area_model.dart';
import '../../../data/models/spk_model.dart';

class SPKSelectionDialog extends StatelessWidget {
  final AddWorkReportController controller;

  const SPKSelectionDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: _DialogContent(controller: controller),
    );
  }

  static Future<Spk?> show(
      BuildContext context, AddWorkReportController controller) async {
    return showDialog<Spk?>(
      context: context,
      builder: (BuildContext context) {
        return SPKSelectionDialog(controller: controller);
      },
    );
  }
}

class _DialogContent extends StatefulWidget {
  final AddWorkReportController controller;

  const _DialogContent({Key? key, required this.controller}) : super(key: key);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dialog title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih SPK',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          'Cari SPK berdasarkan judul, nomor, atau lokasi',
                      hintStyle: GoogleFonts.dmSans(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      isDense: true,
                    ),
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    cursorColor: FigmaColors.primary,
                    onChanged: (value) {
                      widget.controller.searchKeyword.value = value;
                      widget.controller.fetchSPKs(keyword: value);
                    },
                    onSubmitted: (value) {
                      // Tidak perlu fetch lagi di sini
                    },
                  ),
                ),
                // Filter button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final result = await _showLocationPickerDialog(context);
                      if (result != null && result.isApplied) {
                        widget.controller.fetchSPKs(area: result.selectedArea);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Icon(Icons.filter_list,
                          color: FigmaColors.primary, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // SPK list
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Obx(() {
              if (widget.controller.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (widget.controller.spkList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada SPK yang ditemukan',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coba gunakan kata kunci atau filter yang berbeda',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: widget.controller.spkList.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final spk = widget.controller.spkList[index];
                  final isSelected =
                      widget.controller.selectedSpk.value?.id == spk.id;

                  return ListTile(
                    title: Text(
                      spk.title,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'No. SPK: ${spk.spkNo}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Proyek: ${spk.projectName}',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (spk.location != null)
                          Text(
                            'Lokasi: ${spk.location!.name}',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    selected: isSelected,
                    selectedTileColor: FigmaColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () {
                      // Return the selected SPK instead of calling selectSPK
                      Navigator.pop(context, spk);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<AreaPickerResult?> _showLocationPickerDialog(
      BuildContext context) async {
    return Get.dialog<AreaPickerResult>(
      LocationPickerDialog(),
      barrierDismissible: true,
    );
  }
}

// Kelas untuk menyimpan hasil dari dialog pemilihan area
class AreaPickerResult {
  final Area? selectedArea;
  final bool isApplied;
  final bool shouldReturnToSPK;

  AreaPickerResult(this.selectedArea, this.isApplied, this.shouldReturnToSPK);
}

class LocationPickerDialog extends StatelessWidget {
  const LocationPickerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _LocationDialogContent(),
    );
  }
}

class _LocationDialogContent extends StatefulWidget {
  @override
  _LocationDialogContentState createState() => _LocationDialogContentState();
}

class _LocationDialogContentState extends State<_LocationDialogContent> {
  Area? selectedArea;
  final lokasiController = Get.find<LokasiController>();

  @override
  void initState() {
    super.initState();
    _fetchAreas();
  }

  Future<void> _fetchAreas() async {
    if (lokasiController.areas.isEmpty) {
      await lokasiController.fetchAreas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Lokasi',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Location list
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: Obx(() {
              if (lokasiController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final filteredAreas = lokasiController.areas;

              if (filteredAreas.isEmpty) {
                return Center(
                  child: Text(
                    'Tidak ada lokasi yang ditemukan',
                    style: GoogleFonts.dmSans(
                      color: Colors.grey[600],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: filteredAreas.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final area = filteredAreas[index];
                  return RadioListTile<Area>(
                    title: Text(
                      area.name,
                      style: GoogleFonts.dmSans(),
                    ),
                    value: area,
                    groupValue: selectedArea,
                    onChanged: (value) {
                      setState(() {
                        selectedArea = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: FigmaColors.primary,
                  );
                },
              );
            }),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Batal',
                  style: GoogleFonts.dmSans(
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: selectedArea == null
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                          AreaPickerResult(selectedArea, true, true),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: FigmaColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text('Pilih'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
