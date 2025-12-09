import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../repositories/gemini_repository.dart';

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  return ChatViewModel();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? errorMessage;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel() : super(ChatState());

  final GeminiRepository _repository = GeminiRepository();

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || state.isLoading) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      errorMessage: null,
    );

    final typingMessage = ChatMessage(
      id: 'typing',
      role: 'model',
      content: '',
      timestamp: DateTime.now(),
      isTyping: true,
    );

    state = state.copyWith(
      messages: [...state.messages, typingMessage],
    );

    try {
      final response = await _repository.sendMessage(
        state.messages.where((m) => !m.isTyping).toList(),
      );

      final updatedMessages = state.messages.where((m) => m.id != 'typing').toList();

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'model',
        content: response,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...updatedMessages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      final updatedMessages = state.messages.where((m) => m.id != 'typing').toList();

      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'model',
        content: '오류가 발생했습니다:\n${e.toString()}',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...updatedMessages, errorMessage],
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearChat() {
    state = ChatState();
  }

  void initializeChat() {
    if (state.messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: '0',
        role: 'model',
        content: '안녕하세요!\n\nGemini AI 어시스턴트입니다.\n무엇을 도와드릴까요?',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(messages: [welcomeMessage]);
    }
  }
}