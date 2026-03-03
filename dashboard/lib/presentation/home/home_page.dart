import 'package:flutter/material.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/presentation/home/widgets/emotional_heatmap_stats.dart';
import 'package:memories_web_admin/presentation/home/widgets/insights_stats.dart';
import 'package:memories_web_admin/presentation/home/widgets/lesson_learned_stats.dart';
import 'package:memories_web_admin/presentation/home/widgets/memories_counter_stats.dart';
import 'package:memories_web_admin/presentation/home/widgets/people_stats.dart';
import 'package:memories_web_admin/presentation/home/widgets/quote_stats.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: '👋 ¡Hola Abel!',
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 36),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.grey3),
              ),
              child: Column(
                children: [
                  MemoriesCounterStats(),
                  InsightsStats(),
                  EmotionalHeatmapStats(),
                  PeopleStats(),
                  Row(
                    children: [
                      Expanded(child: QuoteStats()),
                      Expanded(child: LessonLearnedStats()),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
