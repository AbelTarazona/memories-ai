import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/failure.dart';
import 'package:memories_web_admin/data/models/person_insight_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/people/bloc/person_insights_event.dart';

class PersonInsightsBloc
    extends Bloc<PersonInsightsEvent, BaseState<PersonInsightModel>> {
  final ISupabaseRepository supabaseRepository;
  final IOpenAIRepository openAiRepository;

  PersonInsightsBloc({
    required this.supabaseRepository,
    required this.openAiRepository,
  }) : super(const InitialState()) {
    on<FetchPersonInsights>(_onFetch);
  }

  Future<void> _onFetch(
    FetchPersonInsights event,
    Emitter<BaseState<PersonInsightModel>> emit,
  ) async {
    emit(const LoadingState());

    // 1. If forceReload is true, skip DB check and go straight to generation
    if (event.forceReload) {
      await _generateAndSave(event, emit);
      return;
    }

    // 2. Try to get from database
    final dbResult = await supabaseRepository.getPersonInsights(event.personId);

    await dbResult.fold(
      (failure) async => emit(ErrorState(failure)),
      (insight) async {
        if (insight != null) {
          emit(LoadedState(insight));
        } else {
          // 3. If not found, fetch memories and generate
          await _generateAndSave(event, emit);
        }
      },
    );
  }

  Future<void> _generateAndSave(
    FetchPersonInsights event,
    Emitter<BaseState<PersonInsightModel>> emit,
  ) async {
    final memoriesResult = await supabaseRepository.getMemoriesForPerson(
      event.personId,
    );

    await memoriesResult.fold(
      (failure) async => emit(ErrorState(failure)),
      (memories) async {
        if (memories.isEmpty) {
          emit(ErrorState(Failure('No hay memorias para analizar.')));
          return;
        }

        final generationResult = await openAiRepository.generatePersonProfile(
          personName: event.personName,
          memories: memories,
        );

        await generationResult.fold(
          (failure) async => emit(ErrorState(failure)),
          (generatedInsight) async {
            // Reconstruct with correct IDs
            // The generated insight has empty IDs.
            // We use a copyWith-like approach (recreating the object)
            final completeInsight = PersonInsightModel(
              personId: event.personId,
              userId: '', // Will be filled by repository
              summary: generatedInsight.summary,
              dominantRole: generatedInsight.dominantRole,
              emotionalImpact: generatedInsight.emotionalImpact,
              relationshipEvolution: generatedInsight.relationshipEvolution,
              keyThemes: generatedInsight.keyThemes,
              representativeQuotes: generatedInsight.representativeQuotes,
              riskFlags: generatedInsight.riskFlags,
              confidenceScore: generatedInsight.confidenceScore,
              sourceMemoriesCount: memories.length,
              analyzedAt: DateTime.now(),
              modelUsed: generatedInsight.modelUsed,
            );

            // 3. Save to database
            final saveResult = await supabaseRepository.savePersonInsights(
              completeInsight,
            );

            await saveResult.fold(
              (failure) async => emit(ErrorState(failure)),
              (_) async => emit(LoadedState(completeInsight)),
            );
          },
        );
      },
    );
  }
}
