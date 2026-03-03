import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:memories/core/app_constants.dart';
import 'package:memories/core/helpers/animation_settings.dart';
import 'package:memories/core/bloc/base_state.dart';
import 'package:memories/core/bloc/fetch_event.dart';
import 'package:memories/core/widgets/background_screen.dart';
import 'package:memories/core/widgets/circular_button.dart';
import 'package:memories/core/widgets/header.dart';
import 'package:memories/core/widgets/ia_indicator.dart';
import 'package:memories/core/widgets/text.dart';
import 'package:memories/data/models/memory_model.dart';
import 'package:memories/data/models/people_model.dart';
import 'package:memories/data/models/transcript_model.dart';
import 'package:memories/data/models/transcript_response_model.dart';
import 'package:memories/presentation/home/bloc/people_list_bloc.dart';
import 'package:memories/presentation/home/widgets/top_toast.dart';
import 'package:memories/presentation/memories_list/bloc/memories_list_bloc.dart';
import 'package:memories/presentation/record_memory/bloc/analyze_memory_bloc.dart';
import 'package:memories/presentation/record_memory/bloc/transcript_save_memory_bloc.dart';
import 'package:memories/core/services/voice_command_service.dart';
import 'package:memories/core/services/voice_preferences.dart';
import 'package:memories/core/services/audio_response_service.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey _bgKey = GlobalKey();
  bool _isHomeAnimationEnabled = true;

  final VoiceCommandService _voiceService = VoiceCommandService();
  final AudioResponseService _audioService = AudioResponseService();
  StreamSubscription? _commandDetectedSubscription;
  bool _isProcessingCommand = false;

  @override
  void initState() {
    super.initState();
    _loadAnimationPreference();
    _loadPeople();
    _loadMemories();
    _setupVoiceListening();
  }


  @override
  void dispose() {
    _commandDetectedSubscription?.cancel();
    super.dispose();
  }

  Future<void> _setupVoiceListening() async {
    final hasPermission = await VoicePreferences.hasVoicePermission();
    if (!hasPermission) return;
    _commandDetectedSubscription = _voiceService.commandDetected.listen((_) => _onCommandDetected());
    await _voiceService.startListening();
  }

  Future<void> _onCommandDetected() async {
    if (!mounted || _isProcessingCommand) return;
    _isProcessingCommand = true;
    try {
      await _audioService.playWelcomeAudio();
      if (mounted) context.push('/record-memory', extra: {'autoStart': true});
    } catch (e) {
      if (mounted) context.push('/record-memory', extra: {'autoStart': true});
    } finally {
      Future.delayed(const Duration(seconds: 5), () { if (mounted) _isProcessingCommand = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const String heroTag = 'imageHero';
    final size = MediaQuery.sizeOf(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<
          TranscriptSaveMemoryBloc,
          BaseState<TranscriptResponseModel>
        >(
          listener: (context, state) {
            if (state is LoadingState<TranscriptResponseModel>) {
              TopToast.showAnchored(
                context,
                anchorKey: _bgKey,
                message: '✨ ${AppConstants.randomMemoryTitle()}',
                showFor: const Duration(seconds: 3),
              );
            } else if (state is LoadedState<TranscriptResponseModel>) {
              TopToast.hideAnchored(_bgKey);
              final people =
                  (context.read<PeopleListBloc>().state
                          as LoadedState<List<PeopleModel>>)
                      .data;
              context.read<AnalyzeMemoryBloc>().add(
                FetchEvent(
                  AnalyzeMemoryParams(
                    transcript: state.data.transcript,
                    memoryId: state.data.idMemory,
                    people: people,
                  ),
                ),
              );
            } else if (state is ErrorState<TranscriptResponseModel>) {
              TopToast.hideAnchored(_bgKey);
              log(state.failure.message);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                ),
              );
            }
          },
        ),
        BlocListener<AnalyzeMemoryBloc, BaseState<TranscriptModel>>(
          listener: (context, state) {
            if (state is LoadedState<TranscriptModel>) {
              context.read<MemoriesListBloc>().add(const FetchEvent(null));
              TopToast.showAnchored(
                context,
                anchorKey: _bgKey,
                message: '¡Memoria lista! 🫶',
                showFor: const Duration(seconds: 3),
              );
            } else if (state is ErrorState<TranscriptModel>) {
              TopToast.hideAnchored(_bgKey);
              log(state.failure.message);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure.message),
                ),
              );
            }
          },
        ),
      ],
      child: BackgroundScreen(
        key: _bgKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              if (_isHomeAnimationEnabled)
                Lottie.asset(
                  'assets/lottie/background_clean2.json',
                  reverse: true,
                  fit: BoxFit.cover,
                ),
              Column(
                children: [
                  AppHeader(),
                  Spacer(),
                  BlocBuilder<MemoriesListBloc, BaseState<List<MemoryModel>>>(
                    builder: (context, state) {
                      if (state is LoadedState<List<MemoryModel>>) {
                        final memories = state.data;
                        if (memories.isEmpty) {
                          return SvgPicture.asset(
                            'assets/images/head.svg',
                            semanticsLabel: 'Head',
                            height: 80,
                          );
                        }
                        return InkWell(
                          onTap: () {
                            context.push(
                              '/memories/${memories.first.id}',
                              extra: memories.first.id,
                            );
                          },
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: memories.first.aiImage ?? '',
                              height: 217,
                              width: 217,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 217,
                                width: 217,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  SvgPicture.asset(
                                    'assets/images/head.svg',
                                    semanticsLabel: 'Head',
                                    height: 80,
                                    width: 80,
                                  ),
                            ),
                          ),
                        );
                      }
                      return SvgPicture.asset(
                        'assets/images/head.svg',
                        semanticsLabel: 'Head',
                        height: 80,
                      );
                    },
                  ),
                  /*                  ImagePreview(
                    heroTag: heroTag,
                    title: 'Memoria de hoy',
                    description: AppUtils.getDate(),
                    onTap: () {
                      context.push('/fullscreen', extra: heroTag);
                    },
                  ),*/
                  const SizedBox(height: 20),
                  AppText(
                    text: '¿Transformamos tu día en un recuerdo?',
                    fontWeight: FontWeight.w600,
                    fontSize: 23,
                  ),
                  const SizedBox(height: 11),
                  AppText(
                    text: 'Cuéntame tu historia favorita',
                    fontSize: 20,
                    color: Colors.black.withValues(alpha: 0.62),
                  ),
                  Spacer(),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircularButton(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/gallery.svg',
                              semanticsLabel: 'Mic',
                            ),
                          ),
                          onTap: () {
                            context.push('/memories');
                          },
                        ),
                        CircularButton(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 43,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/mic.svg',
                              semanticsLabel: 'Mic',
                            ),
                          ),
                          onTap: () {
                            context.push('/record-memory');
                          },
                        ),
                        CircularButton(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: SvgPicture.asset(
                              'assets/images/settings.svg',
                              semanticsLabel: 'Mic',
                            ),
                          ),
                          onTap: () {
                            context.push('/settings');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child:
                    BlocBuilder<AnalyzeMemoryBloc, BaseState<TranscriptModel>>(
                      builder: (context, analyzeState) {
                        return BlocBuilder<
                          TranscriptSaveMemoryBloc,
                          BaseState<TranscriptResponseModel>
                        >(
                          builder: (context, transcriptState) {
                            if (transcriptState
                                    is LoadingState<TranscriptResponseModel> ||
                                analyzeState is LoadingState<TranscriptModel>) {
                              return IaIndicator();
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadPeople() {
    context.read<PeopleListBloc>().add(const FetchEvent(null));
  }

  void _loadMemories() {
    context.read<MemoriesListBloc>().add(const FetchEvent(null));
  }

  Future<void> _loadAnimationPreference() async {
    final isEnabled = await AnimationSettings.isHomeAnimationEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _isHomeAnimationEnabled = isEnabled;
    });
  }
}
