import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/goal_model.dart';
import '../../ai_assistant/application/gemini_service.dart';

part 'goal_provider.g.dart';

@riverpod
class GoalNotifier extends _$GoalNotifier {
  static const _prefsKey = 'goals_key';

  @override
  FutureOr<List<GoalModel>> build() async {
    return _loadGoals();
  }

  Future<List<GoalModel>> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_prefsKey) ?? [];
    return jsonStringList.map((str) => GoalModel.fromJson(str)).toList();
  }

  Future<void> _saveGoals(List<GoalModel> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = goals.map((g) => g.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonStringList);
  }

  Future<void> checkAndCreateGoal(
    String name,
    double targetAmount,
    DateTime targetDate,
  ) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    String? steadyPlan;
    
    try {
      final gemini = await ref.read(geminiServiceProvider.future);
      if (gemini != null) {
        final formattedDate = "${targetDate.month}/${targetDate.day}/${targetDate.year}";
        steadyPlan = await gemini.generateSteadyPath(targetAmount, formattedDate);
      }
    } catch (e) {
      steadyPlan = "Could not generate AI plan automatically.";
    }

    final newGoal = GoalModel(
      id: id,
      name: name,
      targetAmount: targetAmount,
      targetDate: targetDate,
      aiGeneratedPlan: steadyPlan,
      currentSaved: 0.0,
    );

    final currentList = state.valueOrNull ?? [];
    final newList = [...currentList, newGoal];
    state = AsyncValue.data(newList);
    await _saveGoals(newList);
  }
  
  Future<void> deleteGoal(String id) async {
    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((g) => g.id != id).toList();
    state = AsyncValue.data(newList);
    await _saveGoals(newList);
  }
}
