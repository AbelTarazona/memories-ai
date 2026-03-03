import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:memories/core/failure.dart';
import 'package:memories/data/models/transcript_model.dart';
import 'package:memories/data/models/transcript_response_model.dart';

abstract class IRemoteSupabaseRepository {
  Future<Either<Failure, TranscriptResponseModel>> transcriptAndSaveMemory({
    required Uint8List audioBytes,
  });

  Future<Either<Failure, void>> savePeopleRelation({
    required int memoryId,
    required List<String> peopleNames,
    required Map<String, String> peopleRoles,
  });
}
