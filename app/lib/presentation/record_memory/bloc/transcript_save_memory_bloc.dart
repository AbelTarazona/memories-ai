import 'dart:typed_data';

import 'package:memories/core/bloc/generic_bloc.dart';
import 'package:memories/data/models/transcript_response_model.dart';
import 'package:memories/data/repositories/interfaces/i_remote_supabase_repository.dart';

class TranscriptSaveMemoryBloc extends GenericBloc<Uint8List, TranscriptResponseModel> {
  TranscriptSaveMemoryBloc({required IRemoteSupabaseRepository repository})
    : super(
        fetchFunction: (audioBytes) async {
          if (audioBytes == null) {
            throw Exception('Image bytes cannot be null');
          }
          return repository.transcriptAndSaveMemory(audioBytes: audioBytes);
        },
      );
}
