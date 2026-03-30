import 'dart:convert';

class GoalModel {
  final String id;
  final double targetAmount;
  final DateTime targetDate;
  final String name;
  final double currentSaved;
  final String? aiGeneratedPlan;

  GoalModel({
    required this.id,
    required this.targetAmount,
    required this.targetDate,
    required this.name,
    this.currentSaved = 0.0,
    this.aiGeneratedPlan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'targetAmount': targetAmount,
      'targetDate': targetDate.toIso8601String(),
      'name': name,
      'currentSaved': currentSaved,
      'aiGeneratedPlan': aiGeneratedPlan,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] ?? '',
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      targetDate: DateTime.parse(map['targetDate']),
      name: map['name'] ?? '',
      currentSaved: (map['currentSaved'] ?? 0.0).toDouble(),
      aiGeneratedPlan: map['aiGeneratedPlan'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalModel.fromJson(String source) =>
      GoalModel.fromMap(json.decode(source));

  GoalModel copyWith({
    String? id,
    double? targetAmount,
    DateTime? targetDate,
    String? name,
    double? currentSaved,
    String? aiGeneratedPlan,
  }) {
    return GoalModel(
      id: id ?? this.id,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      name: name ?? this.name,
      currentSaved: currentSaved ?? this.currentSaved,
      aiGeneratedPlan: aiGeneratedPlan ?? this.aiGeneratedPlan,
    );
  }
}
