import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../controllers/spk_details_controller.dart';
import '../../data/models/spk_detail_with_progress_response.dart'
    as spk_progress;

class SpkDetailsPage extends GetView<SpkDetailsController> {
  const SpkDetailsPage({Key? key}) : super(key: key);

  // Format rupiah dengan standar Indonesia
  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FigmaColors.background,
      appBar: AppBar(
        backgroundColor: FigmaColors.primary,
        title: Text(
          'Detail SPK',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Terjadi kesalahan: ${controller.error.value}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: FigmaColors.error,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FigmaColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => controller.fetchSpkDetails(),
                  child: Text(
                    'Coba Lagi',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final spkData = controller.spkDetails.value;
        if (spkData == null) {
          return Center(
            child: Text(
              'Data tidak ditemukan',
              style: GoogleFonts.dmSans(
                color: FigmaColors.abu,
                fontSize: 16,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Dasar SPK
              _buildSection(
                'Informasi Dasar',
                [
                  _buildInfoCard([
                    _buildInfoRow('Nomor SPK', controller.spkNo),
                    _buildInfoRow('Nomor WAP', controller.wapNo),
                    _buildInfoRow('Judul', controller.title),
                    _buildInfoRow('Nama Proyek', controller.projectName),
                    _buildInfoRow('Kontraktor', controller.contractor),
                    _buildInfoRow('Lokasi', controller.location),
                    _buildInfoRow(
                        'Tanggal Mulai', _formatDate(controller.startDate)),
                    _buildInfoRow(
                        'Tanggal Selesai', _formatDate(controller.endDate)),
                    _buildInfoRow('Anggaran', _formatRupiah(controller.budget)),
                  ]),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Keseluruhan
              _buildSection(
                'Progress Keseluruhan',
                [
                  _buildProgressCard(
                      controller.spkDetails.value?.totalProgress),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: FigmaColors.hitam,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: FigmaColors.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: FigmaColors.primary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: FigmaColors.hitam,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableInfoRow(String label, String value,
      {required VoidCallback onTap, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (color ?? FigmaColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (color ?? FigmaColors.primary).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: color ?? FigmaColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color ?? FigmaColors.primary,
                  ),
                ),
              ),
              Icon(
                Icons.touch_app,
                size: 16,
                color: color ?? FigmaColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(spk_progress.TotalProgress? progress) {
    if (progress == null) return const SizedBox.shrink();

    // Hitung total sales berdasarkan progress percentage dan total budget
    final totalSales = (progress.percentage / 100) * progress.totalBudget;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress.percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(FigmaColors.primary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Persentase', '${progress.percentage.toStringAsFixed(2)}%'),
            _buildInfoRow(
                'Total Anggaran', _formatRupiah(progress.totalBudget)),
            _buildClickableInfoRow(
              'Total Sales',
              _formatRupiah(totalSales),
              onTap: () => _showWorkItemsDialog(),
              color: Colors.green,
            ),
            _buildClickableInfoRow(
              'Total Cost',
              _formatRupiah(progress.totalSpent),
              onTap: () => _showCostBreakdownDialog(),
              color: Colors.orange,
            ),
            _buildInfoRow(
                'Sisa Anggaran', _formatRupiah(progress.remainingBudget)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItemsCard(List<spk_progress.WorkItem> workItems) {
    if (workItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort work items berdasarkan progress percentage (descending - yang paling selesai di atas)
    final sortedWorkItems = List<spk_progress.WorkItem>.from(workItems);
    sortedWorkItems.sort((a, b) {
      // Hitung progress percentage untuk item a
      double progressA = 0.0;
      if (a.boqVolume.nr > 0) {
        progressA = (a.progressAchieved.nr / a.boqVolume.nr) * 100;
      } else if (a.boqVolume.r > 0) {
        progressA = (a.progressAchieved.r / a.boqVolume.r) * 100;
      }

      // Hitung progress percentage untuk item b
      double progressB = 0.0;
      if (b.boqVolume.nr > 0) {
        progressB = (b.progressAchieved.nr / b.boqVolume.nr) * 100;
      } else if (b.boqVolume.r > 0) {
        progressB = (b.progressAchieved.r / b.boqVolume.r) * 100;
      }

      // Sort descending (progress tertinggi di atas)
      return progressB.compareTo(progressA);
    });

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header dengan informasi sorting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: FigmaColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort,
                    size: 16,
                    color: FigmaColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diurutkan berdasarkan progress tertinggi',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: FigmaColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...sortedWorkItems.map((item) => _buildWorkItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItemRow(spk_progress.WorkItem item) {
    final RxBool isExpanded = false.obs;

    // Hitung progress percentage yang benar
    double progressPercentage = 0.0;
    if (item.boqVolume.nr > 0) {
      progressPercentage = (item.progressAchieved.nr / item.boqVolume.nr) * 100;
    } else if (item.boqVolume.r > 0) {
      progressPercentage = (item.progressAchieved.r / item.boqVolume.r) * 100;
    }

    // Tentukan warna berdasarkan progress
    Color progressColor = FigmaColors.primary;
    if (progressPercentage >= 100) {
      progressColor = Colors.green;
    } else if (progressPercentage >= 75) {
      progressColor = Colors.blue;
    } else if (progressPercentage >= 50) {
      progressColor = Colors.orange;
    } else if (progressPercentage >= 25) {
      progressColor = Colors.amber;
    } else {
      progressColor = Colors.red;
    }

    return Obx(() => Column(
          children: [
            InkWell(
              onTap: () => isExpanded.value = !isExpanded.value,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      isExpanded.value ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: FigmaColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: FigmaColors.hitam,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: progressColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: progressColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  '${progressPercentage.toStringAsFixed(1)}%',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: progressColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progressPercentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      progressColor),
                                  borderRadius: BorderRadius.circular(2),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded.value) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        'Volume BOQ', '${item.boqVolume.nr} ${item.unit.name}'),
                    _buildInfoRow('Volume Selesai',
                        '${item.actualQuantity.nr} ${item.unit.name}'),
                    _buildInfoRow('Progress Hari Ini',
                        '${item.dailyProgress.nr} ${item.unit.name}'),
                    _buildInfoRow('Biaya Hari Ini',
                        'Rp ${item.dailyCost.nr.toStringAsFixed(0)}'),
                    _buildInfoRow(
                        'Terakhir Diperbarui', _formatDate(item.lastUpdatedAt)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ));
  }

  Widget _buildCostBreakdownCard(List<spk_progress.DailyActivity> activities) {
    if (activities.isEmpty) return const SizedBox.shrink();

    final RxString viewMode = 'tanggal'.obs;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Keseluruhan
            Text(
              'Total Keseluruhan',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: FigmaColors.hitam,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Total Biaya',
                'Rp ${controller.totalSpent.toStringAsFixed(0)}'),
            const Divider(),
            const SizedBox(height: 16),

            // Tab View
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: FigmaColors.abu.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => InkWell(
                          onTap: () => viewMode.value = 'tanggal',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: viewMode.value == 'tanggal'
                                      ? FigmaColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Per Tanggal',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: viewMode.value == 'tanggal'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: viewMode.value == 'tanggal'
                                    ? FigmaColors.primary
                                    : FigmaColors.abu,
                              ),
                            ),
                          ),
                        )),
                  ),
                  Expanded(
                    child: Obx(() => InkWell(
                          onTap: () => viewMode.value = 'bulan',
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: viewMode.value == 'bulan'
                                      ? FigmaColors.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              'Per Bulan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: viewMode.value == 'bulan'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: viewMode.value == 'bulan'
                                    ? FigmaColors.primary
                                    : FigmaColors.abu,
                              ),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Breakdown Content
            Obx(() {
              if (viewMode.value == 'tanggal') {
                return Column(
                  children: activities
                      .map((activity) => _buildDailyActivityCard(activity))
                      .toList(),
                );
              } else {
                return _buildMonthlyBreakdown(activities);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(List<spk_progress.DailyActivity> activities) {
    // Kelompokkan berdasarkan bulan
    final Map<String, List<spk_progress.DailyActivity>> monthlyData = {};

    for (var activity in activities) {
      try {
        final DateTime dateTime = DateTime.parse(activity.date);
        final String monthKey = '${dateTime.year} - ${_bulan(dateTime.month)}';

        if (!monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = [];
        }

        monthlyData[monthKey]!.add(activity);
      } catch (e) {
        print('Error parsing date: ${activity.date}');
      }
    }

    // Urutkan bulan dari terbaru
    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedMonths.map((month) {
        final monthActivities = monthlyData[month]!;
        double totalCost = 0.0;
        final Map<String, double> categoryTotals = {
          'materials': 0.0,
          'manpower': 0.0,
          'equipment': 0.0,
          'otherCosts': 0.0,
        };

        for (var activity in monthActivities) {
          totalCost += activity.costs.materials.totalCost +
              activity.costs.manpower.totalCost +
              activity.costs.equipment.totalCost +
              activity.costs.otherCosts.totalCost;

          categoryTotals['materials'] = (categoryTotals['materials'] ?? 0.0) +
              activity.costs.materials.totalCost;
          categoryTotals['manpower'] = (categoryTotals['manpower'] ?? 0.0) +
              activity.costs.manpower.totalCost;
          categoryTotals['equipment'] = (categoryTotals['equipment'] ?? 0.0) +
              activity.costs.equipment.totalCost;
          categoryTotals['otherCosts'] = (categoryTotals['otherCosts'] ?? 0.0) +
              activity.costs.otherCosts.totalCost;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: FigmaColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                month,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FigmaColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Total Biaya', 'Rp ${totalCost.toStringAsFixed(0)}'),
            _buildInfoRow('Material',
                'Rp ${categoryTotals['materials']!.toStringAsFixed(0)}'),
            _buildInfoRow('Manpower',
                'Rp ${categoryTotals['manpower']!.toStringAsFixed(0)}'),
            _buildInfoRow('Equipment',
                'Rp ${categoryTotals['equipment']!.toStringAsFixed(0)}'),
            _buildInfoRow('Biaya Lainnya',
                'Rp ${categoryTotals['otherCosts']!.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDailyActivityCard(spk_progress.DailyActivity activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: FigmaColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatDate(activity.date),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FigmaColors.primary,
                  ),
                ),
              ),
              Text(
                'Status: ${activity.status}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: _getStatusColor(activity.status),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Total Biaya',
            'Rp ${(activity.costs.materials.totalCost + activity.costs.manpower.totalCost + activity.costs.equipment.totalCost + activity.costs.otherCosts.totalCost).toStringAsFixed(0)}'),
        _buildExpandableCategory('Material', activity.costs.materials.totalCost,
            activity.costs.materials),
        _buildExpandableCategory('Manpower', activity.costs.manpower.totalCost,
            activity.costs.manpower),
        _buildExpandableCategory('Equipment',
            activity.costs.equipment.totalCost, activity.costs.equipment),
        _buildExpandableCategory('Biaya Lainnya',
            activity.costs.otherCosts.totalCost, activity.costs.otherCosts),
        if (activity.closingRemarks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Catatan: ${activity.closingRemarks}',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: FigmaColors.abu,
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpandableCategory(
      String title, double total, dynamic category) {
    final RxBool isExpanded = false.obs;

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => isExpanded.value = !isExpanded.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isExpanded.value ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: FigmaColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: FigmaColors.hitam,
                        ),
                      ),
                    ),
                    Text(
                      'Rp ${total.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FigmaColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded.value) ..._buildCostItemsByCategory(title, category),
          ],
        ));
  }

  List<Widget> _buildCostItemsByCategory(String title, dynamic category) {
    switch (title) {
      case 'Material':
        return (category as spk_progress.MaterialCosts)
            .items
            .map((item) => _buildCostItem(item, title))
            .toList();
      case 'Manpower':
        return (category as spk_progress.ManpowerCosts)
            .items
            .map((item) => _buildCostItem(item, title))
            .toList();
      case 'Equipment':
        return (category as spk_progress.EquipmentCosts)
            .items
            .map((item) => _buildCostItem(item, title))
            .toList();
      case 'Biaya Lainnya':
        // OtherCosts.items bertipe List<dynamic>, tampilkan deskripsi jika ada
        return (category as spk_progress.OtherCosts)
            .items
            .map<Widget>((item) => _buildCostItem(item, title))
            .toList();
      default:
        return [];
    }
  }

  Widget _buildCostItem(dynamic item, String category) {
    String description = '';
    switch (category) {
      case 'Material':
        final mat = item as spk_progress.MaterialItem;
        description = '${mat.material} - ${mat.quantity} unit';
        return _costItemRow(description, mat.cost);
      case 'Manpower':
        final man = item as spk_progress.ManpowerItem;
        description =
            '${man.role} - ${man.numberOfWorkers} orang, ${man.workingHours} jam';
        return _costItemRow(description, man.cost);
      case 'Equipment':
        final eq = item as spk_progress.EquipmentItem;
        description = '${eq.equipment.equipmentCode} - ${eq.workingHours} jam';
        if (eq.fuelUsed > 0) {
          description += ', BBM: ${eq.fuelUsed}L';
        }
        return _costItemRow(description, eq.cost);
      case 'Biaya Lainnya':
        // item di OtherCosts bisa Map atau String, tampilkan deskripsi jika ada
        if (item is Map && item['description'] != null) {
          description = item['description'].toString();
        } else {
          description = item?.toString() ?? '-';
        }
        double cost = 0;
        if (item is Map && item['cost'] != null) {
          cost = (item['cost'] is num) ? (item['cost'] as num).toDouble() : 0;
        }
        return _costItemRow(description, cost);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _costItemRow(String description, double cost) {
    return Padding(
      padding: const EdgeInsets.only(left: 28, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: FigmaColors.hitam,
              ),
            ),
          ),
          Text(
            _formatRupiah(cost),
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: FigmaColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final day = date.day.toString();
      final month = _bulan(date.month);
      final year = date.year.toString();
      return '$day $month $year';
    } catch (e) {
      return dateStr;
    }
  }

  static String _bulan(int month) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return bulan[month];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'pending':
        return Colors.blue;
      default:
        return FigmaColors.abu;
    }
  }

  void _showWorkItemsDialog() {
    final workItems = controller.workItems;
    final activities = controller.dailyActivities;
    final RxInt selectedTab = 0.obs; // 0 = Per Hari, 1 = Per Bulan

    // Sort work items berdasarkan progress percentage (descending - yang tertinggi di atas)
    final sortedWorkItems = List<spk_progress.WorkItem>.from(workItems);
    sortedWorkItems.sort((a, b) {
      // Hitung progress percentage untuk item a
      double progressA = 0.0;
      if (a.boqVolume.nr > 0) {
        progressA = (a.progressAchieved.nr / a.boqVolume.nr) * 100;
      } else if (a.boqVolume.r > 0) {
        progressA = (a.progressAchieved.r / a.boqVolume.r) * 100;
      }

      // Hitung progress percentage untuk item b
      double progressB = 0.0;
      if (b.boqVolume.nr > 0) {
        progressB = (b.progressAchieved.nr / b.boqVolume.nr) * 100;
      } else if (b.boqVolume.r > 0) {
        progressB = (b.progressAchieved.r / b.boqVolume.r) * 100;
      }

      // Sort descending (progress tertinggi di atas)
      return progressB.compareTo(progressA);
    });

    // Hitung total sales keseluruhan
    double totalSalesOverall = 0.0;
    for (var item in sortedWorkItems) {
      if (item.boqVolume.nr > 0) {
        totalSalesOverall += item.progressAchieved.nr * item.rates.nr.rate;
      } else if (item.boqVolume.r > 0) {
        totalSalesOverall += item.progressAchieved.r * item.rates.r.rate;
      }
    }

    // Group activities by month and year
    final Map<String, List<spk_progress.DailyActivity>> groupedByMonth = {};
    for (var activity in activities) {
      final date = DateTime.parse(activity.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      groupedByMonth.putIfAbsent(monthKey, () => []).add(activity);
    }

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.work, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Item Pekerjaan & Sales',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Total Sales Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.green.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      'Total Sales',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRupiah(totalSalesOverall),
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Urut: Persentase Tertinggi',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Obx(() => Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => selectedTab.value = 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTab.value == 0
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Per Hari',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontWeight: selectedTab.value == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedTab.value == 0
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => selectedTab.value = 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTab.value == 1
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Per Bulan',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontWeight: selectedTab.value == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedTab.value == 1
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              // Content
              Flexible(
                child: Obx(() => SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: selectedTab.value == 0
                          ? _buildWorkItemsPerHariContent(
                              activities, sortedWorkItems)
                          : _buildWorkItemsPerBulanContent(
                              groupedByMonth, sortedWorkItems),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkItemsPerHariContent(
      List<spk_progress.DailyActivity> activities,
      List<spk_progress.WorkItem> workItems) {
    // Sort activities by date (terbaru di atas)
    final sortedActivities = List<spk_progress.DailyActivity>.from(activities);
    sortedActivities.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return dateB.compareTo(dateA); // Descending (terbaru di atas)
    });

    return Column(
      children: sortedActivities.map((activity) {
        final RxBool isExpanded = false.obs;

        // Calculate daily total cost
        final dailyTotalCost = activity.costs.materials.totalCost +
            activity.costs.manpower.totalCost +
            activity.costs.equipment.totalCost +
            activity.costs.otherCosts.totalCost;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // Accordion Header
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Obx(() => Icon(
                            isExpanded.value
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.orange,
                          )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(activity.date),
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatRupiah(dailyTotalCost)}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '4 kategori',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Accordion Content
              Obx(() => isExpanded.value
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          _buildClickableCostCategoryRow(
                              'Material',
                              activity.costs.materials.totalCost,
                              activity.costs.materials.items,
                              'Material'),
                          _buildClickableCostCategoryRow(
                              'Manpower',
                              activity.costs.manpower.totalCost,
                              activity.costs.manpower.items,
                              'Manpower'),
                          _buildClickableCostCategoryRow(
                              'Equipment',
                              activity.costs.equipment.totalCost,
                              activity.costs.equipment.items,
                              'Equipment'),
                          _buildClickableCostCategoryRow(
                              'Biaya Lainnya',
                              activity.costs.otherCosts.totalCost,
                              activity.costs.otherCosts.items,
                              'Biaya Lainnya'),
                          const Divider(),
                          _buildCostCategoryRow(
                            'Total',
                            dailyTotalCost,
                            isTotal: true,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkItemsPerBulanContent(
      Map<String, List<spk_progress.DailyActivity>> groupedByMonth,
      List<spk_progress.WorkItem> workItems) {
    // Sort months by date (terbaru di atas)
    final sortedMonthEntries = groupedByMonth.entries.toList();
    sortedMonthEntries.sort((a, b) {
      final dateA = DateTime.parse(a.key + '-01');
      final dateB = DateTime.parse(b.key + '-01');
      return dateB.compareTo(dateA); // Descending (terbaru di atas)
    });

    return Column(
      children: sortedMonthEntries.map((entry) {
        final monthKey = entry.key;
        final monthDate = DateTime.parse(monthKey + '-01');
        final monthName = '${_bulan(monthDate.month)} ${monthDate.year}';
        final monthActivities = entry.value;
        final RxBool isExpanded = false.obs;

        // Sort activities within month by date (terbaru di atas)
        final sortedMonthActivities =
            List<spk_progress.DailyActivity>.from(monthActivities);
        sortedMonthActivities.sort((a, b) {
          final dateA = DateTime.parse(a.date);
          final dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA); // Descending (terbaru di atas)
        });

        // Calculate monthly totals
        double totalMaterial = 0,
            totalManpower = 0,
            totalEquipment = 0,
            totalOther = 0;
        List<dynamic> allMaterialItems = [],
            allManpowerItems = [],
            allEquipmentItems = [],
            allOtherItems = [];

        for (var activity in monthActivities) {
          totalMaterial += activity.costs.materials.totalCost;
          totalManpower += activity.costs.manpower.totalCost;
          totalEquipment += activity.costs.equipment.totalCost;
          totalOther += activity.costs.otherCosts.totalCost;

          allMaterialItems.addAll(activity.costs.materials.items);
          allManpowerItems.addAll(activity.costs.manpower.items);
          allEquipmentItems.addAll(activity.costs.equipment.items);
          allOtherItems.addAll(activity.costs.otherCosts.items);
        }

        final monthlyTotalCost =
            totalMaterial + totalManpower + totalEquipment + totalOther;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // Accordion Header
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Obx(() => Icon(
                            isExpanded.value
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.orange,
                          )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monthName,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatRupiah(monthlyTotalCost)}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${monthActivities.length} hari',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Accordion Content
              Obx(() => isExpanded.value
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          // Monthly summary categories
                          _buildClickableCostCategoryRow('Material',
                              totalMaterial, allMaterialItems, 'Material'),
                          _buildClickableCostCategoryRow('Manpower',
                              totalManpower, allManpowerItems, 'Manpower'),
                          _buildClickableCostCategoryRow('Equipment',
                              totalEquipment, allEquipmentItems, 'Equipment'),
                          _buildClickableCostCategoryRow('Biaya Lainnya',
                              totalOther, allOtherItems, 'Biaya Lainnya'),
                          const Divider(),
                          _buildCostCategoryRow(
                            'Total Bulan',
                            monthlyTotalCost,
                            isTotal: true,
                          ),
                          const SizedBox(height: 16),
                          // Daily breakdown
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Rincian Harian',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...sortedMonthActivities.map((activity) {
                            final dailyTotal =
                                activity.costs.materials.totalCost +
                                    activity.costs.manpower.totalCost +
                                    activity.costs.equipment.totalCost +
                                    activity.costs.otherCosts.totalCost;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(activity.date),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(dailyTotal),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactCostItem('Material',
                                            activity.costs.materials.totalCost),
                                      ),
                                      Expanded(
                                        child: _buildCompactCostItem('Manpower',
                                            activity.costs.manpower.totalCost),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactCostItem(
                                            'Equipment',
                                            activity.costs.equipment.totalCost),
                                      ),
                                      Expanded(
                                        child: _buildCompactCostItem(
                                            'Lainnya',
                                            activity
                                                .costs.otherCosts.totalCost),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactCostItem(String category, double cost) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatRupiah(cost),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCostBreakdownDialog() {
    final activities = controller.dailyActivities;
    final RxInt selectedTab = 0.obs; // 0 = Per Hari, 1 = Per Bulan

    // Group activities by month and year
    final Map<String, List<spk_progress.DailyActivity>> groupedByMonth = {};
    for (var activity in activities) {
      final date = DateTime.parse(activity.date);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      groupedByMonth.putIfAbsent(monthKey, () => []).add(activity);
    }

    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet,
                        color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rincian Total Cost',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.orange.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      'Total Keseluruhan',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatRupiah(controller.totalSpent),
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Obx(() => Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => selectedTab.value = 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTab.value == 0
                                        ? Colors.orange
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Per Hari',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontWeight: selectedTab.value == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedTab.value == 0
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => selectedTab.value = 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: selectedTab.value == 1
                                        ? Colors.orange
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Per Bulan',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontWeight: selectedTab.value == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: selectedTab.value == 1
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ),
              // Content
              Flexible(
                child: Obx(() => SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: selectedTab.value == 0
                          ? _buildPerHariContent(activities)
                          : _buildPerBulanContent(groupedByMonth),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerHariContent(List<spk_progress.DailyActivity> activities) {
    // Sort activities by date (terbaru di atas)
    final sortedActivities = List<spk_progress.DailyActivity>.from(activities);
    sortedActivities.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return dateB.compareTo(dateA); // Descending (terbaru di atas)
    });

    return Column(
      children: sortedActivities.map((activity) {
        final RxBool isExpanded = false.obs;

        // Calculate daily total cost
        final dailyTotalCost = activity.costs.materials.totalCost +
            activity.costs.manpower.totalCost +
            activity.costs.equipment.totalCost +
            activity.costs.otherCosts.totalCost;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // Accordion Header
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Obx(() => Icon(
                            isExpanded.value
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.orange,
                          )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(activity.date),
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatRupiah(dailyTotalCost)}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '4 kategori',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Accordion Content
              Obx(() => isExpanded.value
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          _buildClickableCostCategoryRow(
                              'Material',
                              activity.costs.materials.totalCost,
                              activity.costs.materials.items,
                              'Material'),
                          _buildClickableCostCategoryRow(
                              'Manpower',
                              activity.costs.manpower.totalCost,
                              activity.costs.manpower.items,
                              'Manpower'),
                          _buildClickableCostCategoryRow(
                              'Equipment',
                              activity.costs.equipment.totalCost,
                              activity.costs.equipment.items,
                              'Equipment'),
                          _buildClickableCostCategoryRow(
                              'Biaya Lainnya',
                              activity.costs.otherCosts.totalCost,
                              activity.costs.otherCosts.items,
                              'Biaya Lainnya'),
                          const Divider(),
                          _buildCostCategoryRow(
                            'Total',
                            dailyTotalCost,
                            isTotal: true,
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerBulanContent(
      Map<String, List<spk_progress.DailyActivity>> groupedByMonth) {
    // Sort months by date (terbaru di atas)
    final sortedMonthEntries = groupedByMonth.entries.toList();
    sortedMonthEntries.sort((a, b) {
      final dateA = DateTime.parse(a.key + '-01');
      final dateB = DateTime.parse(b.key + '-01');
      return dateB.compareTo(dateA); // Descending (terbaru di atas)
    });

    return Column(
      children: sortedMonthEntries.map((entry) {
        final monthKey = entry.key;
        final monthDate = DateTime.parse(monthKey + '-01');
        final monthName = '${_bulan(monthDate.month)} ${monthDate.year}';
        final monthActivities = entry.value;
        final RxBool isExpanded = false.obs;

        // Sort activities within month by date (terbaru di atas)
        final sortedMonthActivities =
            List<spk_progress.DailyActivity>.from(monthActivities);
        sortedMonthActivities.sort((a, b) {
          final dateA = DateTime.parse(a.date);
          final dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA); // Descending (terbaru di atas)
        });

        // Calculate monthly totals
        double totalMaterial = 0,
            totalManpower = 0,
            totalEquipment = 0,
            totalOther = 0;
        List<dynamic> allMaterialItems = [],
            allManpowerItems = [],
            allEquipmentItems = [],
            allOtherItems = [];

        for (var activity in monthActivities) {
          totalMaterial += activity.costs.materials.totalCost;
          totalManpower += activity.costs.manpower.totalCost;
          totalEquipment += activity.costs.equipment.totalCost;
          totalOther += activity.costs.otherCosts.totalCost;

          allMaterialItems.addAll(activity.costs.materials.items);
          allManpowerItems.addAll(activity.costs.manpower.items);
          allEquipmentItems.addAll(activity.costs.equipment.items);
          allOtherItems.addAll(activity.costs.otherCosts.items);
        }

        final monthlyTotalCost =
            totalMaterial + totalManpower + totalEquipment + totalOther;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              // Accordion Header
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Obx(() => Icon(
                            isExpanded.value
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.orange,
                          )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              monthName,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${_formatRupiah(monthlyTotalCost)}',
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${monthActivities.length} hari',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Accordion Content
              Obx(() => isExpanded.value
                  ? Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          // Monthly summary categories
                          _buildClickableCostCategoryRow('Material',
                              totalMaterial, allMaterialItems, 'Material'),
                          _buildClickableCostCategoryRow('Manpower',
                              totalManpower, allManpowerItems, 'Manpower'),
                          _buildClickableCostCategoryRow('Equipment',
                              totalEquipment, allEquipmentItems, 'Equipment'),
                          _buildClickableCostCategoryRow('Biaya Lainnya',
                              totalOther, allOtherItems, 'Biaya Lainnya'),
                          const Divider(),
                          _buildCostCategoryRow(
                            'Total Bulan',
                            monthlyTotalCost,
                            isTotal: true,
                          ),
                          const SizedBox(height: 16),
                          // Daily breakdown
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 14, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text(
                                  'Rincian Harian',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...sortedMonthActivities.map((activity) {
                            final dailyTotal =
                                activity.costs.materials.totalCost +
                                    activity.costs.manpower.totalCost +
                                    activity.costs.equipment.totalCost +
                                    activity.costs.otherCosts.totalCost;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(activity.date),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(
                                        _formatRupiah(dailyTotal),
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactCostItem('Material',
                                            activity.costs.materials.totalCost),
                                      ),
                                      Expanded(
                                        child: _buildCompactCostItem('Manpower',
                                            activity.costs.manpower.totalCost),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildCompactCostItem(
                                            'Equipment',
                                            activity.costs.equipment.totalCost),
                                      ),
                                      Expanded(
                                        child: _buildCompactCostItem(
                                            'Lainnya',
                                            activity
                                                .costs.otherCosts.totalCost),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClickableCostCategoryRow(
      String category, double cost, List<dynamic> items, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _showCostDetailDialog(category, items, type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    category,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.touch_app, size: 14, color: Colors.orange),
                ],
              ),
              Text(
                _formatRupiah(cost),
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCostDetailDialog(
      String category, List<dynamic> items, String type) {
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.list_alt, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Detail $category',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: items.isEmpty
                        ? [
                            Center(
                              child: Text(
                                'Tidak ada data $category',
                                style: GoogleFonts.dmSans(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ]
                        : items
                            .map((item) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: _buildCostDetailItem(item, type),
                                  ),
                                ))
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostDetailItem(dynamic item, String type) {
    String description = '';
    double cost = 0;

    switch (type) {
      case 'Material':
        final mat = item as spk_progress.MaterialItem;
        description = '${mat.material} - ${mat.quantity} unit';
        cost = mat.cost;
        break;
      case 'Manpower':
        final man = item as spk_progress.ManpowerItem;
        description =
            '${man.role} - ${man.numberOfWorkers} orang, ${man.workingHours} jam';
        cost = man.cost;
        break;
      case 'Equipment':
        final eq = item as spk_progress.EquipmentItem;
        description = '${eq.equipment.equipmentCode} - ${eq.workingHours} jam';
        if (eq.fuelUsed > 0) {
          description += ', BBM: ${eq.fuelUsed}L';
        }
        cost = eq.cost;
        break;
      case 'Biaya Lainnya':
        if (item is Map && item['description'] != null) {
          description = item['description'].toString();
        } else {
          description = item?.toString() ?? '-';
        }
        if (item is Map && item['cost'] != null) {
          cost = (item['cost'] is num) ? (item['cost'] as num).toDouble() : 0;
        }
        break;
      default:
        description = item?.toString() ?? '-';
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: FigmaColors.hitam,
            ),
          ),
        ),
        Text(
          _formatRupiah(cost),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildCostCategoryRow(String category, double cost,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: GoogleFonts.dmSans(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            _formatRupiah(cost),
            style: GoogleFonts.dmSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.orange : FigmaColors.hitam,
            ),
          ),
        ],
      ),
    );
  }
}
