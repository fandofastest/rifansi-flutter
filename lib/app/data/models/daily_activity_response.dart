import 'package:intl/intl.dart';

class DailyActivityResponse {
  final String id;
  final String date;
  final String location;
  final String weather;
  final String status;
  final String workStartTime;
  final String workEndTime;
  final List<String> startImages;
  final List<String> finishImages;
  final String closingRemarks;
  final String createdAt;
  final String updatedAt;
  final double progressPercentage;
  final List<ActivityDetailResponse> activityDetails;
  final List<EquipmentLogResponse> equipmentLogs;
  final List<ManpowerLogResponse> manpowerLogs;
  final List<MaterialUsageLogResponse> materialUsageLogs;
  final List<OtherCostResponse> otherCosts;
  final SPKResponse? spkDetail;
  final UserResponse userDetail;

  // Properti tambahan untuk kompatibilitas dengan kode existing
  String get spkId => spkDetail?.id ?? '';
  String get areaId => ''; // Defaultnya kosong, bisa diupdate nanti

  DailyActivityResponse({
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
  });

  factory DailyActivityResponse.fromJson(Map<String, dynamic> json) {
    try {
      return DailyActivityResponse(
        id: json['id']?.toString() ?? '',
        date: json['date']?.toString() ?? '',
        location: json['location']?.toString() ?? '',
        weather: json['weather']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        workStartTime: json['workStartTime']?.toString() ?? '',
        workEndTime: json['workEndTime']?.toString() ?? '',
        startImages: json['startImages'] != null
            ? List<String>.from(json['startImages'].map((x) => x.toString()))
            : [],
        finishImages: json['finishImages'] != null
            ? List<String>.from(json['finishImages'].map((x) => x.toString()))
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
            ? List<ActivityDetailResponse>.from(json['activityDetails']
                .map((detail) => ActivityDetailResponse.fromJson(detail)))
            : [],
        equipmentLogs: json['equipmentLogs'] != null
            ? List<EquipmentLogResponse>.from(json['equipmentLogs']
                .map((log) => EquipmentLogResponse.fromJson(log)))
            : [],
        manpowerLogs: json['manpowerLogs'] != null
            ? List<ManpowerLogResponse>.from(json['manpowerLogs']
                .map((log) => ManpowerLogResponse.fromJson(log)))
            : [],
        materialUsageLogs: json['materialUsageLogs'] != null
            ? List<MaterialUsageLogResponse>.from(json['materialUsageLogs']
                .map((log) => MaterialUsageLogResponse.fromJson(log)))
            : [],
        otherCosts: json['otherCosts'] != null
            ? List<OtherCostResponse>.from(json['otherCosts']
                .map((cost) => OtherCostResponse.fromJson(cost)))
            : [],
        spkDetail: json['spkDetail'] != null
            ? SPKResponse.fromJson(json['spkDetail'])
            : null,
        userDetail: UserResponse.fromJson(json['userDetail'] ?? {}),
      );
    } catch (e, stackTrace) {
      print('[DailyActivityResponse] Error parsing JSON: $e');
      print('[DailyActivityResponse] Stack trace: $stackTrace');
      print('[DailyActivityResponse] JSON data: $json');
      rethrow;
    }
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
}

class QuantityResponse {
  final double nr;
  final double r;

  QuantityResponse({
    required this.nr,
    required this.r,
  });

  factory QuantityResponse.fromJson(Map<String, dynamic> json) {
    return QuantityResponse(
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

class WorkItemResponse {
  final String id;
  final String name;
  final UnitResponse? unit;

  WorkItemResponse({
    required this.id,
    required this.name,
    this.unit,
  });

  factory WorkItemResponse.fromJson(Map<String, dynamic> json) {
    return WorkItemResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unit: json['unit'] != null ? UnitResponse.fromJson(json['unit']) : null,
    );
  }
}

class UnitResponse {
  final String name;

  UnitResponse({required this.name});

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    return UnitResponse(name: json['name']?.toString() ?? '');
  }
}

class ActivityDetailResponse {
  final String id;
  final QuantityResponse actualQuantity;
  final String status;
  final String remarks;
  final WorkItemResponse? workItem;
  final double? progressPercentage;
  final double? dailyProgressPercentage;
  final double? totalProgressValue;
  final double? rateR;
  final double? rateNR;
  final String? rateDescriptionR;
  final String? rateDescriptionNR;
  final double? boqVolumeR;
  final double? boqVolumeNR;
  final double? dailyTargetR;
  final double? dailyTargetNR;

