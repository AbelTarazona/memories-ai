import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/app_utils.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/widgets/container_shimmer.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/insights_model.dart';
import 'package:memories_web_admin/presentation/home/bloc/insights_bloc.dart';
import 'package:memories_web_admin/presentation/home/widgets/insight_data.dart';

class InsightsStats extends StatelessWidget {
  const InsightsStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: BlocBuilder<InsightsBloc, BaseState<InsightsModel>>(
        builder: (context, state) {
          if (state is LoadedState<InsightsModel>) {
            final data = state.data;
            return Row(
              children: <Widget>[
                Expanded(
                  child: InsightData(
                    title: 'Personas \nmencionadas',
                    content: AppText(
                      text: data.peopleMentionedQuantity,
                      textAlign: TextAlign.start,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InsightData(
                    title: 'Emoción \npredominante',
                    content: Row(
                      children: [
                        Image.asset(
                          AppUtils.emojiFeelingAsset(data.feelingPredominant),
                          height: 30,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          text: data.feelingPredominant,
                          textAlign: TextAlign.start,
                          fontSize: 26,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InsightData(
                    title: 'Racha actual',
                    content: AppText(
                      text: '${data.currentStreak} días',
                      textAlign: TextAlign.start,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InsightData(
                    title: 'Última memoria',
                    content: AppText(
                      text: data.lastMemoryDate,
                      textAlign: TextAlign.start,
                      fontSize: 26,
                    ),
                  ),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: ContainerShimmer(width: double.infinity, height: 106),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ContainerShimmer(width: double.infinity, height: 106),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ContainerShimmer(width: double.infinity, height: 106),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ContainerShimmer(width: double.infinity, height: 106),
              ),
            ],
          );
        },
      ),
    );
  }
}
