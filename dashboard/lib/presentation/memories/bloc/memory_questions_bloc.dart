import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/bloc/generic_bloc.dart';
import 'package:memories_web_admin/data/models/memory_question_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';

class MemoryQuestionsBloc extends GenericBloc<int, List<MemoryQuestionModel>> {
  final ISupabaseRepository repository;

  MemoryQuestionsBloc({required this.repository})
    : super(
        fetchFunction: (memoryId) => repository.getMemoryQuestions(memoryId!),
      );

  Future<List<MemoryQuestionModel>> saveGeneratedQuestions({
    required int memoryId,
    required List<String> questions,
  }) async {
    final List<MemoryQuestionModel> savedQuestions = [];
    for (final question in questions) {
      final result = await repository.saveMemoryQuestion(
        memoryId: memoryId,
        question: question,
      );
      result.fold((_) {}, (q) => savedQuestions.add(q));
    }
    add(FetchEvent(memoryId));
    return savedQuestions;
  }

  Future<void> answerQuestion({
    required MemoryQuestionModel question,
    required String answer,
  }) async {
    final updatedQuestion = question.copyWith(
      userAnswer: answer,
      answered: true,
    );
    final result = await repository.updateMemoryQuestion(updatedQuestion);

    result.fold(
      (failure) {
        // Handle error if needed
      },
      (_) {
        // Refresh list
        add(FetchEvent(question.memoryId));
      },
    );
  }
}
