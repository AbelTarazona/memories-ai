part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class ConversationMessageSubmitted extends ConversationEvent {
  const ConversationMessageSubmitted(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ConversationReset extends ConversationEvent {
  const ConversationReset();
}
