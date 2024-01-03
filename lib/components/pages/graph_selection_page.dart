import 'package:diffcalc_graph/app_state.dart';
import 'package:diffcalc_graph/components/pages/graph_editing_page.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphSelectionPage extends StatelessWidget {
  const GraphSelectionPage({super.key});

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
                  appState.setState(() {
                    appState.workingGraph = UiGraph();
                  });
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => GraphEditingPage(
                            graph: appState.workingGraph!,
                            nodeDirectory: appState.nodeDirectory)));
                  });
                },
                child: const Text("New Graph"))
          ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildContent(context),
    );
  }
}
