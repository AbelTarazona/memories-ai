import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/people_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class PeopleListBloc extends GenericBloc<String?, List<PeopleModel>> {
  PeopleListBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (gender) async {
          return repository.people(gender: gender);
        },
      );
}
