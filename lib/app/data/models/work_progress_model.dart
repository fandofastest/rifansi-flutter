import 'package:hive/hive.dart';

part 'work_progress_model.g.dart';

@HiveType(typeId: 15)
class WorkProgress {
  @HiveField(0)
  final String workItemId;
  @HiveField(1)
  final String workItemName;
  @HiveField(2)
  final String unit;
  @HiveField(3)
  final double boqVolumeR;
  @HiveField(4)
  final double boqVolumeNR;
  @HiveField(5)
  final double progressVolumeR;
  @HiveField(6)
  final double progressVolumeNR;
  @HiveField(7)
  final int workingDays;
  @HiveField(8)
  final String? remarks;
  @HiveField(9)
  final double rateR;
  @HiveField(10)
  final double rateNR;
  @HiveField(11)
  final String? rateDescriptionR;
  @HiveField(12)
  final String? rateDescriptionNR;
  @HiveField(13)
  final double dailyTargetR;
  @HiveField(14)
  final double dailyTargetNR;

  WorkProgress({
    required this.workItemId,
    required this.workItemName,
    required this.unit,
    required this.boqVolumeR,
    required this.boqVolumeNR,
    required this.progressVolumeR,
    required this.progressVolumeNR,
    required this.workingDays,
    required this.rateR,
    required this.rateNR,
    required this.dailyTargetR,
    required this.dailyTargetNR,
    this.rateDescriptionR,
    this.rateDescriptionNR,
    this.remarks,
  });

  // Persentase progress harian untuk volume R
  double get dailyProgressPercentageR {
    if (dailyTargetR <= 0) return 0;
    return (progressVolumeR / dailyTargetR) * 100;
  }

  // Persentase progress harian untuk volume NR
  double get dailyProgressPercentageNR {
    if (dailyTargetNR <= 0) return 0;
    return (progressVolumeNR / dailyTargetNR) * 100;
  }

  // Total persentase progress harian (rata-rata dari R dan NR)
  double get dailyProgressPercentage {
    double totalProgress = 0;
    int countNonZero = 0;

    if (dailyTargetR > 0) {
      totalProgress += dailyProgressPercentageR;
      countNonZero++;
    }
    if (dailyTargetNR > 0) {
      totalProgress += dailyProgressPercentageNR;
      countNonZero++;
    }

    return countNonZero > 0 ? totalProgress / countNonZero : 0;
  }

  // Persentase total progress untuk volume R
  double get totalProgressPercentageR {
    if (boqVolumeR <= 0) return 0;
    return (progressVolumeR / boqVolumeR) * 100;
  }

  // Persentase total progress untuk volume NR
  double get totalProgressPercentageNR {
    if (boqVolumeNR <= 0) return 0;
    return (progressVolumeNR / boqVolumeNR) * 100;
  }

  // Total persentase progress keseluruhan (untuk SPK)
  double get totalProgressPercentage {
    double totalProgress = 0;
    int countNonZero = 0;

    if (boqVolumeR > 0) {
      totalProgress += totalProgressPercentageR;
      countNonZero++;
    }
    if (boqVolumeNR > 0) {
      totalProgress += totalProgressPercentageNR;
      countNonZero++;
    }

    return countNonZero > 0 ? totalProgress / countNonZero : 0;
  }

  // Nilai progress R (volume × harga satuan)
  double get progressValueR => progressVolumeR * rateR;

  // Nilai progress NR (volume × harga satuan)
  double get progressValueNR => progressVolumeNR * rateNR;

  // Total nilai progress
  double get totalProgressValue => progressValueR + progressValueNR;

  Map<String, dynamic> toJson() {
    return {
      'workItemId': workItemId,
      'workItemName': workItemName,
      'unit': unit,
      'boqVolumeR': boqVolumeR,
      'boqVolumeNR': boqVolumeNR,
      'progressVolumeR': progressVolumeR,
      'progressVolumeNR': progressVolumeNR,
      'workingDays': workingDays,
      'rateR': rateR,
      'rateNR': rateNR,
      'dailyTargetR': dailyTargetR,
      'dailyTargetNR': dailyTargetNR,
      'rateDescriptionR': rateDescriptionR,
      'rateDescriptionNR': rateDescriptionNR,
      'remarks': remarks,
    };
  }

