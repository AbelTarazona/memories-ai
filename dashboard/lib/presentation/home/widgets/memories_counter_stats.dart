import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/widgets/container_shimmer.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memories_list_bloc.dart';

class MemoriesCounterStats extends StatelessWidget {
  const MemoriesCounterStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey3,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppText(
            text: 'Tienes ',
            fontSize: 24,
            height: 1,
          ),
          BlocBuilder<MemoriesListBloc, BaseState<List<MemoryModel>>>(
            builder: (context, state) {
              if (state is LoadingState<List<MemoryModel>>) {
                return ContainerShimmer(
                  width: 30,
                  height: 30,
                );
              } else if (state is LoadedState<List<MemoryModel>>) {
                final memoriesCount = state.data.length;
                return AppText(
                  text: '$memoriesCount',
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w600,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          AppText(
            text: ' memorias',
            fontSize: 24,
            height: 1,
          ),
        ],
      ),
    );
  }
}
