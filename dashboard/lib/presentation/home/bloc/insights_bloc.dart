import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/models/insights_model.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class InsightsBloc extends GenericBloc<void, InsightsModel> {
  InsightsBloc({required ISupabaseRepository repository})
    : super(
        fetchFunction: (_) async {
          return repository.insights();
        },
      );
}
