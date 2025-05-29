import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/material_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/material_model.dart' as material_model;
import 'package:intl/intl.dart';

class AddMaterialDialog extends StatelessWidget {
  final MaterialController controller;

  const AddMaterialDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: _DialogContent(controller: controller),
    );
  }

  static Future<void> show(
      BuildContext context, MaterialController controller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddMaterialDialog(controller: controller);
      },
    );
  }
}

class _DialogContent extends StatefulWidget {
  final MaterialController controller;

  const _DialogContent({Key? key, required this.controller}) : super(key: key);

  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  material_model.Material? selectedMaterial;
  double quantity = 1.0;
  String? remarks;

  // Filter
  String searchKeyword = '';
  List<material_model.Material> filteredMaterials = [];
  final numberFormat = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar material yang difilter
    filteredMaterials = widget.controller.materials
        .where((mat) => !widget.controller.selectedMaterials
            .any((entry) => entry.material.id == mat.id))
        .toList();
  }

  void filterMaterials(String keyword) {
    setState(() {
      searchKeyword = keyword;

      // Filter material berdasarkan keyword dan yang belum dipilih
      filteredMaterials = widget.controller.materials
          .where((mat) =>
              !widget.controller.selectedMaterials
                  .any((entry) => entry.material.id == mat.id) &&
              (mat.name.toLowerCase().contains(keyword.toLowerCase()) ||
                  mat.description
                          ?.toLowerCase()
                          .contains(keyword.toLowerCase()) ==
                      true))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Material',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari material...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: filterMaterials,
            ),
            const SizedBox(height: 12),

            // Material selection
            Text(
              'Pilih Material',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: filteredMaterials.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            searchKeyword.isNotEmpty
                                ? 'Tidak ada material yang cocok dengan pencarian'
                                : 'Semua material sudah ditambahkan',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredMaterials.length,
                      itemBuilder: (context, index) {
                        final material = filteredMaterials[index];
                        return RadioListTile<material_model.Material>(
                          title: Text(
                            material.name,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (material.unit != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.blue[200]!),
                                      ),
                                      child: Text(
                                        material.unit!.name,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                    ),
                                  if (material.unitRate != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.green[200]!),
                                      ),
                                      child: Text(
                                        'Rp ${numberFormat.format(material.unitRate)}/${material.unit?.code ?? ''}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (material.description != null &&
                                  material.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  material.description!,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          value: material,
                          groupValue: selectedMaterial,
                          onChanged: (value) {
                            setState(() {
                              selectedMaterial = value;
                            });
                          },
                          activeColor: FigmaColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: selectedMaterial == material
                                  ? FigmaColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Konfigurasi material section - muncul hanya jika material sudah dipilih
            if (selectedMaterial != null) ...[
              const Divider(height: 24),

              Text(
                'Konfigurasi Material',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Input jumlah
              Text(
                'Jumlah',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: quantity.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixText: selectedMaterial?.unit?.code ?? '',
                ),
                onChanged: (value) {
                  setState(() {
                    quantity = double.tryParse(value) ?? 1.0;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Input catatan
              Text(
                'Catatan (opsional)',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  hintText: 'Masukkan catatan jika ada',
                ),
                onChanged: (value) {
                  setState(() {
                    remarks = value;
                  });
                },
              ),
            ],

            const SizedBox(height: 20),

            // Tombol aksi
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
                  onPressed: selectedMaterial == null
                      ? null
                      : () {
                          // Buat entry material baru
                          final entry = MaterialEntry(
                            material: selectedMaterial!,
                            quantity: quantity,
                            remarks: remarks,
                          );

                          // Tambahkan ke controller
                          widget.controller.addMaterialEntry(entry);

                          // Tutup dialog
                          Navigator.pop(context);

                          // Tampilkan snackbar konfirmasi
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text(
                          //         'Material ${selectedMaterial!.name} berhasil ditambahkan'),
                          //     backgroundColor: Colors.green,
                          //   ),
                          // );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
