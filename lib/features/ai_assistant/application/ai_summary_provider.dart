import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ai_summary_model.dart';
import 'gemini_service.dart';
import '../../dashboard/application/transaction_provider.dart';

final aiSummaryProvider = AsyncNotifierProvider<AISummaryNotifier, AISummaryModel?>(() {
  return AISummaryNotifier();
});

class AISummaryNotifier extends AsyncNotifier<AISummaryModel?> {
  static const _cacheKey = 'ai_summary_cache';
  static const _dateKey = 'ai_summary_date';

  @override
  Future<AISummaryModel?> build() async {
    return _loadCachedSummary();
  }

  Future<AISummaryModel?> _loadCachedSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedDateStr = prefs.getString(_dateKey);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (cachedDateStr == todayStr) {
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
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
        buffer.writeln("- [${t.type}] ${t.categoryId} ₹${t.amount} on ${DateFormat.yMMMd().format(t.date)} (${t.note})");
      }

      final rawJson = await gemini.generateFullSummary(buffer.toString());
      final cleanJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = json.decode(cleanJson);
      
      final model = AISummaryModel.fromJson(decoded);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dateKey, DateFormat('yyyy-MM-dd').format(DateTime.now()));
      await prefs.setString(_cacheKey, json.encode(model.toJson()));

      state = AsyncValue.data(model);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
