import 'package:memories/core/bloc/generic_bloc.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';

class PeopleListBloc extends GenericBloc<void, List<PeopleModel>> {
  PeopleListBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (_) async {
          return repository.people();
        },
      );
}
