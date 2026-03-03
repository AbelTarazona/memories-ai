import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memories_web_admin/core/widgets/text.dart';
import 'package:memories_web_admin/data/models/memory_question_model.dart';
import 'package:memories_web_admin/presentation/memories/bloc/memory_questions_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MemoryCuratorPopup extends StatefulWidget {
  const MemoryCuratorPopup({
    super.key,
    required this.questions,
  });

  final List<MemoryQuestionModel> questions;

  @override
  State<MemoryCuratorPopup> createState() => _MemoryCuratorPopupState();
}

class _MemoryCuratorPopupState extends State<MemoryCuratorPopup> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing answers
    for (var i = 0; i < widget.questions.length; i++) {
      if (widget.questions[i].userAnswer != null) {
        _controllers[i] = TextEditingController(
          text: widget.questions[i].userAnswer,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Center(
      child: Container(
        width: size.width * 0.4,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: '✨ Explora más allá del recuerdo',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8.0),
            AppText(
              text:
                  'Reflexiona sobre los detalles y emociones que hicieron especial este instante.',
              fontSize: 16,
            ),
            const SizedBox(height: 16.0),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: size.height * 0.6),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.questions.length,
                itemBuilder: (BuildContext context, int index) {
                  final controller = _controllers.putIfAbsent(
                    index,
                    () => TextEditingController(),
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: AppText(
                            text:
                                '${index + 1}. ${widget.questions[index].question}',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ShadInput(maxLines: 3, controller: controller),
                      const SizedBox(height: 8),
                      ShadButton.outline(
                        child: const Text('Guardar respuesta'),
                        onPressed: () {
                          final answer = controller.text;
                          if (answer.isNotEmpty) {
                            context
                                .read<MemoryQuestionsBloc>()
                                .answerQuestion(
                                  question: widget.questions[index],
                                  answer: answer,
                                )
                                .then((_) {
                                  if (context.mounted) {
                                    ShadToaster.of(context).show(
                                      ShadToast(
                                        title: const Text('Respuesta guardada'),
                                        description: const Text(
                                          'Tu respuesta ha sido guardada correctamente.',
                                        ),
                                      ),
                                    );
                                  }
                                });
                          }
                        },
                      ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(height: 32);
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ShadButton(
                child: const Text('Cerrar'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
