import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finsense/services/ai/gemini_service.dart';

part 'chat_provider.g.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isGenerating;
  ChatMessage({
    required this.text,
    required this.isUser,
    this.isGenerating = false,
  });
}

@riverpod
class ChatController extends _$ChatController {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        text:
            'Hello! I am FinSense AI, your financial assistant. How can I help you today?',
        isUser: false,
      ),
    ];
  }

  Future<void> sendMessage(String text, {String? hiddenContext}) async {
    if (text.trim().isEmpty) return;

    state = [
      ...state,
      ChatMessage(text: text, isUser: true),
      ChatMessage(text: '', isUser: false, isGenerating: true),
    ];

    final gemini = await ref.read(geminiServiceProvider.future);
    if (gemini == null) {
      state = [
        ...state.where((m) => !m.isGenerating),
        ChatMessage(
          text: 'API Key is missing. Update it in Settings.',
          isUser: false,
        ),
      ];
      return;
    }

    try {
      final promptWithContext = hiddenContext != null
          ? "CONTEXT OF USER DATA: $hiddenContext\n\nUSER PROMPT: $text"
          : text;
      final response = await gemini.chat(promptWithContext);
      state = [
        ...state.where((m) => !m.isGenerating),
        ChatMessage(text: response, isUser: false),
      ];
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      String errorMessage = 'Failed to generate response.';
      if (errStr.contains('quota exceeded') ||
          errStr.contains('rate limit') ||
          errStr.contains('429')) {
        errorMessage =
            'I cannot respond because your Gemini API key has exceeded its quota or rate limit. Please check your billing details.';
      } else if (errStr.contains('api key not valid') ||
          errStr.contains('api key')) {
        errorMessage =
            'Your API key is invalid or missing. Please update it in Settings.';
      } else if (errStr.contains('socketexception') ||
          errStr.contains('network') ||
          errStr.contains('failed host')) {
        errorMessage =
            'I cannot connect to the server. Please check your internet connection.';
      }
      state = [
        ...state.where((m) => !m.isGenerating),
        ChatMessage(text: errorMessage, isUser: false),
      ];
    }
  }
}
