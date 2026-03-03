import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

/// Event to fetch memories for a specific person
class FetchPersonMemoriesEvent extends FetchEvent<String> {
  final String personName;

  const FetchPersonMemoriesEvent(this.personName) : super(personName);
}

/// BLoC to manage person memories state
class PersonMemoriesBloc
    extends Bloc<FetchEvent, BaseState<List<MemoryModel>>> {
  final ISupabaseRepository _supabaseRepository;

  PersonMemoriesBloc({
    required ISupabaseRepository supabaseRepository,
  }) : _supabaseRepository = supabaseRepository,
       super(const InitialState()) {
    on<FetchPersonMemoriesEvent>(_onFetchPersonMemories);
  }

  Future<void> _onFetchPersonMemories(
    FetchPersonMemoriesEvent event,
    Emitter<BaseState<List<MemoryModel>>> emit,
  ) async {
    emit(const LoadingState());

    final result = await _supabaseRepository.memoriesByPerson(
      personName: event.personName,
    );

    result.fold(
      (failure) => emit(ErrorState(failure)),
      (memories) => emit(LoadedState(memories)),
    );
  }
}