  ActivityDetailResponse({
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

  factory ActivityDetailResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ActivityDetailResponse(
        id: json['id']?.toString() ?? '',
        actualQuantity: QuantityResponse.fromJson(
            json['actualQuantity'] ?? {'nr': 0, 'r': 0}),
        status: json['status']?.toString() ?? '',
        remarks: json['remarks']?.toString() ?? '',
        workItem: json['workItem'] != null
            ? WorkItemResponse.fromJson(json['workItem'])
            : null,
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
    } catch (e, stackTrace) {
      print('[ActivityDetailResponse] Error parsing JSON: $e');
      print('[ActivityDetailResponse] Stack trace: $stackTrace');
      print('[ActivityDetailResponse] JSON data: $json');
      rethrow;
    }
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
}

class AreaResponse {
  final String id;
  final String name;

  AreaResponse({
    required this.id,
    required this.name,
  });

  factory AreaResponse.fromJson(Map<String, dynamic> json) {
    return AreaResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class FuelPriceResponse {
  final String id;
  final double pricePerLiter;
  final int effectiveDate;

  FuelPriceResponse({
    required this.id,
    required this.pricePerLiter,
    required this.effectiveDate,
  });

  factory FuelPriceResponse.fromJson(Map<String, dynamic> json) {
    return FuelPriceResponse(
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
}

class EquipmentResponse {
  final String id;
  final String equipmentCode;
  final String equipmentType;
  final String plateOrSerialNo;
  final String defaultOperator;
  final AreaResponse? area;
  final FuelPriceResponse? currentFuelPrice;

  EquipmentResponse({
    required this.id,
    required this.equipmentCode,
    required this.equipmentType,
    required this.plateOrSerialNo,
    required this.defaultOperator,
    this.area,
    this.currentFuelPrice,
  });

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentResponse(
      id: json['id']?.toString() ?? '',
      equipmentCode: json['equipmentCode']?.toString() ?? '',
      equipmentType: json['equipmentType']?.toString() ?? '',
      plateOrSerialNo: json['plateOrSerialNo']?.toString() ?? '',
      defaultOperator: json['defaultOperator']?.toString() ?? '',
      area: json['area'] != null ? AreaResponse.fromJson(json['area']) : null,
      currentFuelPrice: json['currentFuelPrice'] != null
          ? FuelPriceResponse.fromJson(json['currentFuelPrice'])
          : null,
    );
  }
}

class EquipmentLogResponse {
  final String id;
  final double fuelIn;
  final double fuelRemaining;
  final double workingHour;
  final bool isBrokenReported;
  final String remarks;
  final EquipmentResponse? equipment;
  final double hourlyRate;

  EquipmentLogResponse({
    required this.id,
    required this.fuelIn,
    required this.fuelRemaining,
    required this.workingHour,
    required this.isBrokenReported,
    required this.remarks,
    this.equipment,
    required this.hourlyRate,
  });

  factory EquipmentLogResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentLogResponse(
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
          ? EquipmentResponse.fromJson(json['equipment'])
          : null,
      hourlyRate: json['hourlyRate'] != null
          ? json['hourlyRate'] is int
              ? (json['hourlyRate'] as int).toDouble()
              : json['hourlyRate'] is double
                  ? json['hourlyRate']
                  : 0.0
          : 0.0,
    );
  }
}

class PersonnelRoleResponse {
  final String id;
  final String roleName;

  PersonnelRoleResponse({
    required this.id,
    required this.roleName,
  });

  factory PersonnelRoleResponse.fromJson(Map<String, dynamic> json) {
    return PersonnelRoleResponse(
      id: json['id']?.toString() ?? '',
      roleName: json['roleName']?.toString() ?? '',
    );
  }
}

class ManpowerLogResponse {
  final String id;
  final int personCount;
  final double normalHoursPerPerson;
  final double normalHourlyRate;
  final double overtimeHourlyRate;
  final PersonnelRoleResponse? personnelRole;

  ManpowerLogResponse({
    required this.id,
    required this.personCount,
    required this.normalHoursPerPerson,
    required this.normalHourlyRate,
    required this.overtimeHourlyRate,
    this.personnelRole,
  });

  factory ManpowerLogResponse.fromJson(Map<String, dynamic> json) {
    try {
      return ManpowerLogResponse(
        id: json['id']?.toString() ?? '',
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
            ? PersonnelRoleResponse.fromJson(json['personnelRole'])
            : null,
      );
    } catch (e, stackTrace) {
      print('[ManpowerLogResponse] Error parsing JSON: $e');
      print('[ManpowerLogResponse] Stack trace: $stackTrace');
      print('[ManpowerLogResponse] JSON data: $json');
      rethrow;
    }
  }
}

class MaterialResponse {
  final String id;
  final String name;

  MaterialResponse({
    required this.id,
    required this.name,
  });

  factory MaterialResponse.fromJson(Map<String, dynamic> json) {
    return MaterialResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class MaterialUsageLogResponse {
  final String id;
  final double quantity;
  final double unitRate;
  final String remarks;
  final MaterialResponse? material;

  MaterialUsageLogResponse({
    required this.id,
    required this.quantity,
    required this.unitRate,
    required this.remarks,
    this.material,
  });

  factory MaterialUsageLogResponse.fromJson(Map<String, dynamic> json) {
    return MaterialUsageLogResponse(
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
      material: json['material'] != null
          ? MaterialResponse.fromJson(json['material'])
          : null,
    );
  }
}

class OtherCostResponse {
  final String id;
  final String costType;
  final double amount;
  final String description;
  final String? receiptNumber;
  final String? remarks;

  OtherCostResponse({
    required this.id,
    required this.costType,
    required this.amount,
    required this.description,
    this.receiptNumber,
    this.remarks,
  });

  factory OtherCostResponse.fromJson(Map<String, dynamic> json) {
    return OtherCostResponse(
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
}

class SPKResponse {
  final String id;
  final String spkNo;
  final String title;
  final String projectName;

  SPKResponse({
    required this.id,
    required this.spkNo,
    required this.title,
    required this.projectName,
  });

  factory SPKResponse.fromJson(Map<String, dynamic> json) {
    return SPKResponse(
      id: json['id']?.toString() ?? '',
      spkNo: json['spkNo']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
    );
  }

  // Property tambahan untuk kompatibilitas
  LocationResponse? get location => null;
}

// Class tambahan untuk kompatibilitas dengan code lama
class LocationResponse {
  final String id;
  final String name;

  LocationResponse({
    required this.id,
    required this.name,
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class UserResponse {
  final String id;
  final String username;
  final String fullName;
  final String? email;
  final String? role;

  UserResponse({
    required this.id,
    required this.username,
    required this.fullName,
    this.email,
    this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString(),
    );
  }
}
