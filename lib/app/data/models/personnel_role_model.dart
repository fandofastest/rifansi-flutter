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
  final SalaryComponent? salaryComponent;

  @HiveField(5)
  final String createdAt;

  @HiveField(6)
  final String updatedAt;

  PersonnelRole({
    required this.id,
    required this.roleCode,
    required this.roleName,
    required this.description,
    this.salaryComponent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersonnelRole.fromJson(Map<String, dynamic> json) {
    return PersonnelRole(
      id: json['id'] ?? '',
      roleCode: json['roleCode'] ?? '',
      roleName: json['roleName'] ?? '',
      description: json['description'] ?? '',
      salaryComponent: json['salaryComponent'] != null
          ? SalaryComponent.fromJson(json['salaryComponent'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleCode': roleCode,
      'roleName': roleName,
      'description': description,
      'salaryComponent': salaryComponent?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
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

  SalaryComponent({
    required this.id,
    required this.gajiPokok,
    required this.tunjanganTetap,
    required this.tunjanganTidakTetap,
    required this.transport,
    required this.pulsa,
  });

  factory SalaryComponent.fromJson(Map<String, dynamic> json) {
    return SalaryComponent(
      id: json['id'] ?? '',
      gajiPokok: _parseDouble(json['gajiPokok']),
      tunjanganTetap: _parseDouble(json['tunjanganTetap']),
      tunjanganTidakTetap: _parseDouble(json['tunjanganTidakTetap']),
      transport: _parseDouble(json['transport']),
      pulsa: _parseDouble(json['pulsa']),
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
}
