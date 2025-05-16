import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../controllers/auth_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool fingerprintEnabled = true; // Dummy state, can be linked to storage later

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        backgroundColor: FigmaColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: FigmaColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: FigmaColors.primarycontainer,
                      child: Icon(Icons.person, color: FigmaColors.primary, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? '-',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: FigmaColors.hitam,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '-',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: FigmaColors.abu,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.role.roleName ?? '-',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: FigmaColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Fingerprint Switch
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fingerprint, color: FigmaColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'Aktifkan Fingerprint Login',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: FigmaColors.hitam,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: fingerprintEnabled,
                      activeColor: FigmaColors.primary,
                      onChanged: (val) {
                        setState(() {
                          fingerprintEnabled = val;
                        });
                        // TODO: Simpan preferensi fingerprint ke storage
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Ganti Profil Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () {
                    // TODO: Navigasi ke halaman ganti profil
                  },
                  child: const Text('Ganti Profil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 