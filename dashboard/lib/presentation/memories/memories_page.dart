import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/widgets/app_header.dart';
import 'package:memories_web_admin/core/widgets/image_preview.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memories_list_bloc.dart';
import 'package:memories_web_admin/presentation/memories/widgets/memory_timeline_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MemoriesPage extends StatelessWidget {
  const MemoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemoriesListBloc>(
      create: (context) => MemoriesListBloc(
        repository: context.read<ISupabaseRepository>(),
      )..add(const FetchEvent<MemoriesFilterParams>(MemoriesFilterParams())),
      child: const MemoriesContent(),
    );
  }
}

class MemoriesContent extends StatefulWidget {
  const MemoriesContent({super.key});

  @override
  State<MemoriesContent> createState() => _MemoriesContentState();
}

class _MemoriesContentState extends State<MemoriesContent> {
  DateTimeRange? _selectedRange;
  bool _isTimelineMode = false;

  final ShadPopoverController _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  MemoriesFilterParams _currentFilterParams() {
    if (_selectedRange == null) {
      return const MemoriesFilterParams();
    }

    final start = DateTime(
      _selectedRange!.start.year,
      _selectedRange!.start.month,
      _selectedRange!.start.day,
    );

    final end = DateTime(
      _selectedRange!.end.year,
      _selectedRange!.end.month,
      _selectedRange!.end.day,
      23,
      59,
      59,
      999,
    );

    return MemoriesFilterParams(startDate: start, endDate: end);
  }

  void _fetchMemories() {
    context.read<MemoriesListBloc>().add(FetchEvent(_currentFilterParams()));
  }

  void _clearRange() {
    setState(() {
      _selectedRange = null;
    });
    _fetchMemories();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildFilters() {
    final filterDescription = _selectedRange == null
        ? 'Mostrando todas las memorias'
        : 'Rango seleccionado: ${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShadPopover(
              controller: _popoverController,
              popover: (context) {
                return ShadCalendar.range(
                  selected: _selectedRange != null
                      ? ShadDateTimeRange(
                          start: _selectedRange!.start,
                          end: _selectedRange!.end,
                        )
                      : null,
                  onChanged: (range) {
                    if (range != null &&
                        range.start != null &&
                        range.end != null) {
                      setState(() {
                        _selectedRange = DateTimeRange(
                          start: range.start!,
                          end: range.end!,
                        );
                      });
                      _fetchMemories();
                      _popoverController.toggle();
                    }
                  },
                );
              },
              child: ShadButton.outline(
                onPressed: _popoverController.toggle,
                size: ShadButtonSize.sm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.calendar),
                    const SizedBox(width: 8),
                    Text(
                      _selectedRange == null
                          ? 'Seleccionar rango'
                          : 'Cambiar rango',
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedRange != null) ...[
              const SizedBox(width: 12),
              ShadButton.ghost(
                onPressed: _clearRange,
                size: ShadButtonSize.sm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(LucideIcons.x),
                    SizedBox(width: 4),
                    Text('Limpiar'),
                  ],
                ),
              ),
            ],
            const Spacer(),
            // Timeline Mode Toggle Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: _isTimelineMode
                    ? const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ShadButton(
                onPressed: () {
                  setState(() {
                    _isTimelineMode = !_isTimelineMode;
                  });
                },
                size: ShadButtonSize.sm,
                backgroundColor: _isTimelineMode ? Colors.transparent : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        _isTimelineMode
                            ? LucideIcons.layoutGrid
                            : LucideIcons.gitBranch,
                        key: ValueKey(_isTimelineMode),
                        color: _isTimelineMode ? Colors.white : null,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _isTimelineMode ? 'Vista Grid' : 'Modo Timeline',
                        key: ValueKey(_isTimelineMode),
                        style: TextStyle(
                          color: _isTimelineMode ? Colors.white : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText(
          text: filterDescription,
          fontSize: 13,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppHeader(title: 'Mis memorias'),
          _buildFilters(),
          const SizedBox(height: 24),
          Expanded(
            child: BlocBuilder<MemoriesListBloc, BaseState<List<MemoryModel>>>(
              builder: (context, state) {
                if (state is LoadingState<List<MemoryModel>>) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is ErrorState<List<MemoryModel>>) {
                  return Center(
                    child: Text(state.failure.message),
                  );
                } else if (state is LoadedState<List<MemoryModel>>) {
                  final memories = state.data;
                  if (memories.isEmpty) {
                    return Center(
                      child: Text(
                        _selectedRange == null
                            ? 'No hay memorias disponibles.'
                            : 'No se encontraron memorias en el rango seleccionado.',
                      ),
                    );
                  }
                  // AnimatedSwitcher for smooth transition between views
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _isTimelineMode
                        ? MemoryTimelineView(
                            key: const ValueKey('timeline'),
                            memories: memories,
                          )
                        : GridView.builder(
                            key: const ValueKey('grid'),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 5,
                                ),
                            itemCount: memories.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      ImagePreview(
                                        heroTag: 'memory-${memories[index].id}',
                                        imagePath:
                                            memories[index].aiImage ?? '',
                                        title: memories[index].content,
                                        description: memories[index].createdAt
                                            .toString(),
                                        onTap: () => context.push(
                                          '/memories/${memories[index].id}',
                                        ),
                                        width: double.infinity,
                                        height: 180,
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Visibility(
                                          visible: memories[index].isTruthful,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              LucideIcons.badgeCheck,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
