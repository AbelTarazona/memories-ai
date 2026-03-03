import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/widgets/app_sidebar.dart';
import 'package:memories_web_admin/presentation/home/bloc/insights_bloc.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memories_list_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  void initState() {
    super.initState();
    context.read<MemoriesListBloc>().add(const FetchEvent<MemoriesFilterParams>(MemoriesFilterParams()));
    context.read<InsightsBloc>().add(FetchEvent(null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          AppSidebar(navigationShell: widget.navigationShell),
          Expanded(
            child: Container(
              color: AppColors.backgroundContent,
              child: widget.navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
