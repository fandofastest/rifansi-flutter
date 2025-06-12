import 'area_model.dart';

class FuelPrice {
  final String id;
  final double pricePerLiter;
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
          ? (json['pricePerLiter'] is int
              ? (json['pricePerLiter'] as int).toDouble()
              : json['pricePerLiter'] is double
                  ? json['pricePerLiter']
                  : double.tryParse(json['pricePerLiter'].toString()) ?? 0.0)
          : 0.0,
      effectiveDate: json['effectiveDate'] != null
          ? (json['effectiveDate'] is int
              ? json['effectiveDate']
              : int.tryParse(json['effectiveDate'].toString()) ?? 0)
          : 0,
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

class Equipment {
  final String id;
  final String equipmentCode;
  final String? plateOrSerialNo;
  final String equipmentType;
  final String? defaultOperator;
  final Area? area;
  final FuelPrice? currentFuelPrice;
  final String? fuelType;
  final int? year;
  final String? serviceStatus;
  final String? description;
  final List<EquipmentContract> contracts;
  final String createdAt;
  final String updatedAt;

  Equipment({
    required this.id,
    required this.equipmentCode,
    this.plateOrSerialNo,
    required this.equipmentType,
    this.defaultOperator,
    this.area,
    this.currentFuelPrice,
    this.fuelType,
    this.year,
    this.serviceStatus,
    this.description,
    required this.contracts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    List<EquipmentContract> contractsList = [];
    if (json['contracts'] != null) {
      contractsList = (json['contracts'] as List)
          .map((contract) => EquipmentContract.fromJson(contract))
          .toList();
    }

    return Equipment(
      id: json['id']?.toString() ?? '',
      equipmentCode: json['equipmentCode']?.toString() ?? '',
      plateOrSerialNo: json['plateOrSerialNo']?.toString(),
      equipmentType: json['equipmentType']?.toString() ?? '',
      defaultOperator: json['defaultOperator']?.toString(),
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
      currentFuelPrice: json['currentFuelPrice'] != null
          ? FuelPrice.fromJson(json['currentFuelPrice'])
          : null,
      fuelType: json['fuelType']?.toString(),
      year: json['year'] != null
          ? (json['year'] is int
              ? json['year']
              : int.tryParse(json['year'].toString()))
          : null,
      serviceStatus: json['serviceStatus']?.toString(),
      description: json['description']?.toString(),
      contracts: contractsList,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'equipmentCode': equipmentCode,
      'plateOrSerialNo': plateOrSerialNo,
      'equipmentType': equipmentType,
      'defaultOperator': defaultOperator,
      'area': area?.toJson(),
      'currentFuelPrice': currentFuelPrice?.toJson(),
      'fuelType': fuelType,
      'year': year,
      'serviceStatus': serviceStatus,
      'description': description,
      'contracts': contracts.map((c) => c.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class EquipmentContract {
  final String contractId;
  final String equipmentId;
  final double? rentalRate;
  final Contract contract;

  EquipmentContract({
    required this.contractId,
    required this.equipmentId,
    this.rentalRate,
    required this.contract,
  });

  factory EquipmentContract.fromJson(Map<String, dynamic> json) {
    return EquipmentContract(
      contractId: json['contractId']?.toString() ?? '',
      equipmentId: json['equipmentId']?.toString() ?? '',
      rentalRate: json['rentalRate'] != null
          ? (json['rentalRate'] is int
              ? (json['rentalRate'] as int).toDouble()
              : json['rentalRate'] is double
                  ? json['rentalRate']
                  : double.tryParse(json['rentalRate'].toString()))
          : null,
      contract: Contract.fromJson(json['contract'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractId': contractId,
      'equipmentId': equipmentId,
      'rentalRate': rentalRate,
      'contract': contract.toJson(),
    };
  }
}

class Contract {
  final String id;
  final String contractNo;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? vendorName;

  Contract({
    required this.id,
    required this.contractNo,
    this.description,
    this.startDate,
    this.endDate,
    this.vendorName,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id']?.toString() ?? '',
      contractNo: json['contractNo']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      vendorName: json['vendorName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contractNo': contractNo,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'vendorName': vendorName,
    };
  }
}
