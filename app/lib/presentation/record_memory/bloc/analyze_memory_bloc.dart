import 'package:fpdart/fpdart.dart';
import 'package:memories/core/bloc/generic_bloc.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/transcript_model.dart';
import 'package:memories/data/repositories/interfaces/i_remote_open_ai_repository.dart';
import 'package:memories/data/repositories/interfaces/i_remote_supabase_repository.dart';

class AnalyzeMemoryParams {
  final String transcript;
  final int memoryId;
  final List<PeopleModel> people;

  AnalyzeMemoryParams({
    required this.transcript,
    required this.memoryId,
    required this.people,
  });
}

class AnalyzeMemoryBloc
    extends GenericBloc<AnalyzeMemoryParams, TranscriptModel> {
  AnalyzeMemoryBloc({
    required IRemoteOpenAiRepository repository,
    required IRemoteSupabaseRepository supabaseRepository,
  }) : super(
         fetchFunction: (params) async {
           if (params == null) {
             throw Exception('Params cannot be null');
           }
           final result = await repository.analyzeMemory(
             transcript: params.transcript,
             memoryId: params.memoryId,
             people: params.people,
           );

           return result.fold(
             (failure) async => Left(failure),
             (transcriptModel) async {
               // Save people relation
               if (transcriptModel.memory?.people.isNotEmpty ?? false) {
                 await supabaseRepository.savePeopleRelation(
                   memoryId: params.memoryId,
                   peopleNames: transcriptModel.memory!.people,
                   peopleRoles: transcriptModel.memory!.peopleRoles,
                 );
               }
               return Right(transcriptModel);
             },
           );
         },
       );
}
