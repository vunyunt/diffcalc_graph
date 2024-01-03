import 'package:diffcalc_graph/app_state.dart';
import 'package:diffcalc_graph/ui_graph.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                onPressed: () => appState.setState(() {
                      appState.workingGraph = UiGraph();
                    }),
                child: const Text("New Graph"))
          ]),
    );
  }
}
