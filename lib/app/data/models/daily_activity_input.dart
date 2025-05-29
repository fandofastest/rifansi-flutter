import 'package:hive/hive.dart';
import 'package:rifansi/app/data/models/daily_activity_response.dart';
import 'package:rifansi/app/data/models/spk_model.dart';
import 'package:rifansi/app/data/models/location_model.dart';
import 'package:get/get.dart';
import 'package:rifansi/app/data/providers/graphql_service.dart';

part 'daily_activity_input.g.dart';

@HiveType(typeId: 1)
class DailyActivity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String spkId;

  @HiveField(24)
  final SPKDetails? spkDetails;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String areaId;

  @HiveField(4)
  final String weather;

  @HiveField(5)
  final String status;

  @HiveField(6)
  final String workStartTime;

  @HiveField(7)
  final String workEndTime;

  @HiveField(8)
  final List<String> startImages;

  @HiveField(9)
  final List<String> finishImages;

  @HiveField(10)
  final String closingRemarks;

  @HiveField(11)
  final double progressPercentage;

  @HiveField(12)
  final List<ActivityDetail> activityDetails;

  @HiveField(13)
  final List<EquipmentLog> equipmentLogs;

  @HiveField(14)
  final List<ManpowerLog> manpowerLogs;

  @HiveField(15)
  final List<MaterialUsageLog> materialUsageLogs;

  @HiveField(16)
  final List<OtherCost> otherCosts;

  @HiveField(17)
  final String createdAt;

  @HiveField(18)
  final String updatedAt;

  @HiveField(19)
  final bool isSynced;

  @HiveField(20)
  final String localId;

  @HiveField(21)
  final DateTime lastSyncAttempt;

  @HiveField(22)
  final int syncRetryCount;

  @HiveField(23)
  final String? syncError;

  DailyActivity({
    this.id = '',
    required this.spkId,
    this.spkDetails,
    required this.date,
    required this.areaId,
    required this.weather,
    this.status = 'Draft',
    required this.workStartTime,
    required this.workEndTime,
    this.startImages = const [],
    this.finishImages = const [],
    required this.closingRemarks,
    this.progressPercentage = 0.0,
    required this.activityDetails,
    required this.equipmentLogs,
    required this.manpowerLogs,
    required this.materialUsageLogs,
    this.otherCosts = const [],
    String? createdAt,
    String? updatedAt,
    this.isSynced = false,
    String? localId,
    DateTime? lastSyncAttempt,
    this.syncRetryCount = 0,
    this.syncError,
  })  : this.createdAt = createdAt ?? DateTime.now().toIso8601String(),
        this.updatedAt = updatedAt ?? DateTime.now().toIso8601String(),
        this.localId =
            localId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        this.lastSyncAttempt = lastSyncAttempt ?? DateTime.now();

  Map<String, dynamic> toRequestJson() {
    return {
      "input": {
        "spkId": spkId,
        "date": date,
        "areaId": areaId,
        "weather": weather,
        "workStartTime": workStartTime,
        "workEndTime": workEndTime,
        "closingRemarks": closingRemarks,
        "activityDetails":
            activityDetails.map((detail) => detail.toRequestJson()).toList(),
        "equipmentLogs":
            equipmentLogs.map((log) => log.toRequestJson()).toList(),
        "manpowerLogs": manpowerLogs.map((log) => log.toRequestJson()).toList(),
        "materialUsageLogs":
            materialUsageLogs.map((log) => log.toRequestJson()).toList(),
        "otherCosts": otherCosts.map((cost) => cost.toRequestJson()).toList(),
      }
    };
  }

  DailyActivity copyWith({
    String? id,
    String? spkId,
    SPKDetails? spkDetails,
    String? date,
    String? areaId,
    String? weather,
    String? status,
    String? workStartTime,
    String? workEndTime,
    List<String>? startImages,
    List<String>? finishImages,
    String? closingRemarks,
    double? progressPercentage,
    List<ActivityDetail>? activityDetails,
    List<EquipmentLog>? equipmentLogs,
    List<ManpowerLog>? manpowerLogs,
    List<MaterialUsageLog>? materialUsageLogs,
    List<OtherCost>? otherCosts,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
    String? localId,
    DateTime? lastSyncAttempt,
    int? syncRetryCount,
    String? syncError,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      spkId: spkId ?? this.spkId,
      spkDetails: spkDetails ?? this.spkDetails,
      date: date ?? this.date,
      areaId: areaId ?? this.areaId,
      weather: weather ?? this.weather,
      status: status ?? this.status,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      startImages: startImages ?? this.startImages,
      finishImages: finishImages ?? this.finishImages,
      closingRemarks: closingRemarks ?? this.closingRemarks,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      activityDetails: activityDetails ?? this.activityDetails,
      equipmentLogs: equipmentLogs ?? this.equipmentLogs,
      manpowerLogs: manpowerLogs ?? this.manpowerLogs,
      materialUsageLogs: materialUsageLogs ?? this.materialUsageLogs,
      otherCosts: otherCosts ?? this.otherCosts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      syncRetryCount: syncRetryCount ?? this.syncRetryCount,
      syncError: syncError ?? this.syncError,
    );
  }

  DailyActivity toPending() {
    return copyWith(status: 'Pending');
  }

  DailyActivity toSynced(String serverId) {
    return copyWith(status: 'Submitted', id: serverId, isSynced: true);
  }

  DailyActivity toFailed(String error) {
    return copyWith(status: 'Failed', syncError: error);
  }

  factory DailyActivity.fromResponse(DailyActivityResponse response) {
    return DailyActivity(
      id: response.id,
      spkId: response.spkDetail?.id ?? '',
      date: response.date,
      areaId: '', // This needs to be set from elsewhere or persisted
      weather: response.weather,
      status: response.status,
      workStartTime: response.workStartTime,
      workEndTime: response.workEndTime,
      startImages: response.startImages,
      finishImages: response.finishImages,
      closingRemarks: response.closingRemarks,
      progressPercentage: response.progressPercentage,
      activityDetails: response.activityDetails.map((detail) {
        return ActivityDetail(
          id: detail.id,
          workItemId: detail.workItem?.id ?? '',
          actualQuantity: Quantity(
            nr: detail.actualQuantity.nr,
            r: detail.actualQuantity.r,
          ),
          status: detail.status,
          remarks: detail.remarks,
        );
      }).toList(),
      equipmentLogs: response.equipmentLogs.map((log) {
        return EquipmentLog(
          id: log.id,
          equipmentId: log.equipment?.id ?? '',
          fuelIn: log.fuelIn,
          fuelRemaining: log.fuelRemaining,
          workingHour: log.workingHour,
          isBrokenReported: log.isBrokenReported,
          remarks: log.remarks,
          hourlyRate: log.hourlyRate,
        );
      }).toList(),
      manpowerLogs: response.manpowerLogs.map((log) {
        return ManpowerLog(
          id: log.id,
          role: log.personnelRole?.id ?? '',
          personCount: log.personCount,
          hourlyRate: log.normalHourlyRate,
        );
      }).toList(),
      materialUsageLogs: response.materialUsageLogs.map((log) {
        return MaterialUsageLog(
          id: log.id,
          materialId: log.material?.id ?? '',
          quantity: log.quantity,
          unitRate: log.unitRate,
          remarks: log.remarks,
        );
      }).toList(),
      otherCosts: response.otherCosts.map((cost) {
        return OtherCost(
          id: cost.id,
          costType: cost.costType,
          amount: cost.amount,
          description: cost.description,
          receiptNumber: cost.receiptNumber,
          remarks: cost.remarks,
        );
      }).toList(),
      createdAt: response.createdAt,
      updatedAt: response.updatedAt,
    );
  }

  DailyActivityResponse toResponse() {
    final dummyUser = UserResponse(
      id: '',
      username: '',
      fullName: '',
    );

    SPKResponse spkResponse;
    if (spkDetails != null) {
      spkResponse = EnhancedSPKResponse(
          id: spkId,
          spkNo: spkDetails!.spkNo,
          title: spkDetails!.title,
          projectName: spkDetails!.projectName,
          customLocation: spkDetails!.location != null
              ? LocationResponse(
                  id: spkDetails!.location!.id,
                  name: spkDetails!.location!.name)
              : null);
    } else {
      spkResponse = SPKResponse(
        id: spkId,
        spkNo: '',
        title: 'SPK Draft',
        projectName: '',
      );
    }

    return DailyActivityResponse(
      id: this.id.isEmpty ? this.localId : this.id,
      date: this.date,
      location: this.areaId,
      weather: this.weather,
      status: this.status,
      workStartTime: this.workStartTime,
      workEndTime: this.workEndTime,
      startImages: this.startImages,
      finishImages: this.finishImages,
      closingRemarks: this.closingRemarks,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      progressPercentage: this.progressPercentage,
      activityDetails: this.activityDetails.map((detail) {
        final dummyWorkItem = WorkItemResponse(
          id: detail.workItemId,
          name: '',
        );

        return ActivityDetailResponse(
          id: detail.id,
          actualQuantity: QuantityResponse(
            nr: detail.actualQuantity.nr,
            r: detail.actualQuantity.r,
          ),
          status: detail.status,
          remarks: detail.remarks,
          workItem: dummyWorkItem,
        );
      }).toList(),
      equipmentLogs: this.equipmentLogs.map((log) {
        final dummyEquipment = EquipmentResponse(
          id: log.equipmentId,
          equipmentCode: '',
          equipmentType: '',
          plateOrSerialNo: '',
          defaultOperator: '',
        );

        return EquipmentLogResponse(
          id: log.id,
          fuelIn: log.fuelIn,
          fuelRemaining: log.fuelRemaining,
          workingHour: log.workingHour,
          isBrokenReported: log.isBrokenReported,
          remarks: log.remarks,
          equipment: dummyEquipment,
          hourlyRate: log.hourlyRate,
        );
      }).toList(),
      manpowerLogs: this.manpowerLogs.map((log) {
        final dummyRole = PersonnelRoleResponse(
          id: log.role,
          roleName: '',
        );

        return ManpowerLogResponse(
          id: log.id,
          personCount: log.personCount,
          normalHoursPerPerson: 0,
          normalHourlyRate: log.hourlyRate,
          overtimeHourlyRate: 0,
          personnelRole: dummyRole,
        );
      }).toList(),
      materialUsageLogs: this.materialUsageLogs.map((log) {
        final dummyMaterial = MaterialResponse(
          id: log.materialId,
          name: '',
        );

        return MaterialUsageLogResponse(
          id: log.id,
          quantity: log.quantity,
          unitRate: log.unitRate,
          remarks: log.remarks,
          material: dummyMaterial,
        );
      }).toList(),
      otherCosts: this.otherCosts.map((cost) {
        return OtherCostResponse(
          id: cost.id,
          costType: cost.costType,
          amount: cost.amount,
          description: cost.description,
          receiptNumber: cost.receiptNumber,
          remarks: cost.remarks,
        );
      }).toList(),
      spkDetail: spkResponse,
      userDetail: dummyUser,
    );
  }

  static Future<SPKDetails> fetchSPKDetails(String spkId) async {
    try {
      final graphQLService = Get.find<GraphQLService>();
      final spk = await graphQLService.fetchSPKById(spkId);
      return SPKDetails.fromSpk(spk);
    } catch (e) {
      print('[DailyActivity] Error fetching SPK details: $e');
      throw Exception('Gagal mengambil detail SPK: $e');
    }
  }

  Future<DailyActivity> updateSPKDetails() async {
    try {
      final spkDetails = await fetchSPKDetails(spkId);
      return copyWith(spkDetails: spkDetails);
    } catch (e) {
      print('[DailyActivity] Error updating SPK details: $e');
      throw Exception('Gagal memperbarui detail SPK: $e');
    }
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

  Map<String, dynamic> toRequestJson() {
    return {
      "nr": nr,
      "r": r,
    };
  }
}

