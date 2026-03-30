import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:finsense/core/database/app_database.dart';
import 'package:finsense/features/ai_insights/models/ai_summary_model.dart';
import 'package:finsense/services/ai/gemini_service.dart';
import 'package:finsense/features/transactions/view_models/transaction_provider.dart';

final aiSummaryProvider =
    AsyncNotifierProvider<AISummaryNotifier, AISummaryModel?>(() {
      return AISummaryNotifier();
    });

class AISummaryNotifier extends AsyncNotifier<AISummaryModel?> {
  static const _cacheKey = 'ai_summary_cache';
  static const _dateKey = 'ai_summary_date';

  Future<AISummaryModel?> build() async {
    return _loadCachedSummary();
  }

  Future<AISummaryModel?> _loadCachedSummary() async {
    final db = await AppDatabase.instance.database;
    final dateRes = await db.query(
      'cache',
      where: 'id = ?',
      whereArgs: [_dateKey],
    );
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (dateRes.isNotEmpty && dateRes.first['value'] as String == todayStr) {
      final cacheRes = await db.query(
        'cache',
        where: 'id = ?',
        whereArgs: [_cacheKey],
      );
      if (cacheRes.isNotEmpty) {
        final cachedData = cacheRes.first['value'] as String;
        try {
          final jsonMap = json.decode(cachedData);
          return AISummaryModel.fromJson(jsonMap);
        } catch (_) {}
      }
    }
    return null;
  }

  Future<void> generateNewSummary() async {
    state = const AsyncValue.loading();
    try {
      final gemini = await ref.read(geminiServiceProvider.future);
      if (gemini == null) throw Exception("Gemini API missing context");

      final txs = ref.read(transactionNotifierProvider).valueOrNull ?? [];
      final buffer = StringBuffer();
      for (var t in txs) {
        buffer.writeln(
          "- [${t.type}] ${t.categoryId} ₹${t.amount} on ${DateFormat.yMMMd().format(t.date)} (${t.note})",
        );
      }

      final rawJson = await gemini.generateFullSummary(buffer.toString());
      final cleanJson = rawJson
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final decoded = json.decode(cleanJson);

      final model = AISummaryModel.fromJson(decoded);

      final db = await AppDatabase.instance.database;
      await db.insert('cache', {
        'id': _dateKey,
        'value': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await db.insert('cache', {
        'id': _cacheKey,
        'value': json.encode(model.toJson()),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      state = AsyncValue.data(model);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
