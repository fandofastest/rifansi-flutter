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
    print('========== DEBUG: initializeFromWorkItems ==========');
    
    // STORE PROGRESS DATA FOR ITEMS THAT ACTUALLY HAVE PROGRESS
    // 1. Collect workItems that have progress
    List<WorkProgress> itemsWithProgress = [];
    for (var progress in workProgresses) {
      if (progress.progressVolumeR > 0 || progress.progressVolumeNR > 0) {
        print('Found item with progress: ${progress.workItemName} (ID: ${progress.workItemId}) - R:${progress.progressVolumeR}, NR:${progress.progressVolumeNR}');
        itemsWithProgress.add(progress);
      }
    }
    
    print('Total items with progress: ${itemsWithProgress.length}');
    
    // Clear existing list
    workProgresses.clear();
    
    // REBUILD THE LIST WITH NEW WORK ITEMS
    // 2. For each workItem in the new list
    print('Processing ${workItems.length} work items from API');
    
    for (int i = 0; i < workItems.length; i++) {
      var workItem = workItems[i];
      final workItemId = workItem['workItemId'] ?? workItem['id'] ?? '';
      final workItemName = workItem['workItem']?['name'] ?? workItem['name'] ?? 'Unknown';
      
      print('Processing item $i: ID=$workItemId, Name=$workItemName');
      
      // Check if this workItem had progress before
      bool hasProgress = false;
      WorkProgress? existingProgress;
      
      for (var item in itemsWithProgress) {
        if (item.workItemId == workItemId) {
          hasProgress = true;
          existingProgress = item;
          break;
        }
      }
      
      if (hasProgress && existingProgress != null) {
        print(' - FOUND progress data for this item: R=${existingProgress.progressVolumeR}, NR=${existingProgress.progressVolumeNR}');
        // Create new WorkProgress with data from API but keep progress values
        workProgresses.add(WorkProgress(
          workItemId: workItemId,
          workItemName: workItem['workItem']?['name'] ?? workItem['name'] ?? '',
          unit: workItem['workItem']?['unit']?['name'] ?? workItem['unit'] ?? '',
          boqVolumeR: (workItem['boqVolume']?['r'] as num?)?.toDouble() ?? 0.0,
          boqVolumeNR: (workItem['boqVolume']?['nr'] as num?)?.toDouble() ?? 0.0,
          // Use existing progress values
          progressVolumeR: existingProgress.progressVolumeR,
          progressVolumeNR: existingProgress.progressVolumeNR,
          workingDays: existingProgress.workingDays,
          rateR: (workItem['rates']?['r']?['rate'] as num?)?.toDouble() ?? 0.0,
          rateNR: (workItem['rates']?['nr']?['rate'] as num?)?.toDouble() ?? 0.0,
          dailyTargetR: (workItem['dailyTarget']?['r'] as num?)?.toDouble() ?? 0.0,
          dailyTargetNR: (workItem['dailyTarget']?['nr'] as num?)?.toDouble() ?? 0.0,
          rateDescriptionR: workItem['rates']?['r']?['description'] ?? '',
          rateDescriptionNR: workItem['rates']?['nr']?['description'] ?? '',
          remarks: existingProgress.remarks
        ));
      } else {
        // Item doesn't have any previous progress, create with zero progress
        print(' - NO progress data found, adding with zero progress');
        workProgresses.add(WorkProgress.fromWorkItem(workItem));
      }
    }
    print('\nFinished processing. Final items: ${workProgresses.length}');
    int itemsWithProgressCount = 0;
    
    for (int i = 0; i < workProgresses.length; i++) {
      var progress = workProgresses[i];
      if (progress.progressVolumeR > 0 || progress.progressVolumeNR > 0) {
        itemsWithProgressCount++;
        print('Final item $i: ID=${progress.workItemId}, Name=${progress.workItemName} HAS PROGRESS R=${progress.progressVolumeR}, NR=${progress.progressVolumeNR}');
      }
    }
    
    print('Total items with progress after processing: $itemsWithProgressCount');
    print('========== END DEBUG ==========');
    
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
