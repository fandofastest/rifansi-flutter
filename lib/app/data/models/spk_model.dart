import 'location_model.dart';
import 'work_item_model.dart';

class Spk {
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
  final List<WorkItem> workItems;
  final String createdAt;
  final String updatedAt;

  Spk({
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
    required this.workItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Spk.fromJson(Map<String, dynamic> json) {
    return Spk(
      id: json['id']?.toString() ?? '',
      spkNo: json['spkNo']?.toString() ?? '',
      wapNo: json['wapNo']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      contractor: json['contractor']?.toString() ?? '',
      workDescription: json['workDescription']?.toString() ?? '',
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : Location(id: '', name: ''),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      budget: json['budget'] is int
          ? json['budget']
          : (json['budget'] is double ? json['budget'].toInt() : 0),
      workItems: (json['workItems'] as List?)
              ?.map((item) => WorkItem.fromJson(item))
              .toList() ??
          [],
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}
