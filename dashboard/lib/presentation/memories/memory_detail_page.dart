import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/core/bloc/base_state.dart';
import 'package:memories_web_admin/core/bloc/fetch_event.dart';
import 'package:memories_web_admin/core/widgets/app_full_loader.dart';
import 'package:memories_web_admin/core/widgets/app_header.dart';
import 'package:memories_web_admin/core/widgets/background_stats.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_model.dart';
import 'package:memories_web_admin/data/models/memory_question_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_open_ai_repository.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memory_curator_bloc.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memory_detail_bloc.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memory_questions_bloc.dart';
import 'package:memories_web_admin/presentation/memories/widgets/expandable_fab.dart';
import 'package:memories_web_admin/presentation/memories/widgets/memory_curator_popup.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MemoryDetailPage extends StatelessWidget {
  const MemoryDetailPage({super.key, required this.memoryId});

  final int memoryId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MemoryDetailBloc(
            repository: context.read<ISupabaseRepository>(),
          )..add(FetchEvent(memoryId)),
        ),
        BlocProvider(
          create: (context) => MemoryCuratorBloc(
            repository: context.read<IOpenAIRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => MemoryQuestionsBloc(
            repository: context.read<ISupabaseRepository>(),
          )..add(FetchEvent(memoryId)),
        ),
      ],
      child: const _MemoryDetailView(),
    );
  }
}

