import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memories/core/bloc/base_state.dart';
import 'package:memories/core/bloc/fetch_event.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/header_internals.dart';
import 'package:memories/core/widgets/image_preview.dart';
import 'package:memories/core/widgets/text.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories/presentation/memories_list/bloc/memories_list_bloc.dart';

class MemoriesListPage extends StatelessWidget {
  const MemoriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MemoriesListContent();
  }
}

class MemoriesListContent extends StatefulWidget {
  const MemoriesListContent({super.key});

  @override
  State<MemoriesListContent> createState() => _MemoriesListContentState();
}

class _MemoriesListContentState extends State<MemoriesListContent> {
  @override
  Widget build(BuildContext context) {
    return BackgroundScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
            ),
            child: AppHeaderInternal(
              title: 'Memorias',
              description: 'Revive tus momentos capturados',
            ),
          ),
          BlocBuilder<MemoriesListBloc, BaseState<List<MemoryModel>>>(
            builder: (context, state) {
              if (state is LoadingState<List<MemoryModel>>) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is ErrorState<List<MemoryModel>>) {
                return Expanded(
                  child: Center(
                    child: Text(state.failure.message),
                  ),
                );
              } else if (state is LoadedState<List<MemoryModel>>) {
                final memories = state.data;
                if (memories.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text('No hay memorias disponibles.'),
                    ),
                  );
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: memories.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ImagePreview(
                              heroTag: 'preview-$index',
                              imagePath: memories[index].aiImage ?? '',
                              title: memories[index].content,
                              description: memories[index].createdAt.toString(),
                              onTap: () {
                                context.push(
                                  '/memories/${memories[index].id}',
                                  extra: memories[index],
                                );
                              },
                              width: double.infinity,
                            ),
                            const SizedBox(height: 10),
                            AppText(
                              text: memories[index].aiTitle ?? '---',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
