import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key, required this.isLoading});

  final bool isLoading;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: _controller,
      placeholder: const Text('Ahondemos en tus memorias...'),
      enabled: !widget.isLoading,
      decoration: const ShadDecoration(color: Colors.white),
      onSubmitted: _onSubmitted,
    );
  }

  void _onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || widget.isLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<ConversationBloc>().submitMessage(trimmed);
    _controller.clear();
  }
}
