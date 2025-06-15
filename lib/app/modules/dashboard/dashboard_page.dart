import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/spk_controller.dart';
import '../../controllers/daily_activity_controller.dart';
import '../../controllers/equipment_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final SpkController spkController = Get.find<SpkController>();
    final DailyActivityController activityController =
        Get.find<DailyActivityController>();
    final EquipmentController equipmentController =
        Get.find<EquipmentController>();
    final user = authController.currentUser.value;

    // Ensure data is loaded for dashboard analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only load if data is empty to avoid duplicate requests
      if (spkController.spks.isEmpty) {
        spkController.fetchSPKs();
      }
      if (activityController.serverActivities.isEmpty) {
        activityController.fetchServerActivities();
      }
      if (equipmentController.readyEquipmentCount == 0 &&
          equipmentController.damagedEquipmentCount == 0) {
        equipmentController.fetchEquipments();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: FigmaColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Dashboard Analytics',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Stats
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    FigmaColors.primary,
                    FigmaColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Overview Hari Ini',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => _StatCard(
                                title: 'Total SPK',
                                value: '${spkController.spks.length}',
                                icon: Icons.assignment,
                                color: Colors.blue,
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _StatCard(
                                title: 'Laporan',
                                value:
                                    '${activityController.totalReportsCount}',
                                icon: Icons.description,
                                color: Colors.green,
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _StatCard(
                                title: 'Equipment',
                                value:
                                    '${equipmentController.readyEquipmentCount}',
                                icon: Icons.build,
                                color: Colors.orange,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Performance Metrics
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: FigmaColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Performance Metrics',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.hitam,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Approval Rate
                  Obx(() {
                    final total = activityController.totalReportsCount;
                    final approved = activityController.approvedReportsCount;
                    final approvalRate =
                        total > 0 ? (approved / total * 100) : 0.0;

                    return _ProgressMetric(
                      title: 'Approval Rate',
                      value: '${approvalRate.toStringAsFixed(1)}%',
                      progress: approvalRate / 100,
                      color: Colors.green,
                    );
                  }),

                  const SizedBox(height: 16),

                  // Equipment Readiness
                  Obx(() {
                    final total = equipmentController.readyEquipmentCount +
                        equipmentController.damagedEquipmentCount;
                    final ready = equipmentController.readyEquipmentCount;
                    final readinessRate =
                        total > 0 ? (ready / total * 100) : 0.0;

                    return _ProgressMetric(
                      title: 'Equipment Readiness',
                      value: '${readinessRate.toStringAsFixed(1)}%',
                      progress: readinessRate / 100,
                      color: Colors.blue,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Weekly Trend (Mock Data)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.show_chart,
                        color: FigmaColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weekly Trend',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.hitam,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Simple Bar Chart - Real Data
                  SizedBox(
                    height: 200,
                    child: Obx(() {
                      // Get real data from activities
                      final activities = activityController.serverActivities;
                      final now = DateTime.now();

                      // Calculate reports for last 7 days
                      List<int> dailyCounts = [];
                      List<String> dayLabels = [
                        'Sen',
                        'Sel',
                        'Rab',
                        'Kam',
                        'Jum',
                        'Sab',
                        'Min'
                      ];

                      for (int i = 6; i >= 0; i--) {
                        final targetDate = now.subtract(Duration(days: i));
                        final count = activities.where((activity) {
                          try {
                            // Parse timestamp (milliseconds) to DateTime
                            final timestamp = int.parse(activity.date);
                            final activityDate =
                                DateTime.fromMillisecondsSinceEpoch(timestamp);
                            return activityDate.year == targetDate.year &&
                                activityDate.month == targetDate.month &&
                                activityDate.day == targetDate.day;
                          } catch (e) {
                            // If parsing fails, skip this activity
                            print(
                                '[Dashboard] Error parsing date: ${activity.date}, error: $e');
                            return false;
                          }
                        }).length;
                        dailyCounts.add(count);
                      }

                      // Find max value for scaling
                      final maxCount = dailyCounts.isEmpty
                          ? 1
                          : dailyCounts.reduce((a, b) => a > b ? a : b);
                      final maxValue = maxCount == 0 ? 1 : maxCount;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(7, (index) {
                          final count = dailyCounts[index];
                          final normalizedValue = count / maxValue;
                          final dayIndex = (now.weekday - 7 + index) % 7;

                          return _BarChart(
                              day: dayLabels[dayIndex],
                              value: normalizedValue,
                              label: count.toString());
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Laporan per Hari (7 hari terakhir)',
                    style: GoogleFonts.dmSans(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: FigmaColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Actions',
                        style: GoogleFonts.dmSans(
                          color: FigmaColors.hitam,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle,
                          title: 'Buat Laporan',
                          subtitle: 'Laporan baru',
                          color: Colors.green,
                          onTap: () => Get.toNamed('/work-report/add'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.assessment,
                          title: 'Lihat SPK',
                          subtitle: 'Daftar SPK',
                          color: Colors.blue,
                          onTap: () => Get.toNamed('/spk'),
                        ),
                      ),
                    ],
                  ),
                  if (user?.role.roleName.toLowerCase() == 'supervisor') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.approval,
                            title: 'Approval',
                            subtitle: 'Review laporan',
                            color: Colors.orange,
                            onTap: () => Get.toNamed('/area-report'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.build_circle,
                            title: 'Equipment',
                            subtitle: 'Approval alat',
                            color: Colors.purple,
                            onTap: () => Get.toNamed('/equipment-approval'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final Color color;

  const _ProgressMetric({
    required this.title,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.dmSans(
                color: FigmaColors.hitam,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
        ),
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final String day;
  final double value;
  final String label;

  const _BarChart({
    required this.day,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: FigmaColors.hitam,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 150 * value,
          decoration: BoxDecoration(
            color: FigmaColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.dmSans(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.dmSans(
                color: FigmaColors.hitam,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
