import 'package:diffcalc_graph/components/graph/graph_editor.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

class GraphEditingPage extends StatelessWidget {
  final UiGraph graph;
  final NodeDirectory nodeDirectory;

  const GraphEditingPage(
      {super.key, required this.graph, required this.nodeDirectory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GraphEditor(
        graph: graph,
        nodeDirectory: nodeDirectory,
      ),
    );
  }
}
