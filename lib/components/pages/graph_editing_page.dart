import 'dart:io';

import 'package:computational_graph/computational_graph.dart';
import 'package:diffcalc_graph/app_state.dart';
import 'package:diffcalc_graph/components/graph/graph_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final ProtobufSerializer protobufSerializer = ProtobufSerializer();

class GraphEditingPage extends StatelessWidget {
  const GraphEditingPage({super.key});

  PreferredSizeWidget buildAppBar(BuildContext context,
      {required AppState appState}) {
    final graph = appState.workingGraph;

    return AppBar(
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      title: Text(appState.workingGraph?.title ?? ""),
      actions: [
        IconButton(
            onPressed: graph == null
                ? null
                : () async {
                    final path = await FilePicker.platform.saveFile(
                      dialogTitle: 'Save graph',
                      allowedExtensions: ['cgraph'],
                    );

                    if (path == null) return;

                    final serialized = protobufSerializer.serializeGraph(graph);
                    final file = File.fromUri(Uri.parse(path));
                    final stream = await file.open(mode: FileMode.writeOnly);
                    final serializedBytes = serialized.writeToBuffer();

                    stream.writeFrom(serializedBytes);
                  },
            icon: const Icon(Icons.save))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final workingGraph = appState.workingGraph;

    print(workingGraph);

    // If there is no graph loaded, go back to the previous page
    if (workingGraph == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pop();
      });

      return Container();
    }

    return Scaffold(
      appBar: buildAppBar(context, appState: appState),
      body: GraphEditor(
        graph: workingGraph,
        nodeDirectory: appState.nodeDirectory,
      ),
    );
  }
}
