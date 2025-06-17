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
  final String? rejectionReason;
  final AreaResponse? area;
  final bool isApproved;
  final UserResponse? approvedBy;
  final String? approvedAt;
  final double? budgetUsage;

  // Properti tambahan untuk kompatibilitas dengan kode existing
  String get spkId => spkDetail?.id ?? '';
  String get areaId => area?.id ?? '';

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
    this.rejectionReason,
    this.area,
    required this.isApproved,
    this.approvedBy,
    this.approvedAt,
    this.budgetUsage,
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
        rejectionReason: json['rejectionReason']?.toString(),
        area: json['area'] != null ? AreaResponse.fromJson(json['area']) : null,
        isApproved: json['isApproved'] as bool? ?? false,
        approvedBy: json['approvedBy'] != null
            ? UserResponse.fromJson(json['approvedBy'])
            : null,
        approvedAt: json['approvedAt']?.toString(),
        budgetUsage: json['budgetUsage'] != null
            ? json['budgetUsage'] is int
                ? (json['budgetUsage'] as int).toDouble()
                : json['budgetUsage'] is double
                    ? json['budgetUsage']
                    : 0.0
            : null,
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
      // === DEBUG LOGGING RAW JSON ===
      print('[RATE JSON DEBUG] === RAW JSON for ActivityDetail ===');
      print('[RATE JSON DEBUG] Full JSON: $json');
      print('[RATE JSON DEBUG] Available keys: ${json.keys.toList()}');
      print('[RATE JSON DEBUG] rateR value: ${json['rateR']} (type: ${json['rateR'].runtimeType})');
      print('[RATE JSON DEBUG] rateNR value: ${json['rateNR']} (type: ${json['rateNR'].runtimeType})');
      print('[RATE JSON DEBUG] totalProgressValue: ${json['totalProgressValue']} (type: ${json['totalProgressValue'].runtimeType})');
      print('[RATE JSON DEBUG] workItem: ${json['workItem']}');
      if (json['workItem'] != null) {
        print('[RATE JSON DEBUG] workItem keys: ${(json['workItem'] as Map).keys.toList()}');
        // Debug rate location
        final workItem = json['workItem'] as Map<String, dynamic>;
        if (workItem['rates'] != null) {
          print('[RATE JSON DEBUG] workItem.rates: ${workItem['rates']}');
          final rates = workItem['rates'] as Map<String, dynamic>;
          print('[RATE JSON DEBUG] rates.nr: ${rates['nr']}');
          print('[RATE JSON DEBUG] rates.r: ${rates['r']}');
          if (rates['nr'] != null) {
            print('[RATE JSON DEBUG] rates.nr.rate: ${rates['nr']['rate']}');
          }
          if (rates['r'] != null) {
            print('[RATE JSON DEBUG] rates.r.rate: ${rates['r']['rate']}');
          }
        }
      }
      print('[RATE JSON DEBUG] actualQuantity: ${json['actualQuantity']}');
      print('[RATE JSON DEBUG] boqVolumeR: ${json['boqVolumeR']}');
      print('[RATE JSON DEBUG] boqVolumeNR: ${json['boqVolumeNR']}');
      print('[RATE JSON DEBUG] ==========================================');
      
      // Extract rates from workItem.rates if available
      double rateNR = 0.0;
      double rateR = 0.0;
      String? rateDescriptionNR;
      String? rateDescriptionR;
      
      if (json['workItem'] != null) {
        final workItem = json['workItem'] as Map<String, dynamic>;
        if (workItem['rates'] != null) {
          final rates = workItem['rates'] as Map<String, dynamic>;
          if (rates['nr'] != null) {
            final nrRate = rates['nr'] as Map<String, dynamic>;
            rateNR = _parseDouble(nrRate['rate']) ?? 0.0;
            rateDescriptionNR = nrRate['description']?.toString();
          }
          if (rates['r'] != null) {
            final rRate = rates['r'] as Map<String, dynamic>;
            rateR = _parseDouble(rRate['rate']) ?? 0.0;
            rateDescriptionR = rRate['description']?.toString();
          }
        }
      }
      
      print('[RATE JSON DEBUG] Extracted rateNR: $rateNR');
      print('[RATE JSON DEBUG] Extracted rateR: $rateR');
      print('[RATE JSON DEBUG] Extracted rateDescriptionNR: $rateDescriptionNR');
      print('[RATE JSON DEBUG] Extracted rateDescriptionR: $rateDescriptionR');
      
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
        rateR: rateR,  // Use extracted rate
        rateNR: rateNR,  // Use extracted rate
        rateDescriptionR: rateDescriptionR,  // Use extracted description
        rateDescriptionNR: rateDescriptionNR,  // Use extracted description
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
    // Debug untuk rate parsing
    if (value.toString().contains('rate') || value != null) {
      print('[PARSE DEBUG] Parsing value: $value (type: ${value.runtimeType})');
    }
    
    if (value == null) {
      print('[PARSE DEBUG] Value is null, returning 0.0');
      return 0.0;
    }
    if (value is int) {
      final result = value.toDouble();
      print('[PARSE DEBUG] Int value $value converted to double: $result');
      return result;
    }
    if (value is double) {
      print('[PARSE DEBUG] Already double: $value');
      return value;
    }
    if (value is String) {
      try {
        final result = double.parse(value);
        print('[PARSE DEBUG] String "$value" parsed to double: $result');
        return result;
      } catch (e) {
        print('[PARSE DEBUG] Failed to parse string "$value" to double, returning 0.0. Error: $e');
        return 0.0;
      }
    }
    print('[PARSE DEBUG] Unknown type ${value.runtimeType} for value $value, returning 0.0');
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
  final double rentalRatePerDay;
  final double fuelPrice;

  EquipmentLogResponse({
    required this.id,
    required this.fuelIn,
    required this.fuelRemaining,
    required this.workingHour,
    required this.isBrokenReported,
    required this.remarks,
    this.equipment,
    required this.hourlyRate,
    this.rentalRatePerDay = 0.0,
    this.fuelPrice = 0.0,
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
  final double workingHours;

  ManpowerLogResponse({
    required this.id,
    required this.personCount,
    required this.normalHoursPerPerson,
    required this.normalHourlyRate,
    required this.overtimeHourlyRate,
    this.personnelRole,
    this.workingHours = 0.0,
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
        normalHourlyRate: json['hourlyRate'] != null
            ? json['hourlyRate'] is int
                ? (json['hourlyRate'] as int).toDouble()
                : json['hourlyRate'] is double
                    ? json['hourlyRate']
                    : 0.0
            : json['normalHourlyRate'] != null
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
        workingHours: json['workingHours'] != null
            ? json['workingHours'] is int
                ? (json['workingHours'] as int).toDouble()
                : json['workingHours'] is double
                    ? json['workingHours']
                    : 0.0
            : 0.0,
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
  final String wapNo;
  final String title;
  final String projectName;
  final String contractor;
  final double budget;
  final String startDate;
  final String endDate;
  final String workDescription;
  final String date;
  final LocationResponse? location;

  SPKResponse({
    required this.id,
    required this.spkNo,
    required this.wapNo,
    required this.title,
    required this.projectName,
    required this.contractor,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.workDescription,
    required this.date,
    this.location,
  });

  factory SPKResponse.fromJson(Map<String, dynamic> json) {
    return SPKResponse(
      id: json['id']?.toString() ?? '',
      spkNo: json['spkNo']?.toString() ?? '',
      wapNo: json['wapNo']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      contractor: json['contractor']?.toString() ?? '',
      budget: json['budget'] != null
          ? json['budget'] is int
              ? (json['budget'] as int).toDouble()
              : json['budget'] is double
                  ? json['budget']
                  : 0.0
          : 0.0,
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      workDescription: json['workDescription']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      location: json['location'] != null
          ? LocationResponse.fromJson(json['location'])
          : null,
    );
  }
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
