import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memories/core/app_colors.dart';
import 'package:memories/core/app_utils.dart';
import 'package:memories/core/helpers/animation_settings.dart';
import 'package:memories/core/bloc/base_state.dart';
import 'package:memories/core/bloc/fetch_event.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/floating_emojis_background.dart';
import 'package:memories/core/widgets/header_internals.dart';
import 'package:memories/core/widgets/text.dart';
import 'package:memories/data/models/full_screen_data.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/presentation/memories_list/bloc/memories_list_bloc.dart';
import 'package:memories/presentation/memories_list/widgets/reprocess_memory_button.dart';
import 'package:memories/presentation/record_memory/bloc/analyze_memory_bloc.dart';

class MemoryDetailPage extends StatefulWidget {
  const MemoryDetailPage({super.key, required this.memoryId});

  final int memoryId;

  @override
  State<MemoryDetailPage> createState() => _MemoryDetailPageState();
}

class _MemoryDetailPageState extends State<MemoryDetailPage> {
  final double _size = 320;

  late MemoryModel memory;
  bool _isDetailAnimationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAnimationPreference();
    _loadMemory();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BackgroundScreen(
      child: Stack(
        children: [
          Positioned.fill(
            child: _isDetailAnimationEnabled
                ? FloatingEmojisBackground(
                    assets: _getAssetsForMemory(),
                    burstDuration: const Duration(seconds: 5),
                    spawnRatePerSecond: 7,
                    maxParticles: 36,
                  )
                : const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                AppHeaderInternal(
                  title: 'Mis recuerdos',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        AppText(
                          text: memory.aiTitle ?? '---',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 29),
                        SizedBox(
                          width: _size,
                          child: Column(
                            children: [
                              // Mostrar botón si necesita reprocesar, sino mostrar imagen
                              if (memory.aiImage == null ||
                                  memory.aiImage!.isEmpty)
                                ReprocessMemoryButton(
                                  memory: memory,
                                  size: _size,
                                  onSuccess: _loadMemory,
                                )
                              else
                                InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  onTap: () {
                                    context.push(
                                      '/fullscreen',
                                      extra: FullScreenData(
                                        hero: 'hero-memory-${memory.id}',
                                        memory: memory,
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Hero(
                                          tag: 'hero-memory-${memory.id}',
                                          child: CachedNetworkImage(
                                            imageUrl: memory.aiImage ?? '',
                                            width: _size,
                                            height: _size,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                                  width: _size,
                                                  height: _size,
                                                  color: AppColors.grey
                                                      .withValues(
                                                        alpha: .1,
                                                      ),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                                      width: _size,
                                                      height: _size,
                                                      color: AppColors.grey
                                                          .withValues(
                                                            alpha: .1,
                                                          ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.error,
                                                          size: 20,
                                                          color: AppColors.grey,
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 13,
                                        right: 13,
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.zoom_out_map_rounded,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppText(
                                      text: AppUtils.getDateFromDateTime(
                                        memory.createdAt,
                                        withYear: true,
                                      ),
                                      color: AppColors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: AppText(
                                      text:
                                          memory.aiKeyTopics
                                              ?.map((e) => '#$e')
                                              .join(' ') ??
                                          '',
                                      color: AppColors.blue,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 82),
                        Center(
                          child: SizedBox(
                            width: size.width * 0.4,
                            child: Column(
                              children: [
                                if (memory.aiFeelings != null &&
                                    memory.aiFeelings!.isNotEmpty) ...[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: AppText(
                                          text: 'Emociones',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 30,
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            itemCount:
                                                memory.aiFeelings!.length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder:
                                                (
                                                  BuildContext context,
                                                  int index,
                                                ) {
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Image.asset(
                                                        AppUtils.emojiFeelingAsset(
                                                          memory
                                                              .aiFeelings![index],
                                                        ),
                                                        height: 30,
                                                      ),
                                                      const SizedBox(width: 10),
                                                      AppText(
                                                        text: memory
                                                            .aiFeelings![index],
                                                      ),
                                                    ],
                                                  );
                                                },
                                            separatorBuilder:
                                                (
                                                  BuildContext context,
                                                  int index,
                                                ) {
                                                  return const SizedBox(
                                                    width: 12,
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: AppText(
                                        text: 'Historia',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Expanded(
                                      child: AppText(
                                        text: memory.content,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadMemory() {
    final memoriesBloc = context.read<MemoriesListBloc>();
    final state = memoriesBloc.state;
    if (state is LoadedState<List<MemoryModel>>) {
      final memories = state.data;
      final foundMemory = memories.firstWhere(
        (memory) => memory.id == widget.memoryId,
      );
      setState(() {
        memory = foundMemory;
      });
    }
  }

  Future<void> _loadAnimationPreference() async {
    final isEnabled = await AnimationSettings.isMemoryDetailAnimationEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _isDetailAnimationEnabled = isEnabled;
    });
  }

  List<String> _getAssetsForMemory() {
    final assets = <String>[];
    if (memory.aiFeelings != null) {
      for (final feeling in memory.aiFeelings!) {
        final asset = AppUtils.emojiFeelingAsset(feeling);
        assets.add(asset);
      }
    }
    return assets;
  }
}
