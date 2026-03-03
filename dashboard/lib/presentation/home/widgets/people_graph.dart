import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphview/GraphView.dart';
import 'package:memories_web_admin/core/app_colors.dart';
import 'package:memories_web_admin/data/models/graph_model.dart';
import 'package:memories_web_admin/data/repositories/interfaces/i_supabase_repository.dart';
import 'package:memories_web_admin/presentation/home/bloc/person_memories_bloc.dart';
import 'package:memories_web_admin/presentation/home/widgets/person_memories_drawer.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PeopleGraphV2 extends StatefulWidget {
  final GraphData data;

  const PeopleGraphV2({super.key, required this.data});

  @override
  State<PeopleGraphV2> createState() => _PeopleGraphV2State();
}

class _PeopleGraphV2State extends State<PeopleGraphV2> {
  late Graph _graph;
  late Algorithm _algorithm;
  final TransformationController _transformationController =
      TransformationController();

  final Map<String, Node> _nodes = {};
  final Map<String, int> _degree = {};
  late int _minW, _maxW;

  int _minWeight = 1;

  @override
  void initState() {
    super.initState();
    _algorithm = FruchtermanReingoldAlgorithm(
      iterations: 1000,
      renderer: ArrowEdgeRenderer(),
    );
    _rebuildGraph();
  }

  @override
  void didUpdateWidget(covariant PeopleGraphV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _rebuildGraph();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _rebuildGraph() {
    _graph = Graph()..isTree = false;
    _nodes.clear();
    _degree.clear();

    if (widget.data.links.isEmpty) return;

    _minW = widget.data.links
        .map((e) => e.weight)
        .reduce((a, b) => a < b ? a : b);
    _maxW = widget.data.links
        .map((e) => e.weight)
        .reduce((a, b) => a > b ? a : b);

    for (final e in widget.data.links) {
      final int w = e.weight;
      if (w < _minWeight) continue;

      final String a = e.source;
      final String b = e.target;

      final na = _nodes.putIfAbsent(a, () => Node.Id(a));
      final nb = _nodes.putIfAbsent(b, () => Node.Id(b));

      _degree[a] = (_degree[a] ?? 0) + 1;
      _degree[b] = (_degree[b] ?? 0) + 1;

      _graph.addEdge(na, nb, paint: _edgePaint(w));
    }
  }

  Paint _edgePaint(int w) {
    if (_maxW == _minW) {
      return Paint()
        ..color = Colors.grey.withOpacity(0.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
    }

    final thickness = 1.0 + (w - _minW) * (6.0 - 1.0) / (_maxW - _minW);
    final opacity = 0.3 + (thickness - 1.0) * (0.7) / (6.0 - 1.0);

    final t = (w - _minW) / (_maxW - _minW);
    final color = Color.lerp(Colors.blueGrey, AppColors.blue, t)!;

    return Paint()
      ..color = color.withOpacity(opacity.clamp(0.3, 1.0))
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;
  }

  double _sizeFor(String id) {
    if (_nodes.isEmpty) return 40;
    final values = _degree.values.toList();
    if (values.isEmpty) return 40;
    final minD = values.reduce((a, b) => a < b ? a : b);
    final maxD = values.reduce((a, b) => a > b ? a : b);
    final d = _degree[id] ?? 1;
    if (maxD == minD) return 44;
    return 32 + (d - minD) * (70 - 32) / (maxD - minD);
  }

  String _getLabel(String id) {
    try {
      return widget.data.nodes.firstWhere((n) => n.id == id).label;
    } catch (_) {
      return id;
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final double scaleChange = event.scrollDelta.dy < 0 ? 1.05 : 0.95;
      final Matrix4 matrix = _transformationController.value.clone();

      // Basic zoom around center (can be improved to zoom around pointer)
      // For simplicity, just scaling the matrix
      matrix.scale(scaleChange);

      _transformationController.value = matrix;
    }
  }

  void _showPersonMemoriesDrawer(BuildContext context, String personName) {
    // Capture the repository from the current context before opening the dialog
    final repository = context.read<ISupabaseRepository>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: BlocProvider(
            create: (_) => PersonMemoriesBloc(
              supabaseRepository: repository,
            )..add(FetchPersonMemoriesEvent(personName)),
            child: PersonMemoriesDrawer(personName: personName),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
              ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.links.isEmpty) {
      return Center(
        child: Text(
          'No hay suficientes datos para generar el grafo.',
          style: ShadTheme.of(context).textTheme.p,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey4,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRect(
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.1,
            maxScale: 5.0,
            boundaryMargin: EdgeInsets.all(500), // Allow panning far
            scaleEnabled: true,
            panEnabled: true,
            constrained: false, // Allow graph to be larger than viewport
            child: SizedBox(
              // Ensure the graph has enough space to be laid out
              width: 1000,
              height: 1000,
              child: Center(
                child: GraphView(
                  graph: _graph,
                  algorithm: _algorithm,
                  builder: (Node node) {
                    final id = node.key!.value as String;
                    final label = _getLabel(id);
                    final size = _sizeFor(id);
                    final isDegreeHigh = (_degree[id] ?? 0) > 3;

                    return Tooltip(
                      message: "$label (${_degree[id] ?? 0} conexiones)",
                      child: InkWell(
                        onTap: () {
                          _showPersonMemoriesDrawer(context, label);
                        },
                        child: Container(
                          width: size,
                          height: size,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isDegreeHigh
                                  ? AppColors.blue
                                  : Colors.black87,
                              width: isDegreeHigh ? 2.5 : 1.2,
                            ),
                            borderRadius: BorderRadius.circular(size / 2),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                offset: Offset(0, 3),
                                color: Colors.black.withOpacity(0.15),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size / 4,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
