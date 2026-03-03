import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/widgets/background_stats.dart';
import 'package:memories_web_admin/core/widgets/container_shimmer.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/graph_model.dart';
import 'package:memories_web_admin/presentation/home/bloc/network_graph_bloc.dart';
import 'package:memories_web_admin/presentation/home/widgets/people_graph.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PeopleStats extends StatefulWidget {
  const PeopleStats({super.key});

  @override
  State<PeopleStats> createState() => _PeopleStatsState();
}

class _PeopleStatsState extends State<PeopleStats> {
  @override
  void initState() {
    super.initState();
    // Dispatch fetch event on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkGraphBloc>().add(const FetchEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackgroundStats(
            child: Row(
              children: [
                Icon(
                  LucideIcons.gitGraph,
                  color: AppColors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                AppText(
                  text: 'Grafo de co-ocurrencias entre personas',
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppText(text: 'Co-ocurrencias en tus memorias'),
          const SizedBox(height: 12),
          SizedBox(
            height: 450,
            child: BlocBuilder<NetworkGraphBloc, BaseState<GraphData>>(
              builder: (context, state) {
                if (state is LoadingState<GraphData>) {
                  return const ContainerShimmer(
                    width: double.infinity,
                    height: 450,
                  );
                }

                if (state is ErrorState<GraphData>) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.circleAlert, color: Colors.red),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar el grafo',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (state is LoadedState<GraphData>) {
                  return PeopleGraphV2(
                    data: state.data,
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
