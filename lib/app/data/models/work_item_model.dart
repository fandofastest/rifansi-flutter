import 'category_model.dart';
import 'unit_model.dart';

class WorkItem {
  final String workItemId;
  final BoqVolume boqVolume;
  final int amount;
  final Rates rates;
  final String? description;
  final WorkItemDetail workItem;

  WorkItem({
    required this.workItemId,
    required this.boqVolume,
    required this.amount,
    required this.rates,
    this.description,
    required this.workItem,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      workItemId: json['workItemId']?.toString() ?? '',
      boqVolume: json['boqVolume'] != null
          ? BoqVolume.fromJson(json['boqVolume'])
          : BoqVolume(nr: 0, r: 0),
      amount: json['amount'] is int
          ? json['amount']
          : (json['amount'] is double ? json['amount'].toInt() : 0),
      rates: json['rates'] != null
          ? Rates.fromJson(json['rates'])
          : Rates(nr: Rate(rate: 0), r: Rate(rate: 0)),
      description: json['description']?.toString(),
      workItem: json['workItem'] != null
          ? WorkItemDetail.fromJson(json['workItem'])
          : WorkItemDetail(
              id: '',
              name: '',
              category: Category(id: '', name: ''),
              subCategory: Category(id: '', name: ''),
              unit: Unit(id: '', name: ''),
            ),
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
      'workItem': {
        'id': workItem.id,
        'name': workItem.name,
        'category': workItem.category.toJson(),
        'subCategory': workItem.subCategory.toJson(),
        'unit': workItem.unit.toJson(),
      },
    };
  }
}

class BoqVolume {
  final int nr;
  final int r;

  BoqVolume({required this.nr, required this.r});

  factory BoqVolume.fromJson(Map<String, dynamic> json) {
    return BoqVolume(
      nr: json['nr'] is int
          ? json['nr']
          : (json['nr'] is double ? json['nr'].toInt() : 0),
      r: json['r'] is int
          ? json['r']
          : (json['r'] is double ? json['r'].toInt() : 0),
    );
  }
}

class Rates {
  final Rate nr;
  final Rate r;

  Rates({required this.nr, required this.r});

  factory Rates.fromJson(Map<String, dynamic> json) {
    return Rates(
      nr: json['nr'] != null ? Rate.fromJson(json['nr']) : Rate(rate: 0),
      r: json['r'] != null ? Rate.fromJson(json['r']) : Rate(rate: 0),
    );
  }
}

class Rate {
  final int rate;
  final String? description;

  Rate({required this.rate, this.description});

  factory Rate.fromJson(Map<String, dynamic> json) {
    return Rate(
      rate: json['rate'] is int
          ? json['rate']
          : (json['rate'] is double ? json['rate'].toInt() : 0),
      description: json['description']?.toString(),
    );
  }
}

class WorkItemDetail {
  final String id;
  final String name;
  final Category category;
  final Category subCategory;
  final Unit unit;

  WorkItemDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.unit,
  });

  factory WorkItemDetail.fromJson(Map<String, dynamic> json) {
    return WorkItemDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category'] != null
          ? Category.fromJson(json['category'])
          : Category(id: '', name: ''),
      subCategory: json['subCategory'] != null
          ? Category.fromJson(json['subCategory'])
          : Category(id: '', name: ''),
      unit: json['unit'] != null
          ? Unit.fromJson(json['unit'])
          : Unit(id: '', name: ''),
    );
  }
}
