import 'dart:convert';

class TransactionModel {
  final String id;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;
  final String accountId;
  final String type; // 'Income' or 'Expense'

  TransactionModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.date,
    required this.note,
    this.accountId = '',
    this.type = 'Expense',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'note': note,
      'accountId': accountId,
      'type': type,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      categoryId:
          map['categoryId'] ?? map['category'] ?? '', // Fallback for legacy
      date: DateTime.parse(map['date']),
      note: map['note'] ?? '',
      accountId: map['accountId'] ?? '',
      type: map['type'] ?? 'Expense',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) =>
      TransactionModel.fromMap(json.decode(source));

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    String? accountId,
    String? type,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
    );
  }
}
