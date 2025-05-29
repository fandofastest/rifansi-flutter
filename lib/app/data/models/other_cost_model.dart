class OtherCost {
  final String costType;
  final double amount;
  final String description;
  final String? receiptNumber;
  final String? remarks;

  OtherCost({
    required this.costType,
    required this.amount,
    required this.description,
    this.receiptNumber,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'costType': costType,
      'amount': amount,
      'description': description,
      'receiptNumber': receiptNumber,
      'remarks': remarks,
    };
  }

  factory OtherCost.fromJson(Map<String, dynamic> json) {
    return OtherCost(
      costType: json['costType']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      receiptNumber: json['receiptNumber']?.toString(),
      remarks: json['remarks']?.toString(),
    );
  }
}
