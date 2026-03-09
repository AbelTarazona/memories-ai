import 'dart:convert';
import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:memories_web_admin/core/app_prompts.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/empathetic_response_model.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';

class LangchainOpenAiRepository implements IOpenAIRepository {
  final ChatOpenAI _chatModel;

  LangchainOpenAiRepository(this._chatModel);

  @override
  Future<Either<Failure, EmpatheticResponseModel>> naturalResponse({
    required String inputJson,
  }) async {
    try {
      final prompt = ChatPromptTemplate.fromPromptMessages([
        SystemChatMessagePromptTemplate.fromTemplate(
          AppPrompts.empatheticMemory,
        ),
        HumanChatMessagePromptTemplate.fromTemplate('{inputJson}'),
      ]);

      final chain = prompt.pipe(_chatModel).pipe(const StringOutputParser());

      final res = await chain.invoke({'inputJson': inputJson});

      log(
        'Langchain Response Content: $res',
        name: 'LangchainOpenAiRepository.naturalResponse',
      );

      if (res.isEmpty) {
        return left(Failure('Empty response from Langchain'));
      }

      // Cleanup JSON if needed (in case the model wraps it in markdown blocks)
      final cleanRes = res
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final map = json.decode(cleanRes) as Map<String, dynamic>;
      final response = EmpatheticResponseModel.fromJson(map);

      return right(response);
    } catch (e) {
      log(e.toString(), name: 'LangchainOpenAiRepository.naturalResponse');
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
      final prompt = ChatPromptTemplate.fromPromptMessages([
        SystemChatMessagePromptTemplate.fromTemplate(AppPrompts.memoryCurator),
        HumanChatMessagePromptTemplate.fromTemplate('{input}'),
      ]);

      final chain = prompt.pipe(_chatModel).pipe(const StringOutputParser());

      final res = await chain.invoke({'input': input});

      log(
        'Langchain Response Content: $res',
        name: 'LangchainOpenAiRepository.memoryCurator',
      );

      if (res.isEmpty) {
        return left(Failure('Empty response from Langchain'));
      }

      final cleanRes = res
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final map = json.decode(cleanRes) as Map<String, dynamic>;
      final response = List<String>.from(map['questions'] ?? []);

      return right(response);
    } catch (e) {
      log(e.toString(), name: 'LangchainOpenAiRepository.memoryCurator');
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PersonInsightModel>> generatePersonProfile({
    required String personName,
    required List<MemoryModel> memories,
  }) async {
    try {
      final memoriesJson = jsonEncode(
        memories
            .map(
              (m) => {
                'content': m.content,
                'created_at': m.createdAt.toIso8601String(),
                'ai_overall_tone': m.aiOverallTone,
                'ai_emotional_intensity': m.aiEmotionalIntensity,
              },
            )
            .toList(),
      );

      final input = jsonEncode({
        'display_name': personName,
        'memories': memoriesJson,
      });

      final prompt = ChatPromptTemplate.fromPromptMessages([
        SystemChatMessagePromptTemplate.fromTemplate(
          AppPrompts.peopleProfileIntelligence,
        ),
        HumanChatMessagePromptTemplate.fromTemplate('{input}'),
      ]);

      // gpt-4o equivalent setup can be done dynamically or initialized in the DI layer.
      // We assume _chatModel is configured correctly or we can override it here if needed.
      // E.g., _chatModel.copyWith(model: 'gpt-4o') if supported, but typically we inject the right one.

      final chain = prompt.pipe(_chatModel).pipe(const StringOutputParser());

      final res = await chain.invoke({'input': input});

      log(
        'Langchain Response Content: $res',
        name: 'LangchainOpenAiRepository.generatePersonProfile',
      );

      if (res.isEmpty) {
        return left(Failure('Empty response from Langchain'));
      }

      final cleanRes = res
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final map = json.decode(cleanRes) as Map<String, dynamic>;

      final insight = PersonInsightModel.fromJson({
        ...map,
        'person_id': '',
        'user_id': '',
        'model_used':
            'gpt-4o', // Consider extracting this to a constant or variable based on actual model
        'analyzed_at': DateTime.now().toIso8601String(),
        'source_memories_count': memories.length,
      });

      return right(insight);
    } catch (e) {
      log(
        e.toString(),
        name: 'LangchainOpenAiRepository.generatePersonProfile',
      );
      return left(Failure(e.toString()));
    }
  }
}
