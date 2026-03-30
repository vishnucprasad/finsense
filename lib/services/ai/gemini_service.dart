import 'package:finsense/services/storage/secure_storage_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gemini_service.g.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(this._model);

  Future<String> generateTip(String recentTransactions) async {
    final prompt =
        'You are a Prudent Financial Advisor. Based on these 30-day transactions, provide a single 1-sentence behavioral tip to save money:\n$recentTransactions';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text?.trim() ?? 'Unable to generate tip.';
  }

  Future<String> generateSteadyPath(
    double targetAmount,
    String deadline,
  ) async {
    final prompt =
        'You are a Prudent Financial Advisor. I want to save \$$targetAmount by $deadline. Provide a "Steady Path Plan" consisting of a structured list of weekly or monthly milestones.';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text?.trim() ?? 'Unable to generate plan.';
  }

  Future<String> chat(String prompt) async {
    final chat = _model.startChat();
    final response = await chat.sendMessage(Content.text(prompt));
    return response.text ?? 'No response';
  }

  Future<String> generateFullSummary(String contextData) async {
    final prompt =
        '''
You are FinSense AI, an expert financial analyst.
Analyze the following user transaction data and provide a "Full History Summary".
You MUST output your response strictly as valid JSON, with the following keys and data types natively:
{
  "narrative": "A 2-3 sentence overview of their financial story this month",
  "burnRate": 45.5,
  "topCategories": { "Food": 150.0, "Transport": 50.0 }, 
  "savingsPotential": "You could save ₹500 if you cut back on dining out.",
  "projectedBalances": [1000.0, 950.0, 900.0, 850.0, 800.0],
  "steadyPathRecommendations": ["Actionable tip 1", "Actionable tip 2", "Actionable tip 3"]
}

Do not use markdown blocks around the JSON output, return absolute pure raw JSON text strictly.
Data:
$contextData
''';
    final chat = _model.startChat();
    final response = await chat.sendMessage(Content.text(prompt));
    return response.text ?? '{}';
  }
}

@riverpod
Future<GeminiService?> geminiService(GeminiServiceRef ref) async {
  final storage = ref.watch(secureStorageProvider);
  final apiKey = await storage.getApiKey();

  if (apiKey == null || apiKey.isEmpty) return null;

  final model = GenerativeModel(
    model: 'gemini-3-flash-preview',
    apiKey: apiKey,
    systemInstruction: Content.system(
      'You are a Prudent Financial Advisor. Provide concise, actionable advice focusing on practical money management.',
    ),
  );

  return GeminiService(model);
}