  factory WorkProgress.fromJson(Map<String, dynamic> json) {
    return WorkProgress(
      workItemId: json['workItemId']?.toString() ?? '',
      workItemName: json['workItemName']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      boqVolumeR: (json['boqVolumeR'] as num?)?.toDouble() ?? 0.0,
      boqVolumeNR: (json['boqVolumeNR'] as num?)?.toDouble() ?? 0.0,
      progressVolumeR: (json['progressVolumeR'] as num?)?.toDouble() ?? 0.0,
      progressVolumeNR: (json['progressVolumeNR'] as num?)?.toDouble() ?? 0.0,
      workingDays: (json['workingDays'] as num?)?.toInt() ?? 1,
      rateR: (json['rateR'] as num?)?.toDouble() ?? 0.0,
      rateNR: (json['rateNR'] as num?)?.toDouble() ?? 0.0,
      dailyTargetR: (json['dailyTargetR'] as num?)?.toDouble() ?? 0.0,
      dailyTargetNR: (json['dailyTargetNR'] as num?)?.toDouble() ?? 0.0,
      rateDescriptionR: json['rateDescriptionR']?.toString(),
      rateDescriptionNR: json['rateDescriptionNR']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }

  factory WorkProgress.fromWorkItem(Map<String, dynamic> workItem) {
    final boqVolume = workItem['boqVolume'] ?? {};
    final rates = workItem['rates'] ?? {};
    final rateR = rates['r'] ?? {};
    final rateNR = rates['nr'] ?? {};
    final dailyTarget = workItem['dailyTarget'] ?? {};
    
    // Debug: Log dailyTarget data
    print('[WorkProgress] Creating from workItem: ${workItem['workItem']?['name']}');
    print('[WorkProgress] dailyTarget received: $dailyTarget');
    print('[WorkProgress] dailyTarget.r: ${dailyTarget['r']}, dailyTarget.nr: ${dailyTarget['nr']}');

    // Hitung workingDays dari startDate dan endDate SPK
    int calculateWorkingDays(dynamic startDate, dynamic endDate) {
      try {
        DateTime start;
        DateTime end;

        // Handle format timestamp dalam milidetik
        if (startDate is int ||
            startDate is String && startDate.contains('000')) {
          start = DateTime.fromMillisecondsSinceEpoch(
              int.parse(startDate.toString()));
        } else {
          start = DateTime.parse(startDate.toString());
        }

        if (endDate is int || endDate is String && endDate.contains('000')) {
          end = DateTime.fromMillisecondsSinceEpoch(
              int.parse(endDate.toString()));
        } else {
          end = DateTime.parse(endDate.toString());
        }

        final days = end.difference(start).inDays; // Hapus +1
        return days > 0 ? days : 30; // Fallback ke 30 jika perhitungan gagal
      } catch (e) {
        print('[WorkProgress] Error calculating working days: $e');
        print('[WorkProgress] startDate: $startDate, endDate: $endDate');
        return 30; // Default 30 hari jika ada error
      }
    }

    // Ambil startDate dan endDate dari SPK
    final spk = workItem['spk'] ?? {};
    final startDate = spk['startDate'];
    final endDate = spk['endDate'];

    // Hitung workingDays
    final workingDays = (startDate != null && endDate != null)
        ? calculateWorkingDays(startDate, endDate)
        : 30;

    return WorkProgress(
      workItemId: workItem['workItemId']?.toString() ?? '',
      workItemName: workItem['workItem']?['name']?.toString() ?? '',
      unit: workItem['workItem']?['unit']?['name']?.toString() ?? '',
      boqVolumeR: (boqVolume['r'] as num?)?.toDouble() ?? 0.0,
      boqVolumeNR: (boqVolume['nr'] as num?)?.toDouble() ?? 0.0,
      progressVolumeR: 0.0,
      progressVolumeNR: 0.0,
      workingDays: workingDays, // Gunakan hasil perhitungan
      rateR: (rateR['rate'] as num?)?.toDouble() ?? 0.0,
      rateNR: (rateNR['rate'] as num?)?.toDouble() ?? 0.0,
      dailyTargetR: (dailyTarget['r'] as num?)?.toDouble() ?? 0.0,
      dailyTargetNR: (dailyTarget['nr'] as num?)?.toDouble() ?? 0.0,
      rateDescriptionR: rateR['description']?.toString(),
      rateDescriptionNR: rateNR['description']?.toString(),
      remarks: null,
    );
  }
}
