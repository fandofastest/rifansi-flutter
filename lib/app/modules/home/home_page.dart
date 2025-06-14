import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/spk_controller.dart';
import '../../controllers/daily_activity_controller.dart';
import '../../controllers/equipment_controller.dart';
import '../../routes/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AuthController authController = Get.find<AuthController>();
    final SpkController spkController = Get.put(SpkController());
    final DailyActivityController activityController =
        Get.put(DailyActivityController());
    final EquipmentController equipmentController =
        Get.put(EquipmentController());
    final user = authController.currentUser.value;

    // Load SPK count, activity count, and equipment data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      spkController.fetchSPKs();
      activityController.fetchServerActivities();
      equipmentController.fetchEquipments();
    });

    return Scaffold(
      backgroundColor: FigmaColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              height: 160,
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
                  SizedBox(
                    height: 20,
                  ),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null
                                  ? 'Selamat Datang, ${user.fullName}'
                                  : 'Selamat Datang',
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
                            if (user?.area != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white.withOpacity(0.75),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user!.area!.name,
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white.withOpacity(0.75),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Logout Button
                      IconButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Logout',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                'Apakah Anda yakin ingin keluar?',
                                style: GoogleFonts.dmSans(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Logout',
                                    style: GoogleFonts.dmSans(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldLogout == true) {
                            await authController.logout();
                            Get.offAllNamed(Routes.login);
                          }
                        },
                        icon: Icon(
                          Icons.logout,
                          color: Colors.white.withOpacity(0.9),
                          size: 24,
                        ),
                        tooltip: 'Logout',
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [FigmaColors.primary, FigmaColors.error],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Hari ini',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Vertical layout for info stats
                  Column(
                    children: [
                      Obx(() => _InfoStatVertical(
                            icon: Icons.assignment,
                            title: 'SPK Aktif',
                            value: '${spkController.spks.length}',
                            subtitle: 'Surat Perintah Kerja',
                          )),
                      const SizedBox(height: 12),
                      // Only show "Laporan Kerja" count if user is not supervisor
                      if (user?.role.roleName.toLowerCase() !=
                          'supervisor') ...[
                        Obx(() => _InfoStatVertical(
                              icon: Icons.work,
                              title: 'Total Laporan',
                              value: '${activityController.totalReportsCount}',
                              subtitle: 'Semua laporan kerja',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.check_circle,
                              title: 'Laporan Disetujui',
                              value:
                                  '${activityController.approvedReportsCount}',
                              subtitle: 'Laporan yang diterima',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.cancel,
                              title: 'Laporan Ditolak',
                              value:
                                  '${activityController.rejectedReportsCount}',
                              subtitle: 'Laporan yang ditolak',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.build_circle,
                              title: 'Alat yang Rusak',
                              value:
                                  '${equipmentController.damagedEquipmentCount}',
                              subtitle: 'Peralatan bermasalah',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.build,
                              title: 'Alat Siap Pakai',
                              value:
                                  '${equipmentController.readyEquipmentCount}',
                              subtitle: 'Peralatan siap operasi',
                            )),
                      ],
                      // Show approval statistics if user is supervisor
                      if (user?.role.roleName.toLowerCase() ==
                          'supervisor') ...[
                        Obx(() => _InfoStatVertical(
                              icon: Icons.work,
                              title: 'Total Laporan',
                              value: '${activityController.totalReportsCount}',
                              subtitle: 'Semua laporan area',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.pending_actions,
                              title: 'Pending Approval',
                              value:
                                  '${activityController.pendingReportsCount}',
                              subtitle: 'Menunggu persetujuan',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.check_circle,
                              title: 'Laporan Disetujui',
                              value:
                                  '${activityController.approvedReportsCount}',
                              subtitle: 'Disetujui hari ini',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.cancel,
                              title: 'Laporan Ditolak',
                              value:
                                  '${activityController.rejectedReportsCount}',
                              subtitle: 'Ditolak hari ini',
                            )),
                        const SizedBox(height: 12),
                        Obx(() => _InfoStatVertical(
                              icon: Icons.build,
                              title: 'Alat Siap Pakai',
                              value:
                                  '${equipmentController.readyEquipmentCount}',
                              subtitle: 'Peralatan siap operasi',
                            )),
                      ],
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
                crossAxisSpacing: 1,
                childAspectRatio: 0.8,
                children: [
                  Obx(() => _MenuItem(
                        iconAsset: 'assets/images/icon_spk_home.svg',
                        label:
                            'Daftar SPK \n(${spkController.spks.length} SPK)',
                        onTap: () => Get.toNamed(Routes.spk),
                      )),
                  // Only show "Laporan Pekerjaan" if user is not supervisor
                  if (user?.role.roleName.toLowerCase() != 'supervisor')
                    Obx(() => _MenuItem(
                          iconAsset: 'assets/images/icon_kerja_home.svg',
                          label:
                              'Laporan \nPekerjaan\n(${activityController.activities.length} laporan)',
                          onTap: () => Get.toNamed(Routes.workReport),
                        )),
                  // Only show "Laporan Alat" if user is not supervisor
                  if (user?.role.roleName.toLowerCase() != 'supervisor')
                    _MenuItem(
                      iconAsset: 'assets/images/icon_absen_home.svg',
                      label: 'Laporan Alat',
                      onTap: () => Get.toNamed(Routes.equipmentReport),
                    ),

                  // Only show "Approval Laporan" if user is supervisor
                  if (user?.role.roleName.toLowerCase() == 'supervisor')
                    _MenuItem(
                      iconAsset: 'assets/images/icon_kerja_home.svg',
                      label: 'Approval\nLaporan',
                      onTap: () => Get.toNamed(Routes.areaReport),
                    ),
                  // Only show "Approval Alat" if user is supervisor
                  if (user?.role.roleName.toLowerCase() == 'supervisor')
                    _MenuItem(
                      iconAsset: 'assets/images/icon_absen_home.svg',
                      label: 'Approval\nAlat',
                      onTap: () => Get.toNamed(Routes.equipmentApproval),
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

class _InfoStatVertical extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  const _InfoStatVertical({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: Colors.white.withOpacity(0.75),
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
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
