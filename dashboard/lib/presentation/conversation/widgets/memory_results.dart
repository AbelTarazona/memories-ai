import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_search_model.dart';

class MemoryResults extends StatelessWidget {
  const MemoryResults({super.key, required this.memories});

  final List<MemorySearchModel> memories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          text: 'Esto es lo que encontré:',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 12),
        ...List.generate(memories.length, (index) {
          final memory = memories[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == memories.length - 1 ? 0 : 12,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sideBarBackground),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: memory.aiTitle ?? 'Sin título',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: memory.content ?? '',
                      fontSize: 14,
                      color: AppColors.grey,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
