import 'category_model.dart';
import 'unit_model.dart';

class WorkItem {
  final String workItemId;
  final BoqVolume boqVolume;
  final int amount;
  final Rates rates;
  final String? description;
  final WorkItemDetail? workItem;

  WorkItem({
    required this.workItemId,
    required this.boqVolume,
    required this.amount,
    required this.rates,
    this.description,
    this.workItem,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      workItemId: json['workItemId'],
      boqVolume: BoqVolume.fromJson(json['boqVolume']),
      amount: json['amount'],
      rates: Rates.fromJson(json['rates']),
      description: json['description'] as String?,
      workItem: json['workItem'] != null ? WorkItemDetail.fromJson(json['workItem']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workItemId': workItemId,
      'boqVolume': {
        'nr': boqVolume.nr,
        'r': boqVolume.r,
      },
      'amount': amount,
      'rates': {
        'nr': {
          'rate': rates.nr.rate,
          'description': rates.nr.description,
        },
        'r': {
          'rate': rates.r.rate,
          'description': rates.r.description,
        },
      },
      'description': description,
      'workItem': workItem?.toJson(),
    };
  }
}

class BoqVolume {
  final int nr;
  final int r;

  BoqVolume({required this.nr, required this.r});

  factory BoqVolume.fromJson(Map<String, dynamic> json) {
    return BoqVolume(
      nr: (json['nr'] as num).toInt(),
      r: (json['r'] as num).toInt(),
    );
  }
}

class Rates {
  final Rate nr;
  final Rate r;

  Rates({required this.nr, required this.r});

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      nr: Rate.fromJson(json['nr']),
      r: Rate.fromJson(json['r']),
    );
  }
}

class Rate {
  final int rate;
  final String? description;

  Rate({required this.rate, this.description});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      rate: json['rate'],
      description: json['description'] as String?,
    );
  }
}

class WorkItemDetail {
  final String id;
  final String name;
  final Category? category;
  final Category? subCategory;
  final Unit? unit;

  WorkItemDetail({
    required this.id,
    required this.name,
    this.category,
    this.subCategory,
    this.unit,
  });

  factory WorkItemDetail.fromJson(Map<String, dynamic> json) {
    return WorkItemDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      subCategory: json['subCategory'] != null ? Category.fromJson(json['subCategory']) : null,
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category?.toJson(),
      'subCategory': subCategory?.toJson(),
      'unit': unit?.toJson(),
    };
  }
}
