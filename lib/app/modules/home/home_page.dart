import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FigmaColors.primary, FigmaColors.error],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      // Profile Icon
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset(
                          'assets/images/icon_profile.svg',
                          width: 36,
                          height: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Welcome Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null ? 'Selamat Datang, ${user.fullName}' : 'Selamat Datang',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user != null ? user.role.roleName : '',
                            style: GoogleFonts.dmSans(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // INFORMASI HARI INI
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FigmaColors.primary, FigmaColors.error],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Hari ini',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _InfoStat(title: 'SPK Aktif', value: '3'),
                      _InfoStat(title: 'Absen Hari ini', value: '12'),
                      _InfoStat(title: 'Progress', value: '65%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // MENU GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: [
                  _MenuItem(
                    iconAsset: 'assets/images/icon_spk_home.svg',
                    label: 'Daftar SPK \n(6 file)',
                    onTap: () => Get.toNamed(Routes.spk),
                  ),
                  _MenuItem(
                    iconAsset: 'assets/images/icon_kerja_home.svg',
                    label: 'Laporan \nPekerjaan',
                    onTap: () => Get.toNamed(Routes.workReport),
                  ),
                  _MenuItem(
                    iconAsset: 'assets/images/icon_absen_home.svg',
                    label: 'Absen',
                  ),
                  _MenuItem(
                    iconAsset: 'assets/images/icon_perusahaan.svg',
                    label: 'Profile Perusahaan',
                  ),
                  _MenuItem(
                    iconAsset: 'assets/images/icon_profile.svg',
                    label: 'Coming soon',
                  ),
                  _MenuItem(
                    iconAsset: 'assets/images/icon_profile.svg',
                    label: 'Pengaturan',
                    onTap: () => Get.toNamed(Routes.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String title;
  final String value;
  const _InfoStat({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: FigmaColors.primarycontainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$title : $value',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconAsset;
  final String label;
  final VoidCallback? onTap;
  const _MenuItem({required this.iconAsset, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            Center(
              child: SvgPicture.asset(
                iconAsset,
                width: 90,
                height: 90,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: FigmaColors.hitam,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 