import 'package:hive/hive.dart';

part 'location_model.g.dart';

@HiveType(typeId: 17)
class Location {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
