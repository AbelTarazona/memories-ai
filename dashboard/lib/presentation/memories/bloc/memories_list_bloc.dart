import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class MemoriesFilterParams {
  const MemoriesFilterParams({
    this.startDate,
    this.endDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;
}

class MemoriesListBloc extends GenericBloc<MemoriesFilterParams, List<MemoryModel>> {
  MemoriesListBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (params) async {
          return repository.memories(
            startDate: params?.startDate,
            endDate: params?.endDate,
          );
        },
      );
}
