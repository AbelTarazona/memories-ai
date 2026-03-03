import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class DeletePersonBloc extends GenericBloc<String, void> {
  DeletePersonBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (id) async {
          return repository.deletePerson(id!);
        },
      );
}
