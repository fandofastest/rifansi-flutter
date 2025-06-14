import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

part 'daily_activity_model.g.dart';

@HiveType(typeId: 25)
class DailyActivity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String date;
  @HiveField(2)
  final String location;
  @HiveField(3)
  final String weather;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final String workStartTime;
  @HiveField(6)
  final String workEndTime;
  @HiveField(7)
  final List<String> startImages;
  @HiveField(8)
  final List<String> finishImages;
  @HiveField(9)
  final String closingRemarks;
  @HiveField(10)
  final String createdAt;
  @HiveField(11)
  final String updatedAt;
  @HiveField(12)
  final double progressPercentage;
  @HiveField(13)
  final List<ActivityDetail> activityDetails;
  @HiveField(14)
  final List<EquipmentLog> equipmentLogs;
  @HiveField(15)
  final List<ManpowerLog> manpowerLogs;
  @HiveField(16)
  final List<MaterialUsageLog> materialUsageLogs;
  @HiveField(17)
  final List<OtherCost> otherCosts;
  @HiveField(18)
  final SPK? spkDetail;
  @HiveField(19)
  final User userDetail;
  @HiveField(20)
  final bool isSynced;
  @HiveField(21)
  final String localId;
  @HiveField(22)
  final DateTime lastSyncAttempt;
  @HiveField(23)
  final int syncRetryCount;
  @HiveField(24)
  final String? syncError;

  DailyActivity({
    required this.id,
    required this.date,
    required this.location,
    required this.weather,
    required this.status,
    required this.workStartTime,
    required this.workEndTime,
    required this.startImages,
    required this.finishImages,
    required this.closingRemarks,
    required this.createdAt,
    required this.updatedAt,
    required this.progressPercentage,
    required this.activityDetails,
    required this.equipmentLogs,
    required this.manpowerLogs,
    required this.materialUsageLogs,
    required this.otherCosts,
    this.spkDetail,
    required this.userDetail,
    this.isSynced = false,
    String? localId,
    DateTime? lastSyncAttempt,
    this.syncRetryCount = 0,
    this.syncError,
  })  : this.localId =
            localId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        this.lastSyncAttempt = lastSyncAttempt ?? DateTime.now();

  DailyActivity copyWith({
    bool? isSynced,
    String? id,
    String? status,
    DateTime? lastSyncAttempt,
    int? syncRetryCount,
    String? syncError,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      date: this.date,
      location: this.location,
      weather: this.weather,
      status: status ?? this.status,
      workStartTime: this.workStartTime,
      workEndTime: this.workEndTime,
      startImages: this.startImages,
      finishImages: this.finishImages,
      closingRemarks: this.closingRemarks,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      progressPercentage: this.progressPercentage,
      activityDetails: this.activityDetails,
      equipmentLogs: this.equipmentLogs,
      manpowerLogs: this.manpowerLogs,
      materialUsageLogs: this.materialUsageLogs,
      otherCosts: this.otherCosts,
      spkDetail: this.spkDetail,
      userDetail: this.userDetail,
      isSynced: isSynced ?? this.isSynced,
      localId: this.localId,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
      syncError: syncError ?? this.syncError,
    );
  }

  Map<String, dynamic> toServerJson() {
    return {
      "data": {
        "submitDailyReport": {
          "spkId": spkDetail?.id ?? '',
          "date": date,
          "location": location,
          "weather": weather,
          "status": status,
          "workStartTime": workStartTime,
          "workEndTime": workEndTime,
          "startImages": startImages,
          "finishImages": finishImages,
          "closingRemarks": closingRemarks,
          "progressPercentage": progressPercentage,
          "activityDetails": activityDetails
              .map((detail) => {
                    "workItemId": detail.workItem?.id ?? '',
                    "actualQuantity": {
                      "r": detail.actualQuantity.r,
                      "nr": detail.actualQuantity.nr,
                    },
                    "status": detail.status,
                    "remarks": detail.remarks,
                  })
              .toList(),
          "equipmentLogs": equipmentLogs
              .map((log) => {
                    "equipmentId": log.equipment?.id ?? '',
                    "fuelIn": log.fuelIn,
                    "fuelRemaining": log.fuelRemaining,
                    "workingHour": log.workingHour,
                    "isBrokenReported": log.isBrokenReported,
                    "remarks": log.remarks,
                  })
              .toList(),
          "manpowerLogs": manpowerLogs
              .map((log) => {
                    "role": log.personnelRole?.id ?? '',
                    "personCount": log.personCount,
                    "hourlyRate": log.normalHourlyRate,
                  })
              .toList(),
          "materialUsageLogs": materialUsageLogs
              .map((log) => {
                    "materialId": log.material?.id ?? '',
                    "quantity": log.quantity,
                    "unitRate": log.unitRate,
                    "remarks": log.remarks,
                  })
              .toList(),
          "otherCosts": otherCosts
              .map((cost) => {
                    "costType": cost.costType,
                    "amount": cost.amount,
                    "description": cost.description,
                    "receiptNumber": cost.receiptNumber,
                    "remarks": cost.remarks,
                  })
              .toList(),
        }
      }
    };
  }

  factory DailyActivity.create({
    required String date,
    required String location,
    required String weather,
    required String workStartTime,
    required String workEndTime,
    required List<String> startImages,
    required List<String> finishImages,
    required String closingRemarks,
    required double progressPercentage,
    required List<ActivityDetail> activityDetails,
    required List<EquipmentLog> equipmentLogs,
    required List<ManpowerLog> manpowerLogs,
    required List<MaterialUsageLog> materialUsageLogs,
    required List<OtherCost> otherCosts,
    required SPK spkDetail,
    required User userDetail,
  }) {
    final now = DateTime.now();
    return DailyActivity(
      id: '',
      date: date,
      location: location,
      weather: weather,
      status: 'Draft',
      workStartTime: workStartTime,
      workEndTime: workEndTime,
      startImages: startImages,
      finishImages: finishImages,
      closingRemarks: closingRemarks,
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
      progressPercentage: progressPercentage,
      activityDetails: activityDetails,
      equipmentLogs: equipmentLogs,
      manpowerLogs: manpowerLogs,
      materialUsageLogs: materialUsageLogs,
      otherCosts: otherCosts,
      spkDetail: spkDetail,
      userDetail: userDetail,
      isSynced: false,
      lastSyncAttempt: now,
      syncRetryCount: 0,
    );
  }

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      workStartTime: json['workStartTime']?.toString() ?? '',
      workEndTime: json['workEndTime']?.toString() ?? '',
      startImages: json['startImages'] != null
          ? List<String>.from(json['startImages'])
          : [],
      finishImages: json['finishImages'] != null
          ? List<String>.from(json['finishImages'])
          : [],
      closingRemarks: json['closingRemarks']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      progressPercentage: json['progressPercentage'] != null
          ? json['progressPercentage'] is int
              ? (json['progressPercentage'] as int).toDouble()
              : json['progressPercentage'] is double
                  ? json['progressPercentage']
                  : 0.0
          : 0.0,
      activityDetails: json['activityDetails'] != null
          ? List<ActivityDetail>.from(json['activityDetails']
              .map((detail) => ActivityDetail.fromJson(detail)))
          : [],
      equipmentLogs: json['equipmentLogs'] != null
          ? List<EquipmentLog>.from(
              json['equipmentLogs'].map((log) => EquipmentLog.fromJson(log)))
          : [],
      manpowerLogs: json['manpowerLogs'] != null
          ? List<ManpowerLog>.from(
              json['manpowerLogs'].map((log) => ManpowerLog.fromJson(log)))
          : [],
      materialUsageLogs: json['materialUsageLogs'] != null
          ? List<MaterialUsageLog>.from(json['materialUsageLogs']
              .map((log) => MaterialUsageLog.fromJson(log)))
          : [],
      otherCosts: json['otherCosts'] != null
          ? List<OtherCost>.from(
              json['otherCosts'].map((cost) => OtherCost.fromJson(cost)))
          : [],
      spkDetail:
          json['spkDetail'] != null ? SPK.fromJson(json['spkDetail']) : null,
      userDetail: User.fromJson(json['userDetail'] ?? {}),
      isSynced: json['isSynced'] as bool? ?? false,
      localId: json['localId']?.toString() ?? '',
      lastSyncAttempt: json['lastSyncAttempt'] != null
          ? DateTime.parse(json['lastSyncAttempt'])
          : DateTime.now(),
      syncRetryCount: json['syncRetryCount'] as int? ?? 0,
      syncError: json['syncError']?.toString(),
    );
  }

  String getFormattedDate() {
    try {
      final timestamp = int.parse(date);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (_) {
      return date;
    }
  }

  String getFormattedTime(String timeString) {
    try {
      final timestamp = int.parse(timeString);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateFormat('HH:mm').format(dateTime);
    } catch (_) {
      return timeString;
    }
  }

  String getWorkHours() {
    try {
      final startTimestamp = int.parse(workStartTime);
      final endTimestamp = int.parse(workEndTime);

      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimestamp);
      final endTime = DateTime.fromMillisecondsSinceEpoch(endTimestamp);

      final duration = endTime.difference(startTime);

      final hours = duration.inHours;
      final minutes = (duration.inMinutes % 60);

      return '$hours jam $minutes menit';
    } catch (_) {
      return 'N/A';
    }
  }

  String getFormattedProgressPercentage() {
    return '${(progressPercentage * 100).toStringAsFixed(2)}%';
  }

  DailyActivity toPending() {
    return copyWith(status: 'Pending');
  }

  DailyActivity toSynced(String serverId) {
    return copyWith(status: 'Submitted', id: serverId);
  }

  DailyActivity toFailed(String error) {
    return copyWith(status: 'Failed', syncError: error);
  }
}

