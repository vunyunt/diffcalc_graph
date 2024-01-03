import 'package:diffcalc_graph/components/graph/main_editing_area.dart';
import 'package:diffcalc_graph/components/graph/node_selector/node_selector.dart';
import 'package:diffcalc_graph/nodes/node_directory.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';

class GraphEditor extends StatelessWidget {
  final UiGraph graph;
  final NodeDirectory nodeDirectory;

  const GraphEditor(
      {Key? key, required this.graph, required this.nodeDirectory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // Center is a layout widget. It takes a single child and positions it
      // in the middle of the parent.
      children: [
        NodeSelector(directory: nodeDirectory),
        Expanded(
            child: MainEditingArea(graph: graph, nodeDirectory: nodeDirectory))
      ],
    );
  }
}
