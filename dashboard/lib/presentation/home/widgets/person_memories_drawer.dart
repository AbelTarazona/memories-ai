import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/widgets/container_shimmer.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/presentation/home/bloc/person_memories_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';

class PersonMemoriesDrawer extends StatelessWidget {
  final String personName;

  const PersonMemoriesDrawer({
    super.key,
    required this.personName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 500,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: AppColors.grey3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.user,
                    color: AppColors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: personName,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        text: 'Memorias relacionadas',
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child:
                BlocBuilder<PersonMemoriesBloc, BaseState<List<MemoryModel>>>(
                  builder: (context, state) {
                    if (state is LoadingState<List<MemoryModel>>) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 3,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ContainerShimmer(
                            width: double.infinity,
                            height: 150,
                          ),
                        ),
                      );
                    }

                    if (state is ErrorState<List<MemoryModel>>) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.circleAlert,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            AppText(
                              text: 'Error al cargar las memorias',
                              color: Colors.red,
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is LoadedState<List<MemoryModel>>) {
                      final memories = state.data;

                      if (memories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.inbox,
                                color: AppColors.grey,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              AppText(
                                text: 'No hay memorias con esta persona',
                                color: AppColors.grey,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: memories.length,
                        itemBuilder: (context, index) {
                          final memory = memories[index];
                          return _MemoryCard(memory: memory);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryModel memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es');
    final formattedDate = dateFormat.format(memory.createdAt);

    return InkWell(
      onTap: () {
        // Close the drawer first
        Navigator.of(context).pop();
        // Navigate to memory detail
        context.go('/memories/${memory.id}');
      },
      borderRadius: BorderRadius.circular(12),
      hoverColor: AppColors.blue.withOpacity(0.05),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    text: memory.aiTitle ?? 'Sin título',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey4,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AppText(
                    text: formattedDate,
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Content preview
            AppText(
              text: memory.content,
              fontSize: 14,
              color: AppColors.grey,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            // Feelings
            if (memory.aiFeelings != null && memory.aiFeelings!.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: memory.aiFeelings!.take(3).map((feeling) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: AppText(
                      text: feeling,
                      fontSize: 12,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
