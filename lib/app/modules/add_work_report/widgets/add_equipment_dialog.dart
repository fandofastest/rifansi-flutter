import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/equipment_model.dart';
import 'package:intl/intl.dart';

class AddEquipmentDialog extends StatelessWidget {
  final AddWorkReportController controller;

  const AddEquipmentDialog({
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
      BuildContext context, AddWorkReportController controller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddEquipmentDialog(controller: controller);
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
  Equipment? selectedEquipment;
  double workingHours = 8.0;
  double? fuelIn;
  double? fuelRemaining;
  bool isBrokenReported = false;
  String? remarks;

  // Filter
  String searchKeyword = '';
  List<Equipment> filteredEquipments = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar peralatan yang difilter
    filteredEquipments = widget.controller.equipmentList
        .where((eq) => !widget.controller.selectedEquipment
            .any((entry) => entry.equipment.id == eq.id))
        .toList();
  }

  void filterEquipments(String keyword) {
    setState(() {
      searchKeyword = keyword;

      // Filter peralatan berdasarkan keyword dan yang belum dipilih
      filteredEquipments = widget.controller.equipmentList
          .where((eq) =>
              !widget.controller.selectedEquipment
                  .any((entry) => entry.equipment.id == eq.id) &&
              (eq.equipmentCode.toLowerCase().contains(keyword.toLowerCase()) ||
                  eq.equipmentType
                      .toLowerCase()
                      .contains(keyword.toLowerCase())))
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
              'Tambah Peralatan',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari peralatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: filterEquipments,
            ),
            const SizedBox(height: 12),

            // Equipment selection
            Text(
              'Pilih Peralatan',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: filteredEquipments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            searchKeyword.isNotEmpty
                                ? 'Tidak ada peralatan yang cocok dengan pencarian'
                                : 'Semua peralatan sudah ditambahkan',
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
                      itemCount: filteredEquipments.length,
                      itemBuilder: (context, index) {
                        final equipment = filteredEquipments[index];
                        return RadioListTile<Equipment>(
                          title: Text(
                            equipment.equipmentCode,
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            equipment.equipmentType,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          secondary: equipment.area != null
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: Colors.blue[200]!),
                                  ),
                                  child: Text(
                                    equipment.area!.name,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                )
                              : null,
                          value: equipment,
                          groupValue: selectedEquipment,
                          onChanged: (value) {
                            setState(() {
                              selectedEquipment = value;
                            });
                          },
                          activeColor: FigmaColors.primary,
                        );
                      },
                    ),
            ),

            // Konfigurati peralatan section - muncul hanya jika peralatan sudah dipilih
            if (selectedEquipment != null) ...[
              const Divider(height: 24),

              Text(
                'Konfigurasi Peralatan',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Input jam kerja
              Text(
                'Jam Kerja',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                initialValue: workingHours.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixText: 'jam',
                ),
                onChanged: (value) {
                  setState(() {
                    workingHours = double.tryParse(value) ?? 8.0;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Row untuk bahan bakar
              Text(
                'Bahan Bakar',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'Fuel In (L)',
                        labelText: 'Fuel In (L)',
                        errorText: fuelIn == null ? 'Wajib diisi' : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          fuelIn = double.tryParse(value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        hintText: 'Remaining (L)',
                        labelText: 'Remaining (L)',
                        errorText: fuelRemaining == null ? 'Wajib diisi' : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          fuelRemaining = double.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Checkbox kerusakan
              Row(
                children: [
                  Checkbox(
                    value: isBrokenReported,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          isBrokenReported = value;
                        });
                      }
                    },
                    activeColor: FigmaColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      'Laporkan ada kerusakan pada alat',
                      style: GoogleFonts.dmSans(fontSize: 14),
                    ),
                  ),
                ],
              ),

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
                  onPressed: selectedEquipment == null ||
                          fuelIn == null ||
                          fuelRemaining == null
                      ? null
                      : () {
                          // Buat entry equipment baru
                          if (selectedEquipment!.contracts.length > 1) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Pilih Kontrak',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: selectedEquipment!.contracts
                                      .map((contract) {
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contract.contract.contractNo,
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (contract.contract.vendorName !=
                                                null)
                                              Text(
                                                contract.contract.vendorName!,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Rp ${NumberFormat("#,##0", "id_ID").format(contract.rentalRate ?? 0)}/jam',
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.bold,
                                                color: FigmaColors.primary,
                                              ),
                                            ),
                                            if (contract.contract.startDate !=
                                                    null &&
                                                contract.contract.endDate !=
                                                    null)
                                              Text(
                                                'Periode: ${contract.contract.startDate} - ${contract.contract.endDate}',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            if (contract.contract.description !=
                                                null)
                                              Text(
                                                contract.contract.description!,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          // Simpan equipment dengan kontrak yang dipilih
                                          final entry = EquipmentEntry(
                                            equipment: selectedEquipment!,
                                            workingHours: workingHours,
                                            fuelIn: fuelIn!,
                                            fuelRemaining: fuelRemaining!,
                                            isBrokenReported: isBrokenReported,
                                            remarks: remarks,
                                            selectedContract: contract,
                                          );

                                          // Tambahkan ke controller
                                          widget.controller
                                              .addEquipmentEntry(entry);

                                          // Tutup dialog pemilihan kontrak
                                          Navigator.pop(context);
                                          // Tutup dialog tambah equipment
                                          Navigator.pop(context);

                                          // Tampilkan snackbar konfirmasi
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Peralatan ${selectedEquipment!.equipmentCode} berhasil ditambahkan'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          } else {
                            // Jika hanya ada 1 kontrak, gunakan kontrak tersebut
                            final selectedContract =
                                selectedEquipment!.contracts.isNotEmpty
                                    ? selectedEquipment!.contracts.first
                                    : null;

                            if (selectedContract != null) {
                              final entry = EquipmentEntry(
                                equipment: selectedEquipment!,
                                workingHours: workingHours,
                                fuelIn: fuelIn!,
                                fuelRemaining: fuelRemaining!,
                                isBrokenReported: isBrokenReported,
                                remarks: remarks,
                                selectedContract: selectedContract,
                              );

                              // Tambahkan ke controller
                              widget.controller.addEquipmentEntry(entry);

                              // Tutup dialog
                              Navigator.pop(context);

                              // Tampilkan snackbar konfirmasi
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   SnackBar(
                              //     content: Text(
                              //         'Peralatan ${selectedEquipment!.equipmentCode} berhasil ditambahkan (Rate: Rp ${NumberFormat("#,##0", "id_ID").format(selectedContract.rentalRate ?? 0)}/jam)'),
                              //     backgroundColor: Colors.green,
                              //   ),
                              // );
                            } else {
                              // Tampilkan pesan error jika tidak ada kontrak
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Peralatan tidak memiliki kontrak yang aktif'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
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
