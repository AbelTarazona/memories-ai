import 'package:fpdart/fpdart.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/insights_model.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/memory_search_model.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';
import 'package:memories_web_admin/data/models/people_model.dart';
import 'package:memories_web_admin/data/models/person_traits_model.dart';
import 'package:memories_web_admin/data/models/user_model.dart';
import 'package:memories_web_admin/data/models/graph_model.dart';
import 'package:memories_web_admin/data/models/memory_question_model.dart';
import 'package:memories_web_admin/data/models/memory_notes_model.dart';

abstract class ISupabaseRepository {
  Future<Either<Failure, void>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> isAuthenticated();

  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, List<MemoryModel>>> memories({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, MemoryModel>> memoryById(int id);

  Future<Either<Failure, List<PeopleModel>>> people({
    String? gender,
    String? searchTerm,
  });

  Future<Either<Failure, void>> createPerson({
    required String displayName,
    required PersonTraitsModel traits,
    String? alias,
    String? gender,
    String? ageRange,
    String? height,
  });

  Future<Either<Failure, void>> updatePerson({
    required String id,
    required String displayName,
    required PersonTraitsModel traits,
    String? alias,
    String? gender,
    String? ageRange,
    String? height,
  });

  Future<Either<Failure, List<MemorySearchModel>>> searchMemories({
    required String query,
  });

  Future<Either<Failure, List<MemorySearchModel>>> getMemoriesByIds(
    List<String> ids,
  );

  Future<Either<Failure, InsightsModel>> insights();

  Future<Either<Failure, GraphData>> getPeopleCooccurrenceGraph();

  Future<Either<Failure, List<MemoryQuestionModel>>> getMemoryQuestions(
    int memoryId,
  );

  Future<Either<Failure, MemoryQuestionModel>> saveMemoryQuestion({
    required int memoryId,
    required String question,
    String? answer,
  });

  Future<Either<Failure, void>> updateMemoryQuestion(
    MemoryQuestionModel question,
  );

  Future<Either<Failure, void>> deleteMemoryQuestion(int id);

  Future<Either<Failure, void>> deletePerson(String id);
  Future<Either<Failure, void>> updateMemory(MemoryModel memory);

  /// Get all memories where a specific person is mentioned
  Future<Either<Failure, List<MemoryModel>>> memoriesByPerson({
    required String personName,
  });
  Future<Either<Failure, PersonInsightModel?>> getPersonInsights(
    String personId,
  );

  Future<Either<Failure, void>> savePersonInsights(PersonInsightModel insight);

  Future<Either<Failure, List<MemoryModel>>> getMemoriesForPerson(
    String personId,
  );

  Future<Either<Failure, void>> saveMemoryNotes(List<MemoryNoteModel> notes);
}