@HiveType(typeId: 3)
class ActivityDetail {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String workItemId;

  @HiveField(2)
  final Quantity actualQuantity;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final String remarks;

  ActivityDetail({
    this.id = '',
    required this.workItemId,
    required this.actualQuantity,
    required this.status,
    required this.remarks,
  });

  Map<String, dynamic> toRequestJson() {
    return {
      "workItemId": workItemId,
      "actualQuantity": actualQuantity.toRequestJson(),
      "status": status,
      "remarks": remarks,
    };
  }
}

@HiveType(typeId: 4)
class EquipmentLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String equipmentId;

  @HiveField(2)
  final double fuelIn;

  @HiveField(3)
  final double fuelRemaining;

  @HiveField(4)
  final double workingHour;

  @HiveField(5)
  final bool isBrokenReported;

  @HiveField(6)
  final String remarks;

  @HiveField(7)
  final double hourlyRate;

  EquipmentLog({
    this.id = '',
    required this.equipmentId,
    required this.fuelIn,
    required this.fuelRemaining,
    required this.workingHour,
    required this.isBrokenReported,
    required this.remarks,
    required this.hourlyRate,
  });

  Map<String, dynamic> toRequestJson() {
    return {
      "equipmentId": equipmentId,
      "fuelIn": fuelIn,
      "fuelRemaining": fuelRemaining,
      "workingHour": workingHour,
      "isBrokenReported": isBrokenReported,
      "remarks": remarks,
      "hourlyRate": hourlyRate,
    };
  }
}

