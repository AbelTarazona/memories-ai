import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories/core/bloc/base_state.dart';
import 'package:memories/core/bloc/fetch_event.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/transcript_model.dart';
import 'package:memories/presentation/home/bloc/people_list_bloc.dart';
import 'package:memories/presentation/memories_list/bloc/memories_list_bloc.dart';
import 'package:memories/presentation/record_memory/bloc/analyze_memory_bloc.dart';

class ReprocessMemoryButton extends StatelessWidget {
  const ReprocessMemoryButton({
    super.key,
    required this.memory,
    required this.size,
    required this.onSuccess,
  });

  final MemoryModel memory;
  final double size;
  final VoidCallback onSuccess;

  bool _needsReprocessing() {
    return memory.aiImage == null || memory.aiImage!.isEmpty;
  }

  void _reprocessMemory(BuildContext context) {
    final peopleBloc = context.read<PeopleListBloc>();
    final peopleState = peopleBloc.state;

    if (peopleState is! LoadedState<List<PeopleModel>>) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo cargar la lista de personas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final people = peopleState.data;

    context.read<AnalyzeMemoryBloc>().add(
      FetchEvent(
        AnalyzeMemoryParams(
          transcript: memory.content,
          memoryId: memory.id,
          people: people,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsReprocessing()) {
      return const SizedBox.shrink();
    }

    return BlocListener<AnalyzeMemoryBloc, BaseState<TranscriptModel>>(
      listener: (context, state) {
        if (state is LoadedState<TranscriptModel>) {
          // Trigger reload of memories list from database
          context.read<MemoriesListBloc>().add(const FetchEvent(null));

          // Wait a bit for the list to reload, then call success callback
          Future.delayed(const Duration(milliseconds: 800), () {
            onSuccess();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Memoria procesada exitosamente! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is ErrorState<TranscriptModel>) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar: ${state.failure.message}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<AnalyzeMemoryBloc, BaseState<TranscriptModel>>(
        builder: (context, state) {
          final isProcessing = state is LoadingState<TranscriptModel>;

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isProcessing ? null : () => _reprocessMemory(context),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isProcessing)
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                    else
                      const Icon(
                        Icons.auto_fix_high,
                        size: 60,
                        color: Colors.white,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      isProcessing ? 'Procesando...' : '✨ Generar Arte con IA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isProcessing
                          ? 'Analizando tu memoria...'
                          : 'Esta memoria aún no tiene imagen',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
