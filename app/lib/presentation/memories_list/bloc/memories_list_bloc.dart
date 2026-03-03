import 'package:memories/core/bloc/generic_bloc.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';

class MemoriesListBloc extends GenericBloc<void, List<MemoryModel>> {
  MemoriesListBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (_) async {
          return repository.memories();
        },
      );
}
