import 'dart:convert';

class AccountModel {
  final String id;
  final String name;
  final String type; // 'Bank', 'Card', 'Cash'
  final double balance;
  final String colorHex;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.colorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'balance': balance,
      'colorHex': colorHex,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      balance: (map['balance'] ?? 0.0).toDouble(),
      colorHex: map['colorHex'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountModel.fromJson(String source) =>
      AccountModel.fromMap(json.decode(source));

  AccountModel copyWith({
    String? id,
    String? name,
    String? type,
    double? balance,
    String? colorHex,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      colorHex: colorHex ?? this.colorHex,
    );
  }
}
