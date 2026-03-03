import 'dart:convert';
import 'dart:developer';

import 'package:fpdart/src/either.dart';
import 'package:memories_web_admin/core/app_prompts.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/empathetic_response_model.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:openai_dart/openai_dart.dart';

class OpenAiRepository implements IOpenAIRepository {
  final OpenAIClient _client;

  OpenAiRepository(this._client);

  @override
  Future<Either<Failure, EmpatheticResponseModel>> naturalResponse({
    required String inputJson,
  }) async {
    try {
      final res = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.model(ChatCompletionModels.gpt5Nano),
          messages: [
            ChatCompletionMessage.developer(
              content: ChatCompletionDeveloperMessageContent.text(
                AppPrompts.empatheticMemory,
              ),
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(inputJson),
            ),
          ],
        ),
      );

      final content = res.choices.first.message.content;

      print('OpenAI Response Content: $content');

      if (content == null) {
        return left(Failure('Empty response from OpenAI'));
      }

      final map = json.decode(content) as Map<String, dynamic>;

      final response = EmpatheticResponseModel.fromJson(map);

      return right(response);
    } catch (e) {
      log(e.toString(), name: 'OpenAiRepository.naturalResponse');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> memoryCurator({
    required MemoryModel memory,
  }) async {
    final input =
        '''
        Here is the memory data:
        
        Content: ${memory.content}
        Title: ${memory.aiTitle ?? "N/A"}
        Feelings: ${memory.aiFeelings?.join(", ") ?? "N/A"}
        People: ${memory.aiPeople?.join(", ") ?? "N/A"}
        Places: ${memory.aiPlaces?.join(", ") ?? "N/A"}
        Objects: ${memory.aiObjects?.join(", ") ?? "N/A"}
        Actions: ${memory.aiActions?.join(", ") ?? "N/A"}
        Tone: ${memory.aiOverallTone ?? "N/A"}
        Key topics: ${memory.aiKeyTopics?.join(", ") ?? "N/A"}
        Highlighted quote: ${memory.aiHighlightedQuote ?? "N/A"}
    ''';

    try {
      final res = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.model(ChatCompletionModels.gpt5Nano),
          messages: [
            ChatCompletionMessage.developer(
              content: ChatCompletionDeveloperMessageContent.text(
                AppPrompts.memoryCurator,
              ),
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(input),
            ),
          ],
        ),
      );

      final content = res.choices.first.message.content;

      print('OpenAI Response Content: $content');

      if (content == null) {
        return left(Failure('Empty response from OpenAI'));
      }

      final map = json.decode(content) as Map<String, dynamic>;

      final response = List<String>.from(map['questions'] ?? []);

      return right(response);
    } catch (e) {
      log(e.toString(), name: 'OpenAiRepository.memoryCurator');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonInsightModel>> generatePersonProfile({
    required String personName,
    required List<MemoryModel> memories,
  }) async {
    try {
      final memoriesJson = memories
          .map(
            (m) => {
              'content': m.content,
              'created_at': m.createdAt.toIso8601String(),
              'ai_overall_tone': m.aiOverallTone,
              'ai_emotional_intensity': m.aiEmotionalIntensity,
            },
          )
          .toList();

      final input = jsonEncode({
        'display_name': personName,
        'memories': memoriesJson,
      });

      final res = await _client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: ChatCompletionModel.model(ChatCompletionModels.gpt4o),
          messages: [
            ChatCompletionMessage.developer(
              content: ChatCompletionDeveloperMessageContent.text(
                AppPrompts.peopleProfileIntelligence,
              ),
            ),
            ChatCompletionMessage.user(
              content: ChatCompletionUserMessageContent.string(input),
            ),
          ],
          // responseFormat: ChatCompletionResponseFormat.jsonObject,
        ),
      );

      var content = res.choices.first.message.content;
      log(
        'OpenAI Response Content: $content',
        name: 'OpenAiRepository.generatePersonProfile',
      );

      if (content == null) {
        return left(Failure('Empty response from OpenAI'));
      }

      content = content.replaceAll('```json', '').replaceAll('```', '').trim();

      final map = json.decode(content) as Map<String, dynamic>;

      final insight = PersonInsightModel.fromJson({
        ...map,
        'person_id': '',
        'user_id': '',
        'model_used': 'gpt-4o',
        'analyzed_at': DateTime.now().toIso8601String(),
        'source_memories_count': memories.length,
      });

      return right(insight);
    } catch (e) {
      log(e.toString(), name: 'OpenAiRepository.generatePersonProfile');
      return left(Failure(e.toString()));
    }
  }
}
