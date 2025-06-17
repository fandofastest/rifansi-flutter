import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../controllers/add_work_report_controller.dart';
import '../../../theme/app_theme.dart';

class WorkDetailsWidget extends StatelessWidget {
  final AddWorkReportController controller;

  const WorkDetailsWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedSpk = controller.selectedSpk.value;
      
      // Filter work items untuk SPK yang dipilih saja
      final workItems = controller.workItems.where((item) {
        return selectedSpk != null && item['spkId'] == selectedSpk.id;
      }).toList();

      print('[WorkDetailsWidget] SPK dipilih: ${selectedSpk?.spkNo}');
      print('[WorkDetailsWidget] Total work items: ${controller.workItems.length}');
      print('[WorkDetailsWidget] Filtered work items: ${workItems.length}');
      
      if (workItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.work_outline,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                selectedSpk != null 
                    ? 'Tidak ada detail pekerjaan untuk SPK ini'
                    : 'Silakan pilih SPK terlebih dahulu',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              if (selectedSpk != null) ...[
                const SizedBox(height: 8),
                Text(
                  'SPK: ${selectedSpk.spkNo}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        );
      }

      // Fungsi untuk mengurutkan item
      List<Map<String, dynamic>> sortedItems = List.from(workItems);
      sortedItems.sort((a, b) {
        if (controller.sortBy.value == 'name') {
          return controller.ascending.value
              ? (a['name'] ?? '').compareTo(b['name'] ?? '')
              : (b['name'] ?? '').compareTo(a['name'] ?? '');
        } else if (controller.sortBy.value == 'volume') {
          final volumeA = (a['volume'] ?? 0).toDouble();
          final volumeB = (b['volume'] ?? 0).toDouble();
          return controller.ascending.value
              ? volumeA.compareTo(volumeB)
              : volumeB.compareTo(volumeA);
        }
        return 0;
      });

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Detail Pekerjaan',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Urutkan:',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: controller.sortBy.value,
                    items: [
                      DropdownMenuItem(
                        value: 'name',
                        child: Text(
                          'Nama',
                          style: GoogleFonts.dmSans(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'volume',
                        child: Text(
                          'Volume',
                          style: GoogleFonts.dmSans(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.sortBy.value = value;
                      }
                    },
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    underline: Container(),
                  ),
                  IconButton(
                    icon: Icon(
                      controller.ascending.value
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 16,
                    ),
                    onPressed: () {
                      controller.ascending.value = !controller.ascending.value;
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
                    ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return _buildWorkItemCard(item);
            },
          ),
        ],
      );
    });
  }



  Widget _buildWorkItemCard(Map<String, dynamic> item) {
    // Parse progress percentage
    double progress = 0.0;
    if (item['progressPercentage'] is num) {
      progress = (item['progressPercentage'] as num).toDouble();
    }

    // Parse volumes
    double completedVolume = 0.0;
    double remainingVolume = 0.0;
    double totalVolume = 0.0;
    double dailyTargetVolume = 0.0;

    if (item['completedVolume'] is Map) {
      final completed = item['completedVolume'] as Map;
      completedVolume = ((completed['nr'] as num?)?.toDouble() ?? 0.0) + 
                       ((completed['r'] as num?)?.toDouble() ?? 0.0);
    }

    if (item['remainingVolume'] is Map) {
      final remaining = item['remainingVolume'] as Map;
      remainingVolume = ((remaining['nr'] as num?)?.toDouble() ?? 0.0) + 
                       ((remaining['r'] as num?)?.toDouble() ?? 0.0);
    }

    if (item['dailyTarget'] is Map) {
      final dailyTarget = item['dailyTarget'] as Map;
      dailyTargetVolume = ((dailyTarget['nr'] as num?)?.toDouble() ?? 0.0) + 
                         ((dailyTarget['r'] as num?)?.toDouble() ?? 0.0);
    }

    if (item['volume'] is num) {
      totalVolume = (item['volume'] as num).toDouble();
    }

    // Calculate actual progress percentage from volumes
    double actualProgress = totalVolume > 0 ? (completedVolume / totalVolume) * 100 : 0.0;

    // Determine progress color
    Color progressColor;
    if (actualProgress >= 100) {
      progressColor = Colors.green[600]!;
    } else if (actualProgress >= 50) {
      progressColor = Colors.orange[600]!;
    } else if (actualProgress > 0) {
      progressColor = Colors.blue[600]!;
    } else {
      progressColor = Colors.grey[400]!;
    }

    // Format currency
    final formatter = NumberFormat('#,##0.##', 'id_ID');
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item['name'] ?? '',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: progressColor.withOpacity(0.3)),
              ),
              child: Text(
                '${actualProgress.toStringAsFixed(1)}%',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Compact progress info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatter.format(completedVolume)} / ${formatter.format(totalVolume)} ${item['unit'] ?? ''}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (dailyTargetVolume > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Target: ${formatter.format(dailyTargetVolume)} ${item['unit'] ?? ''}',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: Colors.teal[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  currencyFormatter.format(item['amount'] ?? 0),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.purple[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Progress bar
            LinearProgressIndicator(
              value: totalVolume > 0 ? (completedVolume / totalVolume).clamp(0.0, 1.0) : 0.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 4,
            ),
          ],
        ),
        children: [
          // Expanded content - detail informasi
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Volume details in grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildVolumeInfo(
                            'Volume BOQ',
                            '${formatter.format(totalVolume)} ${item['unit'] ?? ''}',
                            Colors.blue[700]!,
                            Icons.assignment,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildVolumeInfo(
                            'Target Harian',
                            '${formatter.format(dailyTargetVolume)} ${item['unit'] ?? ''}',
                            dailyTargetVolume > 0 ? Colors.teal[700]! : Colors.grey[500]!,
                            dailyTargetVolume > 0 ? Icons.flag : Icons.flag_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVolumeInfo(
                            'Selesai',
                            '${formatter.format(completedVolume)} ${item['unit'] ?? ''}',
                            Colors.green[700]!,
                            Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildVolumeInfo(
                            'Sisa',
                            '${formatter.format(remainingVolume)} ${item['unit'] ?? ''}',
                            remainingVolume > 0 ? Colors.orange[700]! : Colors.red[700]!,
                            remainingVolume > 0 ? Icons.pending : Icons.done_all,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildVolumeInfo(
                            'Nilai Total',
                            currencyFormatter.format(item['amount'] ?? 0),
                            Colors.purple[700]!,
                            Icons.monetization_on,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Placeholder untuk simetri
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Financial info
              if ((item['spentAmount'] ?? 0) > 0 || (item['remainingAmount'] ?? 0) > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.amber[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Keuangan',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Terpakai: ${currencyFormatter.format(item['spentAmount'] ?? 0)}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                Text(
                                  'Sisa: ${currencyFormatter.format(item['remainingAmount'] ?? 0)}',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: Colors.amber[700],
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
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeInfo(String label, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
