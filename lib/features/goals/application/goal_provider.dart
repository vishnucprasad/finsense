import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/app_database.dart';
import '../../../core/models/goal_model.dart';
import '../../ai_assistant/application/gemini_service.dart';

part 'goal_provider.g.dart';

@riverpod
class GoalNotifier extends _$GoalNotifier {
  static const _tableName = 'goals';

  @override
  FutureOr<List<GoalModel>> build() async {
    return _loadGoals();
  }

  Future<List<GoalModel>> _loadGoals() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(_tableName);
    return maps.map((map) => GoalModel.fromMap(map)).toList();
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
    
    final db = await AppDatabase.instance.database;
    await db.insert(_tableName, newGoal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> deleteGoal(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);

    final currentList = state.valueOrNull ?? [];
    final newList = currentList.where((g) => g.id != id).toList();
    state = AsyncValue.data(newList);
  }
}
