import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/app_utils.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/widgets/background_stats.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/insights_model.dart';
import 'package:memories_web_admin/presentation/home/bloc/insights_bloc.dart';
import 'package:memories_web_admin/presentation/home/widgets/square_emotion_level.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EmotionalHeatmapStats extends StatefulWidget {
  const EmotionalHeatmapStats({super.key});

  @override
  State<EmotionalHeatmapStats> createState() => _EmotionalHeatmapStatsState();
}

class _EmotionalHeatmapStatsState extends State<EmotionalHeatmapStats> {
  List<ContributionEntry> entries = [];

  late DateTime initialDate;

  late DateTime finalDate;

  @override
  void initState() {
    super.initState();
    initialDate = DateTime.now();
    finalDate = DateTime(initialDate.year, initialDate.month - 3, initialDate.day);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InsightsBloc, BaseState<InsightsModel>>(
      listener: (context, state) {
        if (state is LoadedState<InsightsModel>) {
          final data = state.data;
          setState(() {
            entries = data.dailyMood
                .map(
                  (e) => ContributionEntry(
                    e.date,
                    e.mood,
                  ),
                )
                .toList();
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 20,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.grey3,
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            BackgroundStats(
              child: Row(
                children: [
                  Icon(
                    LucideIcons.brickWallFire,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  AppText(
                    text: 'Mapa de calor emocional',
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey3),
              ),
              child: Column(
                children: [
                  Center(
                    child: ContributionHeatmap(
                      splittedMonthView: true,
                      showCellDate: true,
                      showWeekdayLabels: false,
                      cellSize: 30.0,
                      minDate: finalDate,
                      maxDate: initialDate,
                      colorScale: (value) {
                        if (value <= 1) return Color(0xFFF5F5F5);
                        if (value <= 3) return Color(0xFFDBEAFE);
                        if (value <= 5) return Color(0xFFBEDBFF);
                        if (value <= 6) return Color(0xFF7BF1A8);
                        if (value <= 8) return Color(0xFF05DF72);
                        if (value <= 10) return Color(0xFF00C950);
                        return Color(0xFFF5F5F5);
                      },
                      entries: entries,
                      onCellTap: (date, value) {
                        showShadDialog(
                          context: context,
                          builder: (context) => ShadDialog.alert(
                            title: AppText(
                              text: '${AppUtils.getDateFromDateTime(date, withYear: true)} ($value/10)',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            description: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(text: _getEmotionalIntensityDescription(value)),
                              ],
                            ),
                            actions: [
                              ShadButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    child: Row(
                      children: [
                        AppText(
                          text: 'Menos',
                          fontSize: 12,
                        ),
                        const SizedBox(width: 15),
                        SquareEmotionLevel(color: Color(0xFFF5F5F5)),
                        const SizedBox(width: 4),
                        SquareEmotionLevel(color: Color(0xFFDBEAFE)),
                        const SizedBox(width: 4),
                        SquareEmotionLevel(color: Color(0xFFBEDBFF)),
                        const SizedBox(width: 4),
                        SquareEmotionLevel(color: Color(0xFF7BF1A8)),
                        const SizedBox(width: 4),
                        SquareEmotionLevel(color: Color(0xFF05DF72)),
                        const SizedBox(width: 4),
                        SquareEmotionLevel(color: Color(0xFF00C950)),
                        const SizedBox(width: 15),
                        AppText(
                          text: 'Más emocional',
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmotionalIntensityDescription(int value) {
    if (value <= 1) {
      return 'Emoción casi nula. Estado neutral, calma total, sin carga emocional.';
    } else if (value <= 3) {
      return 'Emoción leve. Sensación ligera, tranquila, poco involucrada.';
    } else if (value <= 5) {
      return 'Emoción moderada. Hay reacción emocional, pero aún controlada y estable.';
    } else if (value <= 6) {
      return 'Emoción activa. La emoción se percibe con claridad, pero sigue siendo positiva o manejable.';
    } else if (value <= 8) {
      return 'Emoción intensa. Sentimiento fuerte, comprometido, claramente dominante.';
    } else {
      return 'Emoción máxima. Explosión emocional, intensidad muy alta, difícil de contener.';
    }
  }
}
