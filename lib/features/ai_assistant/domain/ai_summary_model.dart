class AISummaryModel {
  final String narrative;
  final double burnRate;
  final Map<String, double> topCategories;
  final String savingsPotential;
  final List<double> projectedBalances;
  final List<String> steadyPathRecommendations;
  final DateTime generatedAt;

  AISummaryModel({
    required this.narrative,
    required this.burnRate,
    required this.topCategories,
    required this.savingsPotential,
    required this.projectedBalances,
    required this.steadyPathRecommendations,
    required this.generatedAt,
  });

  factory AISummaryModel.fromJson(Map<String, dynamic> json) {
    return AISummaryModel(
      narrative: json['narrative'] ?? '',
      burnRate: (json['burnRate'] ?? 0.0).toDouble(),
      topCategories: Map<String, double>.from(
        (json['topCategories'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
            ) ??
            {},
      ),
      savingsPotential: json['savingsPotential'] ?? '',
      projectedBalances: List<double>.from(
        (json['projectedBalances'] as List?)?.map((e) => (e as num).toDouble()) ?? [],
      ),
      steadyPathRecommendations: List<String>.from(json['steadyPathRecommendations'] ?? []),
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'narrative': narrative,
      'burnRate': burnRate,
      'topCategories': topCategories,
      'savingsPotential': savingsPotential,
      'projectedBalances': projectedBalances,
      'steadyPathRecommendations': steadyPathRecommendations,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
