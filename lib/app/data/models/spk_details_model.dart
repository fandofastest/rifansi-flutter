import 'package:get/get.dart';

class SpkDetails {
  final String id;
  final String spkNo;
  final String wapNo;
  final String title;
  final String projectName;
  final String date;
  final String contractor;
  final String workDescription;
  final Location location;
  final String startDate;
  final String endDate;
  final double budget;
  final List<DailyActivity> dailyActivities;
  final TotalProgress totalProgress;
  final String createdAt;
  final String updatedAt;

  SpkDetails({
    required this.id,
    required this.spkNo,
    required this.wapNo,
    required this.title,
    required this.projectName,
    required this.date,
    required this.contractor,
    required this.workDescription,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.dailyActivities,
    required this.totalProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpkDetails.fromJson(Map<String, dynamic> json) {
    return SpkDetails(
      id: json['id'] ?? '',
      spkNo: json['spkNo'] ?? '',
      wapNo: json['wapNo'] ?? '',
      title: json['title'] ?? '',
      projectName: json['projectName'] ?? '',
      date: json['date'] ?? '',
      contractor: json['contractor'] ?? '',
      workDescription: json['workDescription'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      dailyActivities: (json['dailyActivities'] as List?)
              ?.map((e) => DailyActivity.fromJson(e))
              .toList() ??
          [],
      totalProgress: TotalProgress.fromJson(json['totalProgress'] ?? {}),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Location {
  final String id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class DailyActivity {
  final String id;
  final String date;
  final String location;
  final String weather;
  final String status;
  final String workStartTime;
  final String workEndTime;
  final String createdBy;
  final String closingRemarks;
  final List<WorkItem> workItems;
  final Costs costs;

  DailyActivity({
    required this.id,
    required this.date,
    required this.location,
    required this.weather,
    required this.status,
    required this.workStartTime,
    required this.workEndTime,
    required this.createdBy,
    required this.closingRemarks,
    required this.workItems,
    required this.costs,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      weather: json['weather'] ?? '',
      status: json['status'] ?? '',
      workStartTime: json['workStartTime'] ?? '',
      workEndTime: json['workEndTime'] ?? '',
      createdBy: json['createdBy'] ?? '',
      closingRemarks: json['closingRemarks'] ?? '',
      workItems: (json['workItems'] as List?)
              ?.map((e) => WorkItem.fromJson(e))
              .toList() ??
          [],
      costs: Costs.fromJson(json['costs'] ?? {}),
    );
  }
}

class WorkItem {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String subCategoryId;
  final String unitId;
  final Category category;
  final SubCategory subCategory;
  final Unit unit;
  final Rates rates;
  final Volume boqVolume;
  final Volume dailyProgress;
  final Volume progressAchieved;
  final Volume actualQuantity;
  final Volume dailyCost;
  final String lastUpdatedAt;

  WorkItem({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.subCategoryId,
    required this.unitId,
    required this.category,
    required this.subCategory,
    required this.unit,
    required this.rates,
    required this.boqVolume,
    required this.dailyProgress,
    required this.progressAchieved,
    required this.actualQuantity,
    required this.dailyCost,
    required this.lastUpdatedAt,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? '',
      subCategoryId: json['subCategoryId'] ?? '',
      unitId: json['unitId'] ?? '',
      category: Category.fromJson(json['category'] ?? {}),
      subCategory: SubCategory.fromJson(json['subCategory'] ?? {}),
      unit: Unit.fromJson(json['unit'] ?? {}),
      rates: Rates.fromJson(json['rates'] ?? {}),
      boqVolume: Volume.fromJson(json['boqVolume'] ?? {}),
      dailyProgress: Volume.fromJson(json['dailyProgress'] ?? {}),
      progressAchieved: Volume.fromJson(json['progressAchieved'] ?? {}),
      actualQuantity: Volume.fromJson(json['actualQuantity'] ?? {}),
      dailyCost: Volume.fromJson(json['dailyCost'] ?? {}),
      lastUpdatedAt: json['lastUpdatedAt'] ?? '',
    );
  }
}

class Category {
  final String id;
  final String name;
  final String code;

  Category({required this.id, required this.name, required this.code});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class SubCategory {
  final String id;
  final String name;

  SubCategory({required this.id, required this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Unit {
  final String id;
  final String name;
  final String code;

  Unit({required this.id, required this.name, required this.code});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class Rates {
  final Rate nr;
  final Rate r;

  Rates({required this.nr, required this.r});

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      nr: Rate.fromJson(json['nr'] ?? {}),
      r: Rate.fromJson(json['r'] ?? {}),
    );
  }
}

class Rate {
  final double rate;
  final String description;

  Rate({required this.rate, required this.description});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      rate: (json['rate'] ?? 0).toDouble(),
      description: json['description'] ?? '',
    );
  }
}

class Volume {
  final double nr;
  final double r;

  Volume({required this.nr, required this.r});

  factory Volume.fromJson(Map<String, dynamic> json) {
    return Volume(
      nr: (json['nr'] ?? 0).toDouble(),
      r: (json['r'] ?? 0).toDouble(),
    );
  }
}

class Costs {
  final CostCategory materials;
  final CostCategory manpower;
  final CostCategory equipment;
  final CostCategory otherCosts;

  Costs({
    required this.materials,
    required this.manpower,
    required this.equipment,
    required this.otherCosts,
  });

  factory Costs.fromJson(Map<String, dynamic> json) {
    return Costs(
      materials: CostCategory.fromJson(json['materials'] ?? {}),
      manpower: CostCategory.fromJson(json['manpower'] ?? {}),
      equipment: CostCategory.fromJson(json['equipment'] ?? {}),
      otherCosts: CostCategory.fromJson(json['otherCosts'] ?? {}),
    );
  }
}

class CostCategory {
  final double totalCost;
  final List<CostItem> items;

  CostCategory({required this.totalCost, required this.items});

  factory CostCategory.fromJson(Map<String, dynamic> json) {
    return CostCategory(
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      items:
          (json['items'] as List?)?.map((e) => CostItem.fromJson(e)).toList() ??
              [],
    );
  }
}

class CostItem {
  final String? material;
  final double? quantity;
  final String? unit;
  final double? unitRate;
  final double? cost;
  final String? role;
  final int? numberOfWorkers;
  final int? workingHours;
  final double? hourlyRate;
  final Equipment? equipment;
  final double? fuelUsed;
  final double? fuelPrice;
  final String? description;

  CostItem({
    this.material,
    this.quantity,
    this.unit,
    this.unitRate,
    this.cost,
    this.role,
    this.numberOfWorkers,
    this.workingHours,
    this.hourlyRate,
    this.equipment,
    this.fuelUsed,
    this.fuelPrice,
    this.description,
  });

  factory CostItem.fromJson(Map<String, dynamic> json) {
    return CostItem(
      material: json['material'],
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'],
      unitRate: (json['unitRate'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
      role: json['role'],
      numberOfWorkers: json['numberOfWorkers'],
      workingHours: json['workingHours'],
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      equipment: json['equipment'] != null
          ? Equipment.fromJson(json['equipment'])
          : null,
      fuelUsed: (json['fuelUsed'] ?? 0).toDouble(),
      fuelPrice: (json['fuelPrice'] ?? 0).toDouble(),
      description: json['description'],
    );
  }
}

class Equipment {
  final String id;
  final String equipmentCode;
  final String plateOrSerialNo;
  final String equipmentType;
  final String? description;

  Equipment({
    required this.id,
    required this.equipmentCode,
    required this.plateOrSerialNo,
    required this.equipmentType,
    this.description,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] ?? '',
      equipmentCode: json['equipmentCode'] ?? '',
      plateOrSerialNo: json['plateOrSerialNo'] ?? '',
      equipmentType: json['equipmentType'] ?? '',
      description: json['description'],
    );
  }
}

class TotalProgress {
  final double percentage;
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;

  TotalProgress({
    required this.percentage,
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
  });

  factory TotalProgress.fromJson(Map<String, dynamic> json) {
    return TotalProgress(
      percentage: (json['percentage'] ?? 0).toDouble(),
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      totalSpent: (json['totalSpent'] ?? 0).toDouble(),
      remainingBudget: (json['remainingBudget'] ?? 0).toDouble(),
    );
  }
}
