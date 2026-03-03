import 'package:fpdart/fpdart.dart';
import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';

class MemoryCuratorBloc extends GenericBloc<MemoryModel, List<String>> {
  MemoryCuratorBloc({required IOpenAIRepository repository})
    : super(
        fetchFunction: (params) async {
          if (params == null) {
            return left(Failure('No válido'));
          }
          return repository.memoryCurator(memory: params);
        },
      );
}
