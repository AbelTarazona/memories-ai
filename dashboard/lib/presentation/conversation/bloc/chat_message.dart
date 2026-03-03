part of 'conversation_bloc.dart';

class ChatMessage extends Equatable {
  const ChatMessage._({
    required this.isUser,
    this.text,
    this.relatedMemories,
  });

  const ChatMessage.user(String text) : this._(isUser: true, text: text);

  const ChatMessage.ai({String? text, List<MemorySearchModel>? relatedMemories})
    : this._(isUser: false, text: text, relatedMemories: relatedMemories);

  final bool isUser;
  final String? text;
  final List<MemorySearchModel>? relatedMemories;

  bool get hasMemories =>
      relatedMemories != null && relatedMemories!.isNotEmpty;

  @override
  List<Object?> get props => [isUser, text, relatedMemories];
}
