import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../controllers/spk_details_controller.dart';
import '../../data/models/spk_detail_with_progress_response.dart'
    as spk_progress;

class SpkDetailsPage extends GetView<SpkDetailsController> {
  const SpkDetailsPage({Key? key}) : super(key: key);

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
                  _buildInfoRow('Nomor SPK', controller.spkNo),
                  _buildInfoRow('Nomor WAP', controller.wapNo),
                  _buildInfoRow('Judul', controller.title),
                  _buildInfoRow('Nama Proyek', controller.projectName),
                  _buildInfoRow('Kontraktor', controller.contractor),
                  _buildInfoRow('Lokasi', controller.location),
                  _buildInfoRow('Tanggal Mulai', controller.startDate),
                  _buildInfoRow('Tanggal Selesai', controller.endDate),
                  _buildInfoRow(
                      'Anggaran', 'Rp ${controller.budget.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Keseluruhan
              _buildSection(
                'Progress Keseluruhan',
                [
                  _buildProgressCard(
                      controller.spkDetails.value?.totalProgress),
                ],
              ),
              const SizedBox(height: 24),

              // Item Pekerjaan
              _buildSection(
                'Item Pekerjaan',
                [
                  _buildWorkItemsCard(controller.workItems),
                ],
              ),
              const SizedBox(height: 24),

              // Breakdown Biaya
              _buildSection(
                'Breakdown Biaya',
                [
                  _buildCostBreakdownCard(controller.dailyActivities),
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: FigmaColors.hitam,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w500,
                color: FigmaColors.abu,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: FigmaColors.hitam,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(spk_progress.TotalProgress? progress) {
    if (progress == null) return const SizedBox.shrink();

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
            _buildInfoRow('Total Anggaran',
                'Rp ${progress.totalBudget.toStringAsFixed(0)}'),
            _buildInfoRow('Total Terpakai',
                'Rp ${progress.totalSpent.toStringAsFixed(0)}'),
            _buildInfoRow('Sisa Anggaran',
                'Rp ${progress.remainingBudget.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItemsCard(List<spk_progress.WorkItem> workItems) {
    if (workItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...workItems.map((item) => _buildWorkItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkItemRow(spk_progress.WorkItem item) {
    final RxBool isExpanded = false.obs;

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
                          Text(
                            'Progress: ${item.progressAchieved.nr.toStringAsFixed(2)}%',
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
                      value: item.progressAchieved.nr / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          FigmaColors.primary),
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
        description = '${mat.material} - ${mat.quantity} ${mat.unit}';
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
            'Rp ${cost.toStringAsFixed(0)}',
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
}
