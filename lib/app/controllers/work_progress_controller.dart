import 'package:get/get.dart';
import '../data/models/work_progress_model.dart';
import 'dart:convert';
import '../controllers/add_work_report_controller.dart';
import '../controllers/material_controller.dart';
import '../controllers/other_cost_controller.dart';

class WorkProgressController extends GetxController {
  final workProgresses = <WorkProgress>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;
  final totalProgress = 0.0.obs;
  final totalValue = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Observe perubahan pada workProgresses
    ever(workProgresses, (_) {
      calculateTotalProgress();
    });
  }

  void calculateTotalProgress() {
    if (workProgresses.isEmpty) {
      totalProgress.value = 0.0;
      totalValue.value = 0.0;
      return;
    }

    double totalWeightedProgress = 0.0;
    final totalBoqValue = getTotalBOQValue();

    if (totalBoqValue > 0) {
      for (var progress in workProgresses) {
        // Hitung nilai total BOQ untuk item ini
        final itemValue = (progress.boqVolumeR * progress.rateR) +
            (progress.boqVolumeNR * progress.rateNR);

        if (itemValue > 0) {
          // Hitung progress tertimbang berdasarkan nilai
          final weightedProgress =
              progress.totalProgressPercentage * (itemValue / totalBoqValue);
          totalWeightedProgress += weightedProgress;
        }
      }
    }

    totalProgress.value = totalWeightedProgress;
    totalValue.value = getTotalProgressValue();
  }

  void initializeFromWorkItems(List<Map<String, dynamic>> workItems) {
    workProgresses.clear();
    for (var workItem in workItems) {
      workProgresses.add(WorkProgress.fromWorkItem(workItem));
    }
    calculateTotalProgress();
  }

  void updateProgressR(int index, double progressVolume, {String? remarks}) {
    if (index >= 0 && index < workProgresses.length) {
      final progress = workProgresses[index];
      workProgresses[index] = WorkProgress(
        workItemId: progress.workItemId,
        workItemName: progress.workItemName,
        unit: progress.unit,
        boqVolumeR: progress.boqVolumeR,
        boqVolumeNR: progress.boqVolumeNR,
        progressVolumeR: progressVolume,
        progressVolumeNR: progress.progressVolumeNR,
        workingDays: progress.workingDays,
        rateR: progress.rateR,
        rateNR: progress.rateNR,
        dailyTargetR: progress.dailyTargetR,
        dailyTargetNR: progress.dailyTargetNR,
        rateDescriptionR: progress.rateDescriptionR,
        rateDescriptionNR: progress.rateDescriptionNR,
        remarks: remarks ?? progress.remarks,
      );
      calculateTotalProgress();
    }
  }

  void updateProgressNR(int index, double progressVolume, {String? remarks}) {
    if (index >= 0 && index < workProgresses.length) {
      final progress = workProgresses[index];
      workProgresses[index] = WorkProgress(
        workItemId: progress.workItemId,
        workItemName: progress.workItemName,
        unit: progress.unit,
        boqVolumeR: progress.boqVolumeR,
        boqVolumeNR: progress.boqVolumeNR,
        progressVolumeR: progress.progressVolumeR,
        progressVolumeNR: progressVolume,
        workingDays: progress.workingDays,
        rateR: progress.rateR,
        rateNR: progress.rateNR,
        dailyTargetR: progress.dailyTargetR,
        dailyTargetNR: progress.dailyTargetNR,
        rateDescriptionR: progress.rateDescriptionR,
        rateDescriptionNR: progress.rateDescriptionNR,
        remarks: remarks ?? progress.remarks,
      );
      calculateTotalProgress();
    }
  }

  void updateRemarks(int index, String remarks) {
    if (index >= 0 && index < workProgresses.length) {
      final progress = workProgresses[index];
      workProgresses[index] = WorkProgress(
        workItemId: progress.workItemId,
        workItemName: progress.workItemName,
        unit: progress.unit,
        boqVolumeR: progress.boqVolumeR,
        boqVolumeNR: progress.boqVolumeNR,
        progressVolumeR: progress.progressVolumeR,
        progressVolumeNR: progress.progressVolumeNR,
        workingDays: progress.workingDays,
        rateR: progress.rateR,
        rateNR: progress.rateNR,
        dailyTargetR: progress.dailyTargetR,
        dailyTargetNR: progress.dailyTargetNR,
        rateDescriptionR: progress.rateDescriptionR,
        rateDescriptionNR: progress.rateDescriptionNR,
        remarks: remarks,
      );
    }
  }

  double get totalProgressPercentage => totalProgress.value;

  // Hitung total nilai BOQ
  double getTotalBOQValue() {
    return workProgresses.fold(
        0.0,
        (sum, progress) =>
            sum +
            (progress.boqVolumeR * progress.rateR) +
            (progress.boqVolumeNR * progress.rateNR));
  }

  // Hitung total nilai progress hari ini
  double getTotalProgressValue() {
    return workProgresses.fold(
        0.0, (sum, progress) => sum + progress.totalProgressValue);
  }

  bool get isAllProgressFilled {
    return workProgresses.every((progress) {
      if (progress.dailyTargetR > 0 && progress.progressVolumeR <= 0)
        return false;
      if (progress.dailyTargetNR > 0 && progress.progressVolumeNR <= 0)
        return false;
      return true;
    });
  }

  // Method untuk preview data dalam format JSON
  void previewProgressData() {
    final reportController = Get.find<AddWorkReportController>();
    final materialController = Get.find<MaterialController>();
    final otherCostController = Get.find<OtherCostController>();

    final input = {
      "spkId": reportController.selectedSpk.value?.id ?? '',
      "date": reportController.reportDate.value.toIso8601String().split('T')[0],
      "areaId": reportController.selectedSpk.value?.location?.id ?? '',
      "workStartTime":
          reportController.workStartTime.value.toUtc().toIso8601String(),
      "workEndTime":
          reportController.workEndTime.value?.toUtc().toIso8601String() ?? '',
      "closingRemarks": reportController.remarks.value,
      "startImages":
          reportController.startPhotos.map((p) => p.accessUrl).toList(),
      "finishImages":
          reportController.endPhotos.map((p) => p.accessUrl).toList(),
      "activityDetails": workProgresses
          .map((p) => {
                "workItemId": p.workItemId,
                "actualQuantity": {
                  "nr": p.progressVolumeNR ?? 0.0,
                  "r": p.progressVolumeR ?? 0.0,
                },
                "status": (p.progressVolumeR >= (p.dailyTargetR ?? 0.0) &&
                        p.progressVolumeNR >= (p.dailyTargetNR ?? 0.0))
                    ? 'Completed'
                    : 'In Progress',
                "remarks": p.remarks ?? '',
              })
          .toList(),
      "equipmentLogs": reportController.selectedEquipment
          .map((e) => {
                "equipmentId": e.equipment.id,
                "fuelIn": e.fuelIn ?? 0.0,
                "fuelRemaining": e.fuelRemaining ?? 0.0,
                "workingHour": e.workingHours ?? 0.0,
                "hourlyRate": e.selectedContract?.rentalRatePerDay ?? 0.0,
                "isBrokenReported": e.isBrokenReported ?? false,
                "remarks": e.remarks ?? '',
              })
          .toList(),
      "manpowerLogs": reportController.selectedManpower
          .map((m) => {
                "role": m.personnelRole.id,
                "personCount": m.personCount ?? 0,
                "hourlyRate": m.normalHourlyRate ?? 0.0,
              })
          .toList(),
      "materialUsageLogs": materialController.selectedMaterials
          .map((m) => {
                "materialId": m.material.id,
                "quantity": m.quantity ?? 0.0,
                "unitRate": m.material.unitRate ?? 0.0,
                "remarks": m.remarks ?? '',
              })
          .toList(),
      "otherCosts": otherCostController.otherCosts
          .map((cost) => {
                "costType": cost.costType,
                "amount": cost.amount,
                "remarks": cost.remarks ?? '',
              })
          .toList(),
    };

    final previewData = {"input": input};
    final encoder = JsonEncoder.withIndent('  ');
    print('=== PREVIEW DATA YANG AKAN DIKIRIM ===');
    print(encoder.convert(previewData));
    print('=== END PREVIEW ===');
  }
}
