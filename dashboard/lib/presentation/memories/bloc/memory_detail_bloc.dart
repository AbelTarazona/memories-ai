import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class UpdateMemoryEvent extends BaseEvent {
  final MemoryModel memory;
  const UpdateMemoryEvent(this.memory);
}

class MemoryDetailBloc extends GenericBloc<int, MemoryModel> {
  final ISupabaseRepository repository;

  MemoryDetailBloc({required this.repository})
    : super(
        fetchFunction: (params) async {
          if (params == null || params <= 0) {
            return left(Failure('Identificador de memoria no válido'));
          }
          return repository.memoryById(params);
        },
      ) {
    on<UpdateMemoryEvent>(_onUpdateMemory);
  }

  Future<void> _onUpdateMemory(
    UpdateMemoryEvent event,
    Emitter<BaseState<MemoryModel>> emit,
  ) async {
    emit(LoadingState<MemoryModel>());
    final result = await repository.updateMemory(event.memory);
    result.fold(
      (failure) => emit(ErrorState<MemoryModel>(failure)),
      (_) => emit(LoadedState<MemoryModel>(event.memory)),
    );
  }
}
