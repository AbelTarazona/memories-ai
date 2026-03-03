import 'package:fpdart/fpdart.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/empathetic_response_model.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';

abstract class IOpenAIRepository {
  Future<Either<Failure, EmpatheticResponseModel>> naturalResponse({
    required String inputJson,
  });

  Future<Either<Failure, List<String>>> memoryCurator({
    required MemoryModel memory,
  });

  Future<Either<Failure, PersonInsightModel>> generatePersonProfile({
    required String personName,
    required List<MemoryModel> memories,
  });
}