@HiveType(typeId: 5)
class ManpowerLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String role;

  @HiveField(2)
  final int personCount;

  @HiveField(3)
  final double hourlyRate;

  ManpowerLog({
    this.id = '',
    required this.role,
    required this.personCount,
    required this.hourlyRate,
  });

  Map<String, dynamic> toRequestJson() {
    return {
      "role": role,
      "personCount": personCount,
      "hourlyRate": hourlyRate,
    };
  }
}

@HiveType(typeId: 6)
class MaterialUsageLog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String materialId;

  @HiveField(2)
  final double quantity;

  @HiveField(3)
  final double unitRate;

  @HiveField(4)
  final String remarks;

  MaterialUsageLog({
    this.id = '',
    required this.materialId,
    required this.quantity,
    required this.unitRate,
    required this.remarks,
  });

  Map<String, dynamic> toRequestJson() {
    return {
      "materialId": materialId,
      "quantity": quantity,
      "unitRate": unitRate,
      "remarks": remarks,
    };
  }
}

@HiveType(typeId: 7)
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
    this.id = '',
    required this.costType,
    required this.amount,
    required this.description,
    this.receiptNumber,
    this.remarks,
  });

  Map<String, dynamic> toRequestJson() {
    return {
      "costType": costType,
      "amount": amount,
      "description": description,
      "receiptNumber": receiptNumber,
      "remarks": remarks,
    };
  }
}

@HiveType(typeId: 8)
class SPKDetails {
  @HiveField(0)
  final String spkNo;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String projectName;

  @HiveField(3)
  final Location? location;

  SPKDetails({
    required this.spkNo,
    required this.title,
    required this.projectName,
    this.location,
  });

  factory SPKDetails.fromSpk(Spk spk) {
    return SPKDetails(
      spkNo: spk.spkNo,
      title: spk.title,
      projectName: spk.projectName,
      location: spk.location,
    );
  }
}

class EnhancedSPKResponse extends SPKResponse {
  final LocationResponse? customLocation;

  EnhancedSPKResponse({
    required String id,
    required String spkNo,
    required String title,
    required String projectName,
    this.customLocation,
  }) : super(
          id: id,
          spkNo: spkNo,
          title: title,
          projectName: projectName,
        );

  @override
  LocationResponse? get location => customLocation;
}
