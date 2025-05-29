class Material {
  final String id;
  final String name;
  final String? unitId;
  final double? unitRate;
  final String? description;
  final Unit? unit;

  Material({
    required this.id,
    required this.name,
    this.unitId,
    this.unitRate,
    this.description,
    this.unit,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      unitId: json['unitId']?.toString(),
      unitRate: json['unitRate'] != null
          ? (json['unitRate'] as num).toDouble()
          : null,
      description: json['description']?.toString(),
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unitId': unitId,
      'unitRate': unitRate,
      'description': description,
      'unit': unit?.toJson(),
    };
  }
}

class Unit {
  final String id;
  final String code;
  final String name;
  final String? description;

  Unit({
    required this.id,
    required this.code,
    required this.name,
    this.description,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
    };
  }
}
