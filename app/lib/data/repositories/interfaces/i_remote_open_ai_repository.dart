import 'package:fpdart/fpdart.dart';
import 'package:memories/core/failure.dart';
import 'package:memories/data/models/ai_memory_model.dart';
import 'package:memories/data/models/memory_analysis_result.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/transcript_model.dart';

abstract class IRemoteOpenAiRepository {
  Future<Either<Failure, AiMemoryModel>> extractDataFromMemory({
    required String memory,
    required int memoryId,
  });

  Future<Either<Failure, String>> getPromptForRepresentativeMoment({
    required String representativeMoment,
    required int memoryId,
  });

  Future<Either<Failure, String>> convertMomentToImage({
    required String representativeMomentPrompt,
    required int memoryId,
  });

  Future<Either<Failure, TranscriptModel>> analyzeMemory({
    required String transcript,
    required int memoryId,
    required List<PeopleModel> people,
  });

  /// Optimized: Combines extractDataFromMemory + getPromptForRepresentativeMoment
  /// into a single API call to reduce latency
  Future<Either<Failure, MemoryAnalysisResult>> analyzeMemoryAndGeneratePrompt({
    required String memory,
    required int memoryId,
  });
}