@HiveType(typeId: 2)
class Quantity {
  @HiveField(0)
  final double nr;
  @HiveField(1)
  final double r;

  Quantity({
    required this.nr,
    required this.r,
  });

  factory Quantity.fromJson(Map<String, dynamic> json) {
    return Quantity(
      nr: json['nr'] != null
          ? json['nr'] is int
              ? (json['nr'] as int).toDouble()
              : json['nr'] is double
                  ? json['nr']
                  : 0.0
          : 0.0,
      r: json['r'] != null
          ? json['r'] is int
              ? (json['r'] as int).toDouble()
              : json['r'] is double
                  ? json['r']
                  : 0.0
          : 0.0,
    );
  }
}

@HiveType(typeId: 3)
class WorkItem {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final Unit? unit;

  WorkItem({
    required this.id,
    required this.name,
    this.unit,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      id: json['id'],
      name: json['name'],
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit?.toJson(),
    };
  }
}

@HiveType(typeId: 4)
class Unit {
  @HiveField(0)
  final String name;

  Unit({required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

@HiveType(typeId: 5)
class ActivityDetail {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Quantity actualQuantity;
  @HiveField(2)
  final String status;
  @HiveField(3)
  final String remarks;
  @HiveField(4)
  final WorkItem? workItem;
  @HiveField(5)
  final double? progressPercentage;
  @HiveField(6)
  final double? dailyProgressPercentage;
  @HiveField(7)
  final double? totalProgressValue;
  @HiveField(8)
  final double? rateR;
  @HiveField(9)
  final double? rateNR;
  @HiveField(10)
  final String? rateDescriptionR;
  @HiveField(11)
  final String? rateDescriptionNR;
  @HiveField(12)
  final double? boqVolumeR;
  @HiveField(13)
  final double? boqVolumeNR;
  @HiveField(14)
  final double? dailyTargetR;
  @HiveField(15)
  final double? dailyTargetNR;

  ActivityDetail({
    required this.id,
    required this.actualQuantity,
    required this.status,
    required this.remarks,
    this.workItem,
    this.progressPercentage = 0.0,
    this.dailyProgressPercentage = 0.0,
    this.totalProgressValue = 0.0,
    this.rateR = 0.0,
    this.rateNR = 0.0,
    this.rateDescriptionR,
    this.rateDescriptionNR,
    this.boqVolumeR = 0.0,
    this.boqVolumeNR = 0.0,
    this.dailyTargetR = 0.0,
    this.dailyTargetNR = 0.0,
  });

  factory ActivityDetail.fromJson(Map<String, dynamic> json) {
    return ActivityDetail(
      id: json['id'],
      actualQuantity: Quantity.fromJson(json['actualQuantity']),
      status: json['status'],
      remarks: json['remarks'],
      workItem:
          json['workItem'] != null ? WorkItem.fromJson(json['workItem']) : null,
      progressPercentage: _parseDouble(json['progressPercentage']),
      dailyProgressPercentage: _parseDouble(json['dailyProgressPercentage']),
      totalProgressValue: _parseDouble(json['totalProgressValue']),
      rateR: _parseDouble(json['rateR']),
      rateNR: _parseDouble(json['rateNR']),
      rateDescriptionR: json['rateDescriptionR']?.toString(),
      rateDescriptionNR: json['rateDescriptionNR']?.toString(),
      boqVolumeR: _parseDouble(json['boqVolumeR']),
      boqVolumeNR: _parseDouble(json['boqVolumeNR']),
      dailyTargetR: _parseDouble(json['dailyTargetR']),
      dailyTargetNR: _parseDouble(json['dailyTargetNR']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actualQuantity': {
        'r': actualQuantity.r,
        'nr': actualQuantity.nr,
      },
      'status': status,
      'remarks': remarks,
      'workItem': workItem?.toJson(),
      'progressPercentage': progressPercentage ?? 0.0,
      'dailyProgressPercentage': dailyProgressPercentage ?? 0.0,
      'totalProgressValue': totalProgressValue ?? 0.0,
      'rateR': rateR ?? 0.0,
      'rateNR': rateNR ?? 0.0,
      'rateDescriptionR': rateDescriptionR,
      'rateDescriptionNR': rateDescriptionNR,
      'boqVolumeR': boqVolumeR ?? 0.0,
      'boqVolumeNR': boqVolumeNR ?? 0.0,
      'dailyTargetR': dailyTargetR ?? 0.0,
      'dailyTargetNR': dailyTargetNR ?? 0.0,
    };
  }
}

@HiveType(typeId: 15)
class Area {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  Area({
    required this.id,
    required this.name,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

@HiveType(typeId: 16)
class FuelPrice {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double pricePerLiter;
  @HiveField(2)
  final int effectiveDate;

  FuelPrice({
    required this.id,
    required this.pricePerLiter,
    required this.effectiveDate,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) {
    return FuelPrice(
      id: json['id']?.toString() ?? '',
      pricePerLiter: json['pricePerLiter'] != null
          ? json['pricePerLiter'] is int
              ? (json['pricePerLiter'] as int).toDouble()
              : json['pricePerLiter'] is double
                  ? json['pricePerLiter']
                  : 0.0
          : 0.0,
      effectiveDate: json['effectiveDate'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pricePerLiter': pricePerLiter,
      'effectiveDate': effectiveDate,
    };
  }
}

@HiveType(typeId: 6)
class Equipment {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String equipmentCode;
  @HiveField(2)
  final String equipmentType;
  @HiveField(3)
  final String plateOrSerialNo;
  @HiveField(4)
  final String defaultOperator;
  @HiveField(5)
  final Area? area;
  @HiveField(6)
  final FuelPrice? currentFuelPrice;

  Equipment({
    required this.id,
    required this.equipmentCode,
    required this.equipmentType,
    required this.plateOrSerialNo,
    required this.defaultOperator,
    this.area,
    this.currentFuelPrice,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id']?.toString() ?? '',
      equipmentCode: json['equipmentCode']?.toString() ?? '',
      equipmentType: json['equipmentType']?.toString() ?? '',
      plateOrSerialNo: json['plateOrSerialNo']?.toString() ?? '',
      defaultOperator: json['defaultOperator']?.toString() ?? '',
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      currentFuelPrice: json['currentFuelPrice'] != null
          ? FuelPrice.fromJson(json['currentFuelPrice'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentCode': equipmentCode,
      'equipmentType': equipmentType,
      'plateOrSerialNo': plateOrSerialNo,
      'defaultOperator': defaultOperator,
      'area': area?.toJson(),
      'currentFuelPrice': currentFuelPrice?.toJson(),
    };
  }
}

@HiveType(typeId: 7)
class EquipmentLog {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double fuelIn;
  @HiveField(2)
  final double fuelRemaining;
  @HiveField(3)
  final double workingHour;
  @HiveField(4)
  final bool isBrokenReported;
  @HiveField(5)
  final String remarks;
  @HiveField(6)
  final Equipment? equipment;
  @HiveField(7)
  final double hourlyRate;
  @HiveField(8)
  final double rentalRatePerDay;
  @HiveField(9)
  final double fuelPrice;

  EquipmentLog({
    required this.id,
    required this.fuelIn,
    required this.fuelRemaining,
    required this.workingHour,
    required this.isBrokenReported,
    required this.remarks,
    this.equipment,
    this.hourlyRate = 0.0,
    this.rentalRatePerDay = 0.0,
    this.fuelPrice = 0.0,
  });

  factory EquipmentLog.fromJson(Map<String, dynamic> json) {
    return EquipmentLog(
      id: json['id']?.toString() ?? '',
      fuelIn: json['fuelIn'] != null
          ? json['fuelIn'] is int
              ? (json['fuelIn'] as int).toDouble()
              : json['fuelIn'] is double
                  ? json['fuelIn']
                  : 0.0
          : 0.0,
      fuelRemaining: json['fuelRemaining'] != null
          ? json['fuelRemaining'] is int
              ? (json['fuelRemaining'] as int).toDouble()
              : json['fuelRemaining'] is double
                  ? json['fuelRemaining']
                  : 0.0
          : 0.0,
      workingHour: json['workingHour'] != null
          ? json['workingHour'] is int
              ? (json['workingHour'] as int).toDouble()
              : json['workingHour'] is double
                  ? json['workingHour']
                  : 0.0
          : 0.0,
      isBrokenReported: json['isBrokenReported'] as bool? ?? false,
      remarks: json['remarks']?.toString() ?? '',
      equipment: json['equipment'] != null
          ? Equipment.fromJson(json['equipment'])
          : null,
      hourlyRate: json['hourlyRate'] != null
          ? json['hourlyRate'] is int
              ? (json['hourlyRate'] as int).toDouble()
              : json['hourlyRate'] is double
                  ? json['hourlyRate']
                  : 0.0
          : 0.0,
      rentalRatePerDay: json['rentalRatePerDay'] != null
          ? json['rentalRatePerDay'] is int
              ? (json['rentalRatePerDay'] as int).toDouble()
              : json['rentalRatePerDay'] is double
                  ? json['rentalRatePerDay']
                  : 0.0
          : 0.0,
      fuelPrice: json['fuelPrice'] != null
          ? json['fuelPrice'] is int
              ? (json['fuelPrice'] as int).toDouble()
              : json['fuelPrice'] is double
                  ? json['fuelPrice']
                  : 0.0
          : 0.0,
    );
  }
}

@HiveType(typeId: 8)
class PersonnelRole {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String roleName;

  PersonnelRole({
    required this.id,
    required this.roleName,
  });

  factory PersonnelRole.fromJson(Map<String, dynamic> json) {
    return PersonnelRole(
      id: json['id'],
      roleName: json['roleName'],
    );
  }
}

@HiveType(typeId: 9)
class ManpowerLog {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final int personCount;
  @HiveField(2)
  final double normalHoursPerPerson;
  @HiveField(3)
  final double normalHourlyRate;
  @HiveField(4)
  final double overtimeHourlyRate;
  @HiveField(5)
  final PersonnelRole? personnelRole;

  ManpowerLog({
    required this.id,
    required this.personCount,
    required this.normalHoursPerPerson,
    required this.normalHourlyRate,
    required this.overtimeHourlyRate,
    this.personnelRole,
  });

  factory ManpowerLog.fromJson(Map<String, dynamic> json) {
    return ManpowerLog(
      id: json['id'],
      personCount: json['personCount'] ?? 0,
      normalHoursPerPerson: json['normalHoursPerPerson'] != null
          ? json['normalHoursPerPerson'] is int
              ? (json['normalHoursPerPerson'] as int).toDouble()
              : json['normalHoursPerPerson'] is double
                  ? json['normalHoursPerPerson']
                  : 0.0
          : 0.0,
      normalHourlyRate: json['normalHourlyRate'] != null
          ? json['normalHourlyRate'] is int
              ? (json['normalHourlyRate'] as int).toDouble()
              : json['normalHourlyRate'] is double
                  ? json['normalHourlyRate']
                  : 0.0
          : 0.0,
      overtimeHourlyRate: json['overtimeHourlyRate'] != null
          ? json['overtimeHourlyRate'] is int
              ? (json['overtimeHourlyRate'] as int).toDouble()
              : json['overtimeHourlyRate'] is double
                  ? json['overtimeHourlyRate']
                  : 0.0
          : 0.0,
      personnelRole: json['personnelRole'] != null
          ? PersonnelRole.fromJson(json['personnelRole'])
          : null,
    );
  }
}

@HiveType(typeId: 10)
class Material {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  Material({
    required this.id,
    required this.name,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      name: json['name'],
    );
  }
}

@HiveType(typeId: 11)
class MaterialUsageLog {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double quantity;
  @HiveField(2)
  final double unitRate;
  @HiveField(3)
  final String remarks;
  @HiveField(4)
  final Material? material;

  MaterialUsageLog({
    required this.id,
    required this.quantity,
    required this.unitRate,
    required this.remarks,
    this.material,
  });

  factory MaterialUsageLog.fromJson(Map<String, dynamic> json) {
    return MaterialUsageLog(
      id: json['id'],
      quantity: json['quantity'] != null
          ? json['quantity'] is int
              ? (json['quantity'] as int).toDouble()
              : json['quantity'] is double
                  ? json['quantity']
                  : 0.0
          : 0.0,
      unitRate: json['unitRate'] != null
          ? json['unitRate'] is int
              ? (json['unitRate'] as int).toDouble()
              : json['unitRate'] is double
                  ? json['unitRate']
                  : 0.0
          : 0.0,
      remarks: json['remarks'] ?? '',
      material:
          json['material'] != null ? Material.fromJson(json['material']) : null,
    );
  }
}

@HiveType(typeId: 12)
class OtherCost {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String costType;
  @HiveField(2)
  final double amount;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String? receiptNumber;
  @HiveField(5)
  final String? remarks;

  OtherCost({
    required this.id,
    required this.costType,
    required this.amount,
    required this.description,
    this.receiptNumber,
    this.remarks,
  });

  factory OtherCost.fromJson(Map<String, dynamic> json) {
    return OtherCost(
      id: json['id']?.toString() ?? '',
      costType: json['costType']?.toString() ?? '',
      amount: json['amount'] != null
          ? json['amount'] is int
              ? (json['amount'] as int).toDouble()
              : json['amount'] is double
                  ? json['amount']
                  : 0.0
          : 0.0,
      description: json['description']?.toString() ?? '',
      receiptNumber: json['receiptNumber']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'costType': costType,
      'amount': amount,
      'description': description,
      'receiptNumber': receiptNumber,
      'remarks': remarks,
    };
  }
}

@HiveType(typeId: 13)
class SPK {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String spkNo;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String projectName;

  SPK({
    required this.id,
    required this.spkNo,
    required this.title,
    required this.projectName,
  });

  factory SPK.fromJson(Map<String, dynamic> json) {
    return SPK(
      id: json['id'],
      spkNo: json['spkNo'],
      title: json['title'],
      projectName: json['projectName'],
    );
  }
}

@HiveType(typeId: 14)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String fullName;

  User({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
    );
  }
}
