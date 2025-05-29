class Area {
  final String id;
  final String name;
  final Location? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Area({
    required this.id,
    required this.name,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['createdAt']?.toString() ?? '0') ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['updatedAt']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location?.toJson(),
      'createdAt': createdAt.millisecondsSinceEpoch.toString(),
      'updatedAt': updatedAt.millisecondsSinceEpoch.toString(),
    };
  }
}

class Location {
  final String type;
  final List<dynamic> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type']?.toString() ?? '',
      coordinates: json['coordinates'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