class _MemoryDetailView extends StatelessWidget {
  const _MemoryDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryDetailBloc, BaseState<MemoryModel>>(
      builder: (context, state) {
        if (state is LoadingState<MemoryModel>) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ErrorState<MemoryModel>) {
          return Center(
            child: AppText(
              text: state.failure.message,
              fontSize: 16,
            ),
          );
        }

        if (state is LoadedState<MemoryModel>) {
          return _MemoryDetailContent(memory: state.data);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _MemoryDetailContent extends StatefulWidget {
  const _MemoryDetailContent({required this.memory});

  final MemoryModel memory;

  @override
  State<_MemoryDetailContent> createState() => _MemoryDetailContentState();
}

class _MemoryDetailContentState extends State<_MemoryDetailContent> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _quoteController;
  late TextEditingController _feelingsController;
  late TextEditingController _peopleController;
  late TextEditingController _placesController;
  late TextEditingController _objectsController;
  late TextEditingController _actionsController;
  late TextEditingController _temporalController;
  late TextEditingController _toneController;
  late TextEditingController _categoriesController;
  late TextEditingController _topicsController;
  late TextEditingController _lessonsController;
  late TextEditingController _durationController;
  late TextEditingController _normalizedDateController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _titleController = TextEditingController(text: widget.memory.aiTitle);
    _contentController = TextEditingController(text: widget.memory.content);
    _quoteController = TextEditingController(
      text: widget.memory.aiHighlightedQuote,
    );
    _feelingsController = TextEditingController(
      text: widget.memory.aiFeelings?.join(', '),
    );
    _peopleController = TextEditingController(
      text: widget.memory.aiPeople?.join(', '),
    );
    _placesController = TextEditingController(
      text: widget.memory.aiPlaces?.join(', '),
    );
    _objectsController = TextEditingController(
      text: widget.memory.aiObjects?.join(', '),
    );
    _actionsController = TextEditingController(
      text: widget.memory.aiActions?.join(', '),
    );
    _temporalController = TextEditingController(
      text: widget.memory.aiTemporalContext,
    );
    _toneController = TextEditingController(text: widget.memory.aiOverallTone);
    _categoriesController = TextEditingController(
      text: widget.memory.aiCategory?.join(', '),
    );
    _topicsController = TextEditingController(
      text: widget.memory.aiKeyTopics?.join(', '),
    );
    _lessonsController = TextEditingController(
      text: widget.memory.aiLessonsLearned?.join(', '),
    );
    _durationController = TextEditingController(
      text: widget.memory.aiEventDuration,
    );
    _normalizedDateController = TextEditingController(
      text: widget.memory.normalizedDate,
    );
  }

  @override
  void didUpdateWidget(_MemoryDetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.memory != oldWidget.memory && !_isEditing) {
      _initControllers();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _quoteController.dispose();
    _feelingsController.dispose();
    _peopleController.dispose();
    _placesController.dispose();
    _objectsController.dispose();
    _actionsController.dispose();
    _temporalController.dispose();
    _toneController.dispose();
    _categoriesController.dispose();
    _topicsController.dispose();
    _lessonsController.dispose();
    _durationController.dispose();
    _normalizedDateController.dispose();
    super.dispose();
  }

  List<String>? _splitList(String text) {
    if (text.trim().isEmpty) return null;
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  void _save() {
    final updatedMemory = widget.memory.copyWith(
      aiTitle: _titleController.text,
      content: _contentController.text,
      aiHighlightedQuote: _quoteController.text,
      aiFeelings: _splitList(_feelingsController.text),
      aiPeople: _splitList(_peopleController.text),
      aiPlaces: _splitList(_placesController.text),
      aiObjects: _splitList(_objectsController.text),
      aiActions: _splitList(_actionsController.text),
      aiTemporalContext: _temporalController.text,
      aiOverallTone: _toneController.text,
      aiCategory: _splitList(_categoriesController.text),
      aiKeyTopics: _splitList(_topicsController.text),
      aiLessonsLearned: _splitList(_lessonsController.text),
      aiEventDuration: _durationController.text,
      normalizedDate: _normalizedDateController.text,
    );

    context.read<MemoryDetailBloc>().add(UpdateMemoryEvent(updatedMemory));
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;
    final formattedDate = _formatDate(memory.createdAt);

    return BlocListener<MemoryCuratorBloc, BaseState<List<String>>>(
      listener: (context, state) {
        if (state is LoadedState<List<String>>) {
          context
              .read<MemoryQuestionsBloc>()
              .saveGeneratedQuestions(
                memoryId: memory.id,
                questions: state.data,
              )
              .then((savedQuestions) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return BlocProvider.value(
                        value: context.read<MemoryQuestionsBloc>(),
                        child: MemoryCuratorPopup(questions: savedQuestions),
                      );
                    },
                  );
                }
              });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: !_isEditing
            ? ExpandableFab(
                items: [
                  ExpandableFabItem(
                    icon: LucideIcons.pencil,
                    label: 'Editar',
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                  ),
                  ExpandableFabItem(
                    icon: LucideIcons.badgeCheck,
                    label: 'Verificar',
                    onPressed: () => _handleVerification(context, memory),
                  ),
                  ExpandableFabItem(
                    icon: LucideIcons.sparkles,
                    label: 'Explorar',
                    onPressed: () => _handleExplore(context, memory),
                  ),
                ],
              )
            : null,
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(showBackButton: true, actions: []),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.grey3),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(context, memory, formattedDate),
                        const SizedBox(height: 32),
                        _buildNarrativeSection(memory),
                        const SizedBox(height: 32),
                        _buildContextAndEntitiesSection(memory),
                        const SizedBox(height: 32),
                        _buildAnalysisAndInsightsSection(memory),
                        const SizedBox(height: 32),
                        _buildExplorationSection(),

                        if (_isEditing) ...[
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ShadButton.ghost(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _initControllers();
                                  });
                                },
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 12),
                              ShadButton(
                                onPressed: _save,
                                child: const Text('Guardar cambios'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<MemoryCuratorBloc, BaseState<List<String>>>(
              builder: (context, state) {
                if (state is LoadingState<List<String>>) {
                  return AppFullLoader(
                    rotateCenterIcon: true,
                    centerIcon: Icon(
                      LucideIcons.sparkles,
                      size: 48,
                      color: Colors.white,
                    ),
                    title: const AppText(
                      text: 'Generando preguntas...',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleVerification(BuildContext context, MemoryModel memory) {
    if (!memory.isTruthful) {
      showShadDialog(
        context: context,
        builder: (context) => ShadDialog.alert(
          title: AppText(
            text: 'Memoria no verificada',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text:
                    'Esta memoria no ha sido verificada y podría contener información inexacta o inventada por la IA. ¿Deseas proceder con la verificación?',
              ),
              const SizedBox(height: 12),
            ],
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ShadButton(
              child: const Text('Activar verificación'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    }
  }

  void _handleExplore(BuildContext context, MemoryModel memory) {
    final questionsState = context.read<MemoryQuestionsBloc>().state;

    if (questionsState is LoadedState<List<MemoryQuestionModel>> &&
        questionsState.data.isNotEmpty) {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return BlocProvider.value(
            value: context.read<MemoryQuestionsBloc>(),
            child: MemoryCuratorPopup(questions: questionsState.data),
          );
        },
      );
    } else {
      context.read<MemoryCuratorBloc>().add(FetchEvent(memory));
    }
  }

  // --- Section Builders ---

  Widget _buildHeaderSection(
    BuildContext context,
    MemoryModel memory,
    String formattedDate,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        // Image Widget
        Widget imageWidget = _CoverImage(memory: memory);

        // Content Widget
        final contentWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditing)
              _buildEditableField(
                'Título',
                _titleController,
                placeholder: 'Título',
              )
            else
              AppText(
                text: memory.aiTitle?.isNotEmpty == true
                    ? memory.aiTitle!
                    : 'Memoria #${memory.id}',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 16, color: AppColors.grey),
                const SizedBox(width: 8),
                AppText(
                  text: 'Creada el $formattedDate',
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                if (memory.isTruthful) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        AppText(
                          text: 'Verificada',
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              _buildEditableField(
                'Fecha normalizada',
                _normalizedDateController,
              ),
            ],
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageWidget,
              const SizedBox(height: 24),
              contentWidget,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: imageWidget),
            const SizedBox(width: 32),
            Expanded(flex: 3, child: contentWidget),
          ],
        );
      },
    );
  }

  Widget _buildNarrativeSection(MemoryModel memory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.bookOpen,
          title: 'Relato',
        ),
        const SizedBox(height: 24),
        if (_isEditing)
          _buildEditableField(
            'Contenido original',
            _contentController,
            maxLines: 10,
          )
        else
          AppText(
            text: memory.content,
            fontSize: 16,
            height: 1.8,
            color: AppColors.black.withValues(alpha: 0.8),
          ),

        const SizedBox(height: 24),

        if (_isEditing)
          _buildEditableField('Cita destacada', _quoteController, maxLines: 3)
        else if (memory.aiHighlightedQuote != null &&
            memory.aiHighlightedQuote!.trim().isNotEmpty)
          _QuoteCard(quote: memory.aiHighlightedQuote!.trim()),
      ],
    );
  }

  Widget _buildContextAndEntitiesSection(MemoryModel memory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.globe,
          title: 'Contexto y Entidades',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            // Use a wrap or grid depending on width
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildInfoGroup(
                  title: 'Cuándo (Temporal)',
                  icon: LucideIcons.clock,
                  content: _isEditing
                      ? Column(
                          children: [
                            _buildEditableField(
                              'Contexto',
                              _temporalController,
                            ),
                            _buildEditableField(
                              'Duración',
                              _durationController,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (memory.aiTemporalContext?.isNotEmpty == true)
                              _buildBulletPoint(memory.aiTemporalContext!),
                            if (memory.aiEventDuration?.isNotEmpty == true)
                              _buildBulletPoint(
                                'Duración: ${memory.aiEventDuration!}',
                              ),

                            if (memory.aiTemporalContext == null &&
                                memory.aiEventDuration == null)
                              AppText(
                                text: 'No especificado',
                                color: AppColors.grey,
                              ),
                          ],
                        ),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Dónde (Lugares)',
                  icon: LucideIcons.mapPin,
                  content: _isEditing
                      ? _buildEditableField('Lugares', _placesController)
                      : _buildPillsList(memory.aiPlaces ?? []),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Quiénes (Personas)',
                  icon: LucideIcons.users,
                  content: _isEditing
                      ? _buildEditableField('Personas', _peopleController)
                      : _buildPillsList(memory.aiPeople ?? []),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Qué (Objetos)',
                  icon: LucideIcons.box,
                  content: _isEditing
                      ? _buildEditableField('Objetos', _objectsController)
                      : _buildPillsList(memory.aiObjects ?? []),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Acciones',
                  icon: LucideIcons.activity,
                  content: _isEditing
                      ? _buildEditableField('Acciones', _actionsController)
                      : _buildPillsList(memory.aiActions ?? []),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisAndInsightsSection(MemoryModel memory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.brainCircuit,
          title: 'Análisis e Insights',
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildInfoGroup(
                  title: 'Emociones',
                  icon: LucideIcons.heart,
                  content: _isEditing
                      ? _buildEditableField('Sentimientos', _feelingsController)
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (memory.aiFeelings != null)
                              for (
                                var i = 0;
                                i < memory.aiFeelings!.length;
                                i++
                              )
                                if (memory.aiFeelings![i].trim().isNotEmpty)
                                  _buildPill(
                                    '${memory.feelingEmojis[i]} ${memory.aiFeelings![i]}',
                                  ),
                            if (memory.aiEmotionalIntensity != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  'Intensidad: ${memory.aiEmotionalIntensity}/10',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ),
                            if (memory.aiFeelings == null ||
                                memory.aiFeelings!.isEmpty)
                              AppText(
                                text: 'No detectado',
                                color: AppColors.grey,
                              ),
                          ],
                        ),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Tono',
                  icon: LucideIcons.music,
                  content: _isEditing
                      ? _buildEditableField('Tono general', _toneController)
                      : AppText(text: memory.aiOverallTone ?? 'No detectado'),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Clasificación',
                  icon: LucideIcons.tag,
                  content: _isEditing
                      ? Column(
                          children: [
                            _buildEditableField(
                              'Categorías',
                              _categoriesController,
                            ),
                            _buildEditableField(
                              'Temas clave',
                              _topicsController,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (memory.aiCategory != null &&
                                memory.aiCategory!.isNotEmpty) ...[
                              AppText(
                                text: 'Categoría:',
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                              const SizedBox(height: 4),
                              _buildPillsList(memory.aiCategory!),
                              const SizedBox(height: 8),
                            ],
                            if (memory.aiKeyTopics != null &&
                                memory.aiKeyTopics!.isNotEmpty) ...[
                              AppText(
                                text: 'Temas:',
                                fontSize: 12,
                                color: AppColors.grey,
                              ),
                              const SizedBox(height: 4),
                              _buildPillsList(memory.aiKeyTopics!),
                            ],
                          ],
                        ),
                  width: _calculateItemWidth(constraints.maxWidth),
                ),
                _buildInfoGroup(
                  title: 'Lecciones',
                  icon: LucideIcons.lightbulb,
                  content: _isEditing
                      ? _buildEditableField('Lecciones', _lessonsController)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (memory.aiLessonsLearned != null)
                              for (final lesson in memory.aiLessonsLearned!)
                                Pad(
                                  bottom: 4,
                                  child: _buildBulletPoint(lesson),
                                ),
                            if (memory.aiLessonsLearned == null ||
                                memory.aiLessonsLearned!.isEmpty)
                              AppText(
                                text: 'Ninguna lección explícita',
                                color: AppColors.grey,
                              ),
                          ],
                        ),
                  width: _calculateItemWidth(
                    constraints.maxWidth,
                  ), // Full width
                  isFullWidth: true,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildExplorationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: LucideIcons.sparkles,
          title: 'Explora tu Recuerdo',
        ),
        const SizedBox(height: 24),
        const _MemoryQuestionsSection(),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return BackgroundStats(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.blue, size: 20),
          const SizedBox(width: 12),
          AppText(
            text: title,
            fontWeight: FontWeight.w600,
            color: AppColors.blue,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  double _calculateItemWidth(double maxWidth) {
    if (maxWidth > 900) {
      return (maxWidth - 32 * 2 - 24) / 2; // 2 columns roughly
    }
    return maxWidth; // 1 column
  }

  Widget _buildInfoGroup({
    required String title,
    required IconData icon,
    required Widget content,
    double? width,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.grey),
              const SizedBox(width: 8),
              AppText(
                text: title,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.black,
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0),
          child: Icon(Icons.circle, size: 6, color: AppColors.blue),
        ),
        const SizedBox(width: 8),
        Expanded(child: AppText(text: text, height: 1.4)),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? placeholder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
          const SizedBox(height: 8),
          ShadInput(
            controller: controller,
            minLines: maxLines > 1 ? maxLines : null,
            maxLines: maxLines > 1 ? null : 1,
            placeholder: Text(placeholder ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildPillsList(List<String> items) {
    if (items.isEmpty) return AppText(text: '-', color: AppColors.grey);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((e) => _buildPill(e)).toList(),
    );
  }

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey3),
      ),
      child: AppText(
        text: text,
        fontSize: 13,
        color: AppColors.black,
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.blue2, // Using blue2 as bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.quote,
            color: AppColors.blue,
            size: 32,
          ),
          const SizedBox(height: 16),
          AppText(
            text: quote,
            fontSize: 18,
            fontStyle: FontStyle.italic,
            textAlign: TextAlign.center,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _MemoryQuestionsSection extends StatelessWidget {
  const _MemoryQuestionsSection();

  @override
  Widget build(BuildContext context) {
    // Re-implementing the questions section based on available state
    return BlocBuilder<
      MemoryQuestionsBloc,
      BaseState<List<MemoryQuestionModel>>
    >(
      builder: (context, state) {
        if (state is LoadedState<List<MemoryQuestionModel>>) {
          final questions = state.data;
          if (questions.isEmpty) return const SizedBox.shrink();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 160,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return _QuestionCard(question: question);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});
  final MemoryQuestionModel question;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.messageCircle,
                size: 18,
                color: AppColors.blue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppText(
                  text: 'Pregunta',
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AppText(
              text: question.question,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class Pad extends StatelessWidget {
  const Pad({super.key, required this.child, this.bottom = 0});
  final Widget child;
  final double bottom;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: child,
    );
  }
}

String _formatDate(DateTime date) {
  return DateFormat('d MMMM yyyy', 'es').format(date);
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.memory});

  final MemoryModel memory;

  @override
  Widget build(BuildContext context) {
    if (memory.aiImage == null || memory.aiImage!.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.grey3,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(LucideIcons.image, size: 48, color: AppColors.grey),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.9),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                InteractiveViewer(
                  child: Hero(
                    tag: 'memory-${memory.id}',
                    child: CachedNetworkImage(
                      imageUrl: memory.aiImage!,
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Hero(
        tag: 'memory-${memory.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: memory.aiImage!,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 300,
              color: AppColors.grey.withValues(alpha: .1),
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 300,
              color: AppColors.grey.withValues(alpha: .1),
              alignment: Alignment.center,
              child: const Icon(
                Icons.error_outline,
                size: 42,
                color: AppColors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
