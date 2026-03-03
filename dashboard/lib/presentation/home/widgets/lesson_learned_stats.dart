import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/widgets/background_stats.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memories_list_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LessonLearnedStats extends StatelessWidget {
  const LessonLearnedStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      padding: EdgeInsets.symmetric(
        horizontal: 27,
        vertical: 20,
      ),
      child: Column(
        children: [
          BackgroundStats(
            child: Row(
              children: [
                Icon(
                  LucideIcons.bookOpenCheck,
                  color: AppColors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                AppText(
                  text: '¿Qué aprendí?',
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 33),
          Expanded(
            child: BlocBuilder<MemoriesListBloc, BaseState<List<MemoryModel>>>(
              builder: (context, state) {
                if (state is LoadingState<List<MemoryModel>>) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LoadedState<List<MemoryModel>>) {
                  final lessons = state.data
                      .where(
                        (m) =>
                            m.aiLessonsLearned != null &&
                            m.aiLessonsLearned!.isNotEmpty,
                      )
                      .expand((m) => m.aiLessonsLearned!)
                      .toList();

                  if (lessons.isEmpty) {
                    return Center(
                      child: AppText(
                        text: 'No hay lecciones aprendidas disponibles',
                        fontStyle: FontStyle.italic,
                        color: AppColors.grey2,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Pick the first one for now
                  final lesson = lessons.first;

                  return BackgroundStats(
                    color: AppColors.backgroundContent,
                    child: Center(
                      child: AppText(
                        text: "``$lesson``",
                        fontStyle: FontStyle.italic,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
