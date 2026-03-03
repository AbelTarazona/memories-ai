import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:memories_web_admin/presentation/conversation/view/conversation_view.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationBloc(
        repository: context.read<ISupabaseRepository>(),
        openAIRepository: context.read<IOpenAIRepository>(),
      ),
      child: const ConversationView(),
    );
  }
}
