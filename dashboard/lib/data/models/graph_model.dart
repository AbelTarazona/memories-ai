class GraphNode {
  final String id;
  final String label;
  final String? image;

  GraphNode({
    required this.id,
    required this.label,
    this.image,
  });
}

class GraphLink {
  final String source;
  final String target;
  final int weight;

  GraphLink({
    required this.source,
    required this.target,
    required this.weight,
  });
}

class GraphData {
  final List<GraphNode> nodes;
  final List<GraphLink> links;

  GraphData({
    required this.nodes,
    required this.links,
  });
}
