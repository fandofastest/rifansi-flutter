import 'package:hive/hive.dart';
import 'role_model.dart';
import 'area_model.dart';

part 'user_model.g.dart';

@HiveType(typeId: 14)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final Role role;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final Area? area;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.email,
    this.area,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      role: Role.fromJson(json['role'] as Map<String, dynamic>),
      email: json['email']?.toString(),
      area: json['area'] != null ? Area.fromJson(json['area']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role.toJson(),
      'email': email,
      'area': area?.toJson(),
    };
  }
}
