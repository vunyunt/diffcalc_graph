import 'dart:io';

import 'package:diffcalc_graph/app_state.dart';
import 'package:diffcalc_graph/components/pages/graph_editing_page.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphSelectionPage extends StatefulWidget {
  const GraphSelectionPage({super.key});

  @override
  State<GraphSelectionPage> createState() => GraphSelectionPageState();
}

class GraphSelectionPageState extends State<GraphSelectionPage> {
  NavigatorState? currentNavigator;

  void setGraph(AppState appState, UiGraph graph) {
    appState.setState(() {
      appState.workingGraph = graph;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      currentNavigator?.push(
          MaterialPageRoute(builder: (context) => const GraphEditingPage()));
    });
  }

  Widget buildContent(BuildContext context) {
    // We only need to write to app state, so we don't need to listen as app state
    // should never be reinstantiated
    final appState = context.read<AppState>();

    return Center(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextButton(
              onPressed: null,
              child: Text("No graph loaded"),
            ),
            const SizedBox(height: 16),
            TextButton(
                onPressed: () {
                  setGraph(appState, UiGraph());
                },
                child: const Text("New Graph")),
            TextButton(
                onPressed: () async {
                  final result =
                      await FilePicker.platform.pickFiles(allowMultiple: false);

                  if (result == null) return;

                  final file =
                      File.fromUri(Uri.parse(result.files.single.path!));
                  final fileBytes = await file.readAsBytes();

                  final graph = appState.protobufSerializer
                      .deserializeGraphFromBytes(fileBytes,
                          (attributes) => UiGraph.fromAttributes(attributes));
                  setGraph(appState, graph);
                },
                child: const Text("Open graph"))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    currentNavigator = Navigator.of(context);

    return Scaffold(
      body: buildContent(context),
    );
  }
}
