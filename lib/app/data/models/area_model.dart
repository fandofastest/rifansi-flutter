class Area {
  final String id;
  final String name;
  final Location location;
  final DateTime createdAt;
  final DateTime updatedAt;

  Area({
    required this.id,
    required this.name,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      location: Location.fromJson(json['location']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(int.parse(json['createdAt'])),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(int.parse(json['updatedAt'])),
    );
  }
}

class Location {
  final String type;
  final List<dynamic> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: json['coordinates'],
    );
  }
} 