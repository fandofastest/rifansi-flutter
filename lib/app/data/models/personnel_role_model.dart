import 'package:hive/hive.dart';

part 'personnel_role_model.g.dart';

@HiveType(typeId: 20)
class PersonnelRole {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String roleCode;

  @HiveField(2)
  final String roleName;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final bool isPersonel;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final String updatedAt;

  @HiveField(7)
  final SalaryComponent? salaryComponent;

  PersonnelRole({
    required this.id,
    required this.roleCode,
    required this.roleName,
    required this.description,
    required this.isPersonel,
    required this.createdAt,
    required this.updatedAt,
    this.salaryComponent,
  });

  factory PersonnelRole.fromJson(Map<String, dynamic> json) {
    return PersonnelRole(
      id: json['id'] ?? '',
      roleCode: json['roleCode'] ?? '',
      roleName: json['roleName'] ?? '',
      description: json['description'] ?? '',
      isPersonel: json['isPersonel'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      salaryComponent: json['salaryComponent'] != null
          ? SalaryComponent.fromJson(json['salaryComponent'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleCode': roleCode,
      'roleName': roleName,
      'description': description,
      'isPersonel': isPersonel,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'salaryComponent': salaryComponent?.toJson(),
    };
  }
}

@HiveType(typeId: 21)
class SalaryComponent {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double gajiPokok;

  @HiveField(2)
  final double tunjanganTetap;

  @HiveField(3)
  final double tunjanganTidakTetap;

  @HiveField(4)
  final double transport;

  @HiveField(5)
  final double pulsa;

  @HiveField(6)
  final double bpjsKT;

  @HiveField(7)
  final double bpjsJP;

  @HiveField(8)
  final double bpjsKES;

  @HiveField(9)
  final double uangCuti;

  @HiveField(10)
  final double thr;

  @HiveField(11)
  final double santunan;

  @HiveField(12)
  final int hariPerBulan;

  @HiveField(13)
  final double totalGajiBulanan;

  @HiveField(14)
  final double biayaTetapHarian;

  @HiveField(15)
  final double upahLemburHarian;

  SalaryComponent({
    required this.id,
    required this.gajiPokok,
    required this.tunjanganTetap,
    required this.tunjanganTidakTetap,
    required this.transport,
    required this.pulsa,
    required this.bpjsKT,
    required this.bpjsJP,
    required this.bpjsKES,
    required this.uangCuti,
    required this.thr,
    required this.santunan,
    required this.hariPerBulan,
    required this.totalGajiBulanan,
    required this.biayaTetapHarian,
    required this.upahLemburHarian,
  });

  factory SalaryComponent.fromJson(Map<String, dynamic> json) {
    return SalaryComponent(
      id: json['id'] ?? '',
      gajiPokok: _parseDouble(json['gajiPokok']),
      tunjanganTetap: _parseDouble(json['tunjanganTetap']),
      tunjanganTidakTetap: _parseDouble(json['tunjanganTidakTetap']),
      transport: _parseDouble(json['transport']),
      pulsa: _parseDouble(json['pulsa']),
      bpjsKT: _parseDouble(json['bpjsKT']),
      bpjsJP: _parseDouble(json['bpjsJP']),
      bpjsKES: _parseDouble(json['bpjsKES']),
      uangCuti: _parseDouble(json['uangCuti']),
      thr: _parseDouble(json['thr']),
      santunan: _parseDouble(json['santunan']),
      hariPerBulan: _parseInt(json['hariPerBulan']),
      totalGajiBulanan: _parseDouble(json['totalGajiBulanan']),
      biayaTetapHarian: _parseDouble(json['biayaTetapHarian']),
      upahLemburHarian: _parseDouble(json['upahLemburHarian']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gajiPokok': gajiPokok,
      'tunjanganTetap': tunjanganTetap,
      'tunjanganTidakTetap': tunjanganTidakTetap,
      'transport': transport,
      'pulsa': pulsa,
      'bpjsKT': bpjsKT,
      'bpjsJP': bpjsJP,
      'bpjsKES': bpjsKES,
      'uangCuti': uangCuti,
      'thr': thr,
      'santunan': santunan,
      'hariPerBulan': hariPerBulan,
      'totalGajiBulanan': totalGajiBulanan,
      'biayaTetapHarian': biayaTetapHarian,
      'upahLemburHarian': upahLemburHarian,
    };
  }

  static double _parseDouble(dynamic value) {
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

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }
}
