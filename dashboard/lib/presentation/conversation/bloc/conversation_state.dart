part of 'conversation_bloc.dart';

class ConversationState extends Equatable {
  const ConversationState({
    required this.messages,
    required this.isLoading,
    required this.conversationAction,
    required this.activeMemories,
  });

  factory ConversationState.initial() => ConversationState(
    messages: List<ChatMessage>.unmodifiable(const [
      ChatMessage.ai(text: 'Soy Memories AI, ¿cómo te ayudo hoy?'),
    ]),
    isLoading: false,
    conversationAction: 'end',
    activeMemories: const [],
  );

  final List<ChatMessage> messages;
  final bool isLoading;
  final String conversationAction; // "continue", "switch", "end"
  final List<MemorySearchModel> activeMemories;

  /// Backward compatibility
  bool get expectsFollowup => conversationAction == 'continue';

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? conversationAction,
    List<MemorySearchModel>? activeMemories,
  }) {
    return ConversationState(
      messages: messages != null
          ? List<ChatMessage>.unmodifiable(messages)
          : this.messages,
      isLoading: isLoading ?? this.isLoading,
      conversationAction: conversationAction ?? this.conversationAction,
      activeMemories: activeMemories != null
          ? List<MemorySearchModel>.unmodifiable(activeMemories)
          : this.activeMemories,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isLoading,
    conversationAction,
    activeMemories,
  ];
}
