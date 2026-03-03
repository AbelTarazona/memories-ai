import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/widgets/app_header.dart';
import 'package:memories_web_admin/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:memories_web_admin/presentation/conversation/widgets/chat_panel.dart';
import 'package:memories_web_admin/presentation/conversation/widgets/example_prompt.dart';
import 'package:memories_web_admin/presentation/conversation/widgets/message_input.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ConversationView extends StatelessWidget {
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppHeader(
            title: 'Conversemos',
            actions: [
              ShadButton.ghost(
                onPressed: () {
                  context.read<ConversationBloc>().add(ConversationReset());
                },
                leading: const Icon(LucideIcons.refreshCcw, size: 16),
                child: const Text('Reiniciar chat'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: size.width * 0.5),
                child: const _ConversationColumn(),
              ),
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

class _ConversationColumn extends StatelessWidget {
  const _ConversationColumn();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        return Column(
          children: [
            const Expanded(child: ChatPanel()),
            const SizedBox(height: 24),
            MessageInput(isLoading: state.isLoading),
            const SizedBox(height: 8),
            const ExamplePrompt(),
          ],
        );
      },
    );
  }
}
