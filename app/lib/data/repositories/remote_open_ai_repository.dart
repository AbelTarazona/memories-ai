import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:fpdart/src/either.dart';
import 'package:memories/core/api/api_service.dart';
import 'package:memories/core/app_prompts.dart';
import 'package:memories/core/failure.dart';
import 'package:memories/core/helpers/person_enrich/moment_enricher.dart';
import 'package:memories/core/helpers/person_enrich/person_description_builder.dart';
import 'package:memories/core/open_ai_helper.dart';
import 'package:memories/data/models/ai_memory_model.dart';
import 'package:memories/data/models/memory_analysis_result.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/transcript_model.dart';
import 'package:memories/data/repositories/interfaces/i_remote_open_ai_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RemoteOpenAIRepository implements IRemoteOpenAiRepository {
  RemoteOpenAIRepository({
    required ApiService openAiService,
    required SupabaseClient supabase,
  }) : _openAiService = openAiService,
       _supabase = supabase;

  final ApiService _openAiService;

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, TranscriptModel>> analyzeMemory({
    required String transcript,
    required int memoryId,
    required List<PeopleModel> people,
  }) async {
    try {
      // Step 1: Consolidated analysis + prompt generation (OPTIMIZED: single API call)
      final analysisResult = await analyzeMemoryAndGeneratePrompt(
        memory: transcript,
        memoryId: memoryId,
      );

      return analysisResult.fold(
        (failure) => left(Failure(failure.message)),
        (result) async {
          final aiMemoryModel = result.aiMemory;
          final imagePrompt = result.imagePrompt;

          // Enrich the prompt with the memory text and the people involved
          final enricher = MomentEnricher();
          final enrichedMoment = enricher.enrich(
            mainMoment: aiMemoryModel.mainRepresentativeMoment,
            people: aiMemoryModel.people,
            peopleRoles: aiMemoryModel.peopleRoles,
            peopleList: people,
          );
          final enrichedFullMemory = enricher.enrich(
            mainMoment: transcript,
            people: aiMemoryModel.people,
            peopleRoles: aiMemoryModel.peopleRoles,
            peopleList: people,
          );
          final owner = people.firstWhereOrNull((person) => person.isSelf);
          final ownerDescription = owner != null
              ? PersonDescriptionBuilder().build(owner)
              : null;

          final enrichedInput =
              '''
                {
                  "full_memory_context": $enrichedFullMemory,
                  "memory_owner": ${ownerDescription ?? ''},
                  "representative_moment": $enrichedMoment
                }
              ''';

          // Combine enriched context with AI-generated prompt for better image quality
          final finalImagePrompt =
              '''
            Context: $enrichedInput
            
            Base prompt: $imagePrompt
          ''';

          // Step 2: Generate image with the enriched prompt
          final imageResult = await convertMomentToImage(
            representativeMomentPrompt: finalImagePrompt,
            memoryId: memoryId,
          );

          return imageResult.fold(
            (failure) => left(Failure(failure.message)),
            (imageUrl) async {
              return right(
                TranscriptModel(
                  memory: aiMemoryModel,
                  image: imageUrl,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> convertMomentToImage({
    required String representativeMomentPrompt,
    required int memoryId,
  }) async {
    final body = {
      'model': 'gpt-image-1',
      'prompt': representativeMomentPrompt,
      'size': '1024x1024',
    };

    try {
      final response = await _openAiService.post<Map<String, dynamic>>(
        'v1/images/generations',
        data: body,
      );

      // Extrae la URL de la imagen generada
      final b64json = response['data'][0]['b64_json'];

      if (b64json == null) {
        return left(Failure('No se pudo extraer la imagen'));
      }

      final imageBytes = OpenAiHelper.decodeBase64Image(b64json);

      final imageName = 'memory_$memoryId';

      // Upload the image to Supabase storage
      await _supabase.storage
          .from('memories')
          .uploadBinary(
            imageName,
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      final publicUrl = _supabase.storage
          .from('memories')
          .getPublicUrl(imageName);

      // Actualiza el registro en Supabase
      await _supabase
          .from('memories')
          .update({
            'ai_image': publicUrl,
          })
          .eq('id', memoryId);

      return right(publicUrl);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiMemoryModel>> extractDataFromMemory({
    required String memory,
    required int memoryId,
  }) async {
    final input =
        '''
    {
      "text": "$memory",
      "reference_datetime": "${DateTime.now().toIso8601String()}"
    }
    ''';

    final body = {
      'model': 'gpt-5-nano',
      'input': [
        {
          'role': 'system',
          'content': AppPrompts.memoryAnalyzerPrompt,
        },
        {
          'role': 'user',
          'content': input,
        },
      ],
    };

    try {
      final response = await _openAiService.post<Map<String, dynamic>>(
        'v1/responses',
        data: body,
      );

      // Extrae el contenido JSON string de la respuesta
      final jsonContent = OpenAiHelper.extractOutputText(response);

      if (jsonContent == null) {
        return left(Failure('No se pudo extraer el contenido de la respuesta'));
      }

      // Convierte el JSON string a AiMemoryModel
      final aiMemoryModel = AiMemoryModel.fromInnerJson(jsonContent);

      // Actualiza el registro en Supabase
      await _supabase
          .from('memories')
          .update({
            'ai_title': aiMemoryModel.title,
            'ai_feelings': aiMemoryModel.feelings,
            'ai_representative_moments': aiMemoryModel.representativeMoments,
            'ai_main_representative_moment':
                aiMemoryModel.mainRepresentativeMoment,
            'ai_people': aiMemoryModel.people,
            'ai_people_roles': aiMemoryModel.peopleRoles,
            'ai_places': aiMemoryModel.places,
            'ai_objects': aiMemoryModel.objects,
            'ai_actions': aiMemoryModel.actions,
            'ai_temporal_context': aiMemoryModel.temporalContext,
            'ai_overall_tone': aiMemoryModel.overallTone,
            'ai_category': aiMemoryModel.category,
            'ai_key_topics': aiMemoryModel.keyTopics,
            'ai_highlighted_quote': aiMemoryModel.highlightedQuote,
            'ai_sensorial_elements': aiMemoryModel.sensorialElements,
            'ai_lessons_learned': aiMemoryModel.lessonsLearned,
            'ai_emotional_intensity': aiMemoryModel.emotionalIntensity,
            'ai_event_duration': aiMemoryModel.eventDuration,
            'normalized_date': aiMemoryModel.normalizedDate,
          })
          .eq('id', memoryId);

      return right(aiMemoryModel);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getPromptForRepresentativeMoment({
    required String representativeMoment,
    required int memoryId,
  }) async {
    final body = {
      'model': 'gpt-5-nano',
      'input': [
        {
          'role': 'system',
          'content': AppPrompts.imagePromptGenerator,
        },
        {
          'role': 'user',
          'content': representativeMoment,
        },
      ],
    };

    try {
      final response = await _openAiService.post<Map<String, dynamic>>(
        'v1/responses',
        data: body,
      );

      // Extrae el contenido JSON string de la respuesta
      final content = OpenAiHelper.extractOutputText(response);

      if (content == null) {
        return left(Failure('No se pudo extraer el contenido de la respuesta'));
      }

      await _supabase
          .from('memories')
          .update({
            'ai_image_prompt': content,
          })
          .eq('id', memoryId);

      return right(content);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemoryAnalysisResult>> analyzeMemoryAndGeneratePrompt({
    required String memory,
    required int memoryId,
  }) async {
    // Combined prompt that generates both analysis and image prompt in one call
    final input =
        '''
    {
      "text": "$memory",
      "reference_datetime": "${DateTime.now().toIso8601String()}"
    }
    ''';

    final body = {
      'model': 'gpt-5-nano',
      'input': [
        {
          'role': 'system',
          'content': AppPrompts.memoryAnalyzerWithImagePrompt,
        },
        {
          'role': 'user',
          'content': input,
        },
      ],
    };

    try {
      final response = await _openAiService.post<Map<String, dynamic>>(
        'v1/responses',
        data: body,
      );

      final jsonContent = OpenAiHelper.extractOutputText(response);

      if (jsonContent == null) {
        return left(Failure('No se pudo extraer el contenido de la respuesta'));
      }

      // Parse the combined response
      final Map<String, dynamic> parsedJson = jsonDecode(jsonContent);
      final aiMemoryModel = AiMemoryModel.fromMap(parsedJson['analysis']);
      final imagePrompt = parsedJson['image_prompt'] as String;

      // Single batch update to Supabase with all fields
      await _supabase
          .from('memories')
          .update({
            'ai_title': aiMemoryModel.title,
            'ai_feelings': aiMemoryModel.feelings,
            'ai_representative_moments': aiMemoryModel.representativeMoments,
            'ai_main_representative_moment':
                aiMemoryModel.mainRepresentativeMoment,
            'ai_people': aiMemoryModel.people,
            'ai_people_roles': aiMemoryModel.peopleRoles,
            'ai_places': aiMemoryModel.places,
            'ai_objects': aiMemoryModel.objects,
            'ai_actions': aiMemoryModel.actions,
            'ai_temporal_context': aiMemoryModel.temporalContext,
            'ai_overall_tone': aiMemoryModel.overallTone,
            'ai_category': aiMemoryModel.category,
            'ai_key_topics': aiMemoryModel.keyTopics,
            'ai_highlighted_quote': aiMemoryModel.highlightedQuote,
            'ai_sensorial_elements': aiMemoryModel.sensorialElements,
            'ai_lessons_learned': aiMemoryModel.lessonsLearned,
            'ai_emotional_intensity': aiMemoryModel.emotionalIntensity,
            'ai_event_duration': aiMemoryModel.eventDuration,
            'normalized_date': aiMemoryModel.normalizedDate,
            'ai_image_prompt': imagePrompt,
          })
          .eq('id', memoryId);

      return right(
        MemoryAnalysisResult(
          aiMemory: aiMemoryModel,
          imagePrompt: imagePrompt,
        ),
      );
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
