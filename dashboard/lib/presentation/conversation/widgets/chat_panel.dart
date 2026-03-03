import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:memories_web_admin/presentation/conversation/widgets/chat_message_bubble.dart';
import 'package:memories_web_admin/presentation/conversation/widgets/loading_bubble.dart';

class ChatPanel extends StatefulWidget {
  const ChatPanel({super.key});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConversationBloc, ConversationState>(
      listener: (context, state) => _scrollToBottom(),
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: state.messages.length + (state.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (state.isLoading && index == state.messages.length) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LoadingBubble(),
                );
              }

              final message = state.messages[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == state.messages.length - 1 ? 0 : 16,
                ),
                child: ChatMessageBubble(message: message),
              );
            },
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
