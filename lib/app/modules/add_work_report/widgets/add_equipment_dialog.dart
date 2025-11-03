import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/equipment_model.dart';
import 'package:intl/intl.dart';

class AddEquipmentDialog extends StatefulWidget {
  final AddWorkReportController controller;
  const AddEquipmentDialog({Key? key, required this.controller}) : super(key: key);
  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();

  static Future<void> show(BuildContext context, AddWorkReportController controller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddEquipmentDialog(controller: controller);
      },
    );
  }
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  Equipment? selectedEquipment;
  EquipmentContract? selectedContract;
  double workingHours = 8.0;
  double? fuelIn;
  bool isBrokenReported = false;
  String? remarks;
  final TextEditingController _dropdownSearchController = TextEditingController();

  List<Equipment> get _availableEquipment {
    final authController = Get.find<AuthController>();
    final userArea = authController.currentUser.value?.area;
    
    return widget.controller.equipmentList.where((eq) {
      // Filter equipment yang belum dipilih
      final isNotSelected = !widget.controller.selectedEquipment.any((entry) => entry.equipment.id == eq.id);
      
      if (userArea == null) {
        // Jika tidak ada area user, tampilkan semua equipment
        return isNotSelected;
      }
      
      // Hanya tampilkan equipment yang ada di area user
      final isFromUserArea = eq.area?.id == userArea.id;
      
      return isNotSelected && isFromUserArea;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _dropdownSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableEquipment = _availableEquipment;
    final authController = Get.find<AuthController>();
    final userArea = authController.currentUser.value?.area;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Peralatan', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              // Show area info if user has area
              if (userArea != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Area: ${userArea.name}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Show message when no equipment available
              if (availableEquipment.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.warning_amber, size: 32, color: Colors.orange[700]),
                      const SizedBox(height: 8),
                      Text(
                        userArea != null 
                          ? 'Tidak ada peralatan tersedia di area ${userArea.name}'
                          : 'Tidak ada peralatan tersedia',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Semua peralatan sudah dipilih atau tidak ada peralatan di area ini',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              ] else ...[
                DropdownButtonFormField2<Equipment>(
                  value: selectedEquipment,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Pilih Peralatan',
                  ),
                  items: availableEquipment
                      .map((eq) => DropdownMenuItem<Equipment>(
                            value: eq,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${eq.equipmentCode} - ${eq.equipmentType}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (eq.area != null)
                                  Text(
                                    'Area: ${eq.area!.name}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (eq) {
                    setState(() {
                      selectedEquipment = eq;
                      selectedContract = eq?.contracts.isNotEmpty == true ? eq!.contracts.first : null;
                    });
                  },
                  dropdownSearchData: DropdownSearchData(
                    searchController: _dropdownSearchController,
                    searchInnerWidgetHeight: 56,
                    searchInnerWidget: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _dropdownSearchController,
                        decoration: InputDecoration(
                          hintText: 'Cari peralatan (kode/jenis/area)',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      final eq = item.value as Equipment;
                      final q = searchValue.toLowerCase();
                      final code = eq.equipmentCode.toLowerCase();
                      final type = eq.equipmentType.toLowerCase();
                      final area = (eq.area?.name ?? '').toLowerCase();
                      return code.contains(q) || type.contains(q) || area.contains(q);
                    },
                  ),
                  onMenuStateChange: (isOpen) {
                    if (!isOpen) {
                      _dropdownSearchController.clear();
                    }
                  },
                ),
                if (selectedEquipment != null && selectedEquipment!.contracts.length > 1) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<EquipmentContract>(
                    value: selectedContract,
                    isExpanded: true,
                    hint: const Text('Pilih Kontrak'),
                    items: selectedEquipment!.contracts
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text('Rp ${NumberFormat("#,##0", "id_ID").format(c.rentalRatePerDay ?? 0)}/hari'),
                            ))
                        .toList(),
                    onChanged: (c) => setState(() => selectedContract = c),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: workingHours.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Jam Kerja'),
                        onChanged: (v) => setState(() => workingHours = double.tryParse(v) ?? 8.0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fuel In (L)'),
                        onChanged: (v) => setState(() => fuelIn = double.tryParse(v)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isBrokenReported,
                      onChanged: (v) => setState(() => isBrokenReported = v ?? false),
                    ),
                    const Text('Ada kerusakan'),
                  ],
                ),
                TextFormField(
                  maxLines: 1,
                  decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                  onChanged: (v) => remarks = v,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: selectedEquipment == null || selectedContract == null || fuelIn == null
                          ? null
                          : () {
                              final entry = EquipmentEntry(
                                equipment: selectedEquipment!,
                                workingHours: workingHours,
                                fuelIn: fuelIn!,
                                fuelRemaining: 0.0,
                                isBrokenReported: isBrokenReported,
                                remarks: remarks,
                                selectedContract: selectedContract!,
                              );
                              widget.controller.addEquipmentEntry(entry);
                              Navigator.pop(context);
                            },
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
