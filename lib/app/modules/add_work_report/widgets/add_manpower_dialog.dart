import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/personnel_role_model.dart';

class AddManpowerDialog extends StatelessWidget {
  final AddWorkReportController controller;

  const AddManpowerDialog({
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

  static Future<void> show(BuildContext context, AddWorkReportController controller) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AddManpowerDialog(controller: controller);
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
  PersonnelRole? selectedRole;
  int personCount = 1;
  double normalHours = 8.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Personel',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Jam kerja normal
            Text(
              'Jam Kerja (Per Crew)',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                suffixText: 'jam',
              ),
              initialValue: normalHours.toString(),
              onChanged: (value) {
                final doubleValue = double.tryParse(value);
                if (doubleValue != null && doubleValue > 0) {
                  setState(() {
                    normalHours = doubleValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Pilih jabatan
            Text(
              'Jabatan',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (widget.controller.isLoadingPersonnel.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (widget.controller.personnelRoles.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.red[50],
                  ),
                  child: Text(
                    'Tidak ada data jabatan tersedia',
                    style: GoogleFonts.dmSans(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                );
              }
              
              return DropdownButtonFormField<PersonnelRole>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Pilih jabatan'),
                value: selectedRole,
                items: widget.controller.personnelRoles
                    .where((role) => role.isPersonel == true)
                    .map((role) {
                  return DropdownMenuItem<PersonnelRole>(
                    value: role,
                    child: Text(role.roleName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            
            // Jumlah personel
            Text(
              'Jumlah personel',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: personCount > 1
                      ? () {
                          setState(() {
                            personCount--;
                          });
                        }
                      : null,
                  color: FigmaColors.primary,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      personCount.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      personCount++;
                    });
                  },
                  color: FigmaColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Catatan: Perhitungan lembur akan otomatis dilakukan di sistem',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 24),
            
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
                  onPressed: selectedRole == null
                      ? null
                      : () async {
                          // Tampilkan loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          try {
                            // Buat entry manpower baru
                            final entry = ManpowerEntry(
                              personnelRole: selectedRole!,
                              personCount: personCount,
                              normalHoursPerPerson: normalHours,
                              overtimeHoursPerPerson: null, // Tidak perlu input lembur
                            );
                            
                            // Tambahkan ke controller (async)
                            await widget.controller.addManpowerEntry(entry);
                            
                            // Tutup loading
                            Navigator.pop(context);
                            
                            // Tutup dialog
                            Navigator.pop(context);
                          } catch (e) {
                            // Tutup loading
                            Navigator.pop(context);
                            
                            // Tampilkan error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
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