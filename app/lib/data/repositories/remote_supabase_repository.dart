import 'dart:typed_data';

import 'package:fpdart/src/either.dart';
import 'package:memories/core/api/api_service.dart';
import 'package:memories/core/failure.dart';
import 'package:memories/data/models/transcript_response_model.dart';
import 'package:memories/data/repositories/interfaces/i_remote_supabase_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteSupabaseRepository implements IRemoteSupabaseRepository {
  RemoteSupabaseRepository({
    required ApiService supabaseService,
    required SupabaseClient supabase,
  }) : _supabaseService = supabaseService,
       _supabase = supabase;

  final ApiService _supabaseService;
  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, TranscriptResponseModel>> transcriptAndSaveMemory({
    required Uint8List audioBytes,
  }) async {
    try {
      final transcriptRes = await _supabaseService.postMultipartBytes(
        endpoint: 'v1/transcript-audio',
        bytes: audioBytes,
        filename: 'tau_file.mp4',
      );

      final transcript = transcriptRes.data['text'] as String;

      final save = await _supabase.from('memories').insert({
        'content': transcript,
      }).select();

      final List<Map<String, dynamic>> data = save;
      final memoryId = data[0]['id'] as int;

      final res = TranscriptResponseModel(
        transcript: transcript,
        idMemory: memoryId,
      );

      return Right(res);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePeopleRelation({
    required int memoryId,
    required List<String> peopleNames,
    required Map<String, String> peopleRoles,
  }) async {
    try {
      const ownerUserId = 'aeeab61b-3554-44f8-966a-8754559402d3';

      for (final personName in peopleNames) {
        // 1. Check if person exists (by display_name OR alias) or create
        final existingPerson = await _supabase
            .from('people')
            .select('id')
            .eq('owner_user_id', ownerUserId)
            .or('display_name.ilike.$personName,alias.ilike.$personName')
            .maybeSingle();

        String personId;

        if (existingPerson != null) {
          personId = existingPerson['id'] as String;
        } else {
          final newPerson = await _supabase
              .from('people')
              .insert({
                'owner_user_id': ownerUserId,
                'display_name': personName,
              })
              .select('id')
              .single();
          personId = newPerson['id'] as String;
        }

        // 2. Link person to memory with role
        final role = peopleRoles[personName];
        await _supabase.from('memory_person').upsert({
          'memory_id': memoryId,
          'person_id': personId,
          'role': role,
        });
      }

      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
