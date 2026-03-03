import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:memories_web_admin/data/models/empathetic_response_model.dart';
import 'package:memories_web_admin/data/models/memory_notes_model.dart';
import 'package:memories_web_admin/data/models/memory_search_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

part 'chat_message.dart';
part 'conversation_event.dart';
part 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  ConversationBloc({
    required ISupabaseRepository repository,
    required IOpenAIRepository openAIRepository,
  }) : _repository = repository,
       _openAIRepository = openAIRepository,
       super(ConversationState.initial()) {
    on<ConversationMessageSubmitted>(_onMessageSubmitted);
    on<ConversationReset>(_onReset);
  }

  final ISupabaseRepository _repository;
  final IOpenAIRepository _openAIRepository;

  Future<void> _onMessageSubmitted(
    ConversationMessageSubmitted event,
    Emitter<ConversationState> emit,
  ) async {
    final query = event.message.trim();
    if (query.isEmpty || state.isLoading) {
      return;
    }

    final updatedMessages = [...state.messages, ChatMessage.user(query)];

    emit(state.copyWith(messages: updatedMessages, isLoading: true));

    final bool isFollowup = state.expectsFollowup;
    final List<MemorySearchModel> activeMemories = state.activeMemories;

    // ALWAYS search for memories, regardless of mode.
    // This ensures topic changes are handled naturally.
    final searchResponse = await _repository.searchMemories(query: query);
    final relatedMemories = searchResponse.match(
      (failure) => <MemorySearchModel>[],
      (memories) => memories,
    );

    // Call LLM with BOTH active memories (current context) and related memories (fresh search)
    final naturalResponse = await _callLLM(
      query: query,
      isFollowup: isFollowup,
      relatedMemories: relatedMemories,
      activeMemories: activeMemories,
      updatedMessages: updatedMessages,
    );

    if (naturalResponse == null) {
      final msgs = [
        ...updatedMessages,
        ChatMessage.ai(text: 'Hubo un error al procesar tu mensaje.'),
      ];
      emit(state.copyWith(messages: msgs, isLoading: false));
      return;
    }

    _emitResponse(
      emit: emit,
      natural: naturalResponse,
      updatedMessages: updatedMessages,
      relatedMemories: relatedMemories,
      activeMemories: activeMemories,
      isFollowup: isFollowup,
      userQuery: query,
    );
  }

  /// Helper: Call the LLM with the given parameters
  Future<EmpatheticResponseModel?> _callLLM({
    required String query,
    required bool isFollowup,
    required List<MemorySearchModel> relatedMemories,
    required List<MemorySearchModel> activeMemories,
    required List<ChatMessage> updatedMessages,
  }) async {
    // Prepare chat history (excluding the current new message, max 6)
    final historyCandidates = updatedMessages
        .take(updatedMessages.length - 1)
        .toList();
    final limitedHistory = historyCandidates.length > 6
        ? historyCandidates.sublist(historyCandidates.length - 6)
        : historyCandidates;

    final history = limitedHistory
        .map(
          (msg) => {
            "role": msg.isUser ? "user" : "ai",
            "content": msg.text ?? "",
          },
        )
        .toList();

    final input = jsonEncode({
      "question": query,
      "mode": isFollowup ? "followup" : "new",
      "related_memories": relatedMemories.map((m) => m.toJson()).toList(),
      "active_memories": activeMemories.map((m) => m.toJson()).toList(),
      "chat_history": history,
    });

    log("Input JSON: $input");

    final result = await _openAIRepository.naturalResponse(inputJson: input);

    return result.match(
      (failure) {
        log("LLM error: ${failure.message}");
        return null;
      },
      (natural) => natural,
    );
  }

  /// Helper: Emit the final response state
  void _emitResponse({
    required Emitter<ConversationState> emit,
    required EmpatheticResponseModel natural,
    required List<ChatMessage> updatedMessages,
    required List<MemorySearchModel> relatedMemories,
    required List<MemorySearchModel> activeMemories,
    required bool isFollowup,
    String? userQuery,
  }) {
    // Resolve new active memories from memory_ids
    final allCandidates = {...relatedMemories, ...activeMemories}.toList();
    final newActive = allCandidates
        .where((m) => natural.ids.contains(m.id))
        .toList();

    // Solo mostrar memory cards en consultas NUEVAS (no followups)
    // y solo cuando la IA realmente referencia memorias en su respuesta
    final shouldShowCards = !isFollowup && newActive.isNotEmpty;

    final msgs = [
      ...updatedMessages,
      ChatMessage.ai(
        text: natural.response,
        relatedMemories: shouldShowCards ? newActive : null,
      ),
    ];

    emit(
      state.copyWith(
        messages: msgs,
        isLoading: false,
        activeMemories: natural.isContinue ? newActive : [],
        conversationAction: natural.action,
      ),
    );

    // Save user's response as memory note when it enriches active memories
    if (isFollowup &&
        userQuery != null &&
        userQuery.isNotEmpty &&
        newActive.isNotEmpty) {
      final notes = newActive
          .map(
            (m) => MemoryNoteModel(
              memoryId: m.id,
              authorType: 'user',
              content: userQuery,
            ),
          )
          .toList();
      _repository.saveMemoryNotes(notes);
    }
  }

  void submitMessage(String message) {
    add(ConversationMessageSubmitted(message));
  }

  void _onReset(ConversationReset event, Emitter<ConversationState> emit) {
    emit(ConversationState.initial());
  }
}
