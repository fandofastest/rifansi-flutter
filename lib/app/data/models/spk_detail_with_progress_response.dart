class SpkDetailWithProgressResponse {
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
  final int budget;
  final List<DailyActivity> dailyActivities;
  final TotalProgress totalProgress;
  final String createdAt;
  final String updatedAt;

  SpkDetailWithProgressResponse({
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

  factory SpkDetailWithProgressResponse.fromJson(Map<String, dynamic> json) {
    return SpkDetailWithProgressResponse(
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
      budget: json['budget'] ?? 0,
      dailyActivities: (json['dailyActivities'] as List<dynamic>?)
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
      workItems: (json['workItems'] as List<dynamic>?)
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
  final BoqVolume boqVolume;
  final DailyProgress dailyProgress;
  final ProgressAchieved progressAchieved;
  final ActualQuantity actualQuantity;
  final DailyCost dailyCost;
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
      boqVolume: BoqVolume.fromJson(json['boqVolume'] ?? {}),
      dailyProgress: DailyProgress.fromJson(json['dailyProgress'] ?? {}),
      progressAchieved:
          ProgressAchieved.fromJson(json['progressAchieved'] ?? {}),
      actualQuantity: ActualQuantity.fromJson(json['actualQuantity'] ?? {}),
      dailyCost: DailyCost.fromJson(json['dailyCost'] ?? {}),
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

class BoqVolume {
  final double nr;
  final double r;

  BoqVolume({required this.nr, required this.r});

  factory BoqVolume.fromJson(Map<String, dynamic> json) {
    return BoqVolume(
      nr: (json['nr'] ?? 0).toDouble(),
      r: (json['r'] ?? 0).toDouble(),
    );
  }
}

class DailyProgress {
  final double nr;
  final double r;

  DailyProgress({required this.nr, required this.r});

  factory DailyProgress.fromJson(Map<String, dynamic> json) {
    return DailyProgress(
      nr: (json['nr'] ?? 0).toDouble(),
      r: (json['r'] ?? 0).toDouble(),
    );
  }
}

class ProgressAchieved {
  final double nr;
  final double r;

  ProgressAchieved({required this.nr, required this.r});

  factory ProgressAchieved.fromJson(Map<String, dynamic> json) {
    return ProgressAchieved(
      nr: (json['nr'] ?? 0).toDouble(),
      r: (json['r'] ?? 0).toDouble(),
    );
  }
}

class ActualQuantity {
  final double nr;
  final double r;

  ActualQuantity({required this.nr, required this.r});

  factory ActualQuantity.fromJson(Map<String, dynamic> json) {
    return ActualQuantity(
      nr: (json['nr'] ?? 0).toDouble(),
      r: (json['r'] ?? 0).toDouble(),
    );
  }
}

class DailyCost {
  final double nr;
  final double r;

  DailyCost({required this.nr, required this.r});

  factory DailyCost.fromJson(Map<String, dynamic> json) {
    return DailyCost(
      nr: (json['nr'] ?? 0).toDouble(),
      r: (json['r'] ?? 0).toDouble(),
    );
  }
}

class Costs {
  final MaterialCosts materials;
  final ManpowerCosts manpower;
  final EquipmentCosts equipment;
  final OtherCosts otherCosts;

  Costs({
    required this.materials,
    required this.manpower,
    required this.equipment,
    required this.otherCosts,
  });

  factory Costs.fromJson(Map<String, dynamic> json) {
    return Costs(
      materials: MaterialCosts.fromJson(json['materials'] ?? {}),
      manpower: ManpowerCosts.fromJson(json['manpower'] ?? {}),
      equipment: EquipmentCosts.fromJson(json['equipment'] ?? {}),
      otherCosts: OtherCosts.fromJson(json['otherCosts'] ?? {}),
    );
  }
}

class MaterialCosts {
  final double totalCost;
  final List<MaterialItem> items;

  MaterialCosts({required this.totalCost, required this.items});

  factory MaterialCosts.fromJson(Map<String, dynamic> json) {
    return MaterialCosts(
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MaterialItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MaterialItem {
  final String material;
  final double quantity;
  final String unit;
  final double unitRate;
  final double cost;

  MaterialItem({
    required this.material,
    required this.quantity,
    required this.unit,
    required this.unitRate,
    required this.cost,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      material: json['material'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      unitRate: (json['unitRate'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
    );
  }
}

class ManpowerCosts {
  final double totalCost;
  final List<ManpowerItem> items;

  ManpowerCosts({required this.totalCost, required this.items});

  factory ManpowerCosts.fromJson(Map<String, dynamic> json) {
    return ManpowerCosts(
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ManpowerItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ManpowerItem {
  final String role;
  final int numberOfWorkers;
  final double workingHours;
  final double hourlyRate;
  final double cost;

  ManpowerItem({
    required this.role,
    required this.numberOfWorkers,
    required this.workingHours,
    required this.hourlyRate,
    required this.cost,
  });

  factory ManpowerItem.fromJson(Map<String, dynamic> json) {
    return ManpowerItem(
      role: json['role'] ?? '',
      numberOfWorkers: json['numberOfWorkers'] ?? 0,
      workingHours: (json['workingHours'] ?? 0).toDouble(),
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
    );
  }
}

class EquipmentCosts {
  final double totalCost;
  final List<EquipmentItem> items;

  EquipmentCosts({required this.totalCost, required this.items});

  factory EquipmentCosts.fromJson(Map<String, dynamic> json) {
    return EquipmentCosts(
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => EquipmentItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EquipmentItem {
  final Equipment equipment;
  final double workingHours;
  final double hourlyRate;
  final double fuelUsed;
  final double fuelPrice;
  final double cost;

  EquipmentItem({
    required this.equipment,
    required this.workingHours,
    required this.hourlyRate,
    required this.fuelUsed,
    required this.fuelPrice,
    required this.cost,
  });

  factory EquipmentItem.fromJson(Map<String, dynamic> json) {
    return EquipmentItem(
      equipment: Equipment.fromJson(json['equipment'] ?? {}),
      workingHours: (json['workingHours'] ?? 0).toDouble(),
      hourlyRate: (json['hourlyRate'] ?? 0).toDouble(),
      fuelUsed: (json['fuelUsed'] ?? 0).toDouble(),
      fuelPrice: (json['fuelPrice'] ?? 0).toDouble(),
      cost: (json['cost'] ?? 0).toDouble(),
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

class OtherCosts {
  final double totalCost;
  final List<dynamic> items;

  OtherCosts({required this.totalCost, required this.items});

  factory OtherCosts.fromJson(Map<String, dynamic> json) {
    return OtherCosts(
      totalCost: (json['totalCost'] ?? 0).toDouble(),
      items: json['items'] ?? [],
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
