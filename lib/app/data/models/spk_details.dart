import 'package:hive/hive.dart';
import 'package:rifansi/app/data/models/location_model.dart';
import 'package:rifansi/app/data/models/spk_model.dart';

// Kelas untuk menyimpan detail SPK lengkap
@HiveType(typeId: 8) // Pastikan typeId unik dan tidak bentrok dengan yang lain
class SPKDetails {
  @HiveField(0)
  final String spkNo;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String projectName;

  @HiveField(3)
  final Location? location;

  SPKDetails({
    required this.spkNo,
    required this.title,
    required this.projectName,
    this.location,
  });

  // Konstruktor untuk membuat SPKDetails dari model Spk
  factory SPKDetails.fromSpk(Spk spk) {
    return SPKDetails(
      spkNo: spk.spkNo,
      title: spk.title,
      projectName: spk.projectName,
      location: spk.location,
    );
  }
}
