import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/models/graph_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class NetworkGraphBloc extends GenericBloc<void, GraphData> {
  NetworkGraphBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (_) async {
          return repository.getPeopleCooccurrenceGraph();
        },
      );
}
