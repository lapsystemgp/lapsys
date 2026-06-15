import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../data/chat_models.dart';
import '../data/chat_repository.dart';

class ChatState {
  const ChatState({
    this.messages = const [],
    this.conversationId,
    this.isStreaming = false,
    this.error,
  });

  final List<AssistantMessage> messages;
  final String? conversationId;
  final bool isStreaming;
  final String? error;

  ChatState copyWith({
    List<AssistantMessage>? messages,
    String? conversationId,
    bool? isStreaming,
    Object? error = _sentinel,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  static const _sentinel = Object();
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() => const ChatState();

  StreamSubscription<ChatStreamEvent>? _sub;

  /// Clears the current thread so the next message starts a fresh conversation.
  void startNewChat() {
    _sub?.cancel();
    state = const ChatState();
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.isStreaming) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final userMessage = AssistantMessage(
      id: 'local-user-$now',
      role: ChatRole.user,
      content: text,
    );
    // Unique per send — a fixed id would let later deltas also match the
    // previous assistant bubble and rewrite it.
    final assistantId = 'local-assistant-$now';
    final assistantMessage = AssistantMessage(
      id: assistantId,
      role: ChatRole.assistant,
      content: '',
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantMessage],
      isStreaming: true,
      error: null,
    );

    final repo = ref.read(chatRepositoryProvider);
    final completer = Completer<void>();

    _sub = repo
        .sendMessage(text: text, conversationId: state.conversationId)
        .listen(
      (event) {
        switch (event['type']) {
          case 'meta':
            state = state.copyWith(
              conversationId: event['conversationId'] as String?,
            );
          case 'delta':
            _appendDelta(assistantId, event['text'] as String? ?? '');
          case 'done':
            _finishAssistant(assistantId);
          case 'error':
            _failAssistant(
              assistantId,
              event['message'] as String? ?? 'Something went wrong.',
            );
        }
      },
      onError: (Object e) {
        final message = e is ApiException ? e.message : e.toString();
        _failAssistant(assistantId, message);
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        // Guard against a stream that ends without a terminal event.
        _finishAssistant(assistantId);
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    await completer.future;
  }

  void _appendDelta(String assistantId, String delta) {
    if (delta.isEmpty) return;
    state = state.copyWith(
      messages: [
        for (final m in state.messages)
          if (m.id == assistantId)
            m.copyWith(content: m.content + delta)
          else
            m,
      ],
    );
  }

  void _finishAssistant(String assistantId) {
    state = state.copyWith(
      isStreaming: false,
      messages: [
        for (final m in state.messages)
          if (m.id == assistantId && m.isStreaming)
            m.copyWith(isStreaming: false)
          else
            m,
      ],
    );
  }

  void _failAssistant(String assistantId, String message) {
    // Drop the empty streaming placeholder; surface the error in state.
    state = state.copyWith(
      isStreaming: false,
      error: message,
      messages: [
        for (final m in state.messages)
          if (!(m.id == assistantId && m.content.isEmpty)) m,
      ],
    );
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
